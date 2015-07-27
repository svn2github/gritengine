------------------------------------------------------------------------------
--  Checkbox Class
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `checkbox` (extends(GuiClass)
{
	alpha = 0;
	colour =vec(0, 1, 0);
	caption="";
	padding = 5;
	checked = false;

	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		
		self.icon = gfx_hud_object_add(`/common/hud/Rect`, { parent = self,  position = vec2(0, 0), texture = `../icons/checkbox_unchecked.png`, size = vec(15, 15) })
		self.icon_checked = gfx_hud_object_add(`/common/hud/Rect`, { parent = self.icon,  position = vec(0, 0), texture = `../icons/checkbox_checked.png`, size = self.icon.size })
		self.icon_checked.enabled = false
		
		self.text = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.text.parent = self
		self.text.text = self.caption
		
		if self.checked then
			self:check()
		end
		
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
			if self.checked then
				self:uncheck()
				self:onUncheck()
			else
				self:check()
				self:onCheck()
			end
		end
    end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
	
	check = function(self)
		self.icon_checked.enabled = true
		self.checked = true
	end;

	onCheck = function(self)

	end;
	
	uncheck = function(self)
		self.icon_checked.enabled = false
		self.checked = false
	end;
	
	onUncheck = function(self)

	end;	
	
})

function create_checkbox(r_tab)
	return gfx_hud_object_add(`checkbox`, r_tab)
end