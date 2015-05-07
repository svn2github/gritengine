------------------------------------------------------------------------------
--  Box Sizer
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- DOESN'T WORKS, JUST A CONCEPT..

hud_class `boxsizer` {
	alpha = 1;
	size = vec(256, 256);
	orient = "v"; -- v = vertical, h = horizontal
	expand = true;
	expandType = function(self)end;
	type = "boxsizer";
	
	init = function (self)
		self.needsParentResizedCallbacks = true
		
		self.childs = {}
		
		if self.orient == "v" then
			self.update = self.updateV
		else
			self.update = self.updateH
		end	
		self.expandType = function(self, psize) self.size = psize end;
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
			
		self:destroy()
	end;
	
	parentResizedCallback = function (self, psize)
		if self.expand then
			--self.size = psize
			self:expandType(psize)
		end
		self:update(psize)
	end;
	
	updateV = function (self, psize)
		for i = 1, #self.childs do
			-- self.childs[i].position = vec(self.childs[i].position.x, -psize.y/#self.childs*(i+1))
			if not self.childs[i].destroyed then
				self.childs[i].position = vec(self.childs[i].position.x,
					psize.y/2 - ((i-1) * psize.y/#self.childs+1) -psize.y/2/#self.childs+1
				)
			end
			--psize.y/2 - ((i-1) * self.menuitems[i].size.y) -self.menuitems[i].size.y/2
		end
	end;
	
	addChild = function (self, child)
		self.childs[#self.childs+1] = child
		self.childs[#self.childs].parent = self
		self:update(self.parent.size)
	end;
	
	updateExpandType = function(self)
		if self.expand then
			if self.parent.type ~= nil and #self.parent.childs > 0 then
				if self.parent.type == "boxsizer" then
					if self.parent.orient == "v" then
						self.expandType = function(self) self.size = vec(self.parent.size.x/#self.parent.childs, self.parent.size.y) end
					elseif self.parent.orient == "h" then
						self.expandType = function(self) self.size = vec(self.parent.size.x, self.parent.size.y/#self.parent.childs) end
					end
				elseif self.parent.type == "grid" then
					self.expandType = function(self) self.size = vec(self.parent.size.x/#self.parent.childs, self.parent.size.y/#self.parent.childs) end
				end
			end
		end
	end;
}
