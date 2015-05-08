-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `radiobutton` {
	alpha = 0;
	colour =vec(0, 1, 0);
	caption="";
	padding = 5;
	float = {
		left = false;
		right = false;
		top = false;
		bottom = false;
	};
	offset = vec(0, 0);
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.icon = gfx_hud_object_add(`/common/hud/Rect`, { parent=self,  position=vec2(0, 0), texture=`../icons/radiobutton_unchecked.png`, size=vec(15, 15) })
		self.text = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.text.parent = self
		self.text.text = self.caption
		
		self:update()
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
		self.inside = inside
	end;
	
    update = function (self)		
		self.size = vec(self.text.size.x+self.padding*4+self.icon.size.x, self.icon.size.y)
		self.icon.position = vec(-self.size.x/2+self.icon.size.x/2, self.icon.position.y)
		self.text.position = vec(-self.size.x/2+self.icon.size.x+self.padding+self.text.size.x/2, self.text.position.y)
	end;	

    buttonCallback = function (self, ev)
		if ev == "-left" and self.inside then
			-- the first radio button creates a table on his parent to point what radio button is selected
			-- when a radio button is selected the previous one is unselected..
			if self.parent.radiobuttons == nil then
				self.parent.radiobuttons = {}
			end
			if self.parent.radiobuttons.selected ~= self and self.parent.radiobuttons.selected ~= nil and not self.parent.radiobuttons.selected.destroyed then
				self.parent.radiobuttons.selected:unselect()
			end
			self.parent.radiobuttons.selected = self
			self:select()
		end
    end;

	floatUpdate = function(self, psize)
		if self.float.left then
			self.position = vec(-psize.x/2+self.size.x/2+self.offset.x, self.offset.y)
		elseif self.float.right then
			self.position = vec(psize.x/2-self.size.x/2+self.offset.x, self.offset.y)
		end
		
		if self.float.top then 
			self.position = vec(self.offset.x, psize.y/2-self.size.y/2+self.offset.y)
		elseif self.float.bottom then
			self.position = vec(self.offset.x, -psize.y/2+self.size.y/2+self.offset.y)
		end
	end;	
	
	parentResizedCallback = function(self, psize)
		self:floatUpdate(psize)
	end;
	
	select = function(self)
		self.icon.texture = `../icons/radiobutton_checked.png`
	end;
	
	unselect = function(self)
		self.icon.texture = `../icons/radiobutton_unchecked.png`
	end;
}

function create_radiobutton(r_caption, r_parent, r_float, r_offset)
	return gfx_hud_object_add(`radiobutton`, { caption = r_caption, parent = r_parent, float = r_float or { left = false, right = false, top = false, bottom = false}, offset = r_offset or vec(0, 0) })
end
