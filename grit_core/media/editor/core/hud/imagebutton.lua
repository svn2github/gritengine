-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `imagebutton` {
	alpha = 1;
	size=vec2(24, 24);
    hoverColour = vec(1, 0.8, 0.5);
    clickColour = vec(1, 0.5, 0);
	activeColour = vec(0.2, 0.7, 1);
	defaultColour = vec(1, 1, 1);
	selected = false;
	hoverTime = 0;
	
	init = function (self)
		self.needsInputCallbacks = true
		self.needsFrameCallbacks = false
		self.dragging = false;
		self.inside = false;
	end;

    destroy = function (self)
		self:destroy()
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		self:mousemovecb(local_pos, screen_pos, inside)
	end;

	frameCallback = function (self, elapsed)
		self.hoverTime = self.hoverTime + elapsed
		if self.hoverTime >= 0.9 then
			show_tip(self.tip)
			self.hoverTime = -1
			self.needsFrameCallbacks = false
		end
	end;	
	
	mousemovecb = function (self, local_pos, screen_pos, inside)
		if self.dragging ~= true and not self.selected then
			if inside then
				self.colour = self.hoverColour
				if self.hoverTime == 0 and self.tip ~= nil then
					self.needsFrameCallbacks = true
				end
			else
				self.colour=self.defaultColour
				self.needsFrameCallbacks = false
				self.hoverTime = 0
				if TIP ~= nil and type(TIP) ~= "table" then
					TIP:destroy()
				end
			end
		end
	end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
			if not self.selected then
				self.colour = self.clickColour
			end
			self.position = vec2(self.position.x, self.position.y - 1)
        elseif ev == "-left" then
            if self.dragging and not self.greyed then
                self.position = vec2(self.position.x, self.position.y + 1)
				if self.inside then
					self:pressedCallback()
				end
			end
			if not self.destroyed then -- if pressed callback destroy itself
				self.dragging = false
				
				if not self.selected then
					self.colour = self.defaultColour
				end
			end
        end
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
	
    select = function (self, m)
        self.selected = m
		if m == true then
			self.colour = self.activeColour
		else
			self.colour = self.defaultColour
		end
    end;	
}