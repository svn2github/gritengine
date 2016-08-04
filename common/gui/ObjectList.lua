------------------------------------------------------------------------------
--  This is a list that can receive hud objects, with multiple sizes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ObjectList` (extends(GuiClass)
{
	alpha = 1;
	size = vec(0, 0);
	zOrder = 0;
	padding = 4;
	cellSpacing = 2;
	orient = "vertical"; -- or horizontal
	
	init = function (self)
		GuiClass.init(self)
		
		self.items = {}
		self.itemsSpace = vec(0, 0)
		
		if self.orient == "vertical" then -- vertical
			self.update = self.updateV
			self.addItem = self.addItemV
		else -- horizontal
			self.update = self.updateH
			self.addItem = self.addItemH
		end
	end;

	destroy = function (self)

	end;

	parentResizedCallback = function (self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
	
	updateV = function(self)	
		local lastsize = -self.cellSpacing*#self.items/2

		for i = 1, #self.items do
			self.items[i].position = vec2(0, self.itemsSpace.y/2 - (self.items[i].size.y+self.cellSpacing)/2 - lastsize)
			lastsize = lastsize + self.items[i].size.y + self.cellSpacing
		end
	end;
	
    addItemV = function (self, itm)
		self.items[#self.items+1] = itm
		itm.parent = self
		self.itemsSpace = vec(0, self.itemsSpace.y + itm.size.y)
		self.size = vec2(math.max(self.size.x, itm.size.x + self.padding*2), self.itemsSpace.y + self.padding*2 + (#self.items-1) * self.cellSpacing)
		self:update()
    end;

	updateH = function(self)	
		local lastsize = -self.cellSpacing*#self.items/2

		for i = 1, #self.items do
			self.items[i].position = vec2(-self.itemsSpace.x/2 + (self.items[i].size.x+self.cellSpacing)/2 + lastsize, 0)
			lastsize = lastsize + self.items[i].size.x + self.cellSpacing
		end
	end;
	
    addItemH = function (self, itm)
		self.items[#self.items+1] = itm
		itm.parent = self
		self.itemsSpace = vec(self.itemsSpace.x + itm.size.x, 0)
		self.size = vec2(self.itemsSpace.x + self.padding*2 + (#self.items-1) * self.cellSpacing, math.max(self.size.y, itm.size.y + self.padding*2))
		self:update()
    end;
})

function gui.list(tab)
	return gfx_hud_object_add(`ObjectList`, tab)
end
