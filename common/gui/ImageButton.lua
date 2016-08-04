------------------------------------------------------------------------------
--  Image Button
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ImageButton` (extends(GuiClass)
{
	alpha = _current_theme.colours.image_button.alpha;
	size = vec2(24, 24);
    hoverColour = _current_theme.colours.image_button.hover;
    clickColour = _current_theme.colours.image_button.pressed;
	activeColour = _current_theme.colours.image_button.active;
	defaultColour = _current_theme.colours.image_button.base;
	selected = false;
	colour = _current_theme.colours.image_button.base;
	
	hoverTime = 0;
	
	init = function (self)
		GuiClass.init(self)
		self.needsInputCallbacks = true
		self.needsFrameCallbacks = false
		self.dragging = false;
		self.inside = false;
		
		if self.icon_texture ~= nil then
			self.icon = create_rect({ texture = self.icon_texture, size = self.size*0.8, parent = self })
			self.cornered = true;
			if self.texture == nil then
				self.texture = _gui_textures.button;
			end
		end
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
			gui.showtip(self.tip)
			self.hoverTime = -1
			self.needsFrameCallbacks = false
		end
	end;	

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
	
	mousemovecb = function (self, local_pos, screen_pos, inside)
		if self.dragging ~= true and not self.selected then
			if inside then
				self.colour = self.hoverColour
				if self.hoverTime == 0 and self.tip ~= nil then
					self.needsFrameCallbacks = true
				end
			else
				self.colour = self.defaultColour
				self.needsFrameCallbacks = false
				self.hoverTime = 0
				if _tip ~= nil and type(_tip) ~= "table" then
					_tip:destroy()
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
})

function gui.imagebutton(tab)
	return gfx_hud_object_add(`ImageButton`, tab)
end
