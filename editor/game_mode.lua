------------------------------------------------------------------------------
--  This is the core of Grit Editor, all common functions are here
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- The editor is a special kind of game mode.  This is the root of the editor state.  Ultimately,
-- everything is initialized and managed from here.

Editor = Editor or {
    name = 'Map Editor',

    debugMode = false,
    noClip = false,
    fast = false,
    mouseCapture = false,
    speedSlow = 3,
    speedFast = 100,
    forwards = 0,
    backwards = 0,
    left = 0,
    right = 0,
    ascend = 0,
    descend = 0,
    camYaw = 0,
    camPitch = 0,
    lastMouseMoveTime = 0,

	selectionEnabled = true;
	
    controlObj = nil,

    -- holds editor camera position and rotation to get back when stop playing
    camera = {
        pos = {};
        rot = {};        
    };

    directory = "editor";
    
    map_dir = "map_templates";
    
    game_data_dir = "editor";
	playGameMode = "fpsgame";
}


function Editor:toggleBoard(mobj)
    if self.controlObj ~= nil then
        -- Currently controlling an object.  Exit it.
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = false
        editor_debug_ghost_binds.enabled = true

        self.controlObj:controlAbandon()
        -- When on foot there is no vehicle pitch.
        local v_pitch = pitch((self.controlObj.instance.body.worldOrientation * V_FORWARDS).z)
        self.camPitch = self.camPitch + v_pitch

        self.controlObj = nil

    else
        -- Board object being pointed at, if possible.
        local obj = mobj or pick_obj()
        if obj == nil then return end
        if obj.controllable == "VEHICLE" then
            playing_vehicle_binds.enabled = true
        elseif obj.controllable == "ACTOR" then
            playing_actor_binds.enabled = true
        else
            print("Cannot board object: " .. tostring(obj))
            return
        end
        editor_debug_ghost_binds.enabled = false
        obj:controlBegin()
        self.controlObj = obj
        print('controlObj now '..tostring(obj))
        -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
        -- So we calculate the camPitch necessary for that.
        local v_pitch = pitch((obj.instance.body.worldOrientation * V_FORWARDS).z)
        self.camPitch = self.camPitch - v_pitch
    end
end

-- if the widget is under mouse cursor, then start dragging, otherwise select an object
function Editor:leftMouseClick()
	if self.selectionEnabled then
        local multi = input_filter_pressed("Shift")
        widget_manager:select(true, multi)
	end
end

function Editor:stopDraggingObj()
    widget_manager:stopDragging()
end

function Editor:deleteSelection()
    local selobjs = {}
	
	for i = 1, #widget_manager.selectedObjs do
		if not widget_manager.selectedObjs[i].destroyed and widget_manager.selectedObjs[i].instance ~= nil then
			selobjs[#selobjs+1] = widget_manager.selectedObjs[i]
		end
	end		
    widget_manager:unselectAll()
	
	for i = 1, #selobjs do
		if not selobjs[i].destroyed then
			safe_destroy(selobjs[i])
		end
	end
end

function Editor:duplicateSelection()
    if widget_manager ~= nil and widget_manager.selectedObjs ~= nil then
		for i = 1, #widget_manager.selectedObjs do
			if not widget_manager.selectedObjs[i].destroyed and widget_manager.selectedObjs[i].instance ~= nil then
				object (widget_manager.selectedObjs[i].className) (widget_manager.selectedObjs[i].instance.body.worldPosition)
				{
					rot = widget_manager.selectedObjs[i].instance.body.worldOrientation;
				}
			end
		end
    end
end

function Editor:destroyAllEditorObjects()
    local objs = object_all()
    for i = 1, #objs do
        if objs[i].editorObject ~= nil then
            safe_destroy(objs[i])
        end
    end
end

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function Editor:frameCallback(elapsed_secs)
    if self.controlObj ~= nil and not self.controlObj.activated then
        self:toggleBoard()
    end

    if self.controlObj ~= nil then
        -- Chase cam
        local obj = self.controlObj
        local instance = obj.instance
        local body = instance.body

        local obj_bearing, obj_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
        local obj_vel = body.linearVelocity
        local obj_vel_xy_speed = #(obj_vel * vector3(1,1,0))

        -- modify the self.camPitch and self.camYaw to track the direction the obj is travelling
        if false and user_cfg.vehicleCameraTrack and obj.cameraTrack and seconds() - game_manager.currentMode.lastMouseMoveTime > 1  and obj_vel_xy_speed > 5 then

            self.camPitch = lerp(self.camPitch, obj_pitch, elapsed_secs * 2)

            -- test avoids degenerative case where x and y are both 0 
            -- if we are looking straight down at the car then the yaw doesn't really matter
            -- you can't see where you are going anyway
            if math.abs(self.camPitch) < 60 then
                local ideal_yaw = yaw(obj_vel.x, obj_vel.y)
                local current_yaw = self.camYaw
                if math.abs(ideal_yaw - current_yaw) > 180 then
                    if ideal_yaw < current_yaw then
                        ideal_yaw = ideal_yaw + 360
                    else
                        current_yaw = current_yaw + 360
                    end
                end
                local new_yaw = lerp(self.camYaw, ideal_yaw, elapsed_secs * 2) % 360

                self.camYaw = new_yaw
            end
        end

        main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)

        --player_ctrl.speedoPos = instance.camAttachPos
        --player_ctrl.speedoSpeed = #obj_vel

        local ray_skip = 0.4
        local ray_dir = main.camQuat * V_BACKWARDS
        local ray_start = instance.camAttachPos + ray_skip * ray_dir
        local ray_len = instance.boomLengthSelected - ray_skip
        local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
        local boom_length = math.max(obj.boomLengthMin, ray_hit_len)
        main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)

    else
        -- Ghosting around
        local right = self.right - self.left
        local forwards = self.forwards - self.backwards
        local ascend = self.ascend - self.descend

        local active_speed = self.fast and self.speedFast or self.speedSlow

        local dist = active_speed * elapsed_secs

        local cam_pos = main.camPos

        -- we now know how far to move (dist)
        -- but not in which directions

        local d = main.camQuat * vec3(dist*right, dist*forwards, 0) + vec3(0, 0, dist*ascend)
        

        if not self.noClip then
            local fraction, n = ghost_cast(cam_pos, d, 1)

            if fraction ~= nil then
                local n = norm(n)
                d = d - dot(d,n) * n
                local fraction2, n2 = ghost_cast(cam_pos, d, .95)
                if fraction2 ~= nil then
                    n2 = norm(n2)
                    d = d - dot(d,n2) * n2
                    local fraction3, n3 = ghost_cast(cam_pos, d, .9)
                    if fraction3 ~= nil then
                        return 0
                    end
                end
            end
        end
        -- splendid, now let's move
        cam_pos = cam_pos + d
        main.camPos = cam_pos
    end

    main.streamerCentre = main.camPos
    main.audioCentrePos = main.camPos
    main.audioCentreVel = vec(0, 0, 0);
end

function Editor:stepCallback(elapsed_secs)
    if self.debugMode then
        WeaponEffectManager:stepCallback(elapsed_secs, main.camPos, main.camQuat)
    end
end

function Editor:setMouseCapture(v)
    self.mouseCapture = v
    ch.enabled = v
    playing_binds.mouseCapture = v
end

function Editor:toggleMouseCapture()
    -- Only called when we are in debug mode
    self:setMouseCapture(not self.mouseCapture)
    if self.mouseCapture then
        -- Various other nice GUI things
		if self.debugModeSettingsWindow ~= nil and not self.debugModeSettingsWindow.destroyed then
			self.debugModeSettingsWindow.enabled = false
		end
	else
		if self.debugModeSettingsWindow ~= nil and not self.debugModeSettingsWindow.destroyed then
			self.debugModeSettingsWindow.enabled = true
		end
    end
end

function Editor:setDebugMode(v)
    -- Detach any object we may be controlling
    
	if widget_manager then
		widget_manager:unselectAll()
	end
	
	if not v then
        if self.controlObj ~= nil then
            self:toggleBoard()
        end
    end

	game_manager.currentMode.debug_mode_text.enabled = v
	
	editor_interface.enabled = not v
	
    self.debugMode = v
    main.physicsEnabled = v
    self:setMouseCapture(v)
    clock.enabled = v
    compass.enabled = v
    stats.enabled = v
    editor_edit_binds.enabled = not v
    editor_core_move_binds.enabled = not v
	-- print(editor_edit_binds.enabled)
	-- print( editor_core_move_binds.enabled)
    editor_debug_binds.enabled = v
    editor_debug_ghost_binds.enabled = v

	if editor_interface.map_editor_page ~= nil then
		if v then
			editor_interface.map_editor_page:unselect()
		else
			editor_interface.map_editor_page:select()
		end
	end
	
    if not v then
        if self.controlObj ~= nil then
            self:toggleBoard()
        end

        for _, obj in ipairs(object_all()) do
            if obj.destroyed then 
                -- Skip
            elseif obj.debugObject == true then
                safe_destroy(obj)
            else
                obj:deactivate()
                obj.skipNextActivation = false
            end
        end
		if self.debugModeSettingsWindow ~= nil and not self.debugModeSettingsWindow.destroyed then
			self.debugModeSettingsWindow.enabled = false
		end
	else
		notify("Press F5 to return to the editor", vec(1, 0.5, 0), vec(1, 1, 1))
		if self.debugModeSettingsWindow == nil or self.debugModeSettingsWindow.destroyed then
			self:createDebugModeSettingsWindow()
			self.debugModeSettingsWindow.enabled = false
		end
    end
end

function Editor:createDebugModeSettingsWindow()
	if self.debugModeSettingsWindow ~= nil and not self.debugModeSettingsWindow.destroyed then
		self.debugModeSettingsWindow:destroy()
	end

	self.debugModeSettingsWindow = hud_object `windows/debug_mode/Settings` {
		title = "Debug Mode Settings";
		parent = hud_centre;
		position = vec(0, 0);
		resizeable = true;
		size = vec(620, 500);
		min_size = vec2(620, 500);
		-- colour = _current_theme.colours.window.background;
		alpha = 1;	
	}

	_windows[#_windows+1] = self.debugModeSettingsWindow
end

function Editor:toggleDebugMode()
    self:setDebugMode(not self.debugMode)
end

function Editor:play()
	print("Currently disabled")
end

function Editor:setPlayMode(v)
	self.playGameMode:editorDebug(v)

	editor_interface.enabled = not v
	
    self.playMode = v
    main.physicsEnabled = v
    self:setMouseCapture(v)

    editor_edit_binds.enabled = not v
    editor_core_move_binds.enabled = not v

	if editor_interface.map_editor_page ~= nil then
		if v then
			editor_interface.map_editor_page:unselect()
		else
			editor_interface.map_editor_page:select()
		end
	end
	
    if not v then
        if self.controlObj ~= nil then
            self:toggleBoard()
        end

        for _, obj in ipairs(object_all()) do
            if obj.destroyed then 
                -- Skip
            elseif obj.debugObject == true then
                safe_destroy(obj)
            else
                obj:deactivate()
                obj.skipNextActivation = false
            end
        end

    end
end

function Editor:togglePlayMode()
    self:setPlayMode(not self.playMode)
end

function is_inside_menu(menu)
    if menu.enabled and mouse_pos_abs.x > menu.derivedPosition.x - menu.size.x/2 and
    mouse_pos_abs.x < menu.derivedPosition.x + menu.size.x/2 and
    mouse_pos_abs.y > menu.derivedPosition.y - menu.size.y/2
    then
        return true
    end
    return false
end

-- return true if the mouse cursor is inside any active menu
function mouse_inside_any_menu()
	for i = 1, #_menus do
		if _menus[i] ~= nil and not _menus[i].destroyed then
			if is_inside_menu(_menus[i]) then return true end
		end
	end
    return false
end

function extra_inside_hud()
	return false
end

function inside_hud()
    -- [dcunnin] If the intention of this is to detect whether the cursor is over a window,
    -- there must be a better way.
    --
    -- All these cross-cutting dependencies on other aspects of GUI layout have to go...
    if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
        if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 52 then
            if not mouse_inside_any_window() and not mouse_inside_any_menu() and not extra_inside_hud() and addobjectelement == nil then
                return true
            end
        end
    end
    return false
end

function Editor:generateEnvCube(pos)
    self.map:generateEnvCube(pos)
end

function Editor:newMap()
    gfx_option("RENDER_SKY", true)
	
    -- Triggers particles to disappear.  We need a better way to render sprites.
	unload_icons = true
	
	navigation_reset()
	
	-- no fog and a smooth background colour
	env_cycle = include `edenv.lua`
    env_recompute()
	
	widget_manager:unselectAll()
	
    -- destroy old editor objects
    -- local remaining_editor_objects = object_all()
    -- for i = 1, #remaining_editor_objects do
    --     if remaining_editor_objects[i].editorObject then
    --         safe_destroy(remaining_editor_objects[i])
    --     end
    -- end
    
    self.map:reset()
    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end

function Editor:openMap(map_file)
    if map_file == nil then
        open_map_dialog()
        return
    end

	widget_manager:unselectAll()

	-- unload_icons = true
	
	-- you can create a new map and include a lua that cointains object placements
    gfx_option("RENDER_SKY", true)
    
    navigation_reset()
    
    self.map:open(map_file)
    main.camPos, main.camQuat = self.map:getEditorCamPosOrientation()
    self.camPitch = quatPitch(main.camQuat)
    self.camYaw = cam_yaw_angle()

    
    create_world_icons()
    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end

-- save current map, if have a "file_name" specified
function Editor:saveCurrentMap()
    if self.map.filename then
        self.map:setEditorCamPosOrientation(main.camPos, main.camQuat)
        self.map:save()
    else
        self:saveCurrentMapAs()
    end
end

function Editor:saveCurrentMapAs(name)
    if name == nil then
		save_map_dialog()
        return false
    else
        self.map:setEditorCamPosOrientation(main.camPos, main.camQuat)
        return self.map:saveAs(name)
    end
end

-- turn the toolbar icons as selected and change mode
function Editor:setWidgetMode(mode)
    if widget_manager.mode == mode then return end
    
    widget_manager:set_mode(mode)
end

-- save editor interface windows
function Editor:saveEditorInterface()
    editor_interface_cfg = {
      content_browser   =   {
        opened   = (editor_interface.map_editor_page.windows.content_browser == nil and false or true) or not editor_interface.map_editor_page.windows.content_browser.destroyed;
        position = { editor_interface.map_editor_page.windows.content_browser.position.x, editor_interface.map_editor_page.windows.content_browser.position.y };
        size     = { editor_interface.map_editor_page.windows.content_browser.size.x, editor_interface.map_editor_page.windows.content_browser.size.y };
      };
      event_editor      =   {
        opened   = editor_interface.map_editor_page.windows.event_editor.enabled;
        position = { editor_interface.map_editor_page.windows.event_editor.position.x, editor_interface.map_editor_page.windows.event_editor.position.y };
        size     = { editor_interface.map_editor_page.windows.event_editor.size.x, editor_interface.map_editor_page.windows.event_editor.size.y };
      };
      level_properties  =   {
        opened   = editor_interface.map_editor_page.windows.level_properties.enabled;
        position = { editor_interface.map_editor_page.windows.level_properties.position.x, editor_interface.map_editor_page.windows.level_properties.position.y };
        size     = { editor_interface.map_editor_page.windows.level_properties.size.x, editor_interface.map_editor_page.windows.level_properties.size.y };
      };
      material_editor   =   {
        opened   = editor_interface.map_editor_page.windows.material_editor.enabled;
        position = { editor_interface.map_editor_page.windows.material_editor.position.x, editor_interface.map_editor_page.windows.material_editor.position.y };
        size     = { editor_interface.map_editor_page.windows.material_editor.size.x, editor_interface.map_editor_page.windows.material_editor.size.y };
      };
      -- object_editor     =   {
        -- opened   = editor_interface.map_editor_page.windows.object_editor.enabled;
        -- position = { editor_interface.map_editor_page.windows.object_editor.position.x, editor_interface.map_editor_page.windows.object_editor.position.y };
        -- size     = { editor_interface.map_editor_page.windows.object_editor.size.x, editor_interface.map_editor_page.windows.object_editor.size.y };
      -- };
      object_properties =   {
        opened   = editor_interface.map_editor_page.windows.object_properties.enabled;
        position = { editor_interface.map_editor_page.windows.object_properties.position.x, editor_interface.map_editor_page.windows.object_properties.position.y };
        size     = { editor_interface.map_editor_page.windows.object_properties.size.x, editor_interface.map_editor_page.windows.object_properties.size.y };
      };
      outliner          =   {
        opened   = editor_interface.map_editor_page.windows.outliner .enabled;
        position = { editor_interface.map_editor_page.windows.outliner .position.x, editor_interface.map_editor_page.windows.outliner .position.y };
        size     = { editor_interface.map_editor_page.windows.outliner .size.x, editor_interface.map_editor_page.windows.outliner .size.y };
      };
      settings          =   {
        opened   = editor_interface.map_editor_page.windows.settings.enabled;
        position = { editor_interface.map_editor_page.windows.settings.position.x, editor_interface.map_editor_page.windows.settings.position.y };
        size     = { editor_interface.map_editor_page.windows.settings.size.x, editor_interface.map_editor_page.windows.settings.size.y };
      };
      size              = { gfx_window_size().x, gfx_window_size().y };
      theme             = editor_interface.map_editor_page.windows.settings.content.themes_panel.theme_selectbox.selected.name;
    }    

    local file = io.open("editor/config/interface.lua", "w")

    if file == nil then error("Could not open file", 1) end

    file:write(
[[-- file auto generated by Grit Editor, be careful when modifying this manually
-- this file stores all editor interface configuration, like windows sizes, positions,
-- interface customizations, etc.
]]
)
    file:write("\neditor_interface_cfg = ")
    file:write(dump(editor_interface_cfg, false))

    file:close()
end

-- save editor config
function Editor:saveEditorConfig()
    local file = io.open("editor/config/config.lua", "w")

    if file == nil then error("Could not open file", 1) end

    file:write(
[[-- file auto generated by Grit Editor, be careful when modifying this manually
-- this file stores all editor configurations.
]]
)
    file:write("\neditor_cfg = ")
    file:write(dump(editor_cfg, false))

    file:close()
end

function Editor:undo()
    self.map:undo()
    widget_manager:updateWidgetFromSelection()
end

function Editor:redo()
    self.map:redo()
    widget_manager:updateWidgetFromSelection()
end

function Editor:cutObject()
end

function Editor:copyObject()
end

function Editor:pasteObject()
end

function Editor:init()
    navigation_reset()

    self.map = EditorMap.new()
    main.camPos, main.camQuat = self.map:getEditorCamPosOrientation()
    self.camPitch = quatPitch(main.camQuat)
    self.camYaw = cam_yaw_angle()

    -- Avoid it interfering with menu and tool bar.
    ticker:setOffset(vec(40, 58))
    -- Avoid distracting text while we load the HUD.
    ticker:clear()

    gfx_option("WIREFRAME_SOLID", true) -- i don't know why but when selecting a object it just shows wireframe, so TEMPORARY?
    -- fix glow in the arrows
    gfx_option("BLOOM_THRESHOLD", 3)

    -- [dcunnin] Ideally we would declare things earlier and only instantiate them at this
    -- point.  However all the code is mixed up right now.
    
    self.debug_mode_text = hud_text_add(`/common/fonts/Verdana12`)
    self.debug_mode_text.parent = hud_bottom_left
    self.debug_mode_text.text = "Mouse left: Use Weapon\nMouse Scroll: Change Weapon\nF: Controll Object\nTab: Console\nF1: Open debug mode menu (TODO)\nF5: Return Editor"
    self.debug_mode_text.position = vec(self.debug_mode_text.size.x/2+10, self.debug_mode_text.size.y)
    
    make_editor_interface()

    playing_binds.enabled = true
    editor_core_binds.enabled = true
    editor_edit_binds.enabled = false
    editor_debug_binds.enabled = false

    self.lastMouseMoveTime = seconds()

    -- set default values/update values for window content
    editor_init_windows()
    
    if editor_cfg.load_startup_map then
        self:openMap(editor_cfg.startup_map)
    else
        self:newMap()
    end
    
    notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
    self:setDebugMode(false)
    
    env.clockRate = 0
end

function Editor:setPause(v)
    -- Do nothing, pause controlled elsewhere.
end

function Editor:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity

    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)

    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)

    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat
    self.lastMouseMoveTime = seconds()
end

function Editor:receiveButton(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end
	if not hud_focus then
		local cobj = self.controlObj

		if button == "debug" then
			if state == '+' then
				self:toggleDebugMode()
			end
		elseif button == "forwards" then
			self.forwards = on_off

		elseif button == "forwards" then
			self.forwards = on_off

		elseif button == "backwards" then
			self.backwards = on_off

		elseif button == "strafeLeft" then
			self.left = on_off

		elseif button == "strafeRight" then
			self.right = on_off

		elseif button == "ascend" then
			self.ascend = on_off
		elseif button == "descend" then
			self.descend = on_off
		elseif button == "faster" then
			if state == '+' then
				self.fast = true
			elseif state == '-' then
				self.fast = false
			end
		elseif button == "delete" then
			if state == '+' then
				self:deleteSelection()
			end

		elseif button == "duplicate" then
			if state == '+' then
				self:duplicateSelection()
			end

		elseif button == "board" then
			if state == '+' then
				self:toggleBoard()
			end

		elseif button == "walkBoard" then
			if state == '+' then
				self:toggleBoard()
			end

		elseif button == "driveAbandon" then
			if state == '+' then
				self:toggleBoard()
			end

		elseif button == "ghost" then
			if state == '+' then
				if inside_hud() then
					self:setMouseCapture(true)
				end
			elseif state == '-' then
				self:setMouseCapture(false)
			end

		elseif button == "toggleGhost" then
			if state == '+' then
				self:toggleMouseCapture()
			end

		elseif button == "selectModeTranslate" then
			self:setWidgetMode("translate")
		elseif button == "selectModeRotate" then
			self:setWidgetMode("rotate")
		elseif button == "weaponPrimary" then
			if not mouse_inside_any_window() then
				if state == '+' then
					WeaponEffectManager:primaryEngage(main.camPos, main.camQuat)
				elseif state == '-' then
					WeaponEffectManager:primaryDisengage()
				end
			end
		elseif button == "weaponSecondary" then
			if not mouse_inside_any_window() then
				if state == '+' then
					WeaponEffectManager:secondaryEngage(main.camPos, main.camQuat)
				elseif state == '-' then
					WeaponEffectManager:secondaryDisengage()
				end
			end
		elseif button == "weaponSwitchUp" then
			if state == '+' then
				WeaponEffectManager:select(WeaponEffectManager:getNext())
			end

		elseif button == "weaponSwitchDown" then
			if state == '+' then
				WeaponEffectManager:select(WeaponEffectManager:getPrev())
			end

		elseif button == "pausePhysics" then
			if state == '+' then
				main.physicsEnabled = not main.physicsEnabled
			end
		else
			local pressed = state ~= '-'
			if state == '=' then return end

			if button == 'walkForwards' then
				cobj:setForwards(pressed)
			elseif button == 'walkBackwards' then
				cobj:setBackwards(pressed)
			elseif button == 'walkLeft' then
				cobj:setLeft(pressed)
			elseif button == 'walkRight' then
				cobj:setRight(pressed)
			elseif button == 'walkBoard' then
				if state == '+' then
					self:scanForBoard()
				end
			elseif button == 'walkJump' then
				cobj:setJump(pressed)
			elseif button == 'walkRun' then
				cobj:setRun(pressed)
			elseif button == 'walkCrouch' then
				cobj:setCrouch(pressed)
			elseif button == 'walkZoomIn' then
				cobj:controlZoomIn()
			elseif button == 'walkZoomOut' then
				cobj:controlZoomOut()
			elseif button == 'walkCamera' then
				-- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

			elseif button == 'driveForwards' then
				cobj:setForwards(pressed)
			elseif button == 'driveBackwards' then
				cobj:setBackwards(pressed)
			elseif button == 'driveLeft' then
				cobj:setLeft(pressed)
			elseif button == 'driveRight' then
				cobj:setRight(pressed)
			elseif button == 'driveZoomIn' then
				cobj:controlZoomIn()
			elseif button == 'driveZoomOut' then
				cobj:controlZoomOut()
			elseif button == 'driveCamera' then
				-- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

			elseif button == 'driveSpecialUp' then
				cobj:setSpecialUp(pressed)
			elseif button == 'driveSpecialDown' then
				cobj:setSpecialDown(pressed)
			elseif button == 'driveSpecialLeft' then
				cobj:setSpecialLeft(pressed)
			elseif button == 'driveSpecialRight' then
				cobj:setSpecialRight(pressed)
			elseif button == 'driveAltUp' then
				cobj:setAltUp(pressed)
			elseif button == 'driveAltDown' then
				cobj:setAltDown(pressed)
			elseif button == 'driveAltLeft' then
				cobj:setAltLeft(pressed)
			elseif button == 'driveAltRight' then
				cobj:setAltRight(pressed)
			elseif button == 'driveAbandon' then
				if state == '+' then
					self:abandonControlObj()
				end
			elseif button == 'driveHandbrake' then
				cobj:setHandbrake(pressed)
			elseif button == 'driveLights' then
				if state == '+' then
					cobj:setLights()
				end
			elseif button == 'driveSpecialToggle' then
				if state == '+' then
					cobj:special()
				end
			else
				error("Editor has no binding for button: "..button)
			end
		end
	end
end

function Editor:destroy()
    widget_manager:unselectAll()
    
    self:saveEditorConfig()
    -- self:saveEditorInterface()
    
    editor_core_binds.enabled = false
    editor_core_move_binds.enabled = false
    editor_edit_binds.enabled = false
    editor_debug_binds.enabled = false
    editor_debug_ghost_binds.enabled = false

    gfx_option("RENDER_SKY", true)
    
    editor_interface.map_editor_page:destroy()
    editor_interface:destroy()
    env.clockRate = 30
    navigation_reset()
    
    gfx_option("BLOOM_THRESHOLD", 1)
end

game_manager:register(Editor)
