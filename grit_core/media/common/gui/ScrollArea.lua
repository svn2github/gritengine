------------------------------------------------------------------------------
--  Scroll bar for now
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `dragbar` {
	alpha = 1;
	size = vec(15, 50);
	zOrder = 0;
	dragging = false;
	draggingPos = vec2(0, 0);
	cornered = true;
	texture = `/common/hud/CornerTextures/Filled04.png`;
	
	baseColour = _current_theme.colours.scroll_bar.base;
	dragColour = _current_theme.colours.scroll_bar.pressed;
	
	init = function (self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks=true
		self.startpos = vec2(0, 0)
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside

		if self.dragging == true then
			self.startpos = vec2(0, self.parent.size.y/2-self.parent.up.size.y-self.size.y/2)
			if self.startpos.y ~= 0 then
				local pcent = (self.position.y + self.startpos.y) / (self.startpos.y * 2)
				self.parent.parent.parent.grid.position = vec2(0,(self.parent.parent.parent.size.y - self.parent.parent.parent.iconarea.y)*(pcent-1))
			else
				self.parent.parent.parent.grid.position = vec2(0, 0)
			end
			self:updateSize(self)
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.position.x, self.position.y)
			self.colour = self.dragColour
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.colour = self.baseColour
        end
    end;
	updateSize = function(self)

	end;
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.startpos = vec2(0, self.parent.size.y/2-self.parent.up.size.y-self.size.y/2)
		end
		-- self:updateSize()
	end;
}

hud_class `rollbuttom` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
	baseColour = _current_theme.colours.scroll_bar.base;
	hoverColour = _current_theme.colours.scroll_bar.hover;
	pressedColour = _current_theme.colours.scroll_bar.pressed;
	
    init = function (self)  
        self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
    end;
	
    parentResizedCallback = function (self, psize)
        --self.size = vec2(self.size.x, psize.y)
        self.position = psize*self.factor + self.offset
    end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self:refreshState()
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                self:pressedCallback()
            end
            self.dragging = false
        end
		self:refreshState()
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
	
    refreshState = function (self)
		if self.dragging and self.inside then
			self.colour = self.pressedColour
		elseif self.inside then
			self.colour = self.hoverColour
		else
			self.colour = self.baseColour
		end
    end;
}   

hud_class `rollbar` {
	alpha = 1;
	size = vec(15, 256);
	zOrder = 0;
	colour = _current_theme.colours.scroll_bar.background;
	cornered = true;
	texture = `/common/hud/CornerTextures/FilledWhiteBorder04.png`;
	
	init = function (self)
		self.needsFrameCallbacks = false;
		self.needsParentResizedCallbacks = true;
		self.up = gfx_hud_object_add(`rollbuttom`, {
			size = vec(15, 15);
			texture = _gui_textures.triangle.up;
			colour=vec(1, 1, 1);
			alpha = 1;
			parent = self;
			offset = vec2(0, -7);
			factor = vec2(0, 0.5);
		})
		self.up.size=vec(15, 15);
		
		self.down = gfx_hud_object_add(`rollbuttom`, {
			size = vec(15, 15);
			texture = _gui_textures.triangle.down;
			colour = vec(1, 1, 1);
			alpha = 1;
			parent = self;
			offset = vec2(0, 7);
			factor = vec2(0, -0.5);
		})
		self.down.size = vec(15, 15);		
		
		self.roll = gfx_hud_object_add(`dragbar`, { size = vec(self.size.x, 50), parent = self })
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;

	parentResizedCallback = function(self, psize)
		self.size = vec2(self.size.x, psize.y)
		--self:updateRolDef()
	end;
	updateRolDef = function(self)
		--self.roll.startpos = vec2(0, self.size.y/2-self.up.size.y-self.roll.size.y/2)
	end;
}





hud_class `ScrollArea` (extends(GuiClass)
{
	size = vec(0, 0);
	alpha = 1;
	icons_size = vec2(80, 80);
    icons_spacing = 4;
	selected = {};
	
	colour = vec(0, 1, 1);
	
	scroll_x = false;
	scroll_y = true;

	expand = true;
	
    init = function (self)
		GuiClass.init(self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
		self.items = {}
		self.grid = create_rect({
			alpha = 1, parent = self,
			colour = vec(1, 0, 0)
		})
		
		self.rollbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(-5, 0);
			factor = vec2(0.5, 0);
			zOrder = 7;
		})

		self.rollbar = gfx_hud_object_add(`/common/gui/rollbar`, { parent = self.rollbar_pos })
		self.rollbar.roll.updateSize = function(self)
			if self.parent.parent.parent.iconarea ~= nil then
				if self.parent.parent.parent.iconarea.y ~= 0 then
					self.size = vec2(self.size.x, math.min(self.parent.parent.parent.size.y / (self.parent.parent.parent.iconarea.y / self.parent.parent.parent.size.y), self.parent.parent.parent.size.y-self.parent.up.size.y*2))
				end
				self.position = vec2(self.position.x, math.clamp(mouse_pos_abs.y - self.draggingPos.y, -(self.parent.size.y/2 -self.size.y/2-self.parent.up.size.y), self.parent.size.y/2 -self.size.y/2-self.parent.down.size.y))
			end
		end;
    end;
	
	parentResizedCallback = function (self, psize)
		GuiClass.parentResizedCallback(self, psize)
		
		if self.scroll_y then
			self.grid.size = vec(self.grid.size.x, psize.y)
		end
		if self.scroll_x then
			self.grid.size = vec(psize.x, self.grid.size.y)
		end

		-- self:reorganize()
	end;

	-- addItem = function(self, m_name, icon, pc, dpc)
		-- if icon == nil then icon = `../icons/icons/foldericon.png`end
		-- self.items[#self.items+1] = gfx_hud_object_add(`browser_icon`, {
			-- icon_texture = icon;
			-- position = vec2(0, 0);
			-- parent = self.grid;
			-- colour = vec(0.5, 0.5, 0.5);
			-- size = vec2(self.icons_size.x, self.icons_size.y);
			-- name = m_name;
		-- })
		
		-- if pc ~= nil then
			-- self.items[#self.items].pressedCallback = pc
		-- end
		-- if dpc ~= nil then
			-- self.items[#self.items].doubleClick = dpc
		-- end
		
		-- self:reorganize()
		-- return self.items[#self.items]
	-- end;
	
	-- reorganize = function(self)
		-- local colums = math.floor(self.size.x / (#self.icons_size.x + self.icons_spacing))
		-- local icol, linepos, li = 1, 0, 1

		
		-- for i = 1, #self.items do
			-- self.items[i].position = vec2(-self.size.x/2 + ((li-1) * (self.icons_size.x )) + (li*self.icons_spacing) + self.icons_size.x/2, self.size.y/2 - self.icons_size.y/2 -linepos*(self.icons_size.y+self.icons_spacing))
			-- if(icol < colums) then
				-- li = li+1
				-- icol=icol+1
			-- else
				-- linepos=linepos+1
				-- icol=1
				-- li = 1
			-- end
		-- end
		
		-- self.iconarea = vec2(colums*(self.icons_size.x+self.icons_spacing), math.ceil(#self.items/colums)*(self.icons_size.y+self.icons_spacing))
		
		-- for i = 1, #self.items do
			-- if (self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y - self.items[i].size.y > self.size.y/2) then
				-- self.items[i].enabled = false
			-- else
				-- self.items[i].enabled = true
			-- end
		-- end
	-- end;
	-- clearAll = function(self)
		-- for i = 1, #self.items do
			-- safe_destroy(self.items[i])
			-- self.items[i]=nil
		-- end
	-- end;

    -- reset = function (self)
		-- self.grid.position = vec(0, 0)
		-- self:updateItems()
		-- self.rollbar.roll:updateSize()
    -- end;	

	updateItems = function(self)
		for i = 1, #self.items do
			-- if (self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y - self.items[i].size.y > self.size.y/2) then
			-- TEMPORARY(until draw only inside parent): (after that, use the commented line above)
			if (self.items[i].position.y + self.grid.position.y - self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 > self.size.y/2) then
				self.items[i].enabled = false
			else
				self.items[i].enabled = true
			end
		end	
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		--if self.rollbar.roll.dragging == true then
			self:updateItems()
		--end
	end;

    buttonCallback = function (self, ev)
		if ev == "+up" then
			
		elseif ev == "+down" then
			
		end
    end;
})



-- xplorer = gfx_hud_object_add(`/common/gui/ScrollArea`, {parent = editor_interface.map_editor_page.windows.level_properties;})





