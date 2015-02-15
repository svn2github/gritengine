-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- just a draggable box
hud_class `draggable` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	draggingPos = vec2(0, 0);

	init = function (self)
		self.needsFrameCallbacks = true
		self.needsInputCallbacks = true
		
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
	frameCallback = function (self, elapsed)
		
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging == true then			
			self.position = vec2(mouse_pos_abs.x - self.draggingPos.x, mouse_pos_abs.y - self.draggingPos.y)
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.position.x, self.position.y)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
}