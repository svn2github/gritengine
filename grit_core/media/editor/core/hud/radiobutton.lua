------------------------------------------------------------------------------
--  Radio Button Class
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `radiobutton` (extends(GuiClass)
{
	alpha = 0;
	colour =vec(0, 1, 0);
	caption="";
	padding = 5;
	selected = false;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		
		self.icon = gfx_hud_object_add(`/common/hud/Rect`, { parent = self,  position = vec2(0, 0), texture = `../icons/radiobutton_unchecked.png`, size = vec(15, 15) })
		self.icon_check = gfx_hud_object_add(`/common/hud/Rect`, { parent = self.icon,  position = vec2(0, 0), texture = `../icons/radiobutton_checked.png`, size = self.icon.size })
		self.icon_check.enabled = false
		
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

	-- the first radio button creates a table on its parent to point what radio button is selected
	setParentTable = function(self)
		if self.parent.radiobuttons == nil then
			self.parent.radiobuttons = {}
		end
	end;

    buttonCallback = function (self, ev)
		if ev == "-left" and self.inside then
			self:setParentTable()
			-- when a radio button is selected the previous one is unselected..
			if self.parent.radiobuttons.selected ~= self and self.parent.radiobuttons.selected ~= nil and not self.parent.radiobuttons.selected.destroyed then
				self.parent.radiobuttons.selected:unselect()
			end
			if self.parent.radiobuttons.selected ~= self then
				self:select()
			end
		end
    end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
	
	select = function(self)
		if self.parent ~= nil then
			self:setParentTable()
			self.parent.radiobuttons.selected = self
		end
		self:onSelect()
		self.icon_check.enabled = true
	end;
	
	onSelect = function(self)
		
	end;	
	
	unselect = function(self)
		self.icon_check.enabled = false
	end;
})

function create_radiobutton(options)
	return gfx_hud_object_add(`radiobutton`, options)
end
