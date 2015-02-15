------------------------------------------------------------------------------
--  This is the core of Grit Editor, all common functions are here
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

GED = {
	-- holds editor camera position and rotation to get back when stop playing
	camera = {
		pos = {};
		rot = {};		
	};

	directory = "editor";
	
	map_dir = "level_templates";
	game_mode_dir = "gamemodes"	;
	
	game_data_dir = "editor";
};

-- returns all objects from a physics_cast
function get_pc_ol(...)
	local t = {...}
	if t == nil then return nil end
	local it = 2
	local mobjs = {}
	for i=1, #t/4 do
		mobjs[#mobjs+1] = t[it].owner
		it = it + 4
	end
	if(next(mobjs)) then
		return mobjs
	else
		return nil
	end
end

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

function GED:set_spawn_point(pos, rotation)
	if pos ~= nil then
		if type(pos) ~= "vector3" then
			print(RED.."Not a vector3")
			return
		end
	end
	pos = pos or (pick_pos() + vector3(0, 0, 0))  or current_level.spawn.pos
	if current_level.spawn_point ~= nil then safe_destroy(current_level.spawn_point)end
	current_level.spawn_point = object (`assets/spawn_point`) (pos) {
		rot=rotation or current_level.spawn.rot
	}
	-- current_level.spawn_point.instance.body.ghost = true
	current_level.spawn.pos = pos
	current_level.spawn.rot = rotation or current_level.spawn.rot
end;

function GED:return_editor()	
	game:stop()
	editor_interface.menubar.enabled = true
	editor_interface.toolbar.enabled =true
	editor_interface.statusbar.enabled = true

	self:toggle_console()

	self:set_editor_bindings()	
	
	-- reset the editor camera
	player_ctrl.camPos = GED.camera.pos
	player_ctrl.camYaw = GED.camera.rot.Yaw
	player_ctrl.camPitch = GED.camera.rot.Pitch
	player_ctrl.camDir = GED.camera.rot.Dir
	
	if current_level.spawn_point ~= nil then
		current_level.spawn_point =  object (`assets/spawn_point`)
		(current_level.spawn.pos) { rot=current_level.spawn.rot }
	end
end;

function GED:simulate()
end;

function GED:stop_simulate()
end;

function GED:run_game()
	if true then
		os.execute("grit.dat include`"..current_level.file_name.."`")
	else
		os.execute("Grit.linux.x86_64")
	end
end;

function GED:destroy_all_editor_objects()
	local objs = object_all()
	for i = 1, #objs do
		if objs[i].editor_object ~= nil then
			safe_destroy(objs[i])
		end
	end
end;

function GED:play()
	if current_level.game_mode ~= nil then
		editor_interface.menubar.enabled = false
		editor_interface.toolbar.enabled = false
		editor_interface.statusbar.enabled = false
		
		self:disable_all_windows()
		
		self:toggle_console()
		
		self.camera.pos = player_ctrl.camPos
		self.camera.rot.Yaw = player_ctrl.camYaw
		self.camera.rot.Pitch = player_ctrl.camPitch
		self.camera.rot.Dir = player_ctrl.camDir
		
		self:set_game_bindings()

		safe_include("/editor/gamemodes/"..current_level.game_mode..".lua")
		
		if current_level.spawn_point ~= nil and current_level.spawn_point ~= nil and current_level.spawn_point.instance ~= nil then
			current_level.spawn.pos = current_level.spawn_point.instance.body.worldPosition
			current_level.spawn.rot = current_level.spawn_point.instance.body.worldOrientation
			safe_destroy(current_level.spawn_point)
			current_level.spawn_point = true
		end
		game:play()
	end
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


function GED:set_editor_bindings()
	menu_binds:bind("Escape", function() do_nothing() end)

	debug_binds:bind("Delete", function() GED:delete_selection() end)
	debug_binds:bind("C+d", function() GED:duplicate_selection() end)
	debug_binds:bind("A+g", function() GED:play()end)
	
	playing_ghost_binds:unbind("e")
	
	menu_binds:bind("Tab", function()
		debug_layer:selectConsole(not console.enabled)
		hud_focus = console
	end)
	
	debug_binds:bind("right", function()
		ch.enabled = true
		debug_binds.modal = not debug_binds.modal
		debug_layer:selectConsole()
		debug_binds:bind("Shift", function()
			ghost.fast = true
		end,
		function()
			ghost.fast = false
		end)
		ghost.fast = false
	end, function()
		ch.enabled = false
		debug_binds.modal = not debug_binds.modal
		debug_binds:unbind("Shift")
	end)

	debug_binds:bind("left", function()
		if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
			if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 25 then
				if not mouse_inside_any_window() and not mouse_inside_any_menu() and addobjectelement == nil then
					self:select_obj()
				end
			end
		end
	end, function() self:unselect_obj() end) -- isn't actually unselect, but just stop dragging
end;

function GED:set_game_bindings()
	menu_binds:bind("Escape", function() GED:return_editor() end)
	menu_binds:bind("Tab", function() GED:return_editor() end)
	debug_binds:unbind("left")
	debug_binds:unbind("right")
	debug_binds:bind("A+g", function() GED:return_editor() end)
end;

function GED:generate_env_cube()
	current_level:generate_env_cube()
end;

function GED:toggle_console()
	debug_layer:onKeyPressed()
	debug_binds.modal = debug_layer.enabled
	ticker.enabled = not debug_layer.enabled
end;

function GED:new_level()
	include`edenv.lua`
	if next(current_level) ~= nil then
		object_all_del()
	end

	-- destroy old editor objects
	local remaining_editor_objects = object_all()
	for i = 1, #remaining_editor_objects do
		if remaining_editor_objects[i].editor_object then
			safe_destroy(remaining_editor_objects[i])
		end
	end
	
	current_level = GritLevel.new()
	current_level.spawn.pos = vector3(0, 0, 0)
	current_level.spawn.rot = quat(1, 0, 0, 0)
	current_level:load_game_mode()
	if update_level_properties ~= nil then
		update_level_properties()
	end
end;

function GED:close_level()
	object_all_del()
	current_level = nil
	self:new_level()
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
	current_level:load_game_mode()
	
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

function GED:show_console()
	toggle_console()
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

-- maybe useful for unloading resources when exiting the editor
function unload_resources()
	disk_resource_unload(`editor/core/icons/arrow_icon.png`)
	disk_resource_unload(`editor/core/icons/config/interface.png`)
	disk_resource_unload(`editor/core/icons/content_browser.png`)
	disk_resource_unload(`editor/core/icons/controller.png`)
	disk_resource_unload(`editor/core/icons/File_icon.png`)
	disk_resource_unload(`editor/core/icons/Folder_icon.png`)
	disk_resource_unload(`editor/core/icons/Folder_icon2.png`)
	disk_resource_unload(`editor/core/icons/foldericon.png`)
	disk_resource_unload(`editor/core/icons/graph_editor.png`)
	disk_resource_unload(`editor/core/icons/help.png`)
	disk_resource_unload(`editor/core/icons/hook.png`)
	disk_resource_unload(`editor/core/icons/hook2.png`)
	disk_resource_unload(`editor/core/icons/level_config.png`)
	disk_resource_unload(`editor/core/icons/line.png`)
	disk_resource_unload(`editor/core/icons/luaicon.png`)
	disk_resource_unload(`editor/core/icons/lvlicon.png`)
	disk_resource_unload(`editor/core/icons/material_editor.png`)
	disk_resource_unload(`editor/core/icons/menubar.png`)
	disk_resource_unload(`editor/core/icons/undo.png`)
	disk_resource_unload(`editor/core/icons/redo.png`)
end
	
function exit_editor()
	-- TODO: prompt if user want to save his work

	GED:save_editor_interface()
	-- GED:close_level()
	-- current_level = nil
	-- if level ~= nil then
		-- level = nil
	-- end
	-- if game ~= nil then
		-- game = nil
	-- end
	
	--editor_interface.menubar:destroy()
	--editor_interface.toolbar:destroy()
	editor_interface.statusbar:destroy()
	
	--destroy_all_editor_menus()		
	destroy_all_editor_windows()
	
	safe_destroy(left_toolbar)
	left_toolbar = nil
	destroy_all_editor_windows = nil
	destroy_all_editor_menus = nil
	
	GED:set_game_bindings()

	GED:destroy_all_editor_objects()
	
	menu_binds:bind("Escape", function()
		if menu.enabled then
            menu_binds.modal = false
            menu.enabled = false
        else
            menu_binds.modal = true
            menu.enabled = true
        end
	end)
	menu_binds:bind("Tab", function()
		debug_layer:onKeyPressed()
		debug_binds.modal = debug_layer.enabled
		ticker.enabled = not debug_layer.enabled
	end)
	debug_binds:bind("right", function() ghost.fast = true end, function() ghost.fast = false end)
	debug_binds:unbind("A+g")
	
	speedo.enabled = true
	clock.enabled = true
	compass.enabled = true
	stats.enabled = true
	ch.enabled = true
	editor_interface = nil
	
	debug_layer.enabled = true
	--debug_layer:onKeyPressed()
	debug_binds.modal = true
	ticker.enabled = false
	debug_layer:selectConsole(true)
	
	hud_focus = console
	
	-- gizmo_cb:stop()	
	-- gizmo = nil
	-- gizmo_resize = nil
	-- destroy_gizmo = nil
	-- create_gizmo = nil
	-- gizmo_fade = nil
	
	-- placement_editor = nil
	
	-- unload_resources()
	-- object_all_del()
	--class_all_del()
	-- class_del(`editor/core/arrows/dummy_plane`)
	-- class_del(`editor/core/arrows/arrow_translate`)
	-- class_del(`editor/core/arrows/arrow_scale`)
	-- class_del(`editor/core/arrows/arrow_rotate`)
	-- unload_unused_materials()
	in_editor = false
	GED = nil
	-- console:clear()
	include`/system/welcome_msg.lua`
end