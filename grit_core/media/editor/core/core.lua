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

	currentWindow = currentWindow,

	currentTheme = editor_themes[editor_interface_cfg.theme];
	
    -- holds editor camera position and rotation to get back when stop playing
    camera = {
        pos = {};
        rot = {};        
    };

    directory = "editor";
    
    map_dir = "level_templates";
    
    game_data_dir = "editor";
};


--[[
function ghost:pickDrive()
    local obj = pick_obj_safe()
    if obj == nil then return end
    main:beginControlObj(obj)
end
]]

function GED:openWindow(wnd)
    wnd.enabled = true
	self:setActiveWindow(wnd)
end;

-- if the widget is under mouse cursor, then start dragging, otherwise select an object
function GED:selectObj()
    widget_manager:select(true)
end;

function GED:stopDraggingObj()
	input_filter_set_cursor_hidden(false)
    widget_manager:select(false)
end;

function GED:deleteSelection()
    local selobj = widget_manager.selectedObj
    widget_manager:unselect()
    safe_destroy(selobj)
end;

function GED:duplicateSelection()
    if widget_manager ~= nil and widget_manager.selectedObj ~= nil then
        object (widget_manager.selectedObj.className) (widget_manager.selectedObj.instance.body.worldPosition) {
            rot=widget_manager.selectedObj.instance.body.worldOrientation;
        }
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
    main.streamerCentre = cam_pos
    main.audioCentrePos = cam_pos
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
    end
end

function GED:setDebugMode(v)
    self.debugMode = v
    main.physicsEnabled = v
    self:setMouseCapture(v)
    clock.enabled = v
    compass.enabled = v
    stats.enabled = v
    editor_edit_binds.enabled = not v
    editor_debug_binds.enabled = v

    editor_interface.menubar.enabled = not v
    editor_interface.toolbar.enabled = not v
    editor_interface.statusbar.enabled = not v

    if not v then

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

function GED:toggleDebugMode()
    self:setDebugMode(not self.debugMode)
end


function is_inside_window(window)
    if window.enabled then
        if mouse_pos_abs.x < gfx_window_size().x/2 + window.position.x + window.size.x/2 and
        mouse_pos_abs.x > gfx_window_size().x/2 + window.position.x - window.size.x/2 and
        mouse_pos_abs.y < gfx_window_size().y/2 + window.position.y + window.size.y/2 + window.draggable_area.size.y and
        mouse_pos_abs.y > gfx_window_size().y/2 + window.position.y - window.size.y/2 then
            return true
        end
    end
    return false
end

-- return true if the mouse cursor is inside any window
function mouse_inside_any_window()
    if is_inside_window(editor_interface.windows.content_browser) or
    is_inside_window(editor_interface.windows.event_editor) or
    is_inside_window(editor_interface.windows.level_properties) or
    is_inside_window(editor_interface.windows.object_properties) or
    is_inside_window(editor_interface.windows.outliner) or
    is_inside_window(open_level_dialog) or
    is_inside_window(save_level_dialog) or
    is_inside_window(editor_interface.windows.settings) or
    (env_cycle_editor.enabled and mouse_pos_abs.x < 530 and mouse_pos_abs.y < 430) or
    (music_player.enabled and mouse_pos_abs.x < 560 and mouse_pos_abs.y < 260)
    then
        return true
    end
    return false
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
    if is_inside_menu(editor_interface.menus.fileMenu) or
    is_inside_menu(editor_interface.menus.editMenu) or
    is_inside_menu(editor_interface.menus.viewMenu) or
    is_inside_menu(editor_interface.menus.gameMenu) or
    is_inside_menu(editor_interface.menus.helpMenu)
    then
        return true
    end
    return false
end

function GED:generateEnvCube(pos)
    current_level:generateEnvCube(pos)
end;

function GED:newLevel(ndestroyobjs)
    include `edenv.lua`  -- [dcunnin] why not system/env_cycle.lua ?
    env_recompute()
	
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
    
    current_level = GritLevel.new()
    if update_level_properties ~= nil then
        update_level_properties()
    end
end;

function GED:openLevel(level_file)
    
    if level_file == nil then
			self:openWindow(open_level_dialog)
        return
    end
    
    -- if is a lua script creates a new level before
    if level_file:sub(-3) ~= "lua" then
        current_level = nil
        current_level = GritLevel.new()
    end
    
    current_level:open(level_file)
    
    if update_level_properties ~= nil then
        update_level_properties()
    end
end;

-- save current level, if have a "file_name" specified
function GED:saveCurrentLevel()
    if #current_level.file_name > 0 then
        current_level:save()
    else
        self:saveCurrentLevelAs()
    end
end;

function GED:saveCurrentLevelAs(name)
    if name == nil then
        save_level_dialog.enabled = true
		self:openWindow(save_level_dialog)
        return
    else
        current_level.file_name = name
        
        local level_ext = name:reverse():match("..."):reverse()
        if level_ext == "lvl" then
            current_level:save()
        else
            current_level:export(name)
        end        
    end
end;

-- turn the toolbar icons as selected and change mode
function GED:setWidgetMode(mode)
    if widget_manager.mode == mode then return end
    
    widget_manager:set_mode(mode)
    widget_menu[0]:select(false)
    widget_menu[1]:select(false)
    widget_menu[2]:select(false)
    widget_menu[3]:select(false)
    
    widget_menu[mode]:select(true)
end;

-- save editor interface windows
function GED:saveEditorInterface()
    editor_interface_cfg = {
      content_browser   =   {
        opened   = editor_interface.windows.content_browser.enabled;
        position = { editor_interface.windows.content_browser.position.x, editor_interface.windows.content_browser.position.y };
        size     = { editor_interface.windows.content_browser.size.x, editor_interface.windows.content_browser.size.y };
      };
      event_editor      =   {
        opened   = editor_interface.windows.event_editor.enabled;
        position = { editor_interface.windows.event_editor.position.x, editor_interface.windows.event_editor.position.y };
        size     = { editor_interface.windows.event_editor.size.x, editor_interface.windows.event_editor.size.y };
      };
      level_properties  =   {
        opened   = editor_interface.windows.level_properties.enabled;
        position = { editor_interface.windows.level_properties.position.x, editor_interface.windows.level_properties.position.y };
        size     = { editor_interface.windows.level_properties.size.x, editor_interface.windows.level_properties.size.y };
      };
      material_editor   =   {
        opened   = editor_interface.windows.material_editor.enabled;
        position = { editor_interface.windows.material_editor.position.x, editor_interface.windows.material_editor.position.y };
        size     = { editor_interface.windows.material_editor.size.x, editor_interface.windows.material_editor.size.y };
      };
      object_editor     =   {
        opened   = editor_interface.windows.object_editor.enabled;
        position = { editor_interface.windows.object_editor.position.x, editor_interface.windows.object_editor.position.y };
        size     = { editor_interface.windows.object_editor.size.x, editor_interface.windows.object_editor.size.y };
      };
      object_properties =   {
        opened   = editor_interface.windows.object_properties.enabled;
        position = { editor_interface.windows.object_properties.position.x, editor_interface.windows.object_properties.position.y };
        size     = { editor_interface.windows.object_properties.size.x, editor_interface.windows.object_properties.size.y };
      };
      outliner          =   {
        opened   = editor_interface.windows.outliner .enabled;
        position = { editor_interface.windows.outliner .position.x, editor_interface.windows.outliner .position.y };
        size     = { editor_interface.windows.outliner .size.x, editor_interface.windows.outliner .size.y };
      };
      settings          =   {
        opened   = editor_interface.windows.settings.enabled;
        position = { editor_interface.windows.settings.position.x, editor_interface.windows.settings.position.y };
        size     = { editor_interface.windows.settings.size.x, editor_interface.windows.settings.size.y };
      };
      size              = { gfx_window_size().x, gfx_window_size().y };
      theme             = "dark_orange";
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

function GED:editorSettings()
	self:openWindow(editor_interface.windows.settings)
end;

function GED:openContentBrowser()
	self:openWindow(editor_interface.windows.content_browser)
end;

function GED:openEventEditor()
	self:openWindow(editor_interface.windows.event_editor)
end;

function GED:openObjectProperties()
	self:openWindow(editor_interface.windows.object_properties)
end;

function GED:openMaterialEditor()
	self:openWindow(editor_interface.windows.material_editor)
end;

function GED:openLevelProperties()
	self:openWindow(editor_interface.windows.level_properties)
end;

function GED:openOutliner()
	self:openWindow(editor_interface.windows.outliner)
end;

-- TODO: object editor is not inside a editor window, but uses all Grit window
-- You right click on the object on the content browser and select "Edit Object"
-- It hides the sky (would be cool also to select the background colour) and all editor interface, creates a object and centralize the camera on it, so you can rotate around
-- the object. You can also reload object assets on a button on the object editor toolbar
function GED:openObjectEditor()
	self:openWindow(editor_interface.windows.object_editor)
end;

function GED:disableAllWindows()
    editor_interface.windows.content_browser.enabled = false
    editor_interface.windows.event_editor.enabled = false
    editor_interface.windows.object_properties.enabled = false
    editor_interface.windows.material_editor.enabled = false
    editor_interface.windows.level_properties.enabled = false
    editor_interface.windows.outliner.enabled = false
    editor_interface.windows.settings.enabled = false
    editor_interface.windows.object_editor.enabled = false
end;

function GED:setActiveWindow(wnd)
	if self.currentWindow ~= nil and self.currentWindow ~= wnd then
		self.currentWindow.zOrder = 0
		self.currentWindow.draggable_area.colour = GED.currentTheme.colours.window.title_background_inactive
		self.currentWindow.window_title.colour = GED.currentTheme.colours.window.title_text_inactive
	end
	self.currentWindow = wnd
	wnd.zOrder = 1
	wnd.draggable_area.colour = GED.currentTheme.colours.window.title_background
	wnd.window_title.colour = GED.currentTheme.colours.window.title_text
end;
