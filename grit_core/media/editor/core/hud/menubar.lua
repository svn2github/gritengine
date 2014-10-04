-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- TODO: add icon space and method
hud_class 'menuitem' {
	alpha = 0;
	size = vec(150, 20);
	value="No text";
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.item = gfx_hud_object_add('/common/hud/Label', {
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

    setGreyed = function (self, v)
        self.greyed = v
		self.item:setGreyed(v)
    end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if inside then
			self.item.colour = vec(1, 0.9, 0.5)
			self.item.alpha = 0.7
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
        error "Menu item has no associated action."
    end;	
	
	endPressedCallback = function (self)
		self.parent.parent.parent.parent.selecting = false
		self.parent.enabled=false
		self.item.colour = vec(1, 1, 1)
		self.item.alpha = 0
	end;
}

-- many hacks on this
hud_class 'menu' {
	alpha = 0.8;
	size = vec(256, 256);
	zOrder = 0;
	lastItem = 0;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.menuitems = {}
		
		if self.items ~= nil then
			for i = 1, #self.items do
				if next(self.items[i]) == nil then
					self.menuitems[i] = gfx_hud_object_add("/common/hud/HorizontalLine", {parent=self, position=vec2(0, self.lastItem + 7.5), colour=vec(0.8, 0.8, 0.8)})
					self.menuitems[i]:setThickness(1);
					self.lastItem = self.lastItem - 5
				else
					self.menuitems[i] = gfx_hud_object_add("/editor/core/hud/menuitem", { value=self.items[i].name, pressedCallback=self.items[i].callback, parent=self, position=vec2(0, self.lastItem), size=vec2(150, 20) })
					self.lastItem = self.lastItem - 20
				end
			end
		end
		self.size = vec2(152, (self.lastItem* -1) +5)
		self:reorganize()
	end;
	
	reorganize = function(self)
		for i = 1, #self.menuitems do
			self.menuitems[i].position = vec2(0, self.menuitems[i].position.y + self.size.y/2 -10 - 2.5) -- "-10" is half size of first item, "-2.5" is half size of previous size increment(for border)
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
}

-- actually I just copy the entirely button class to modify a little thing, because I don't know why method overriding isn't working :/
hud_class "menubarbutton" {
    padding=vec(8,6);

    baseColour = vec(1,1,1) * 0.3;
    hoverColour = vec(1, 0.5, 0) * 0.75;
    clickColour = vec(1, 0.5, 0);

    borderColour = vec(1, 1, 1) * 0.6;

    font = `/common/fonts/Verdana12`;
    caption = "Button";
    captionColour = vec(1, 1, 1);
    captionColourGreyed = vec(1, 1, 1) * 0.4;

    init = function (self)
        self.needsInputCallbacks = true

        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self
        self:setCaption(self.caption)

        if not self.sizeSet then 
            self.size = self.text.size + self.padding * 2
        end

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self.border = gfx_hud_object_add(`/common/hud/Rect`, {
            texture=self.borderTexture,
            colour=self.borderColour,
            parent=self,
            cornered=true
        })
        
        self:updateChildrenSize()
        self:refreshState();
    end;

    updateChildrenSize = function (self)
        self.border.size = self.size
    end;
   
    destroy = function (self)
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self:refreshState();
    end;

    refreshState = function (self)
        if self.greyed then
            self.text.colour = self.captionColourGreyed
            self.colour = self.baseColour
        else
            self.text.colour = self.captionColour
            if self.dragging and self.inside then
                self.colour = self.clickColour
				self.text.colour = vec(0, 0, 0)
            elseif self.inside then
                self.colour = self.hoverColour
            else
                self.colour = self.baseColour
            end
        end
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if inside then
			--self:showTip()
			if self.parent.parent.selecting == true then
				self.parent.parent.selected.menu.enabled=false
				self.parent.parent.selected = self
				self.parent.parent.selected.menu.enabled = true
			end
		end
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
        error "Button has no associated action."
    end;

}

-- TODO: make menu x size dynamic

hud_class `MenuBar` {
    colour = vec(0.1, 0.1, 0.1);
    buttonPadding = vec(16, 4);
	lastButton = 0;
	--selected = nil;
	selecting = false;
	spacing = 1;
	
    init = function (self)
        self.needsParentResizedCallbacks = true
		--self.needsInputCallbacks = true
        self.buttons = {}

		self.leftPositioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self;
			offset = vec2(40, 0);
			factor = vec2(-0.5, 0);
		})
		self.line = gfx_hud_object_add('/common/hud/HorizontalLine', {
			parent = self;
			position=vec2(0, -self.size.y/2+1);
			colour=vec(1, 0.5, 0);
			alpha=0.3;
			zOrder=0;
		})
		self.line:setThickness(1)
    end;

	append = function(self, obj, name)
		self.buttons[#self.buttons + 1] = gfx_hud_object_add(`/editor/core/hud/menubarbutton`, {
			menu = obj;
			pressedCallback = function (self)
				if self.menu.enabled ~= true then
					self.menu.enabled = true
					self.menu.position = vec2(self.menu.size.x/2 - self.size.x/2, -self.size.y/2 - self.menu.size.y/2)
				else
					self.menu.enabled = false
				end
				self.parent.parent.selected = self
				
				if self.parent.parent.selecting ~= true then
				self.parent.parent.selecting = true
				else
					self.parent.parent.selecting = false
				end
			end;
			caption = name;
			padding = self.buttonPadding;
			borderTexture = "/common/hud/cornerTextures/SquareBorderWhite.png";
			parent=self.leftPositioner;
		})
		self.buttons[#self.buttons].position=vec2(self.lastButton + (self.buttons[#self.buttons].size.x/2), 0)
		self.lastButton = self.lastButton + self.buttons[#self.buttons].size.x + self.spacing
		obj.parent = self.buttons[#self.buttons]
		obj.position=vec2(obj.size.x/2 - self.buttons[#self.buttons].size.x/2, - self.buttons[#self.buttons].size.y/2 - obj.size.y/2)
		obj.enabled = false
	end;

    destroy = function (self)
		self.needsParentResizedCallbacks = false
		self:destroy()
    end;
	
    parentResizedCallback = function (self, psize)
		self.position = vec(psize.x/2, -15)
		self.size = vec(psize.x, 30)
    end;
	
	-- mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		-- self.inside = inside
	-- end;

	-- -- used to hide menu when click out (doesn't work)
    -- buttonCallback = function (self, ev)
		-- if self.selected == nil then return end
		-- if ev == "+left" and self.inside == false and self.selected.menu.inside == false then
            -- self.selecting = false
			-- self.selected.menu.enabled = false
        -- end
    -- end;
}