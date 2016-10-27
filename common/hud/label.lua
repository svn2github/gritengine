-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- Label wraps a HUD text object to provide the following additional features:
--
-- Greyout of the text
-- Alignment of the text (LEFT / RIGHT / CENTRE) within the object's dimensions.
-- Background texture / colour (standard HUD object attributes).
--
-- The alignment feature comes into play with the Label is larger than the enclosed text.
hud_class `Label` {

    textColour = vec(1, 1, 1);
    greyColour = vec(0.5, 0.5, 0.5);
    font = `/common/fonts/Verdana12`;
    value = "No label";
    alignment = "CENTRE";

    init = function (self)
        self.text = hud_text_add(self.font)
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
