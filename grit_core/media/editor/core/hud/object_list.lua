------------------------------------------------------------------------------
--  This is a list that can receive hud objects, with multiple sizes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `object_list` {
	alpha = 1;
	size = vec(0, 0);
	zOrder = 0;
	border = 4;
	cellspacing = 2;
	type = "v";
	
	init = function (self)
		self.items = {}
		self.itemsspace = vec(0, 0)
		
		if self.type == "v" then -- vertical
			self.update = self.updateV
			self.addItem = self.addItemV
		else -- horizontal
			self.update = self.updateH
			self.addItem = self.addItemH
		end
	end;

	destroy = function (self)

	end;
	
	updateV = function(self)	
		local lastsize = -self.cellspacing*#self.items/2

		for i = 1, #self.items do
			self.items[i].position = vec2(0, self.itemsspace.y/2 - (self.items[i].size.y+self.cellspacing)/2 - lastsize)
			lastsize = lastsize + self.items[i].size.y + self.cellspacing
		end
	end;
	
    addItemV = function (self, itm)
		self.items[#self.items+1] = itm
		itm.parent = self
		self.itemsspace = vec(0, self.itemsspace.y + itm.size.y)
		self.size = vec2(math.max(self.size.x, itm.size.x + self.border*2), self.itemsspace.y + self.border*2 + (#self.items-1) * self.cellspacing)
		self:update()
    end;

	updateH = function(self)	
		local lastsize = -self.cellspacing*#self.items/2

		for i = 1, #self.items do
			self.items[i].position = vec2(-self.itemsspace.x/2 + (self.items[i].size.x+self.cellspacing)/2 + lastsize, 0)
			lastsize = lastsize + self.items[i].size.x + self.cellspacing
		end
	end;
	
    addItemH = function (self, itm)
		self.items[#self.items+1] = itm
		itm.parent = self
		self.itemsspace = vec(self.itemsspace.x + itm.size.x, 0)
		self.size = vec2(self.itemsspace.x + self.border*2 + (#self.items-1) * self.cellspacing, math.max(self.size.y, itm.size.y + self.border*2))
		self:update()
    end;	
}
