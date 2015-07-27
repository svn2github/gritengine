------------------------------------------------------------------------------
--  GUI class, an example to be followed by all other GUI classes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

GuiClass = {
	alpha = 0;
	colour = vec(1, 1, 1);

	align_center = false;
	align_left = false;
	align_right = false;
	align_top = false;
	align_bottom = false;
	
	expand = false;
	expand_w = false;
	expand_h = false;
	
	offset = vec(0, 0);
	expand_offset = vec(0, 0);
	
	init = function (self)
		self.needsParentResizedCallbacks = self.expand or
		self.expand_w or
		self.expand_h or
		self.align_center or
		self.align_left or
		self.align_right or
		self.align_top or
		self.align_bottom
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	alignUpdate = function(self, psize)
		if not self.align_center then -- align center is default, so just ignore
			local pos_x = self.position.x
			local pos_y = self.position.y
			
			if self.align_left then
				pos_x = -psize.x/2 + self.size.x/2 + self.offset.x
			elseif self.align_right then
				pos_x = psize.x/2 - self.size.x/2 + self.offset.x
			end
			
			if self.align_top then 
				pos_y = psize.y/2 - self.size.y/2 + self.offset.y
			elseif self.align_bottom then
				pos_y = -psize.y/2 + self.size.y/2 + self.offset.y
			end
			
			self.position = vec(pos_x, pos_y)
		end
	end;
	
	updateExpand = function(self, psize)
		if self.expand then
			self.size = psize + self.expand_offset
		else
			if self.expand_w then
				self.size = vec(psize.x + self.expand_offset.x, self.size.y + self.expand_offset.y)
			end
			
			if self.expand_h then
				self.size = vec(self.size.x + self.expand_offset.x, psize.y + self.expand_offset.y)
			end
		end
	end;
	
	parentResizedCallback = function(self, psize)
		self:alignUpdate(psize)
		self:updateExpand(psize)
	end;
}

hud_class `guiclass` (extends(GuiClass)
{
	init = function (self)
		GuiClass.init(self)
	end;
	-- destroy = function (self)
		-- GuiClass.destroy(self)
	-- end;
	
	-- alignUpdate = function(self, psize)
		-- GuiClass.alignUpdate(self)
	-- end;
	
	-- updateExpand = function(self, psize)
		-- GuiClass.updateExpand(self, psize)
	-- end;
	
	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
})

function create_gui_object(options)
	return gfx_hud_object_add(`guiclass`, options)
end

function create_rect(options)
	return gfx_hud_object_add(`/common/hud/Rect`, options)
end
