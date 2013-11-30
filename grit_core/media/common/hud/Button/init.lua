-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "../Button" {

    textureDown = "Button/Pressed.png";
    textureUp = "Button/Unpressed.png";
    textureHover = "Button/Hover.png";

    caption = "Button";
    captionFont = "/common/fonts/misc.fixed";

    init = function (self)
        self.needsInputCallbacks = true

        self.text = gfx_hud_text_add(self.captionFont)
        self.text.parent = self
        self:setCaption(self.caption)

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self:refreshState();
    end;
    
    destroy = function (self)
        safe_destroy(self.text)
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
                self.texture = fqn_ex(self.textureUp, self.className)
                self.text.colour = vector3(0.7,0.7,0.7)
        else
            if self.dragging and self.inside then
                self.texture = fqn_ex(self.textureDown, self.className)
                self.text.colour = vector3(1,1,1)
            elseif self.inside then
                self.texture = fqn_ex(self.textureHover, self.className)
                self.text.colour = vector3(1,1,1)
            else
                self.texture = fqn_ex(self.textureUp, self.className)
                self.text.colour = vector3(1,1,1)
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


