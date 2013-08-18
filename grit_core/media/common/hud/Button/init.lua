-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "../Button" {

    textureDown = "Button/Pressed.png";
    textureUp = "Button/Unpressed.png";
    textureHover = "Button/Hover.png";

    caption = "Button";
    captionFont = "/system/misc.fixed";

    init = function (self)
        self.needsInputCallbacks = true

        self.text = gfx_hud_text_add(self.captionFont)
        self.text.text = self.caption
        self.text.parent = self

        self.dragging = false;
        self.inside = false

        self:refreshState();
    end;
	
	destroy = function (self)
		safe_destroy(self.text)
	end;

    refreshState = function (self)
        if self.dragging and self.inside then
            self.texture = self.textureDown
            self.text.colour = vector3(1,1,1)
        elseif self.inside then
            self.texture = self.textureHover
            self.text.colour = vector3(1,1,1)
        else
            self.texture = self.textureUp
            self.text.colour = vector3(1,1,1)
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
            if self.dragging and self.inside then
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


