-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- NOT TESTED W.I.P.
hud_class 'radiobutton' {
	alpha = 0;
	size = vec(256, 256);
	zOrder = 0;

	init = function (self)
		self.needsFrameCallbacks = true;
		self.needsInputCallbacks = true;
		self.icon = gfx_hud_object_add('/common/hud/Rect', { parent=self,  position=vec2(0, 0)})
		self.text = gfx_hud_text_add("/common/fonts/Arial12")
		self.text.parent = self
		self.text = "Radiobutton"
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
		self.inside = inside
		
	end;

    buttonCallback = function (self, ev)
		-- the first radio button create a table on his parent to point what radio button is selected
		-- when a radio button is selected the previous one is unselected..
		if self.parent.radiobuttons == nil then
			self.parent.radiobuttons = {}
		end
		if self.parent.radiobuttons.selected ~= self then
			self.parent.radiobuttons.selected:unselect()
		end
		self.parent.radiobuttons.selected = self
		self:select()
    end;
	
	select = function(self)
		self.icon.texture = "pressed"
	end;
	
	unselect = function(self)
		self.icon.texture = "unpressed"
	end;
}
