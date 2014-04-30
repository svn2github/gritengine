hud_class `Button` {
    caption = "Button";
    captionColour = vec(0, 0, 0);
    captionColourClick = vec(1, 0.5, 0);
    captionColourHover = vec(1, 1, 1);
    captionColourGreyed = vec(0.4, 0.4, 0.4);
    font = `/common/fonts/Impact50`;
    
    colour = vec(1, 1, 1) * 0.5;
    alpha = 0;
    
    init = function (self)
        self.needsInputCallbacks = true
        
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self
        self:setCaption(self.caption)
        
        self.size = self.text.size
        
        self.dragging = false
        self.inside = false
        self.greyed = self.greyed or false
        
        self:refreshState();
    end;
    
    destroy = function (self)
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
        self.size = self.text.size
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self:refreshState();
    end;
    
    refreshState = function (self)
        if self.greyed then
            self.text.colour = self.captionColourGreyed
        else
            if self.dragging and self.inside then
                self.text.colour = self.captionColourClick
            elseif self.inside then
                self.text.colour = self.captionColourHover
            else
                self.text.colour = self.captionColour
            end
        end
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
        error "Button has no associated action."
    end;
}
