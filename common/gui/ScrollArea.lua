------------------------------------------------------------------------------
--  Scroll bar
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ScrollBar`
{
	alpha = 1;
	size = vec(10, 10);
	zOrder = 0;
	dragging = false;
	draggingPos = vec2(0, 0);
	cornered = false;
	--texture = `/common/hud/CornerTextures/Filled04.png`;
	texture=nil;
	baseColour = _current_theme.colours.scroll_bar.base;
	dragColour = _current_theme.colours.scroll_bar.pressed;
	
	init = function (self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks = false
		
		if self.type == "x" then
			self.mouseMove = self.mouseMoveTypeX
			self.updateSize = self.updateSizeX
		else
			self.mouseMove = self.mouseMoveTypeY
			self.updateSize = self.updateSizeY
		end
		
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

	mouseMoveTypeX = function(self)
		local gt = nonzero(self.parent.size.x/2 -self.size.x/2)
		self.position = vec(math.clamp(mouse_pos_abs.x - self.draggingPos.x, -gt, gt), self.position.y)

		self.parent.content_pos = vec(self.position.x / gt, self.parent.content_pos.y)
	end;

	mouseMoveTypeY = function(self)
		local gt = nonzero(self.parent.size.y/2 -self.size.y/2)
		self.position = vec2(self.position.x, math.clamp(mouse_pos_abs.y - self.draggingPos.y, -gt, gt))

		self.parent.content_pos = vec(self.parent.content_pos.x, self.position.y / gt)
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside

		if self.dragging == true then
			self:mouseMove()
			self.parent:updatecontent()
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - self.position
			self.colour = self.dragColour
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.colour = self.baseColour
			
			self.parent:updateContentInfo()
        end
    end;
	
	updateSizeX = function(self)
		if self.parent.content ~= nil and not self.parent.content.destroyed then
			if self.parent.content.size.x ~= 0 and self.parent.size.x ~= 0 then
				if self.parent.size.x < self.parent.content.size.x then
					self.size = vec(math.min(self.parent.size.x / (self.parent.content.size.x / self.parent.size.x), self.parent.size.x), self.size.y)
				else
					self.size = vec(self.parent.size.x, self.size.y)
				end
			end
			local gt = self.parent.size.y/2 -self.size.y/2
			self.position = vec(math.clamp((self.parent.size.x/2-self.size.x/2)*self.parent.content_pos.x, -gt/2, gt/2), -self.parent.size.y/2+self.size.y/2)
		end
	end;
	
	updateSizeY = function(self)
		if self.parent.content ~= nil and not self.parent.content.destroyed then
			if self.parent.content.size.y ~= 0 and self.parent.size.y ~= 0 then
				if self.parent.size.y < self.parent.content.size.y then
					self.size = vec(self.size.x, math.min(self.parent.size.y / (self.parent.content.size.y / self.parent.size.y), self.parent.size.y))
				else
					self.size = vec(self.size.x, self.parent.size.y)
				end
			end
			local gt = self.parent.size.y/2 -self.size.y/2
			self.position = vec(self.parent.size.x/2-self.size.x/2, math.clamp(((self.parent.size.y/2-self.size.y/2)*self.parent.content_pos.y), -gt, gt))
		end
	end;
}

hud_class `ScrollArea` (extends(_gui.class)
{
	size = vec(0, 0);
	alpha = 1;

	colour = _current_theme.colours.file_explorer.background;
	
	expand = true;
	
	content_pos = vec(-1, 1);
	
	mode_x = false;
	mode_y = false;
	
	x_bar = true;
	y_bar = true;
	
    init = function (self)
		_gui.class.init(self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;

		self.content = create_rect({
			alpha = 0.3, parent = self,
			colour = vec(1, 0, 0),
			size = vec(650, 600),
			zOrder = 1
		})
		
		self.ref_pos = vec(0, 0)
		
		self.scrollbar_x = gfx_hud_object_add(`ScrollBar`, { parent = self, type = "x", zOrder = 3 })
		self.scrollbar_x.enabled = self.x_bar
		self.scrollbar_y = gfx_hud_object_add(`ScrollBar`, { parent = self, type = "y", zOrder = 3 })
		self.scrollbar_y.enabled = self.y_bar
    end;
	
	parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)

		local a, b = self:showOrHideBars()
		
		if not a and not b then self:reset() return end
		
		if self.ref_size == nil then
			self.ref_size = self.size
			
			self:updatecontent()

			self.ref_pos = self.content.position
		else
			-- TODO: when scroll bar reaches the end, the page becomes scrolling the content from top to bottom
			-- but it needs to go back to the normal scroll mode, but when resising the window the scroll bar reaches the end but go back
			-- a little bit, when it needs to stay close to the bottom so the check can work properly and reset only when needed
			-- if -self.scrollbar_y.position.y+self.scrollbar_y.size.y/2 >= self.size.y/2 then
				-- self.mode_y = true
			-- else
				--self.mode_y = false
			-- end

			-- if self.scrollbar_x.position.x+self.scrollbar_x.size.x/2 >= self.size.x/2 then
				-- self.mode_x = true
				-- self.content_pos = vec(1, self.content_pos.y)
			-- else
				--self.mode_x = false
			-- end
			
			local np = self.size - self.ref_size
			
			if self.y_bar then
				-- if self.mode_y then
					-- self.content.position = vec(self.content.position.x, self.ref_pos.y - np.y/2)
				-- else
					self.content.position = vec(self.content.position.x, self.ref_pos.y + np.y/2)
				-- end
			end
			
			if self.x_bar then
				-- if self.mode_x then
					-- self.content.position = vec(self.ref_pos.x + np.x/2, self.content.position.y)
				-- else
					self.content.position = vec(self.ref_pos.x - np.x/2, self.content.position.y)
				-- end			
			end
			self.content_pos = vec(self.content.position.x / nonzero(-self.content.size.x/2 + self.size.x/2),
			self.content.position.y / nonzero(-self.content.size.y/2 + self.size.y/2))
		end
		self.scrollbar_x:updateSize()
		self.scrollbar_y:updateSize()
	end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
	end;

    buttonCallback = function (self, ev)
		if ev == "+up" then
			
		elseif ev == "+down" then
			
		end
    end;
	
	showOrHideBars = function(self, obj)
		if self.x_bar and self.content.size.x > self.size.x then
			self.scrollbar_x.enabled = true
		else
			self.scrollbar_x.enabled = false
		end		

		if self.y_bar and self.content.size.y > self.size.y then
			self.scrollbar_y.enabled = true
		else
			self.scrollbar_y.enabled = false
		end
		return self.scrollbar_x.enabled, self.scrollbar_y.enabled
	end;	
	
	setContent = function(self, obj)
		safe_destroy(self.content)
		if obj ~= nil and not obj.destroyed then
			self.content = obj
			obj.parent = self
			
			self:parentResizedCallback(self.parent.size)
			-- obj.clipOnParent = true
		end
	end;

	updateContentInfo = function(self)
		self.ref_size = self.size
		self.ref_pos = self.content.position
	end;
	
	
	reset = function(self)
		self:updateContentInfo()
		self.content_pos = vec(-1, 1)
		self:updatecontent()
		
		self.scrollbar_x:updateSize()
		self.scrollbar_y:updateSize()
		self.scrollbar_x:mouseMove()
		self.scrollbar_y:mouseMove()
		self:showOrHideBars()
	end;	
	
	updatecontent = function(self)
		self.content.position = vec((-self.size.x/2 + self.content.size.x/2) * -self.content_pos.x,
			(self.size.y/2-self.content.size.y/2) * self.content_pos.y)
	end;
})

function gui.scrollarea(tab)
	return gfx_hud_object_add(`ScrollArea`, tab)
end

-- safe_destroy(xplorer)

-- xplorer = gfx_hud_object_add(`/common/gui/ScrollArea`, {parent = editor_interface.map_editor_page.windows.object_properties;})
