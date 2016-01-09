------------------------------------------------------------------------------
--  GUI class, an example to be followed by all other GUI classes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO (new align): replace all editor source code from "align_left, align_top" idea to ex. align(-1, 1)
-- After that remove all this backward compatibility code

GuiClass = {
	alpha = 0;
	colour = vec(1, 1, 1);

	align = vec(0, 0); -- CENTER = vec(0, 0), RIGHT = vec(1, 0), LEFT = vec(-1, 0)...
	
	-- REMOVE THIS (new align):
		align_center = false;
		align_left = false;
		align_right = false;
		align_top = false;
		align_bottom = false;
	-- ||
	
	expand = false;
	expand_x = false;
	expand_y = false;
	
	offset = vec(0, 0);
	expand_offset = vec(0, 0);
	
	init = function (self)
		self.needsParentResizedCallbacks = self.expand or
		self.expand_x or
		self.expand_y or
		
		-- REMOVE THIS (new align):
			self.align_center or
			self.align_left or
			self.align_right or
			self.align_top or
			self.align_bottom
		-- ||
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	alignUpdate = function(self, psize)
		-- REMOVE THIS (new align):
			if not self.align_center then
			local v1, v2 = 0, 0
			if self.align_left then v1 = -1
			elseif self.align_right then v1 = 1 end
			if self.align_top then v2 = 1
			elseif self.align_bottom then v2 = -1 end			
			self.align = vec(v1, v2)
		-- ||
			
			
			
		self.position = (psize/2 - self.size/2) * self.align + self.offset
			
			
			
			
		-- REMOVE THIS (new align):	
			end
		-- ||
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
