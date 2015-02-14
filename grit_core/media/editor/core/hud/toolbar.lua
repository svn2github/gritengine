-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `ToolBar` {
    colour = vec(0.1, 0.1, 0.1);
    toolPadding = vec(16, 4);
	lastTool = 0;
	
    init = function (self)
        self.needsParentResizedCallbacks = true
        self.tools = {}
		self.separators = {}

		self.leftPositioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self;
			-- HACK (TEMPORARY)
			--offset = vec2(60, 0);
			offset = vec2(0, 0);
			factor = vec2(-0.5, 0);
		})
    end;

	addTool = function(self, name, icon, cb, ttip)
		self.tools[#self.tools + 1] = gfx_hud_object_add("/editor/core/hud/imagebutton", {
			pressedCallback=cb;
			texture=icon;
			tip=ttip;
			position=vec2(self.lastTool, 0);
			parent=self.leftPositioner;
		})
		self.lastTool = self.lastTool + self.tools[#self.tools].size.x + 4
	end;

	addSeparator = function(self)
		self.separators[#self.separators + 1] = gfx_hud_object_add("/common/hud/VerticalLine", { parent=self.leftPositioner, position=vec2(self.lastTool - (self.tools[#self.tools].size.x/2), 0), colour=vec(0.5, 0.5, 0.5), alpha=0.7 })
		self.lastTool = self.lastTool + self.separators[#self.separators].size.x + 4
	end;
	
    destroy = function (self)
		self.needsParentResizedCallbacks = false
		self:destroy()
    end;
	-- HACK, TEMPORARY, problems with menubar clicks (the hud ray hit the menubar and toolbar buttons too)
    parentResizedCallback = function (self, psize)
		--self.position = vec(psize.x/2, -45)
		self.position = vec(psize.x/2 + 370, -15)
		self.size = vec(psize.x, 30)
    end;
}