-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "imagebutton" {
	alpha = 1;
	size=vec2(32, 32);
    hoverColour = vec(1, 0.8, 0.5);
    clickColour = vec(1, 0.5, 0);

	init = function (self)
		self.needsInputCallbacks = true
		self.dragging = false;
		self.inside = false;
	end;

    destroy = function (self)
		self:destroy()
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.dragging ~= true then
			if inside then
				self.colour = self.hoverColour
			else
				self.colour=vec(1, 1, 1)
			end
		end
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
			self.colour=self.clickColour
			self.position=vec2(self.position.x, self.position.y - 1)
        elseif ev == "-left" then
            if self.dragging and not self.greyed then
                self.position=vec2(self.position.x, self.position.y + 1)
				if self.inside then
					self:pressedCallback()
				end
			end
            self.dragging = false
			self.colour=vec(1, 1, 1)
        end
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
}