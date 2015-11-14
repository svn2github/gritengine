include`/editor/core/windows/navigation_editor/tools.lua`
include`/editor/core/windows/navigation_editor/debug.lua`

function open_navmesh_dialog()
	open_file_dialog = create_openfiledialog({
		title = "Open navmesh";
		parent = hud_center;
		position = vec(0, 0);
		resizeable = true;
		size = vec2(720, 465);
		min_size = vec2(720, 465);
		colour = _current_theme.colours.window.background;
		alpha = 1;
		choices = { "Navmesh binary file (*.navmesh)"};
		callback = function(self, str)
			if resource_exists("/"..str) then
				if navigation_load_navmesh(str) then
					notify("Loaded!", vec(0, 0.5, 1), V_ID)
					return true
				else
					notify("Error: Could not open navmesh file!", vec(1, 0, 0), V_ID)
				end
			else
				notify("Error: Navmesh file not found!", vec(1, 0, 0), V_ID)
			end
			return false
		end;	
	})
end

function save_navmesh_dialog()
	save_file_dialog = create_savefiledialog({
		title = "Save navmesh";
		parent = hud_center;
		position = vec(0, 0);
		resizeable = true;
		size = vec2(720, 465);
		min_size = vec2(720, 465);
		colour = _current_theme.colours.window.background;
		alpha = 1;
		choices = { "Navmesh binary file (*.navmesh)"};
		callback = function(self, str)
			if resource_exists("/"..str) then
				local save_overwrite = function (boolean)
					if boolean then
						if navigation_save_navmesh(str) then
							notify("Saved!", vec(0, 1, 0), V_ID)
							self:destroy()
						else
							notify("Error!", vec(1, 0, 0), V_ID)
						end
					end
				end;
				create_dialog("SAVE", "Would you like to overwrite "..str.."?", "yesnocancel", save_overwrite)
				return false
			else
				if navigation_save_navmesh(str) then
					notify("Saved!", vec(0, 1, 0), V_ID)
					return true
				else
					notify("Error!", vec(1, 0, 0), V_ID)
					return false
				end
			end
		end;	
	})
end

editor_interface.navigation_editor = 
{
	windows = {};
	
	select = function(self)
		self.propertiesToolpanel.enabled = true
		self.windows.tools.enabled = true
		self.windows.debug.enabled = true
		self.menubar.enabled = true
		self.statusbar.enabled = true
		GED.selectionEnabled = false
		
		extra_inside_hud = function()
			if mouse_pos_abs.x > gfx_window_size().x - editor_interface.navigation_editor.propertiesToolpanel.size.x then
				return true
			end
			return false
		end;
	end;
	
	unselect = function(self)
		-- temp hack
		addobjectelement = nil
		
		self.propertiesToolpanel.enabled = false
		self.windows.tools.enabled = false
		self.windows.debug.enabled = false
		self.menubar.enabled = false
		self.statusbar.enabled = false
		GED.selectionEnabled = true
		-- playing_binds:unbind("left")
		
		GED.leftMouseClick = function(self) self:selectObj() end;
		extra_inside_hud = function() return false end;
	end;
	
	init = function(self)
		local _ = nil

		self.propertiesToolpanel = create_toolpanel({ size = vec(200, 786), parent = hud_center, offset = vec(0, 20), expand_offset = vec(0, -75), expand_y = true })
		self.propertiesToolpanel.icon.alpha = 0
		
		self.propertiesToolpanel.bxsz = create_box_sizer(true, "v", self.propertiesToolpanel)
		self.propertiesToolpanel.bxsz.zOrder = 5
		self.propertiesToolpanel.bxsz.colour = vec(0.2, 0.2, 0.2)
		self.propertiesToolpanel.bxsz.alpha = 0
		
		self.propertiesToolpanel.titles = {}
		self.propertiesToolpanel.sliders = {}
		self.propertiesToolpanel.radiobuttons = {}
		self.propertiesToolpanel.checkboxes = {}

		self.propertiesToolpanel.buttons = {}
		
		-- Rasterization
		self.propertiesToolpanel.titles[0] = create_guitext({
			colour = V_ID;
			value = "Rasterization:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[0].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[0])

		self.propertiesToolpanel.sliders[0] = create_slider("Cell Size", _, 0.3, _, 0.1, 1, 0, _, function(self) nav_builder_params.cellSize = self.value end)
		self.propertiesToolpanel.sliders[1] = create_slider("Cell Height", _, 0.2, _, 0.1, 1, 0, _, function(self) nav_builder_params.cellHeight = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[0])
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[1])

		-- Agent:
		self.propertiesToolpanel.titles[1] = create_guitext({
			colour = V_ID;
			value = "Agent:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[1].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[1])

		self.propertiesToolpanel.sliders[2] = create_slider("Height", _, 2, _, 0.1, 5, 0.1, _, function(self) nav_builder_params.agentHeight = self.value end)
		self.propertiesToolpanel.sliders[3] = create_slider("Radius", _, 0.6, _, 0, 5, 0.1, _, function(self) nav_builder_params.agentRadius = self.value end)
		self.propertiesToolpanel.sliders[4] = create_slider("Max Climb", _, 0.9, _, 0.1, 5, 0.1, _, function(self) nav_builder_params.agentMaxClimb = self.value end)
		self.propertiesToolpanel.sliders[5] = create_slider("Max Slope", _, 45, _, 0, 90, 1, _, function(self) nav_builder_params.agentMaxSlope = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[2])
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[3])
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[4])
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[5])

		-- Region:
		self.propertiesToolpanel.titles[2] = create_guitext({
			colour = V_ID;
			value = "Region:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[2].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[2])

		self.propertiesToolpanel.sliders[6] = create_slider("Min Region Size", _, 8, _, 0, 150, 1, _, function(self) nav_builder_params.regionMinSize = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[6])
		self.propertiesToolpanel.sliders[7] = create_slider("Merged Region Size", _, 20, _, 0, 150, 1, _, function(self) nav_builder_params.regionMergeSize = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[7])

		-- Partitioning:
		self.propertiesToolpanel.titles[3] = create_guitext({
			colour = V_ID;
			value = "Partitioning:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[3].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[3])

		self.propertiesToolpanel.radiobuttons[0] = create_radiobutton({ caption = "Watershed", textColour = V_ID, parent = self.propertiesToolpanel.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_WATERSHED end, align_left = true, offset =  vec(10, 0) })
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.radiobuttons[0])
		self.propertiesToolpanel.radiobuttons[0]:select()
		self.propertiesToolpanel.radiobuttons[1] = create_radiobutton({ caption = "Monotone", textColour = V_ID, parent = self.propertiesToolpanel.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_MONOTONE end, align_left = true, offset =  vec(10, 0) })
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.radiobuttons[1])
		self.propertiesToolpanel.radiobuttons[2] = create_radiobutton({ caption = "Layers", textColour = V_ID, parent = self.propertiesToolpanel.bxsz, onSelect = function(self) nav_builder_params.partitionType = SAMPLE_PARTITION_LAYERS end, align_left = true, offset =  vec(10, 0) })
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.radiobuttons[2])

		-- Poligonization:
		self.propertiesToolpanel.titles[4] = create_guitext({
			colour = V_ID;
			value = "Poligonization:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[4].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[4])

		self.propertiesToolpanel.sliders[8] = create_slider("Max Edge Length", _, 12, _, 0, 50, 1, _, function(self) nav_builder_params.edgeMaxLen = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[8])
		self.propertiesToolpanel.sliders[9] = create_slider("Max Edge Error", _, 1.3, _, 0.1, 3, 0.1, _, function(self) nav_builder_params.edgeMaxError = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[9])
		self.propertiesToolpanel.sliders[10] = create_slider("Verts Per Poly", _, 6, _, 3, 12, 1, _, function(self) nav_builder_params.vertsPerPoly = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[10])

		-- Detail Mesh:
		self.propertiesToolpanel.titles[5] = create_guitext({
			colour = V_ID;
			value = "Detail Mesh:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[5].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[5])

		self.propertiesToolpanel.sliders[11] = create_slider("Sample Distance", _, 6, _, 0, 16, 1, _, function(self) nav_builder_params.detailSampleDist = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[11])
		self.propertiesToolpanel.sliders[12] = create_slider("Max Sample Error", _, 1, _, 0, 16, 1, _, function(self) nav_builder_params.detailSampleMaxError = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[12])

		self.propertiesToolpanel.checkboxes[1] = create_checkbox({
			caption = "Keep Intermediate Results",
			textColour = V_ID;
			checked = false,
			parent = self.propertiesToolpanel.bxsz,
			align_left = true,
			offset = vec(10, 0),
			onCheck = function(self) nav_builder_params.keepInterResults = true end,
			onUncheck = function(self) nav_builder_params.keepInterResults = false end,
		})
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.checkboxes[1])

		-- Tiling:
		self.propertiesToolpanel.titles[6] = create_guitext({
			colour = V_ID;
			value = "Tiling:";
			font = `/common/fonts/ArialBold12`;
		})
		self.propertiesToolpanel.titles[6].text.shadow = vec(1, -1)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[6])

		self.propertiesToolpanel.sliders[13] = create_slider("Tile Size", _, 48, _, 16, 128, 8, _, function(self) nav_builder_params.tileSize = self.value end)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.sliders[13])

		-- Tile Cache:
		-- self.propertiesToolpanel.titles[7] = create_guitext({
			-- value = "Tile Cache:";
			-- font = `/common/fonts/ArialBold12`;
		-- })	
		-- self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.titles[7])

		self.propertiesToolpanel.txx3 = create_rect({})
		self.propertiesToolpanel.txx3.alpha = 0
		self.propertiesToolpanel.txx3.size = vec(0, 0)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.txx3)

		self.propertiesToolpanel.buttons[1] = create_button({
			caption = "Save",
			parent = self.propertiesToolpanel.bxsz,
			offset = vec(10, 0),
			align_left = true,
			size = vec(150, 20),
			pressedCallback = function(self)
				save_navmesh_dialog()
			end,
		})
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.buttons[1])

		self.propertiesToolpanel.buttons[2] = create_button({
			caption = "Load",
			parent = self.propertiesToolpanel.bxsz,
			offset = vec(10, 0),
			align_left = true,
			size = vec(150, 20),
			pressedCallback = function(self)
				open_navmesh_dialog()
			end,
		})
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.buttons[2])

		self.propertiesToolpanel.txx4 = create_rect({})
		self.propertiesToolpanel.txx4.alpha = 0
		self.propertiesToolpanel.txx4.size = vec(0, 0)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.txx4)

		self.propertiesToolpanel.buttons[3] = create_button({
			caption = "Build",
			parent = self.propertiesToolpanel.bxsz,
			offset = vec(0, 0),
			expand_x = true,
			expand_offset = vec(-20, 0),
			pressedCallback = function(self)
				-- local build_list = {}
				
				-- for k, v in pairs(current_map.objects) do
					-- if not current_map.objects[k].destroyed and current_map.objects[k].instance ~= nil and current_map.objects[k].instance.gfx ~= nil and current_map.objects[k].buildNavmesh then
						-- build_list[#build_list+1] = current_map.objects[k].instance.gfx
					-- end
				-- end					

				-- testnav22(build_list)
				navigation_update_params()
				navigation_build_nav_mesh()
			end,
		})
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.buttons[3])

		self.propertiesToolpanel.txx5 = create_rect({})
		self.propertiesToolpanel.txx5.alpha = 0
		self.propertiesToolpanel.txx5.size = vec(0, 0)
		self.propertiesToolpanel.bxsz:addChild(self.propertiesToolpanel.txx5)

		self.propertiesToolpanel.size = self.propertiesToolpanel.size
	
		self:create_tools()
		self:create_debug()
		
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
		
		self.toolbar:addTool("Crowd Tool", `/editor/core/icons/navigation_editor/agent.png`, (function(self) editor_interface.navigation_editor.windows.tools:show_crowd_tool() end), "Crowd Tool")
		self.toolbar:addTool("Create Offmesh Links", `/editor/core/icons/navigation_editor/offmeshcon.png`, (function(self) editor_interface.navigation_editor.windows.tools:show_offmesh_tool() end), "Create Offmesh Links")
		self.toolbar:addTool("Create Convex Volumes", `/editor/core/icons/navigation_editor/convexvolume.png`, (function(self) editor_interface.navigation_editor.windows.tools:show_convex_tool() end), "Create Convex Volumes")
		self.toolbar:addTool("Create Temporary Obstacles", `/editor/core/icons/navigation_editor/obstacle.png`, (function(self) editor_interface.navigation_editor.windows.tools:show_temp_obstacle_tool() end), "Create Temporary Obstacles")
		self.toolbar:addSeparator()
		self.toolbar:addTool("Tool", `/editor/core/icons/navigation_editor/tool.png`, (function(self) editor_interface.navigation_editor.windows.tools.enabled = not editor_interface.navigation_editor.windows.tools.enabled end), "Tool")
		self.toolbar:addTool("Debug", map_editor_icons.view_mode, (function(self) editor_interface.navigation_editor.windows.debug.enabled = not editor_interface.navigation_editor.windows.debug.enabled end), "Debug")

		self.toolbar:addTool("Toggle Properties Panel", map_editor_icons.config, (function(self) editor_interface.navigation_editor.propertiesToolpanel.enabled = not editor_interface.navigation_editor.propertiesToolpanel.enabled end), "Toggle Properties Panel")
		
		self.statusbar = create_statusbar({ parent = hud_bottom_left, size = vec(0, 20) })

		self.statusbar:setText("Navigation Mesh Editor")
		
		self:unselect()
		--self.windows.tools:show_crowd_tool()
	end;
	destroy = function(self)
		safe_destroy(self.propertiesToolpanel)
		safe_destroy(self.menubar)
		safe_destroy(self.statusbar)
	end;
	
	create_tools = function(self)
		if self.windows.tools ~= nil and not self.windows.tools.destroyed then
			self.windows.tools:destroy()
		end

		self.windows.tools = gfx_hud_object_add(`/editor/core/windows/navigation_editor/Tools`, {
			title = "Tools";
			parent = hud_center;
			position = vec(-390, 100);
			resizeable = true;
			size = vec(180, 225);
			min_size = vec(180, 225);
			colour = _current_theme.colours.window.background;
			alpha = 1;	
		})
		_windows[#_windows+1] = self.windows.tools
		set_active_window(self.windows.tools)
		return self.windows.tools
	end;
	
	create_debug = function(self)
		if self.windows.debug ~= nil and not self.windows.debug.destroyed then
			self.windows.debug:destroy()
		end

		self.windows.debug = gfx_hud_object_add(`/editor/core/windows/navigation_editor/Debug`, {
			title = "Debug";
			parent = hud_center;
			position = vec(-390, -200);
			resizeable = true;
			size = vec(200, 250);
			min_size = vec(200, 250);
			colour = _current_theme.colours.window.background;
			alpha = 1;	
		})
		_windows[#_windows+1] = self.windows.debug
		set_active_window(self.windows.debug)
		return self.windows.debug
	end;	
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
