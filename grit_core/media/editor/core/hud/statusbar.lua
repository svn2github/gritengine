-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `StatusBar` {
    colour = vec(0.3, 0.3, 0.3);
	alpha=0.8;
	size = vec2(0, 25);
	
    init = function (self)
        self.needsParentResizedCallbacks = true
		self.needsFrameCallbacks = true
		self.line = gfx_hud_object_add('/common/hud/HorizontalLine', {
			parent = self;
			position=vec2(0, self.size.y/2);
			colour=vec(1, 0.5, 0);
			alpha=0.3;
		})
		self.line:setThickness(1)
		self.right = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self;
			offset = vec2(-10, 0);
			factor = vec2(0.5, 0);
		})
		self.fps = gfx_hud_text_add("/common/fonts/Arial12")
		self.fps.parent=self.right
		self.fps.colour = vec(1, 1, 1)
		self.fps.text="FPS: "
		self.fps.position = vec2(-self.fps.size.x/2, self.fps.position.y)

		self.pos = gfx_hud_text_add("/common/fonts/Arial12")
		self.pos.parent=self.right
		self.pos.colour = vec(1, 1, 1)
		self.pos.text="POS: "
		self.pos.position = vec2(-self.fps.size.x/2-180, self.fps.position.y)
		
		self.left = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self;
			offset = vec2(45, 0);
			factor = vec2(-0.5, 0);
		})
		
		self.selected = gfx_hud_text_add("/common/fonts/Arial12")
		self.selected.parent=self.left
		self.selected.colour = vec(1, 1, 1)
		self.selected.text="Selected: none"
		self.selected.position = vec2(self.selected.size.x/2, self.selected.position.y)		
    end;

    destroy = function (self)
		self.needsParentResizedCallbacks = false
		self.needsFrameCallbacks = false
		self:destroy()
    end;

    parentResizedCallback = function (self, psize)
		self.position = vec(psize.x/2, self.size.y/2)
		self.size = vec(psize.x, self.size.y)
    end;
	frameCallback = function(self, elapsed)
		self.fps.text = string.format("FPS: %3.0f", 1/nonzero(gfx.frameTime:calcAverage()))
		self.fps.position = vec2(-self.fps.size.x/2, self.fps.position.y)
		
		local x,y,z = unpack(player_ctrl.speedoPos)
		self.pos.text = string.format("POS: %+5.4f | %+5.4f | %+5.4f", x, y, z)
		
		self.selected.position = vec2(self.selected.size.x/2, self.selected.position.y)
	end;
}