
hud_class `Tools` (extends(WindowClass)
{
	init = function (self)
		WindowClass.init(self)
		self.tool = {}	
	end;

	show_temp_obstacle_tool = function(self)
		safe_destroy(self.tool)
		self.tool = create_gui_object({ parent = self, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align_top = true, expand_x = true })
		-- self.tool.title = create_guitext({
			-- value = "Create :";
			-- font = `/common/fonts/ArialBold12`;
		-- })

		self.tool.button = create_button({
			caption = "Remove All",
			parent = self.tool,
			offset = vec(0, -10),
			align_top = true,
			expand_x = true,
			expand_offset = vec(-20, 0),
			pressedCallback = function(self)
				
			end,
		})
		self.tool.size = vec(self.tool.size.x, self.tool.button.size.y *2)
		self.size = self.size
		
		--playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then navigation_add_obstacle(pos) end end)
		GED.leftMouseClick = function() local pos = mouse_pick_pos() if pos then navigation_add_obstacle(pos) end end;
	end;
	
	show_offmesh_tool = function(self)
		safe_destroy(self.tool)
		self.tool = create_gui_object({ parent = self, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align_top = true, expand_x = true })
		self.tool.radiobuttons = {}
		
		self.points = {}
		
		local offmeshclick = function()
			if editor_interface.navigation_editor.windows.tools.points[1] == nil then
				local pos = mouse_pick_pos()
				if pos then
					editor_interface.navigation_editor.windows.tools.points[1] = pos
				end
			elseif editor_interface.navigation_editor.windows.tools.points[2] == nil then
				local pos = mouse_pick_pos()
				if pos then
					editor_interface.navigation_editor.windows.tools.points[2] = pos
				end
				navigation_add_offmesh_connection(
					editor_interface.navigation_editor.windows.tools.points[2],
					editor_interface.navigation_editor.windows.tools.points[1],
					(editor_interface.navigation_editor.windows.tools.tool.bxsz.radiobuttons.selected.caption == "Bidirecional" and true or false)
				)
				editor_interface.navigation_editor.windows.tools.points = {}			
			end
		end
		
		-- playing_binds:bind("middle", offmeshclick)
		GED.leftMouseClick = function() offmeshclick() end;
		
		self.tool.bxsz = create_box_sizer(true, "v", self.tool)
		self.tool.bxsz.zOrder = 5
		
		self.tool.radiobuttons[0] = create_radiobutton({caption = "One way", parent = self.tool, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.tool.bxsz:addChild(self.tool.radiobuttons[0])
		
		self.tool.radiobuttons[1] = create_radiobutton({caption = "Bidirecional", parent = self.tool, onSelect = function(self)  end, align_left = true, offset =  vec(10, 0)})
		self.tool.bxsz:addChild(self.tool.radiobuttons[1])
		self.tool.radiobuttons[1]:select()
		
		self.tool.size = vec(self.tool.size.x, #self.tool.radiobuttons*(self.tool.radiobuttons[1].size.y *2))
		self.size = self.size		
	end;	
	
	show_convex_tool = function(self)
		safe_destroy(self.tool)
		self.tool = create_gui_object({ parent = self, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align_top = true, expand_x = true })
		-- playing_binds:bind("middle", function() end)
		GED.leftMouseClick = function()  end;
	end;	
	
	show_crowd_tool = function(self)
		safe_destroy(self.tool)
		self.tool = create_gui_object({ parent = self, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align_top = true, expand_x = true })
		self.tool.radiobuttons = {}
		
		self.tool.bxsz = create_box_sizer(true, "v", self.tool)
		self.tool.bxsz.zOrder = 5
		
		self.tool.radiobuttons[0] = create_radiobutton({caption = "Create Agents",
			parent = self.tool,
			onSelect = function(self)
				-- playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then agent_add(pos) end end)
				GED.leftMouseClick = function() local pos = mouse_pick_pos() if pos then agent_make(pos) end end;
			end,
			align_left = true,
			offset =  vec(10, 0)
		})
		self.tool.bxsz:addChild(self.tool.radiobuttons[0])
		self.tool.radiobuttons[0]:select()
		
		self.tool.radiobuttons[1] = create_radiobutton({caption = "Move Target",
			parent = self.tool,
			onSelect = function(self)
				-- playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then crowd_move_to(pos) end end)
				GED.leftMouseClick = function() local pos = mouse_pick_pos() if pos then crowd_move_to(pos) end end;
			end,
			align_left = true,
			offset =  vec(10, 0)
		})		
		self.tool.bxsz:addChild(self.tool.radiobuttons[1])
		
		self.tool.radiobuttons[2] = create_radiobutton({caption = "Select Agent",
			parent = self.tool,
			onSelect = function(self)
				-- playing_binds:bind("middle", function() end)
				GED.leftMouseClick = function()  end;
			end,
			align_left = true,
			offset =  vec(10, 0)
		})		
		self.tool.bxsz:addChild(self.tool.radiobuttons[2])
		
		self.tool.size = vec(self.tool.size.x, #self.tool.radiobuttons*(self.tool.radiobuttons[1].size.y *2))
		self.size = self.size
	end;	
	
	destroy = function (self)
		WindowClass.destroy(self)
	end;
	
	buttonCallback = function(self, ev)
		WindowClass.buttonCallback(self, ev)
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		WindowClass.mouseMoveCallback(self, local_pos, screen_pos, inside)
	end;
})