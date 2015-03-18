------------------------------------------------------------------------------
--  This is the core of Grit Editor, all common functions are here
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

GED = {

    noClip = false,
    fast = false,
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


    -- holds editor camera position and rotation to get back when stop playing
    camera = {
        pos = {};
        rot = {};        
    };

    directory = "editor";
    
    map_dir = "level_templates";
    
    game_data_dir = "editor";
};


local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function GED:updateGhost (elapsed)
    local right = self.right - self.left
    local forwards = self.forwards - self.backwards
    local ascend = self.ascend - self.descend

    local active_speed = self.fast and self.speedFast or self.speedSlow

    local dist = active_speed * elapsed

    local cam_pos = main.camPos

    -- we now know how far to move (dist)
    -- but not in which directions

    local d = main.camQuat * vector3(dist*right, dist*forwards, 0) + vector3(0,0,dist*ascend)
    

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
end

--[[
function ghost:pickDrive()
    local obj = pick_obj_safe()
    if obj == nil then return end
    player_ctrl:beginControlObj(obj)
end
]]



function GED:select_obj()
    input_filter_set_cursor_hidden(true)
    widget_manager:select(true)
end;

function GED:unselect_obj()
    input_filter_set_cursor_hidden(false)
    widget_manager:select(false)
end;

function GED:delete_selection()
    local selobj = widget_manager.selectedObj
    self:unselect_obj()
    widget_manager:unselect()
    safe_destroy(selobj)
end;

function GED:duplicate_selection()
    if widget_manager ~= nil and widget_manager.selectedObj ~= nil then
        object (widget_manager.selectedObj.className) (widget_manager.selectedObj.instance.body.worldPosition) {
            rot=widget_manager.selectedObj.instance.body.worldOrientation
        }
    end
end;

--[[
function GED:return_editor()    
    editor_interface.menubar.enabled = true
    editor_interface.toolbar.enabled =true
    editor_interface.statusbar.enabled = true

    -- reset the editor camera
    player_ctrl.camPos = GED.camera.pos
    player_ctrl.camYaw = GED.camera.rot.Yaw
    player_ctrl.camPitch = GED.camera.rot.Pitch
    player_ctrl.camDir = GED.camera.rot.Dir
    
end;
]]

function GED:frameCallback(elapsed_secs)
    self:updateGhost(elapsed_secs)
end;

function GED:simulate()
end;

function GED:stop_simulate()
end;

-- [dcunnin] I'd rather let them escape back to menu to play the game.  Having two Grits
-- loaded simultaneously would make both of them slow.  They should just save the map and start the
-- game from the main menu.

--[[
function GED:run_game()
    if true then
        os.execute("grit.dat include`"..current_level.file_name.."`")
    else
        os.execute("Grit.linux.x86_64")
    end
end;
]]

function GED:destroy_all_editor_objects()
    local objs = object_all()
    for i = 1, #objs do
        if objs[i].editor_object ~= nil then
            safe_destroy(objs[i])
        end
    end
end;

function GED:play()
end;

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

function GED:generate_env_cube(pos)
    current_level:generate_env_cube(pos)
end;

function GED:new_level()
    include `edenv.lua`  -- [dcunnin] why not system/env_cycle.lua ?
    env_recompute()
    object_all_del()

    -- destroy old editor objects
    local remaining_editor_objects = object_all()
    for i = 1, #remaining_editor_objects do
        if remaining_editor_objects[i].editor_object then
            safe_destroy(remaining_editor_objects[i])
        end
    end
    
    current_level = GritLevel.new()
    if update_level_properties ~= nil then
        update_level_properties()
    end
end;

function GED:open_level(level_file)
    
    if level_file == nil then
        open_level_dialog.enabled = true
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
function GED:save_current_level()
    if #current_level.file_name > 0 then
        current_level:save()
    else
        self:save_current_level_as()
    end
end;

function GED:save_current_level_as(name)
    if name == nil then
        save_level_dialog.enabled = true
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
function GED:set_widget_mode(mode)
    if widget_manager.mode == mode then return end
    
    widget_manager:set_mode(mode)
    widget_menu[0]:select(false)
    widget_menu[1]:select(false)
    widget_menu[2]:select(false)
    widget_menu[3]:select(false)
    
    widget_menu[mode]:select(true)
end;

-- save editor interface windows
function GED:save_editor_interface()
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

function GED:cut_object()
end;

function GED:copy_object()
end;

function GED:paste_object()
end;

function GED:editor_settings()
    editor_interface.windows.settings.enabled = true
end;

function GED:open_content_browser()
    editor_interface.windows.content_browser.enabled = true
end;

function GED:open_event_editor()
    editor_interface.windows.event_editor.enabled = true
end;

function GED:open_object_properties()
    editor_interface.windows.object_properties.enabled = true
end;

function GED:open_material_editor()
    editor_interface.windows.material_editor.enabled = true
end;

function GED:open_level_properties()
    editor_interface.windows.level_properties.enabled = true
end;

function GED:open_outliner()
    editor_interface.windows.outliner.enabled = true
end;

function GED:open_object_editor()
    editor_interface.windows.object_editor.enabled = true
end;

function GED:disable_all_windows()
    editor_interface.windows.content_browser.enabled = false
    editor_interface.windows.event_editor.enabled = false
    editor_interface.windows.object_properties.enabled = false
    editor_interface.windows.material_editor.enabled = false
    editor_interface.windows.level_properties.enabled = false
    editor_interface.windows.outliner.enabled = false
    editor_interface.windows.settings.enabled = false
    editor_interface.windows.object_editor.enabled = false
end
