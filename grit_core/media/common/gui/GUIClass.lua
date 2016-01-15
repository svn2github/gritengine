------------------------------------------------------------------------------
--  GUI class, an example to be followed by all other GUI classes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

CENTER = vec(0, 0)
LEFT = vec(-1, 0)
RIGHT = vec(1, 0)
TOP = vec(0, 1)
BOTTOM = vec(0, -1)
TOPLEFT = vec(-1, 1)
TOPRIGHT = vec(1, 1)
BOTTOMLEFT = vec(-1, -1)
BOTTOMRIGHT = vec(1, -1)

GuiClass = {
	alpha = 0;
	colour = vec(1, 1, 1);

	align = vec(0, 0);
	
	expand = false;
	expand_x = false;
	expand_y = false;
	
	offset = vec(0, 0);
	expand_offset = vec(0, 0);
	
	init = function (self)
		self.needsParentResizedCallbacks = self.expand or
		self.expand_x or
		self.expand_y or self.align.x ~= 0 or self.align.y ~= 0
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	alignUpdate = function(self, psize)
		self.position = (psize/2 - self.size/2) * self.align + self.offset
	end;
	
	updateExpand = function(self, psize)
		if self.expand then
			self.size = psize + self.expand_offset
		else
			if self.expand_x then
				self.size = vec(psize.x + self.expand_offset.x, self.size.y + self.expand_offset.y)
			end
			
			if self.expand_y then
				self.size = vec(self.size.x + self.expand_offset.x, psize.y + self.expand_offset.y)
			end
		end
	end;

	pr_update = function(self, psize)
		self:updateExpand(psize)
		self:alignUpdate(psize)
	end;	
	
	parentResizedCallback = function(self, psize)
		self:pr_update(psize)
	end;
}

hud_class `GuiClass` (extends(GuiClass)
{
	alpha = 1;
	
	init = function (self)
		GuiClass.init(self)
	end;
	
	destroy = function (self)
		GuiClass.destroy(self)
	end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
})

function create_gui_object(options)
	return gfx_hud_object_add(`GuiClass`, options)
end

function create_rect(options)
	return gfx_hud_object_add(`/common/hud/Rect`, options)
end
