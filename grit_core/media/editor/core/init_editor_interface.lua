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
	colour=GED.currentTheme.colours.menu_bar.background;
	size=vec(20, 26);
	alpha=GED.currentTheme.colours.menu_bar.background_alpha;
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
				GED:newLevel()
			end;
			name = "New";
			tip = "Creates a new level";
			icon=`icons/new.png`;
		},
		{
			callback = function() GED:openLevel() end;
			name = "Open";
			tip = "Open a level";
			icon=`icons/open.png`;
		},
		{}, -- adds a separator
		{
			callback = function() GED:saveCurrentLevel() end;
			name = "Save";
			tip = "Save the current level";
			icon=`icons/save.png`;
		},
		{
			callback = function() GED:saveCurrentLevelAs() end;
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
			callback = function() GED:cutObject() end;
			name = "Cut";
			tip = "Cut selected object";
		},
		{
			callback = function() GED:copyObject() end;
			name = "Copy";
			tip = "Copy selected object";
		},
		{
			callback = function() GED:pasteObject() end;
			name = "Paste";
			tip = "Paste object";
		},
		{
			callback = function() if GED.selection ~= nil then GED:duplicateSelection() end end;
			name = "Duplicate";
			tip = "Duplicate current selection";
		},
		{}, -- adds a separator
		{
			callback = function() GED:generateEnvCube(vec(0, 0, 0)) end;
			name = "Gen Env Cubes";
			tip = "Generate and apply env cube";
			icon=`icons/solid.png`;
		},	
		{}, -- adds a separator
		{
			callback = function() GED:editorSettings() end;
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
				GED:openContentBrowser()
			end;
			name = "Content browser";
			tip = "Open Content Browser window";
			icon=`icons/content_browser.png`;
		},
		
		{
			callback = function() GED:openEventEditor() end;
			name = "Event Editor";
			tip = "Open Event Editor window";
			icon=`icons/event_editor.png`;
		},
		{
			callback = function() GED:openObjectProperties() end;
			name = "Object Properties";
			tip = "Open Object Properties window";
			icon=`icons/properties.png`;
		},
		{
			callback = function() GED:openMaterialEditor() end;
			name = "Material Editor";
			tip = "Open Material Editor window";
			icon=`icons/material_editor.png`;
		},
		{
			callback = function() GED:openLevelProperties() end;
			name = "Level properties";
			tip = "Open Level Properties window";
			icon=`icons/level_config.png`;
		},
		{
			callback = function() GED:openOutliner() end;
			name = "Outliner";
			tip = "Open Outliner window";
			icon=`icons/properties.png`;
		},		
		-- {
			-- callback = function() GED:openObjectEditor() end;
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
			callback = function() GED:runGame() end;
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
editor_interface.toolbar:addTool("New", `icons/new.png`, (function(self) GED:newLevel() end), "Create new level")
editor_interface.toolbar:addTool("Open", `icons/open.png`, (function(self) GED:openLevel() end), "Open Level")
editor_interface.toolbar:addTool("Save", `icons/save.png`, (function(self) GED:saveCurrentLevel() end), "Save Current Level")
editor_interface.toolbar:addTool("Save As", `icons/save_as.png`, (function(self) GED:saveCurrentLevelAs() end), "Save Level As")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Undo", `icons/undo.png`, (function(self) GED:undo() end), "Undo")
editor_interface.toolbar:addTool("Redo", `icons/redo.png`, (function(self) GED:redo() end), "Redo")
editor_interface.toolbar:addSeparator()

widget_menu = {}

widget_menu[0] = editor_interface.toolbar:addTool("Select", `icons/select.png`, (function(self)
	-- GED:setWidgetMode(0)
end), "Selection Mode")

widget_menu[1] = editor_interface.toolbar:addTool("Translate", `icons/translate.png`, (function(self)
	GED:setWidgetMode(1)
end), "Translate")

widget_menu[2] = editor_interface.toolbar:addTool("Rotate", `icons/rotate.png`, (function(self)
	GED:setWidgetMode(2)
end), "Rotate")

widget_menu[3] = editor_interface.toolbar:addTool("Scale", `icons/scale.png`, (function(self)
	GED:setWidgetMode(3)
end), "Scale")

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
end), "Set Widget Mode Global/Local")

-- editor_interface.toolbar:addSeparator()
-- editor_interface.toolbar:addTool("Pivot", `icons/pivot_centre.png`, (function(self)  end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Controller", `icons/controller.png`, (function(self) GED:play() end), "Play")
--editor_interface.toolbar:addTool("Play", `icons/play.png`, (function(self) GED:simulate() end), "")
--editor_interface.toolbar:addTool("Stop", `icons/stop.png`, (function(self) GED:stopSimulate() end), "")
--editor_interface.toolbar:addTool("Play Window", `icons/play_window.png`, (function(self) runGame() end), "")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Toggle Postprocessing", `icons/toggle_postprocess.png`,(
	function(self)
		gfx_option("POST_PROCESSING", not gfx_option("POST_PROCESSING"))
	end
), "Toggle Postprocessing")
editor_interface.toolbar:addTool("Solid mode", `icons/solid.png`, (function(self) gfx_option("WIREFRAME", false) end), "View Mode: Solid")
editor_interface.toolbar:addTool("Wireframe mode", `icons/wireframe.png`, (function(self) gfx_option("WIREFRAME_SOLID", true)  gfx_option("WIREFRAME", true) end), "View Mode: Wireframe")
editor_interface.toolbar:addTool("Solid Wireframe Mode", `icons/solid_wireframe.png`, (function(self) gfx_option("WIREFRAME_SOLID", false) gfx_option("WIREFRAME", true) end), "View Mode: Solid Wireframe")
editor_interface.toolbar:addSeparator()
-- editor_interface.toolbar:addTool("Object properties", `icons/properties.png`, (function(self) GED:openObjectProperties() end), "")
-- editor_interface.toolbar:addTool("Object Editor", `icons/object_editor.png`, (function(self) GED:openObjectEditor() end), "")
-- editor_interface.toolbar:addTool("Content Browser", `icons/content_browser.png`, (function(self) GED:openContentBrowser() end), "")
-- editor_interface.toolbar:addTool("Event Editor", `icons/event_editor.png`, (function(self) GED:openEventEditor() end), "")
-- editor_interface.toolbar:addTool("Material Editor", `icons/material_editor.png`, (function(self) GED:openMaterialEditor() end), "")
-- editor_interface.toolbar:addTool("Level Configuration", `icons/level_config.png`, (function(self) GED:openLevelProperties() end), "")
-- editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Show collision", `icons/show_collision.png`, (
	function()
		debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame
	end
), "Show Collision")
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
), "Toggle Physics")
editor_interface.toolbar:addSeparator()
editor_interface.toolbar:addTool("Editor Settings", `icons/config.png`, (function(self) GED:editorSettings() end), "Editor Settings")

if left_toolbar ~= nil then
	safe_destroy(left_toolbar)
	for i = 1, 4 do
		safe_destroy(left_toolbar.buttons[i])
	end
end

left_toolbar = gfx_hud_object_add(`/common/hud/Rect`, {alpha = 0, size=vec(0, 0), position = vec(20, -20), orientation = 0, parent=hud_top_left })
left_toolbar.buttons = {}

left_toolbar.buttons[1] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:openObjectProperties()
	end;
	texture = `icons/properties.png`;
	tip="Level Properties";
	position=vec2(0, -30);
	parent = left_toolbar;
	alpha = 0.3;
})

left_toolbar.buttons[2] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:openContentBrowser()
	end;
	texture = `icons/content_browser.png`;
	tip="Content Browser";
	position=vec2(0, -60);
	parent = left_toolbar;
})

left_toolbar.buttons[3] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:openEventEditor()
	end;
	texture = `icons/event_editor.png`;
	tip="Event Editor";
	position=vec2(0, -90);
	parent = left_toolbar;
	alpha = 0.3;
})

left_toolbar.buttons[4] = gfx_hud_object_add(`hud/imagebutton`, {
	pressedCallback = function(self)
		GED:openLevelProperties()
	end;
	texture = `icons/level_config.png`;
	tip="Level Config";
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

editor_interface.windows.content_browser = create_window('Content Browser', vec2(editor_interface_cfg.content_browser.position[1], editor_interface_cfg.content_browser.position[2]), false, vec2(editor_interface_cfg.content_browser.size[1], editor_interface_cfg.content_browser.size[2]), vec2(640, 400), vec2(800, 600))
include`windows/content_browser.lua`
editor_interface.windows.event_editor = create_window('Event Editor', vec2(editor_interface_cfg.event_editor.position[1], editor_interface_cfg.event_editor.position[2]), true, vec2(editor_interface_cfg.event_editor.size[1], editor_interface_cfg.event_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.level_properties = create_window('Level Properties', vec2(editor_interface_cfg.level_properties.position[1], editor_interface_cfg.level_properties.position[2]), true, vec2(editor_interface_cfg.level_properties.size[1], editor_interface_cfg.level_properties.size[2]), vec2(380, 225), vec2(800, 600))
include`windows/level_properties.lua`
editor_interface.windows.material_editor = create_window('Material Editor', vec2(editor_interface_cfg.material_editor.position[1], editor_interface_cfg.material_editor.position[2]), true, vec2(editor_interface_cfg.material_editor.size[1], editor_interface_cfg.material_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.object_editor = create_window('Object Editor', vec2(editor_interface_cfg.object_editor.position[1], editor_interface_cfg.object_editor.position[2]), true, vec2(editor_interface_cfg.object_editor.size[1], editor_interface_cfg.object_editor.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.object_properties = create_window('Properties', vec2(editor_interface_cfg.object_properties.position[1], editor_interface_cfg.object_properties.position[2]), true, vec2(editor_interface_cfg.object_properties.size[1], editor_interface_cfg.object_properties.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.outliner = create_window('Outliner', vec2(editor_interface_cfg.outliner.position[1], editor_interface_cfg.outliner.position[2]), true, vec2(editor_interface_cfg.outliner.size[1], editor_interface_cfg.outliner.size[2]), vec2(350, 200), vec2(800, 600))
editor_interface.windows.settings = create_window('Editor Settings', vec2(editor_interface_cfg.settings.position[1], editor_interface_cfg.settings.position[2]), true, vec2(editor_interface_cfg.settings.size[1], editor_interface_cfg.settings.size[2]), vec2(350, 200), vec2(800, 600))

editor_interface.windows.settings.content = create_notebook(editor_interface.windows.settings)

general_panel = create_panel()
general_panel.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
general_panel.text.text = "TODO: General"
general_panel.text.parent = general_panel

themes_panel = create_panel()
themes_panel.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
themes_panel.text.text = "TODO: Themes"
themes_panel.text.parent = themes_panel

system_panel = create_panel()
system_panel.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
system_panel.text.text = "TODO: System"
system_panel.text.parent = system_panel

editor_interface.windows.settings.content:addPage(general_panel, "General")
editor_interface.windows.settings.content:addPage(themes_panel, "Themes")
editor_interface.windows.settings.content:addPage(system_panel, "System")


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
