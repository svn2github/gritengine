-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `.` {

    cornered=true;
    padding=vec(8,6);

    texture = `/common/hud/CornerTextures/Filled08.png`;
    baseColour = vec(1,1,1) * 0.25;
    hoverColour = vec(1, 0.5, 0) * 0.5;
    clickColour = vec(1, 0.5, 0);

    borderTexture = `/common/hud/CornerTextures/Border08.png`;
    borderColour = vec(1, 1, 1) * 0.6;

    font = `/common/fonts/Verdana12`;
    caption = "Button";
    captionColour = vec(1, 1, 1) * 0.7;
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
            elseif self.inside then
                self.colour = self.hoverColour
            else
                self.colour = self.baseColour
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
				if self.destroyed then return end
            end
            self.dragging = false
        end
        self:refreshState()
    end;

    pressedCallback = function (self)
        error "Button has no associated action."
    end;

}


