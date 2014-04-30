-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Label" {

    textColour = vec(1, 1, 1);
    greyColour = vec(0.5, 0.5, 0.5);
    font = "/common/fonts/Verdana12";
    value = "No label";
    alignment = "CENTRE";

    init = function (self)
        self.text = gfx_hud_text_add(self.font)
        self.text.colour = self.textColour
        self.text.parent = self
        self.text.shadow = self.shadow
        self:setValue(self.value)
        if self.greyed == nil then self.greyed = false end
    end;
    
    setValue = function (self, value)
        self.value = value
        self.text.text = value
        self:updateChildrenSize()
    end;

    destroy = function (self)
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self.text.colour = v and self.greyColour or self.textColour
    end;
    
    updateChildrenSize = function (self)
        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
            self.text.position = - vec(self.size.x/2 -4 - self.text.size.x/2, 0)
        elseif self.alignment == "RIGHT" then
            self.text.position = vec(self.size.x/2 -4 - self.text.size.x/2, 0)
        end
    end;

}
