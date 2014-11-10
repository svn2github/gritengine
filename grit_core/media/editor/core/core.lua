-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-------------------- Editor functions --------------------

include "placement_editor.lua"
include "GritLevel/init.lua"
include "thumbnail_manager.lua"
include "arrows/init.lua"

function select_obj ()
	if editor.selected.instance ~= nil and editor.selected.instance.gfx ~= nil  then
		editor.selected.instance.gfx.wireframe = false
	end
	editor.selected = pick_obj()
	editor.selected.instance.gfx.wireframe = true
	if editor_interface.statusbar.enabled then
		editor_interface.statusbar.selected.text = "Selected: "..editor.selected.name
	end
end

function unselect_obj ()
	placement_editor.handledObj = nil
	if editor.selected.instance ~= nil then
		editor.selected.instance.gfx.wireframe = false
	end
	if editor_interface.statusbar.enabled then
		editor_interface.statusbar.selected.text = "Selected: none"
	end
end

-- NOT TESTED W.I.P.
-- Update Object Properties window when another object in viewport is selected
function update_properties ()
	editor.windows.properties.posx = editor.selected.instance.body.worldPosition.x
	editor.windows.properties.posy = editor.selected.instance.body.worldPosition.y
	editor.windows.properties.posz = editor.selected.instance.body.worldPosition.z
	
	editor.windows.properties.rotw = editor.selected.instance.body.worldOrientation.w
	editor.windows.properties.rotx = editor.selected.instance.body.worldOrientation.x
	editor.windows.properties.roty = editor.selected.instance.body.worldOrientation.y
	editor.windows.properties.rotz = editor.selected.instance.body.worldOrientation.z
end
-- NOT TESTED W.I.P.
function set_camera_move()
end

function set_spawn_point(pos)
	CurrentLevel.spawn_pos = pos or pick_pos() or CurrentLevel.spawn_pos
end

function return_editor()
	
	editor_interface.menubar.enabled=true
	editor_interface.toolbar.enabled=true
	editor_interface.statusbar.enabled=true
	game:stop()
	
	toggle_console()

	set_editor_bindings()	

	player_ctrl.camPos = editor_camera.pos
	player_ctrl.camYaw = editor_camera.rot.Yaw
	player_ctrl.camPitch = editor_camera.rot.Pitch
	player_ctrl.camDir = editor_camera.rot.Dir
end

function mouse_pick_object()
	local ms = vec2((select(3, get_mouse_events()) ), (select(4, get_mouse_events())))
	local selected = gfx_mouse_pick(ms.x, ms.y, player_ctrl.camPos, player_ctrl.camDir)
	if selected ~= nil then
		if selected.arrow ~= nil then
			if selected.name == "arrow_x" then
				editor.selection.dragging = "x"
			elseif selected.name == "arrow_y" then
				editor.selection.dragging = "y"
			elseif selected.name == "arrow_z" then
				editor.selection.dragging = "z"
			elseif selected.name == "dummy_xy" then
				editor.selection.dragging = "xy"
			elseif selected.name == "arrow_xz" then
				editor.selection.dragging = "xz"
			elseif selected.name == "arrow_yz" then
				editor.selection.dragging = "yz"
			else
				print(RED.."something strange is happening..")
			end
		else
			gizmo.node:activate()
			
			-- deactivate object physics when selected
			if selected.instance.body ~= nil then
				editor.selected.mass = selected.instance.body.mass
				selected.instance.body.mass = 0
			end
			selected.instance.gfx.parent = gizmo.node
			
			editor.selected = selected
		end
	else
		editor.selection.dragging = nil
		if selected.instance.body ~= nil then
			selected.instance.body.mass = editor.selected.mass
			editor.selected.mass = nil
		end
		editor.selected = nil
	end
end

function set_editor_bindings()
	menu_binds:bind("Escape", function() do_nothing() end)
	common_binds:bind("i", function() end)
	common_binds:bind("k", function() end)
	common_binds:bind("=", function() end)
	common_binds:bind("-", function() end)
	
	common_binds:bind("Delete", function() delete_selection() end)
	common_binds:bind("C+d", function() duplicate_selection() end)
	
	debug_binds:bind("A+g", function() editor_play()end)
	
	menu_binds:bind("Tab", function() debug_layer:selectConsole(not console.enabled) end)
	
	-- PROBLEM: how we can disable object selection when left mouse click is under a HUD object?
	--debug_binds:bind("left", function() mouse_pick_object()end, function() editor.selection.dragging = nil end)
	
	debug_binds:bind("right", function() debug_binds.modal = not debug_binds.modal
		debug_layer:selectConsole()
		debug_binds:bind("Shift", function() ghost.fast = true end, function() ghost.fast = false end)
		ghost.fast = false
	end, function()
	debug_binds.modal = not debug_binds.modal
		debug_binds:unbind("Shift")
	end)
end

function set_game_bindings()
	menu_binds:bind("Escape", function() return_editor() end)
	menu_binds:bind("Tab", function() return_editor() end)
	debug_binds:unbind("right")
	debug_binds:bind("A+g", function() return_editor() end)
	--common_binds:bind("left", function() game:fire() end)
	--common_binds:bind("right", function() game:aim() end)
	--common_binds:bind("f5", function() do_nothing() end)	
end

-- NOT TESTED W.I.P.
function add_object(obj_class, pos, rotation, obj_name)
	editor.objects[#editor.objects] = object obj_class (pos) { rot=rotation, name=obj_name }
end
-- NOT TESTED W.I.P.
function remove_object(obj)
	for i = 0, #editor.objects do
		if editor.objects[i] == obj then
			safe_destroy(editor.objects[i])
			editor.objects[i] = nil
			return true
		end
	end
	return false
end

function generate_env_cube()
	math.randomseed(os.clock())
	local tex = editor.directory.."/cache/env/".."myenv"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, vector3(0.0, 0.0, 7.0), 0.7, vector3(0.0, 0.0, 0.0))
	gfx_env_cube("/"..tex)
	CurrentLevel.env_cube = tex
end

function toggle_console()
	debug_layer:onKeyPressed()
	debug_binds.modal = debug_layer.enabled
	ticker.enabled = not debug_layer.enabled
end;

------- Interface functions: -------

function new_level()
	unselect_obj ()
	create_gizmo(editor.selection.mode)
	gizmo_fade(0)
	if next(CurrentLevel) ~= nil then
		object_all_del()
		-- CurrentLevel = nil
	end
	CurrentLevel = GritLevel.new()
	CurrentLevel.spawn_pos = vector3(0, 0, 0)
	CurrentLevel:load_game_mode()
end

function open_level(level_file)
	-- actually doesn't work
	if gfx_option("FULLSCREEN") == true then
		gfx_option("FULLSCREEN", false)
	end
	
	unselect_obj ()
	create_gizmo(editor.selection.mode)
	gizmo_fade(0)
	
	if level_file == nil then
		local file = open_file_dialog("Open Level", "Grit Level (*.lvl)\0*.lvl\0Grit Lua (*.lua)\0*.lua\0\0")
		if file == nil then
			return
		end
		local cdir = io.popen"cd":read'*l'
		cdir = cdir:gsub([[\\]], "/")
		file = file:gsub([[\\]], "/")
		file = file:gsub(cdir, "")
		level_file = file:gsub("/", "", 1)
	end
	CurrentLevel = nil
	CurrentLevel = GritLevel.new()
	
	CurrentLevel:open(level_file)
	CurrentLevel:load_game_mode()
end

function save_current_level()
	if #CurrentLevel.file_name > 0 then
		CurrentLevel:save()
	else
		--error("Problem saving level, the file name especified is empy. Try set it manually: CurrentLevel.file_name = 'yourlevelname.lvl'")
		save_current_level_as()
	end
end

function save_current_level_as(name)
	if gfx_option("FULLSCREEN") == true then
		gfx_option("FULLSCREEN", false)
	end
	if name == nil then
		CurrentLevel.file_name = save_file_dialog("Save Level", "Grit Level (*.lvl)\0*.lvl\0\0", "lvl")
	else
		CurrentLevel.file_name = name
	end
	if CurrentLevel.file_name ~= nil then
		CurrentLevel:save()
	end
end

function close_level()
	unselect_obj ()
	object_all_del()
	-- CurrentLevel = nil
	CurrentLevel = GritLevel.new()
	CurrentLevel.spawn_pos = vector3(0, 0, 0)
end

function delete_selection()
	unselect_obj ()
	placement_editor.handledObj = nil

	safe_destroy(editor.selected)
	editor.selected = {}
end

function duplicate_selection()
	object (editor.selected.className) (editor.selected.instance.body.worldPosition) {rot=editor.selected.instance.body.worldOrientation}
end

function exit_editor()
	-- TODO: prompt if user want to save his work
	close_level()
	safe_destroy(editor_interface.toolbar)
	safe_destroy(editor_interface.menubar)
	safe_destroy(editor_interface.statusbar)
	set_game_bindings()
	in_editor = false
end

function undo()
end

function redo()
end

function cut_object()
end

function copy_object()
end

function paste_object()
end

function duplicate_object()
end

function editor_settings()
	editor_interface.windows.settings.enabled = true
end

function show_console()
	toggle_console()
end

function open_content_browser()
	editor_interface.windows.content_browser.enabled = true
end

function open_graph_editor()
	editor_interface.windows.graph_editor.enabled = true
end

function open_object_properties()
	editor_interface.windows.object_properties.enabled = true
end

function open_material_editor()
	editor_interface.windows.material_editor.enabled = true
end

function open_level_properties()
	editor_interface.windows.level_properties.enabled = true
end

function open_outliner()
	editor_interface.windows.outliner.enabled = true
end

function open_object_editor()
	editor_interface.windows.object_editor.enabled = true
end

function editor_simulate()
end

function run_game()
	if true then
		os.execute("grit.dat")
	else
		os.execute("Grit.linux.x86_64")
	end
end

function editor_play()
	if CurrentLevel.game_mode ~= nil then
		editor_interface.menubar.enabled=false
		editor_interface.toolbar.enabled=false
		editor_interface.statusbar.enabled=false
		
		toggle_console()
		
		editor_camera.pos = player_ctrl.camPos
		editor_camera.rot.Yaw = player_ctrl.camYaw
		editor_camera.rot.Pitch = player_ctrl.camPitch
		editor_camera.rot.Dir = player_ctrl.camDir
		
		set_game_bindings()
		--set_game_mode("tps.lua")
		game:play()
	else
		error("Gameplay mode not defined, define it manualy: CurrentLevel.game_mode='example_game'")
	end
end

function simulate_game()
end
function stop_simulate_game()
end