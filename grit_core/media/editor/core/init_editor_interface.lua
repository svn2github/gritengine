-------------------- Create editor interface --------------------

-- store all editor interface
editor_interface = {}

-- stores all editor windows
editor_interface.windows = {}

if editor_interface.menubar ~= nil then
    safe_destroy(editor_interface.menubar)
end

-- Create the menu bar
editor_interface.menubar = gfx_hud_object_add("/editor/core/hud/MenuBar", {
	parent=hud_top_left;
	colour=vector3(0.15, 0.15, 0.15);
	alpha=0.75;
})

-- encapsulate all menus
editor_interface.menus = {}

if editor_interface.menus.fileMenu ~= nil then
    safe_destroy(editor_interface.menus.fileMenu)
	safe_destroy(editor_interface.menus.editMenu)
	safe_destroy(editor_interface.menus.viewMenu)
	safe_destroy(editor_interface.menus.helpMenu)
end

-- All menus are created and linked to the menu bar:

editor_interface.menus.fileMenu = gfx_hud_object_add("/editor/core/hud/menu", {
	items = {
		{
			callback = function()
				new_level()
			end;
			name = "New";
			tip = "Creates a new level"
		},
		{
			callback = function() open_level() end;
			name = "Open";
			tip = "Open a level"		
		},
		{}, -- adds a separator
		{
			callback = function() save_current_level() end;
			name = "Save";
			tip = "Save the current level"		
		},
		{
			callback = function() save_current_level_as() end;
			name = "Save As";
			tip = "Save as the current level"		
		},
		{}, -- adds a separator
		{
			callback = function() close_level() end;
			name = "Close";
			tip = "Close the current level"		
		},
		{}, -- adds a separator
		{
			callback = function()
				exit_editor()
			end;
			name = "Exit";
			tip = "Exit the editor"		
		},
	};
})

editor_interface.menus.editMenu = gfx_hud_object_add("/editor/core/hud/menu", {
	items = {
		{
			callback = function() undo() end;
			name = "Undo";
			tip = "Undo last action";
		},
		{
			callback = function() redo() end;
			name = "Redo";
			tip = "Redo last action";
		},
		{}, -- adds a separator
		{
			callback = function() cut_object() end;
			name = "Cut";
			tip = "Cut selected object";
		},
		{
			callback = function() copy_object() end;
			name = "Copy";
			tip = "Copy selected object";
		},
		{
			callback = function() paste_object() end;
			name = "Paste";
			tip = "Paste object";
		},
		{
			callback = function() duplicate_selection() end;
			name = "Duplicate";
			tip = "Duplicate current selection";
		},
		{}, -- adds a separator
		{
			callback = function() generate_env_cube() end;
			name = "Gen Env Cube";
			tip = "Generate and apply env cube";
		},	
		{}, -- adds a separator
		{
			callback = function() editor_settings() end;
			name = "Editor Settings";
			tip = "Open Editor Settings";
		},
	};
})

editor_interface.menus.viewMenu = gfx_hud_object_add("/editor/core/hud/menu", {
	items = {
		{
			callback = function() debug_layer:selectConsole(not console.enabled) end;
			name = "Show console";
			tip = "Show console"
		},
		{
			callback = function()
				editor_interface.statusbar.enabled = not editor_interface.statusbar.enabled
			end;
			name = "Show Status bar";
			tip = "Show Status bar"		
		},		
		{}, -- adds a separator
		{
			callback = function(self)
				open_content_browser()
			end;
			name = "Content browser";
			tip = "Open Content Browser window"		
		},
		
		{
			callback = function() open_graph_editor() end;
			name = "Graph Editor";
			tip = "Open Graphical Editor window"		
		},
		{
			callback = function() open_object_properties() end;
			name = "Object Properties";
			tip = "Open Object Properties window"		
		},
		{
			callback = function() open_material_editor() end;
			name = "Material Editor";
			tip = "Open Material Editor window"		
		},
		{
			callback = function() open_level_properties() end;
			name = "Level properties";
			tip = "Open Level Properties window"		
		},
		{
			callback = function() open_outliner() end;
			name = "Outliner";
			tip = "Open Outliner window"		
		},		
		{
			callback = function() open_object_editor() end;
			name = "Object Editor";
			tip = "Open object editor window"		
		},
		{}, -- adds a separator
		{
			callback = function()
				gfx_option("RENDER_SKY", not gfx_option("RENDER_SKY"))
			end;
			name = "Render Sky";
			tip = "Toggle render sky"		
		},
		{
			callback = function()
				lens_flare.enabled = not lens_flare.enabled
			end;
			name = "Show Lensflare";
			tip = "Toggle lensflare"		
		},
		{
			callback = function(self)
				gfx_option("FULLSCREEN", not gfx_option("FULLSCREEN"))
				-- if gfx_option("FULLSCREEN") then
					-- self.item.text.text="Exit Fullscreen"
				-- else
					-- self.item.text.text="Fullscreen"
				-- end
			end;
			name = "Fullscreen";
			tip = "Toggle fullscreen"		
		},
	};
})

editor_interface.menus.gameMenu = gfx_hud_object_add("/editor/core/hud/menu", {
	items = {
		{
			callback = editor_play;
			name = "Play";
			tip = "Play on viewport"
		},
		{
			callback = function() end;
			name = "Simulate";
			tip = "Simulates the game but keep editing"		
		},		
		{}, -- adds a separator
		{
			callback = function() run_game() end;
			name = "Run game";
			tip = "Run game in a new window"		
		},
	};
})

editor_interface.menus.helpMenu = gfx_hud_object_add("/editor/core/hud/menu", {
	items = {
		{
			callback = function() os.execute("start http://gritengine.com/grit_book/") end;
			name = "Grit Book";
			tip = "Opens Grit Book page"
		},
		{}, -- adds a separator
		{
			callback = function() os.execute("start http://gritengine.com/game-engine-forum/") end;
			name = "Grit forums";
			tip = "Opens Grit forums page"		
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/game-engine-wiki/HomePage") end;
			name = "Grit wiki";
			tip = "Opens Grit Wiki page"		
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/chat") end;
			name = "Grit IRC";
			tip = "Opens Grit IRC page"		
		},
		{}, -- adds a separator
		{
			callback = function() os.execute("start editor/NOTES.rtf") end;
			name = "Grit Editor Help";
			tip = "Grit Editor Help"		
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/") end;
			name = "About";
			tip = "About Grit Editor"		
		},
	};
})

editor_interface.menubar:append(editor_interface.menus.fileMenu, "File")
editor_interface.menubar:append(editor_interface.menus.editMenu, "Edit")
editor_interface.menubar:append(editor_interface.menus.viewMenu, "View")
editor_interface.menubar:append(editor_interface.menus.gameMenu, "Game")
editor_interface.menubar:append(editor_interface.menus.helpMenu, "Help")


if editor_interface.toolbar ~= nil then
    safe_destroy(editor_interface.toolbar)
end

-- Create the toolbar
editor_interface.toolbar = gfx_hud_object_add("/editor/core/hud/ToolBar", {
	parent=hud_top_left;
	colour=vector3(0.15, 0.15, 0.15);
	--alpha=0.75;
	alpha=0;
	zOrder = 5;
})

-- Add tools to the tool bar
-- addTool(Name, texture, callback, tip)
editor_interface.toolbar:addTool("New", "/editor/core/icons/new.png", (function(self) new_level() end), "Create new level")
editor_interface.toolbar:addTool("Open", "/editor/core/icons/open.png", (function(self) open_level() end), "")
editor_interface.toolbar:addTool("Save", "/editor/core/icons/save.png", (function(self) save_current_level() end), "")
editor_interface.toolbar:addTool("Save As", "/editor/core/icons/save_as.png", (function(self) save_current_level_as() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Undo", "/editor/core/icons/undo.png", (function(self) undo() end), "")
editor_interface.toolbar:addTool("Redo", "/editor/core/icons/redo.png", (function(self) redo() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Select", "/editor/core/icons/select.png", (function(self) editor.selection.mode = 0 end), "")
editor_interface.toolbar:addTool("Translate", "/editor/core/icons/translate.png", (function(self) editor.selection.mode = 1 end), "")
editor_interface.toolbar:addTool("Rotate", "/editor/core/icons/rotate.png", (function(self) editor.selection.mode = 2 end), "")
editor_interface.toolbar:addTool("Scale", "/editor/core/icons/scale.png", (function(self) editor.selection.mode = 3 end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Pivot", "/editor/core/icons/pivot_centre.png", (function(self)  end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Controller", "/editor/core/icons/controller.png", (function(self) editor_play() end), "")
editor_interface.toolbar:addTool("Play", "/editor/core/icons/play.png", (function(self) simulate_game() end), "")
editor_interface.toolbar:addTool("Stop", "/editor/core/icons/stop.png", (function(self) stop_simulate_game() end), "")
editor_interface.toolbar:addTool("Play Window", "/editor/core/icons/play_window.png", (function(self) run_game() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Toggle Postprocessing", "/editor/core/icons/toggle_postprocess.png",(
	function(self)
		if gfx_option("POST_PROCESSING") then
			gfx_option("POST_PROCESSING", false)
		else
			gfx_option("POST_PROCESSING", true)
		end
	end
), "")
editor_interface.toolbar:addTool("Solid mode", "/editor/core/icons/solid.png", (function(self) gfx_option("WIREFRAME", false) end), "")
editor_interface.toolbar:addTool("Wireframe mode", "/editor/core/icons/wireframe.png", (function(self) gfx_option("WIREFRAME_SOLID", true)  gfx_option("WIREFRAME", true) end), "")
editor_interface.toolbar:addTool("Solid Wireframe Mode", "/editor/core/icons/solid_wireframe.png", (function(self) gfx_option("WIREFRAME_SOLID", false) gfx_option("WIREFRAME", true) end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Object properties", "/editor/core/icons/properties.png", (function(self) open_object_properties() end), "")
editor_interface.toolbar:addTool("Object Editor", "/editor/core/icons/object_editor.png", (function(self) open_object_editor() end), "")
editor_interface.toolbar:addTool("Content Browser", "/editor/core/icons/content_browser.png", (function(self) open_content_browser() end), "")
editor_interface.toolbar:addTool("Graph Editor", "/editor/core/icons/graph_editor.png", (function(self) open_graph_editor() end), "")
editor_interface.toolbar:addTool("Material Editor", "/editor/core/icons/material_editor.png", (function(self) open_material_editor() end), "")
editor_interface.toolbar:addTool("Level Configuration", "/editor/core/icons/level_config.png", (function(self) open_level_properties() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Show collision", "/editor/core/icons/show_collision.png", (
	function()
		debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame
	end
), "")
editor_interface.toolbar:addTool("Toggle Physics", "/editor/core/icons/toggle_physics.png", (
	function ()
		physics.enabled = not physics.enabled
		print("Physics enabled: "..tostring(physics.enabled))
	end
), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Editor Settings", "/editor/core/icons/config.png", (function(self) editor_settings() end), "")

-- Status bar
if editor_interface.statusbar ~= nil then
    safe_destroy(editor_interface.statusbar)
end

editor_interface.statusbar = gfx_hud_object_add('/editor/core/hud/StatusBar', { parent=hud_bottom_left, size=vec(0, 20) })


-- Content Browser
if editor_interface.windows.content_browser ~= nil then
	safe_destroy(editor_interface.windows.content_browser)
end

editor_interface.windows.content_browser = gfx_hud_object_add('/editor/core/hud/Window', { title="Content Browser", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.content_browser.opened ~= true then
	editor_interface.windows.content_browser.enabled = false
end

-- Graph Editor
if editor_interface.windows.graph_editor ~= nil then
	safe_destroy(editor_interface.windows.graph_editor)
end

editor_interface.windows.graph_editor = gfx_hud_object_add('/editor/core/hud/Window', { title="Graph Editor", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.graph_editor.opened ~= true then
	editor_interface.windows.graph_editor.enabled = false
end

-- Object Properties
if editor_interface.windows.object_properties ~= nil then
	safe_destroy(editor_interface.windows.object_properties)
end

editor_interface.windows.object_properties = gfx_hud_object_add('/editor/core/hud/Window', { title="Properties", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.object_properties.opened ~= true then
	editor_interface.windows.object_properties.enabled = false
end

-- Material Editor
if editor_interface.windows.material_editor ~= nil then
	safe_destroy(editor_interface.windows.material_editor)
end

editor_interface.windows.material_editor= gfx_hud_object_add('/editor/core/hud/Window', { title="Material Editor", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.material_editor.opened ~= true then
	editor_interface.windows.material_editor.enabled = false
end

-- Level Properties
if editor_interface.windows.level_properties ~= nil then
	safe_destroy(editor_interface.windows.level_properties)
end

editor_interface.windows.level_properties = gfx_hud_object_add('/editor/core/hud/Window', { title="Level Properties", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.level_properties.opened ~= true then
	editor_interface.windows.level_properties.enabled = false
end

-- Outliner
if editor_interface.windows.outliner~= nil then
	safe_destroy(editor_interface.windows.outliner)
end

editor_interface.windows.outliner = gfx_hud_object_add('/editor/core/hud/Window', { title="Outliner", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.outliner.opened ~= true then
	editor_interface.windows.outliner.enabled = false
end

-- Editor Settings
if editor_interface.windows.settings ~= nil then
	safe_destroy(editor_interface.windows.settings)
end

editor_interface.windows.settings = gfx_hud_object_add('/editor/core/hud/Window', { title="Editor Settings", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.settings.opened ~= true then
	editor_interface.windows.settings.enabled = false
end

-- Object Editor
if editor_interface.windows.object_editor ~= nil then
	safe_destroy(editor_interface.windows.object_editor)
end

editor_interface.windows.object_editor = gfx_hud_object_add('/editor/core/hud/Window', { title="Object Editor", parent=hud_center,  position=vec2(0, 0)})

if editor_interface_cfg.object_editor.opened ~= true then
	editor_interface.windows.object_editor.enabled = false
end