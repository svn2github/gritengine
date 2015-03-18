-------------------- Create editor interface --------------------

-- store all editor interface
editor_interface = {}

-- stores all editor windows
editor_interface.windows = {}

if editor_interface.menubar ~= nil then
    -- editor_interface.menubar.enabled = false
	-- safe_destroy(editor_interface.menubar)
	editor_interface.menubar:destroy()
end

-- Create the menu bar
editor_interface.menubar = gfx_hud_object_add(`hud/MenuBar`, {
	parent=hud_top_left;
	--colour=vector3(0.15, 0.15, 0.15);
	size=vec(20, 26);
	alpha=0.75;
})

editor_interface.menus = {}

function destroy_all_editor_menus()
	editor_interface.menus.fileMenu:destroy()
	editor_interface.menus.editMenu:destroy()
	editor_interface.menus.viewMenu:destroy()
	editor_interface.menus.helpMenu:destroy()
end

if editor_interface.menus.fileMenu ~= nil then destroy_all_editor_menus() end

-- All menus are created and linked to the menu bar:

editor_interface.menus.fileMenu = gfx_hud_object_add(`hud/menu`, {
	items = {
		{
			callback = function()
				GED:new_level()
			end;
			name = "New";
			tip = "Creates a new level";
			icon=`icons/new.png`;
		},
		{
			callback = function() GED:open_level() end;
			name = "Open";
			tip = "Open a level";
			icon=`icons/open.png`;
		},
		{}, -- adds a separator
		{
			callback = function() GED:save_current_level() end;
			name = "Save";
			tip = "Save the current level";
			icon=`icons/save.png`;
		},
		{
			callback = function() GED:save_current_level_as() end;
			name = "Save As";
			tip = "Save as the current level";
			icon=`icons/save_as.png`;
		},
		{}, -- adds a separator
		{
			callback = function()
                -- TODO: prompt if user want to save his work
				exit_editor()
			end;
			name = "Exit";
			tip = "Exit the editor";
			icon=`icons/x.png`;
		},
	};
})

editor_interface.menus.editMenu = gfx_hud_object_add(`hud/menu`, {
	items = {
		{
			callback = function() GED:undo() end;
			name = "Undo";
			tip = "Undo last action";
			icon=`icons/undo.png`;
		},
		{
			callback = function() GED:redo() end;
			name = "Redo";
			tip = "Redo last action";
			icon=`icons/redo.png`;
		},
		{}, -- adds a separator
		{
			callback = function() GED:cut_object() end;
			name = "Cut";
			tip = "Cut selected object";
		},
		{
			callback = function() GED:copy_object() end;
			name = "Copy";
			tip = "Copy selected object";
		},
		{
			callback = function() GED:paste_object() end;
			name = "Paste";
			tip = "Paste object";
		},
		{
			callback = function() if GED.selection ~= nil then GED:duplicate_selection() end end;
			name = "Duplicate";
			tip = "Duplicate current selection";
		},
		{}, -- adds a separator
		{
			callback = function() GED:generate_env_cube(vec(0, 0, 0)) end;
			name = "Gen Env Cubes";
			tip = "Generate and apply env cube";
			icon=`icons/solid.png`;
		},	
		{}, -- adds a separator
		{
			callback = function() GED:editor_settings() end;
			name = "Editor Settings";
			tip = "Open Editor Settings";
			icon=`icons/config.png`;
		},
	};
})

editor_interface.menus.viewMenu = gfx_hud_object_add(`hud/menu`, {
	items = {
		{
			callback = function(self)
				editor_interface.statusbar.enabled = not editor_interface.statusbar.enabled
				self.icon.enabled = editor_interface.statusbar.enabled
			end;
			name = "Show Status bar";
			tip = "Show Status bar";
			icon=`icons/v.png`;
		},		
		{}, -- adds a separator
		{
			callback = function(self)
				GED:open_content_browser()
			end;
			name = "Content browser";
			tip = "Open Content Browser window";
			icon=`icons/content_browser.png`;
		},
		
		{
			callback = function() GED:open_event_editor() end;
			name = "Event Editor";
			tip = "Open Event Editor window";
			icon=`icons/event_editor.png`;
		},
		{
			callback = function() GED:open_object_properties() end;
			name = "Object Properties";
			tip = "Open Object Properties window";
			icon=`icons/properties.png`;
		},
		{
			callback = function() GED:open_material_editor() end;
			name = "Material Editor";
			tip = "Open Material Editor window";
			icon=`icons/material_editor.png`;
		},
		{
			callback = function() GED:open_level_properties() end;
			name = "Level properties";
			tip = "Open Level Properties window";
			icon=`icons/level_config.png`;
		},
		{
			callback = function() GED:open_outliner() end;
			name = "Outliner";
			tip = "Open Outliner window";
			icon=`icons/properties.png`;
		},		
		-- {
			-- callback = function() GED:open_object_editor() end;
			-- name = "Object Editor";
			-- tip = "Open object editor window";
			-- icon=`icons/object_editor.png`;
		-- },
		{}, -- adds a separator
		{
			callback = function(self)
				gfx_option("RENDER_SKY", not gfx_option("RENDER_SKY"))
				self.icon.enabled = gfx_option("RENDER_SKY")
			end;
			name = "Render Sky";
			tip = "Toggle render sky";
			icon=`icons/v.png`;
		},
		{
			callback = function(self)
				lens_flare.enabled = not lens_flare.enabled
				self.icon.enabled = lens_flare.enabled
			end;
			name = "Show Lensflare";
			tip = "Toggle lensflare";
			icon=`icons/v.png`;
		},
		{
			callback = function(self)
				gfx_option("FULLSCREEN", not gfx_option("FULLSCREEN"))
				self.icon.enabled = gfx_option("FULLSCREEN")
				-- if gfx_option("FULLSCREEN") then
					-- self.item.text.text="Exit Fullscreen"
				-- else
					-- self.item.text.text="Fullscreen"
				-- end
			end;
			name = "Fullscreen";
			tip = "Toggle fullscreen";
			icon=`icons/v.png`;
			icon_enabled = gfx_option("FULLSCREEN");
		},
	};
})

editor_interface.menus.gameMenu = gfx_hud_object_add(`hud/menu`, {
	items = {
		{
			callback = function() GED:play() end;
			name = "Play";
			tip = "Play on viewport";
			icon=`icons/controller.png`;
		},
		{
			callback = function() end;
			name = "Simulate";
			tip = "Simulates the game but keep editing";
			icon=`icons/play_window.png`;
		},		
		{}, -- adds a separator
		{
			callback = function() GED:run_game() end;
			name = "Run game";
			tip = "Run game in a new window";
			icon=`icons/play.png`;
		},
	};
})

editor_interface.menus.helpMenu = gfx_hud_object_add(`hud/menu`, {
	items = {
		{
			callback = function() os.execute("start http://gritengine.com/grit_book/") end;
			name = "Grit Book";
			tip = "Opens Grit Book page";
			-- icon=`icons/help.png`;
		},
		{}, -- adds a separator
		{
			callback = function() os.execute("start http://gritengine.com/game-engine-forum/") end;
			name = "Grit forums";
			tip = "Opens Grit forums page";
			-- icon=`icons/help.png`;
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/game-engine-wiki/HomePage") end;
			name = "Grit wiki";
			tip = "Opens Grit Wiki page";
			-- icon=`icons/help.png`;
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/chat") end;
			name = "Grit IRC";
			tip = "Opens Grit IRC page";
			-- icon=`icons/help.png`;
		},
		{}, -- adds a separator
		{
			callback = function() os.execute("start http://gritengine.com/game-engine-forum/viewtopic.php?p=5344#p5344") end;
			name = "Grit Editor Help";
			tip = "Grit Editor Help";
			icon=`icons/help.png`;
		},
		{
			callback = function() os.execute("start http://www.gritengine.com/") end;
			name = "About";
			tip = "About Grit Editor";
			-- icon=`icons/help.png`;
		},
	};
})

editor_interface.menubar:append(editor_interface.menus.fileMenu, "File")
editor_interface.menubar:append(editor_interface.menus.editMenu, "Edit")
editor_interface.menubar:append(editor_interface.menus.viewMenu, "View")
editor_interface.menubar:append(editor_interface.menus.gameMenu, "Game")
editor_interface.menubar:append(editor_interface.menus.helpMenu, "Help")


if editor_interface.toolbar ~= nil then
	editor_interface.toolbar:destroy()
end

-- Toolbar
editor_interface.toolbar = gfx_hud_object_add(`hud/ToolBar`, {
	parent=hud_top_left;
	colour=vector3(0.15, 0.15, 0.15);
	--alpha=0.75;
	alpha=0;
	zOrder = 5;
})

-- Add tools to the tool bar
-- addTool(Name, texture, callback, tip)
editor_interface.toolbar:addTool("New", `icons/new.png`, (function(self) GED:new_level() end), "Create new level")
editor_interface.toolbar:addTool("Open", `icons/open.png`, (function(self) GED:open_level() end), "")
editor_interface.toolbar:addTool("Save", `icons/save.png`, (function(self) GED:save_current_level() end), "")
editor_interface.toolbar:addTool("Save As", `icons/save_as.png`, (function(self) GED:save_current_level_as() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Undo", `icons/undo.png`, (function(self) GED:undo() end), "")
editor_interface.toolbar:addTool("Redo", `icons/redo.png`, (function(self) GED:redo() end), "")
editor_interface.toolbar:addSeparator()

widget_menu = {}

widget_menu[0] = editor_interface.toolbar:addTool("Select", `icons/select.png`, (function(self)
	-- GED:set_widget_mode(0)
end), "")

widget_menu[1] = editor_interface.toolbar:addTool("Translate", `icons/translate.png`, (function(self)
	GED:set_widget_mode(1)
end), "")

widget_menu[2] = editor_interface.toolbar:addTool("Rotate", `icons/rotate.png`, (function(self)
	GED:set_widget_mode(2)
end), "")

widget_menu[3] = editor_interface.toolbar:addTool("Scale", `icons/scale.png`, (function(self)
	GED:set_widget_mode(3)
end), "")

editor_interface.toolbar:addTool("Local, global", `icons/global.png`, (function(self)
	if self.mode == nil then
		self.mode = "global"
	end
	
	if self.mode == "global" then
		self.texture = `icons/local.png`
		self.mode = "local"
		widget_manager.translate_mode = "local"
	else
		self.texture = `icons/global.png`
		self.mode = "global"
		widget_manager.translate_mode = "global"
	end
end), "")

-- editor_interface.toolbar:addSeparator()
-- editor_interface.toolbar:addTool("Pivot", `icons/pivot_centre.png`, (function(self)  end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Controller", `icons/controller.png`, (function(self) GED:play() end), "")
--editor_interface.toolbar:addTool("Play", `icons/play.png`, (function(self) GED:simulate() end), "")
--editor_interface.toolbar:addTool("Stop", `icons/stop.png`, (function(self) GED:stop_simulate() end), "")
--editor_interface.toolbar:addTool("Play Window", `icons/play_window.png`, (function(self) run_game() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Toggle Postprocessing", `icons/toggle_postprocess.png`,(
	function(self)
		gfx_option("POST_PROCESSING", not gfx_option("POST_PROCESSING"))
	end
), "")
editor_interface.toolbar:addTool("Solid mode", `icons/solid.png`, (function(self) gfx_option("WIREFRAME", false) end), "")
editor_interface.toolbar:addTool("Wireframe mode", `icons/wireframe.png`, (function(self) gfx_option("WIREFRAME_SOLID", true)  gfx_option("WIREFRAME", true) end), "")
editor_interface.toolbar:addTool("Solid Wireframe Mode", `icons/solid_wireframe.png`, (function(self) gfx_option("WIREFRAME_SOLID", false) gfx_option("WIREFRAME", true) end), "")
editor_interface.toolbar:addSeparator()
-- editor_interface.toolbar:addTool("Object properties", `icons/properties.png`, (function(self) GED:open_object_properties() end), "")
-- editor_interface.toolbar:addTool("Object Editor", `icons/object_editor.png`, (function(self) GED:open_object_editor() end), "")
-- editor_interface.toolbar:addTool("Content Browser", `icons/content_browser.png`, (function(self) GED:open_content_browser() end), "")
-- editor_interface.toolbar:addTool("Event Editor", `icons/event_editor.png`, (function(self) GED:open_event_editor() end), "")
-- editor_interface.toolbar:addTool("Material Editor", `icons/material_editor.png`, (function(self) GED:open_material_editor() end), "")
-- editor_interface.toolbar:addTool("Level Configuration", `icons/level_config.png`, (function(self) GED:open_level_properties() end), "")
-- editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Show collision", `icons/show_collision.png`, (
	function()
		debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame
	end
), "")
editor_interface.toolbar:addTool("Toggle Physics", `icons/toggle_physics.png`, (
	function (self)
		main.physicsEnabled = not main.physicsEnabled
		-- if main.physicsEnabled then
			-- self.colour = self.activeColour
			-- self.selected = true
		-- else
			-- self.colour = self.defaultColour
			-- self.selected = false
		-- end
	end
), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Editor Settings", `icons/config.png`, (function(self) GED:editor_settings() end), "")

if left_toolbar ~= nil then
	safe_destroy(left_toolbar)
	for i = 1, 4 do
		safe_destroy(left_toolbar.buttons[i])
	end
end

left_toolbar = gfx_hud_object_add(`/common/hud/Rect`, {alpha = 0, size=vec(0, 0), position = vec(-35, 0), orientation = 90, parent=debug_layer.consoleButton })
left_toolbar.buttons = {}

left_toolbar.buttons[1] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:open_object_properties()
	end;
	texture = `icons/properties.png`;
	tip="";
	position=vec2(0, -30);
	parent = left_toolbar;
	alpha = 0.3;
})

left_toolbar.buttons[2] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:open_content_browser()
	end;
	texture = `icons/content_browser.png`;
	tip="";
	position=vec2(0, -60);
	parent = left_toolbar;
})

left_toolbar.buttons[3] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:open_event_editor()
	end;
	texture = `icons/event_editor.png`;
	tip="";
	position=vec2(0, -90);
	parent = left_toolbar;
	alpha = 0.3;
})

left_toolbar.buttons[4] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:open_level_properties()
	end;
	texture = `icons/level_config.png`;
	tip="";
	position=vec2(0, -120);
	parent = left_toolbar;
})


-- Status bar
if editor_interface.statusbar ~= nil then editor_interface.statusbar:destroy() end
editor_interface.statusbar = gfx_hud_object_add(`hud/StatusBar`, { parent=hud_bottom_left, size=vec(0, 20) })

-- Windows
function destroy_all_editor_windows()
	editor_interface.windows.content_browser = safe_destroy(editor_interface.windows.content_browser)
	editor_interface.windows.event_editor = safe_destroy(editor_interface.windows.event_editor)
	editor_interface.windows.level_properties = safe_destroy(editor_interface.windows.level_properties)
	editor_interface.windows.material_editor = safe_destroy(editor_interface.windows.material_editor)
	editor_interface.windows.object_editor = safe_destroy(editor_interface.windows.object_editor)
	editor_interface.windows.object_properties = safe_destroy(editor_interface.windows.object_properties)
	editor_interface.windows.outliner = safe_destroy(editor_interface.windows.outliner)
	editor_interface.windows.settings = safe_destroy(editor_interface.windows.settings)
end
if editor_interface.windows.content_browser ~= nil then
	destroy_all_editor_windows()
end

editor_interface.windows.content_browser = create_window('Content Browser', vec2(editor_interface_cfg.content_browser.position[1], editor_interface_cfg.content_browser.position[2]), false, vec2(editor_interface_cfg.content_browser.size[1], editor_interface_cfg.content_browser.size[2]), vec2(640, 365), vec2(800, 600))
include`windows/content_browser.lua`
editor_interface.windows.event_editor = create_window('Event Editor', vec2(editor_interface_cfg.event_editor.position[1], editor_interface_cfg.event_editor.position[2]), true, vec2(editor_interface_cfg.event_editor.size[1], editor_interface_cfg.event_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.level_properties = create_window('Level Properties', vec2(editor_interface_cfg.level_properties.position[1], editor_interface_cfg.level_properties.position[2]), true, vec2(editor_interface_cfg.level_properties.size[1], editor_interface_cfg.level_properties.size[2]), vec2(380, 225), vec2(800, 600))
include`windows/level_properties.lua`
editor_interface.windows.material_editor = create_window('Material Editor', vec2(editor_interface_cfg.material_editor.position[1], editor_interface_cfg.material_editor.position[2]), true, vec2(editor_interface_cfg.material_editor.size[1], editor_interface_cfg.material_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.object_editor = create_window('Object Editor', vec2(editor_interface_cfg.object_editor.position[1], editor_interface_cfg.object_editor.position[2]), true, vec2(editor_interface_cfg.object_editor.size[1], editor_interface_cfg.object_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.object_properties = create_window('Properties', vec2(editor_interface_cfg.object_properties.position[1], editor_interface_cfg.object_properties.position[2]), true, vec2(editor_interface_cfg.object_properties.size[1], editor_interface_cfg.object_properties.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.outliner = create_window('Outliner', vec2(editor_interface_cfg.outliner.position[1], editor_interface_cfg.outliner.position[2]), true, vec2(editor_interface_cfg.outliner.size[1], editor_interface_cfg.outliner.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.settings = create_window('Editor Settings', vec2(editor_interface_cfg.settings.position[1], editor_interface_cfg.settings.position[2]), true, vec2(editor_interface_cfg.settings.size[1], editor_interface_cfg.settings.size[2]), vec2(350, 200), vec2(800, 600))

editor_interface.windows.content_browser.enabled = editor_interface_cfg.content_browser.opened
editor_interface.windows.event_editor.enabled = editor_interface_cfg.event_editor.opened
editor_interface.windows.level_properties.enabled = editor_interface_cfg.level_properties.opened
editor_interface.windows.material_editor.enabled = editor_interface_cfg.material_editor.opened
editor_interface.windows.object_editor.enabled = editor_interface_cfg.object_editor.opened
editor_interface.windows.object_properties.enabled = editor_interface_cfg.object_properties.opened
editor_interface.windows.outliner.enabled = editor_interface_cfg.outliner.opened
editor_interface.windows.settings.enabled = editor_interface_cfg.settings.opened

-- not working tools
editor_interface.toolbar.tools[5].alpha = 0.3
editor_interface.toolbar.tools[6].alpha = 0.3
editor_interface.toolbar.tools[7].alpha = 0.3
editor_interface.toolbar.tools[10].alpha = 0.3
editor_interface.toolbar.tools[11].alpha = 0.3
editor_interface.toolbar.tools[19].alpha = 0.3
