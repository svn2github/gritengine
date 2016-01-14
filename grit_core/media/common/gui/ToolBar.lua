------------------------------------------------------------------------------
--  Toolbar
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ToolBar` (extends(GuiClass)
{
    colour = _current_theme.colours.tool_bar.background;
	alpha = _current_theme.colours.tool_bar.alpha;
    toolPadding = vec(16, 4);
	lastTool = 0;
	orient = "h";
	
    init = function (self)
		GuiClass.init(self)
		
        self.needsParentResizedCallbacks = true
        self.tools = {}
		self.separators = {}

		self.positioner = create_gui_object({
			parent = self,
			align = vec(self.orient == "h" and -1 or 0, self.orient == "v" and 1 or 0),
			--offset = vec(self.orient == "h" and 16 or 0, self.orient == "v" and -16 or 0)
		})
		
    end;

	addTool = function(self, name, icon, cb, ttip)
		local pos = vec(0, 0)
		
		if self.orient == "h" then
			pos = vec2(self.lastTool, 0)
		else
			pos = vec2(0, self.lastTool)
		end
		
		self.tools[#self.tools + 1] = create_imagebutton({
			pressedCallback = cb;
			texture = icon;
			tip = ttip;
			position = pos;
			parent = self.positioner;
		})
		if self.orient == "h" then
			self.lastTool = self.lastTool + self.tools[#self.tools].size.x + 4
			self.size = vec(math.abs(self.lastTool), self.size.y)
		else
			self.lastTool = self.lastTool - self.tools[#self.tools].size.y - 4
			self.size = vec(self.size.x, math.abs(self.lastTool))
		end		
		
		self:pr_update(self.parent.size)
		
		return self.tools[#self.tools]
	end;

	addSeparator = function(self)
		local pos = vec(0, 0)
		local sz = vec(0, 0)
		
		if self.orient == "h" then
			pos = vec2(self.lastTool - (self.tools[#self.tools].size.x/2), 0)
			sz = vec2(2, self.size.y -14)
		else
			pos = vec2(0, self.lastTool + (self.tools[#self.tools].size.y/2))
			sz = vec2(self.size.x -14, 2)
		end
		
		self.separators[#self.separators + 1] = create_rect({
			parent = self.positioner,
			position = pos,
			colour = _current_theme.colours.tool_bar.separator,
			alpha = _current_theme.colours.tool_bar.separator_alpha,
			size = sz
		})
		if self.orient == "h" then
			self.lastTool = self.lastTool + self.separators[#self.separators].size.x + 4
			self.size = vec(math.abs(self.lastTool), self.size.y)
		else
			self.lastTool = self.lastTool - self.separators[#self.separators].size.y - 4
			self.size = vec(self.size.x, math.abs(self.lastTool))
		end	
		self:pr_update(self.parent.size)
	end;
	
    destroy = function (self)
		self.needsParentResizedCallbacks = false
		self:destroy()
    end;

    parentResizedCallback = function (self, psize)
		GuiClass.parentResizedCallback(self, psize)
    end;
})

function create_toolbar(options)
	return gfx_hud_object_add(`ToolBar`, options)
end