------------------------------------------------------------------------------
--  This is the core of Grit Editor, all common functions are here
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

GED = {

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
};


function GED:toggleBoard(mobj)
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
function GED:selectObj()
	if self.selectionEnabled then
		if input_filter_pressed("Shift") then
			widget_manager:select(true, true)
		else
			widget_manager:select(true, false)
		end
	end
end;

function GED:leftMouseClick()
	self:selectObj()
end;

function GED:stopDraggingObj()
    widget_manager:stopDragging()
end;

function GED:deleteSelection()
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
end;

function GED:duplicateSelection()
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
end;

function GED:destroyAllEditorObjects()
    local objs = object_all()
    for i = 1, #objs do
        if objs[i].editorObject ~= nil then
            safe_destroy(objs[i])
        end
    end
end;

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function GED:frameCallback(elapsed_secs)
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
        if false and user_cfg.vehicleCameraTrack and obj.cameraTrack and seconds() - editor.lastMouseMoveTime > 1  and obj_vel_xy_speed > 5 then

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
end;

function GED:stepCallback(elapsed_secs)
    if self.debugMode then
        WeaponEffectManager:stepCallback(elapsed_secs, main.camPos, main.camQuat)
    end
end;

function GED:setMouseCapture(v)
    self.mouseCapture = v
    ch.enabled = v
    playing_binds.mouseCapture = v
end

function GED:toggleMouseCapture()
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

function GED:setDebugMode(v)
    -- Detach any object we may be controlling
    
	if widget_manager then
		widget_manager:unselectAll()
	end
	
	if not v then
        if self.controlObj ~= nil then
            self:toggleBoard()
        end
    end

	editor.debug_mode_text.enabled = v
	
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
end;

include`/editor/core/windows/debug_mode/settings.lua`

function GED:createDebugModeSettingsWindow()
	if self.debugModeSettingsWindow ~= nil and not self.debugModeSettingsWindow.destroyed then
		self.debugModeSettingsWindow:destroy()
	end

	self.debugModeSettingsWindow = hud_object `/editor/core/windows/debug_mode/Settings` {
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

function GED:toggleDebugMode()
    self:setDebugMode(not self.debugMode)
end

function GED:play()
	print("Currently disabled")
end

function GED:setPlayMode(v)
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
end;

function GED:togglePlayMode()
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

function GED:generateEnvCube(pos)
    current_map:generateEnvCube(pos)
end;

function GED:newMap(ndestroyobjs)
    gfx_option("RENDER_SKY", true)
	
	unload_icons = true
	
	navigation_reset()
	
	-- no fog and a smooth background colour
	include `edenv.lua`
    env_recompute()
	
	widget_manager:unselectAll()
	
	-- ndestroyobjs = doesn't destroy current objects
	if not ndestroyobjs then
		object_all_del()
	end
    -- destroy old editor objects
    local remaining_editor_objects = object_all()
    for i = 1, #remaining_editor_objects do
        if remaining_editor_objects[i].editorObject then
            safe_destroy(remaining_editor_objects[i])
        end
    end
    
    current_map = GritMap.new()
    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end;

function GED:openMap(map_file)
    if map_file == nil then
			open_map_dialog()
        return
    end

	widget_manager:unselectAll()

	-- unload_icons = true
	
	-- you can create a new map and include a lua that cointains object placements
	local map_ext = get_extension(map_file)
	if map_ext == "lua" then
        current_map = nil
        current_map = GritMap.new()		
		include (mapfile)
	elseif map_ext == "gmap" then
		gfx_option("RENDER_SKY", true)
		
		navigation_reset()
		
		if current_map == nil then
			current_map = GritMap.new()	
		end
		local success = current_map:open(map_file)

        main.camPos = current_map.editor.cam_pos
        main.camQuat = current_map.editor.cam_quat
        self.camPitch = quatPitch(main.camQuat)
        self.camYaw = cam_yaw_angle()

		
		create_world_icons()
		return success
	end

    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end;

-- save current map, if have a "file_name" specified
function GED:saveCurrentMap()
    if #current_map.file_name > 0 then
        current_map:save()
    else
        self:saveCurrentMapAs()
    end
end;

function GED:saveCurrentMapAs(name)
    if name == nil then
		save_map_dialog()
        return false
    else
        current_map.file_name = name
        
        local map_ext = get_extension(name)
        if map_ext == "gmap" then
            return current_map:save()
        else
            return current_map:export(name)
        end        
    end
end;

-- turn the toolbar icons as selected and change mode
function GED:setWidgetMode(mode)
    if widget_manager.mode == mode then return end
    
    widget_manager:set_mode(mode)
end;

-- save editor interface windows
function GED:saveEditorInterface()
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
end;

-- save editor config
function GED:saveEditorConfig()
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
end;

function GED:undo()
end;

function GED:redo()
end;

function GED:cutObject()
end;

function GED:copyObject()
end;

function GED:pasteObject()
end;

function exit_editor()
	game_manager:exit()
end;
