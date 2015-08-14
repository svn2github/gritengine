function navigation_update_params() end
function buildNavMesh() notify("Needs the C++ implementation, be patient", vec(0, 0.5, 1), vec(1, 1, 1), nil, 1) end

editor_interface.navigation_editor = 
{
	windows = {};
	
	select = function(self)
		-- temp hack
		addobjectelement = ":D"
		
		self.windows.properties.enabled = true
		self.windows.tools.enabled = false
		self.menubar.enabled = true
		self.statusbar.enabled = true
		notify("W.I.P: Not Currently Available", vec(1, 0, 0), vec(1, 1, 1), 1)
	end;
	
	unselect = function(self)
		-- temp hack
		addobjectelement = nil
		
		self.windows.properties.enabled = false
		self.windows.tools.enabled = false
		self.menubar.enabled = false
		self.statusbar.enabled = false
	end;
	
	init = function(self)
		local _ = nil

		self.windows.properties = create_toolpanel({ size = vec(200, 786), parent = hud_center, offset = vec(0, 20), expand_offset = vec(0, -75), expand_y = true })
		self.windows.properties.icon.alpha = 0
		
		self.windows.properties.bxsz = create_box_sizer(true, "v", self.windows.properties)
		self.windows.properties.bxsz.zOrder = 5
		self.windows.properties.bxsz.colour = vec(0.2, 0.2, 0.2)
		self.windows.properties.bxsz.alpha = 0
		
		self.windows.properties.titles = {}
		self.windows.properties.sliders = {}
		self.windows.properties.radiobuttons = {}
		self.windows.properties.checkboxes = {}

		self.windows.properties.buttons = {}
		
		-- Rasterization
		self.windows.properties.titles[0] = create_guitext({
			value = "Rasterization:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[0].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[0])

		self.windows.properties.sliders[0] = create_slider("Cell Size", _, 0.3, _, 0.1, 1, 0, _, function(self) nav_builder_params.cellSize = self.value end)
		self.windows.properties.sliders[1] = create_slider("Cell Height", _, 0.2, _, 0.1, 1, 0, _, function(self) nav_builder_params.cellHeight = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[0])
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[1])

		-- Agent:
		self.windows.properties.titles[1] = create_guitext({
			value = "Agent:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[1].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[1])

		self.windows.properties.sliders[2] = create_slider("Height", _, 2, _, 0.1, 5, 0.1, _, function(self) nav_builder_params.agentHeight = self.value end)
		self.windows.properties.sliders[3] = create_slider("Radius", _, 0.6, _, 0, 5, 0.1, _, function(self) nav_builder_params.agentRadius = self.value end)
		self.windows.properties.sliders[4] = create_slider("Max Climb", _, 0.9, _, 0.1, 5, 0.1, _, function(self) nav_builder_params.agentMaxClimb = self.value end)
		self.windows.properties.sliders[5] = create_slider("Max Slope", _, 45, _, 0, 90, 1, _, function(self) nav_builder_params.agentMaxSlope = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[2])
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[3])
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[4])
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[5])

		-- Region:
		self.windows.properties.titles[2] = create_guitext({
			value = "Region:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[2].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[2])

		self.windows.properties.sliders[6] = create_slider("Min Region Size", _, 8, _, 0, 150, 1, _, function(self) nav_builder_params.regionMinSize = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[6])
		self.windows.properties.sliders[7] = create_slider("Merged Region Size", _, 20, _, 0, 150, 1, _, function(self) nav_builder_params.regionMergeSize = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[7])

		-- Partitioning:
		self.windows.properties.titles[3] = create_guitext({
			value = "Partitioning:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[3].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[3])

		self.windows.properties.radiobuttons[0] = create_radiobutton({ caption = "Watershed", parent = self.windows.properties.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_WATERSHED end, align_left = true, offset =  vec(10, 0) })
		self.windows.properties.bxsz:addChild(self.windows.properties.radiobuttons[0])
		self.windows.properties.radiobuttons[0]:select()
		self.windows.properties.radiobuttons[1] = create_radiobutton({ caption = "Monotone", parent = self.windows.properties.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_MONOTONE end, align_left = true, offset =  vec(10, 0) })
		self.windows.properties.bxsz:addChild(self.windows.properties.radiobuttons[1])
		self.windows.properties.radiobuttons[2] = create_radiobutton({ caption = "Layers", parent = self.windows.properties.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_LAYERS end, align_left = true, offset =  vec(10, 0) })
		self.windows.properties.bxsz:addChild(self.windows.properties.radiobuttons[2])

		-- Poligonization:
		self.windows.properties.titles[4] = create_guitext({
			value = "Poligonization:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[4].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[4])

		self.windows.properties.sliders[8] = create_slider("Max Edge Length", _, 12, _, 0, 50, 1, _, function(self) nav_builder_params.edgeMaxLen = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[8])
		self.windows.properties.sliders[9] = create_slider("Max Edge Error", _, 1.3, _, 0.1, 3, 0.1, _, function(self) nav_builder_params.edgeMaxError = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[9])
		self.windows.properties.sliders[10] = create_slider("Verts Per Poly", _, 6, _, 3, 12, 1, _, function(self) nav_builder_params.vertsPerPoly = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[10])

		-- Detail Mesh:
		self.windows.properties.titles[5] = create_guitext({
			value = "Detail Mesh:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[5].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[5])

		self.windows.properties.sliders[11] = create_slider("Sample Distance", _, 6, _, 0, 16, 1, _, function(self) nav_builder_params.detailSampleDist = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[11])
		self.windows.properties.sliders[12] = create_slider("Max Sample Error", _, 1, _, 0, 16, 1, _, function(self) nav_builder_params.detailSampleMaxError = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[12])

		self.windows.properties.checkboxes[1] = create_checkbox({
			caption = "Keep Intermediate Results",
			checked = false,
			parent = self.windows.properties.bxsz,
			align_left = true,
			offset = vec(10, 0),
			onCheck = function(self) nav_builder_params.keepInterResults = true end,
			onUncheck = function(self) nav_builder_params.keepInterResults = false end,
		})
		self.windows.properties.bxsz:addChild(self.windows.properties.checkboxes[1])

		-- Tiling:
		self.windows.properties.titles[6] = create_guitext({
			value = "Tiling:";
			font = `/common/fonts/ArialBold12`;
		})
		self.windows.properties.titles[6].text.shadow = vec(1, -1)
		self.windows.properties.bxsz:addChild(self.windows.properties.titles[6])

		self.windows.properties.sliders[13] = create_slider("Tile Size", _, 48, _, 16, 128, 8, _, function(self) nav_builder_params.tileSize = self.value end)
		self.windows.properties.bxsz:addChild(self.windows.properties.sliders[13])

		-- Tile Cache:
		-- self.windows.properties.titles[7] = create_guitext({
			-- value = "Tile Cache:";
			-- font = `/common/fonts/ArialBold12`;
		-- })	
		-- self.windows.properties.bxsz:addChild(self.windows.properties.titles[7])

		self.windows.properties.txx3 = create_rect({})
		self.windows.properties.txx3.alpha = 0
		self.windows.properties.txx3.size = vec(0, 0)
		self.windows.properties.bxsz:addChild(self.windows.properties.txx3)

		self.windows.properties.buttons[1] = create_button({
			caption = "Save",
			parent = self.windows.properties.bxsz,
			offset = vec(10, 0),
			align_left = true,
			size = vec(150, 20),
			pressedCallback = function(self)
				-- savenavmeshDialog()
				notify("Needs the C++ implementation, be patient", vec(0, 0.5, 1), vec(1, 1, 1), nil, 1)
			end,
		})
		self.windows.properties.bxsz:addChild(self.windows.properties.buttons[1])

		self.windows.properties.buttons[2] = create_button({
			caption = "Load",
			parent = self.windows.properties.bxsz,
			offset = vec(10, 0),
			align_left = true,
			size = vec(150, 20),
			pressedCallback = function(self)
				-- loadNavmeshDialog()
				notify("Needs the C++ implementation, be patient", vec(0, 0.5, 1), vec(1, 1, 1), nil, 1)
			end,
		})
		self.windows.properties.bxsz:addChild(self.windows.properties.buttons[2])

		self.windows.properties.txx4 = create_rect({})
		self.windows.properties.txx4.alpha = 0
		self.windows.properties.txx4.size = vec(0, 0)
		self.windows.properties.bxsz:addChild(self.windows.properties.txx4)

		self.windows.properties.buttons[3] = create_button({
			caption = "Build",
			parent = self.windows.properties.bxsz,
			offset = vec(0, 0),
			expand_x = true,
			expand_offset = vec(-20, 0),
			pressedCallback = function(self)
				navigation_update_params()
				buildNavMesh()
			end,
		})
		self.windows.properties.bxsz:addChild(self.windows.properties.buttons[3])

		self.windows.properties.txx5 = create_rect({})
		self.windows.properties.txx5.alpha = 0
		self.windows.properties.txx5.size = vec(0, 0)
		self.windows.properties.bxsz:addChild(self.windows.properties.txx5)

		self.windows.properties.size = self.windows.properties.size
	
		-- TOOLS
		self.windows.tools = create_window('Tools', vec2(-390, 0), true, vec(180, 256), vec(180, 256), vec2(800, 600))

		self.windows.tools.masterfbs = create_flex_box_sizer(true, "v", self.windows.tools, vec(2, 2), vec(0, 0, 0), 0)

		self.windows.tools.toolquad = create_gui_object({ parent = self.windows.tools, size = vec(100, 100), alpha = 0, align_left=true } )

		self.windows.tools.toolsel = create_box_sizer(true, "v", self.windows.tools.toolquad)
		self.windows.tools.toolsel.zOrder = 5
		self.windows.tools.toolsel.alpha = 0
		self.windows.tools.toolsel.colour = vec(0, 0, 0)

		self.windows.tools.radiobuttons = {}

		self.windows.tools.radiobuttons[0] = create_radiobutton({caption = "Test Navmesh", parent = self.windows.tools.toolsel, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.toolsel:addChild(self.windows.tools.radiobuttons[0])
		self.windows.tools.radiobuttons[1] = create_radiobutton({caption = "Create Temp Obstacles", parent = self.windows.tools.toolsel, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.toolsel:addChild(self.windows.tools.radiobuttons[1])
		self.windows.tools.radiobuttons[2] = create_radiobutton({caption = "Create Off-Mesh Links", parent = self.windows.tools.toolsel, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.toolsel:addChild(self.windows.tools.radiobuttons[2])

		self.windows.tools.radiobuttons[3] = create_radiobutton({caption = "Create Convex Volumes", parent = self.windows.tools.toolsel, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.toolsel:addChild(self.windows.tools.radiobuttons[3])
		self.windows.tools.radiobuttons[4] = create_radiobutton({caption = "Create Crowds", parent = self.windows.tools.toolsel, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.toolsel:addChild(self.windows.tools.radiobuttons[4])
		self.windows.tools.radiobuttons[4]:select()

		local minsz = 10
		for i = 1, #self.windows.tools.radiobuttons do
			if self.windows.tools.radiobuttons[i] ~= nil and self.windows.tools.radiobuttons[i].size.x > minsz then
				minsz = self.windows.tools.radiobuttons[i].size.x
			end
		end
		self.windows.tools.toolquad.size = vec(minsz+20, #self.windows.tools.radiobuttons*(self.windows.tools.radiobuttons[1].size.y *1.5))
		self.windows.tools.masterfbs:addChild(self.windows.tools.toolquad, true, vec(50, #self.windows.tools.radiobuttons*(self.windows.tools.radiobuttons[1].size.y *2)))

		self.windows.tools.toolsel2 = create_box_sizer(true, "v", self.windows.tools)
		self.windows.tools.toolsel2.zOrder = 5

		self.windows.tools.masterfbs:addChild(self.windows.tools.toolsel2, false, vec(50, 100))

		self.windows.tools.tool = {}	
		
		self:show_crowd_tool()
		
		self.menubar = create_menubar({
			parent = hud_center;
			size = vec(20, 26);
			offset = vec(0, -29);
			expand_x = true;
			align_top = true;
			enabled = false;
		})
		self.menubar:init()
		self.menubar.enabled = false
		
		self.menus = {}
		self.menus.fileMenu = create_menubar_menu({
			items = {
				{
					callback = function()  end;
					name = "Open";
					tip = "Open a navigation mesh";
					icon = map_editor_icons.open15;
				},
				{},
				{
					callback = function()  end;
					name = "Save";
					tip = "Save the current navmesh";
					icon = map_editor_icons.save15;
				},
				{
					callback = function()  end;
					name = "Save As";
					tip = "Save as the current map";
					icon = map_editor_icons.save_as15;
				},
			};
		})
		
		self.menus.editMenu = create_menubar_menu({
			items = {
				{
					callback = function()  end;
					name = "Undo";
					tip = "Undo last action";
					icon = map_editor_icons.undo;
				},
				{
					callback = function()  end;
					name = "Redo";
					tip = "Redo last action";
					icon = map_editor_icons.redo;
				},
				{},
				{
					callback = function()  end;
					name = "Cut";
					tip = "Cut selection";
				},
				{
					callback = function()  end;
					name = "Copy";
					tip = "Copy selection";
				},
				{
					callback = function() end;
					name = "Paste";
					tip = "Paste selection";
				},
			};
		})

		self.menus.viewMenu = create_menubar_menu({
			items = {
				{
					callback = function(self)
						editor_interface.navigation_editor.statusbar.enabled = not editor_interface.navigation_editor.statusbar.enabled
						self.icon.enabled = editor_interface.navigation_editor.statusbar.enabled
					end;
					name = "Show Status bar";
					tip = "Show Status bar";
					icon = _gui_textures.verify.v;
				},		
				{},
				{
					callback = function(self)
						gfx_option("RENDER_SKY", not gfx_option("RENDER_SKY"))
						self.icon.enabled = gfx_option("RENDER_SKY")
					end;
					name = "Render Sky";
					tip = "Toggle render sky";
					icon = _gui_textures.verify.v;
				},
				-- {
					-- callback = function(self)
						-- lens_flare.enabled = not lens_flare.enabled
						-- self.icon.enabled = lens_flare.enabled
					-- end;
					-- name = "Show Lensflare";
					-- tip = "Toggle lensflare";
					-- icon = _gui_textures.verify.v;
				-- },
				{
					callback = function(self)
						gfx_option("FULLSCREEN", not gfx_option("FULLSCREEN"))
						self.icon.enabled = gfx_option("FULLSCREEN")
					end;
					name = "Fullscreen";
					tip = "Toggle fullscreen";
					icon = _gui_textures.verify.v;
					icon_enabled = gfx_option("FULLSCREEN");
				},
			};
		})

		self.menus.helpMenu = create_menubar_menu({
			items = {
				{
					callback = function() os.execute("start http://gritengine.com/grit_book/") end;
					name = "Grit Book";
					tip = "Opens Grit Book page";
				},
				{},
				{
					callback = function() os.execute("start http://gritengine.com/game-engine-forum/") end;
					name = "Grit forums";
					tip = "Opens Grit forums page";
				},
				{
					callback = function() os.execute("start http://www.gritengine.com/game-engine-wiki/HomePage") end;
					name = "Grit wiki";
					tip = "Opens Grit Wiki page";
				},
				{
					callback = function() os.execute("start http://www.gritengine.com/chat") end;
					name = "Grit IRC";
					tip = "Opens Grit IRC page";
				},
				{},
				{
					callback = function() os.execute("start http://gritengine.com/game-engine-forum/viewtopic.php?p=5344#p5344") end;
					name = "Grit Editor Help";
					tip = "Grit Editor Help";
					icon = _gui_textures.help;
				},
				{
					callback = function() os.execute("start http://www.gritengine.com/") end;
					name = "About";
					tip = "About Grit Editor";

				},
			};
		})		
		
		self.menubar:append(self.menus.fileMenu, "File")
		self.menubar:append(self.menus.editMenu, "Edit")
		self.menubar:append(self.menus.viewMenu, "View")
		self.menubar:append(self.menus.helpMenu, "Help")
		
		self.toolbar = create_toolbar({
			parent = self.menubar;
			zOrder = 5;
			align_left = true;
			offset = vec(self.menubar.lastButton+self.menubar.buttons[#self.menubar.buttons].size.x/2+20, 0);
			alpha = 0;
		})

		self.toolbar:addTool("New", map_editor_icons.new, (function(self)  end), "TODO")
		self.toolbar:addTool("Open", map_editor_icons.open, (function(self)  end), "TODO")
		self.toolbar:addTool("Save As", map_editor_icons.save_as, (function(self)  end), "TODO")
		self.toolbar:addSeparator()
		self.toolbar:addTool("Settings", map_editor_icons.config, (function(self)  end), "TODO")

		self.statusbar = create_statusbar({ parent = hud_bottom_left, size = vec(0, 20) })

		self.statusbar:setText("The navigation editor isn't working, the navigation system is being implemented")
		
		self:unselect()

	end;
	destroy = function(self)
		safe_destroy(self.menubar)
		safe_destroy(self.statusbar)
	end;
	show_crowd_tool = function(self)
		safe_destroy(self.windows.tools.tool)
		self.windows.tools.tool = create_gui_object({ parent = self.windows.tools.toolsel2, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align_top = true, expand_x = true })
		self.windows.tools.tool.checkboxes = {}
		
		self.windows.tools.tool.bxsz = create_box_sizer(true, "v", self.windows.tools.tool)
		self.windows.tools.tool.bxsz.zOrder = 5
		
		self.windows.tools.tool.checkboxes[0] = create_radiobutton({caption = "Create Agents", parent = self.windows.tools.tool, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.tool.bxsz:addChild(self.windows.tools.tool.checkboxes[0])
		self.windows.tools.tool.checkboxes[0]:select()
		
		self.windows.tools.tool.checkboxes[1] = create_radiobutton({caption = "Move Target", parent = self.windows.tools.tool, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.tool.bxsz:addChild(self.windows.tools.tool.checkboxes[1])
		
		self.windows.tools.tool.checkboxes[2] = create_radiobutton({caption = "Select Agent", parent = self.windows.tools.tool, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.windows.tools.tool.bxsz:addChild(self.windows.tools.tool.checkboxes[2])
		
		self.windows.tools.tool.size = vec(self.windows.tools.tool.size.x, #self.windows.tools.tool.checkboxes*(self.windows.tools.tool.checkboxes[1].size.y *2))
		self.windows.tools.size = self.windows.tools.size
	end	
}

editor_interface.navigation_editor:init()

function open_navigation_page()
	if not editor_interface.nav_page or editor_interface.nav_page.destroyed then
		editor_interface.nav_page = editor_interface:addPage({ caption = "Navigation Editor", edge_colour = vec(0, 1, 0), onSelect = function(self) editor_interface.navigation_editor:select() end, onUnselect =  function() editor_interface.navigation_editor:unselect() end, closebtn = true, onDestroy = function(self) editor_interface.nav_page_opened = false end })
		editor_interface.nav_page_opened = true
		editor_interface.nav_page:select()
	elseif not editor_interface.nav_page.destroyed then
		editor_interface.nav_page:select()
	end
end

-- add the button to the editor toolbar
editor_interface.map_editor_page.mlefttoolbar:addTool("Navigation Edtor", map_editor_icons.navigation, function(self) open_navigation_page() end, "Navigation Editor")