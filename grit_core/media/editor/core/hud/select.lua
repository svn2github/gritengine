-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `selectmenuitem` {
	alpha = 0;
	size = vec(150, 20);
	value="No text";
	id=0;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.item = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=self.size;
			textColour=vec(0, 0, 0);
			alignment="LEFT";
			value=self.value;
			alpha=0;
		})
		self.dragging = false;
		self.inside = false;
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if inside then
			self.item.colour = vec(1, 0.9, 0.5)
			self.item.alpha = 1
		else
			self.item.colour = vec(1, 1, 1)
			self.item.alpha = 0
		end
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                self:pressedCallback()
				self:endPressedCallback()
            end
            self.dragging = false
        end
    end;

    pressedCallback = function (self)
		self:setSelection()
    end;
	
    setSelection = function (self)
        -- print("Selected: "..self.value.." "..self.id)
		local itm = {}
		itm.name = self.value
		itm.id = self.id
		self.parent.parent:select(itm)
    end;	
	
	endPressedCallback = function (self)
		self.item.colour = vec(1, 1, 1)
		self.item.alpha = 0
		self.parent.enabled = false
	end;
	
	parentResizedCallback = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
	end;
	
}

hud_class `selectmenu` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	lastItem = 0;
	border = 2;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.menuitems = {}
		
		
		self.position = vec2(0, -32)
		self:reorganize()
	end;
	
	reorganize = function(self)
		-- menu item size
		for i=1, #self.menuitems do
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.size = vec2(self.size.x -4, self.menuitems[i].item.size.y)
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			else
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			end
		end
		
		-- menu item and text position
		for i = 1, #self.menuitems do
			self.menuitems[i].position = vec2(0,  self.size.y/2 - ((i-1) * self.menuitems[i].size.y) -self.border -self.menuitems[i].size.y/2)
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.text.position = vec2(-self.menuitems[i].item.size.x/2 + self.menuitems[i].item.text.size.x/2+5, self.menuitems[i].item.text.position.y)
			end
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
	end;

    buttonCallback = function (self, ev)

    end;
	
	parentResizedCallback = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
		self.position=vec2(0, -self.size.y/2 - psize.y/2)
		self:reorganize()
	end;
	
	
    addItem = function (self, itm)
		self.menuitems[#self.menuitems+1] = gfx_hud_object_add(`selectmenuitem`, { value=itm, parent=self, position=vec2(0, self.lastItem), size=vec2(150, 20), id=#self.menuitems })
		self.lastItem = self.lastItem - 20
		self.size = vec2(256, -self.lastItem +5)
		self.position=vec2(0, -self.size.y/2 - self.parent.size.y/2)
		self:reorganize()
    end;
}

hud_class `selectboxicon` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;
    end;
	
    parentResizedCallback = function (self, psize)
        self.position = psize*self.factor + self.offset
    end;
}   

hud_class `selectbox` {
	alpha = 1;
	size = vec(256, 40);
	zOrder = 0;
	colour=vec(0.3, 0.3, 0.3);
	defaulttext = "All Files (*.*)";
	selected={};
	choices = {};
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
	
	init = function (self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
		
		self.icon = gfx_hud_object_add(`selectboxicon`, { texture=`../icons/triangle_icon.png`, size=vec2(15, 15), alpha=1, offset = vec2(-10, 0), factor = vec2(0.5, 0), parent=self, colour=vec(1, 1, 1) })
		self.icon.pressedCallback = function(self, ev) self.parent:showMenu() end;
		
		self.caption_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})
		self.caption = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.caption.parent = self.caption_pos
		self:setTitle(self.defaulttext)
		
		self.menu = gfx_hud_object_add(`selectmenu`, { parent=self })
		
		for i = 1, #self.choices do
			self.menu:addItem(self.choices[i])
		end
		
		if self.selection ~= nil then
			self.menu.menuitems[self.selection+1]:setSelection()
		end
		
		self.menu.enabled = false
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		
	end;
	
	setTitle = function(self, name)
		self.caption.text  = name
		self.caption.position = vec2(self.caption.size.x / 2, self.caption.position.y)
	end;

	showMenu = function(self)
		self.menu.enabled = not self.menu.enabled
	end;

	onSelect = function(self)
		
	end;
	
	select = function(self, itm)
		self.selected = itm
		self:setTitle(self.selected.name)
		self:onSelect()
	end;	
	
	parentResizedCallback = function (self, psize)
		self:parentresizecb(psize)
	end;
	
	parentresizecb = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
	end;

	pressedCallback = function(self, ev)
		self:showMenu()
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
	
    refreshState = function (self)
		if self.dragging and self.inside then
			self.icon.colour = vec(1, 0.5, 0)
			self.colour = vec(1, 0.5, 0)
		elseif self.inside then
			self.icon.colour = vec(1, 0.8, 0.5)
			self.colour = vec(0.35, 0.35, 0.35)
		elseif not self.menu.enabled then
			self.icon.colour = vec(1, 1, 1)
			self.colour = vec(0.3, 0.3, 0.3)
		end
    end;
}