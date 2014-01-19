-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Label" (extends (BorderPane) {

    textColour = vector3(0,0,0);
    font = "/common/fonts/misc.fixed";
    value = "No label";
    alignment = "CENTRE";

    init = function (self)
        BorderPane.init(self)
        self.text = gfx_hud_text_add(self.font)
        self.text.colour = self.textColour
        self.text.parent = self
        self:setValue(self.value)
        if self.greyed == nil then self.greyed = false end
    end;
    
    setValue = function (self, value)
        self.value = value
        self.text.text = value
        self:updateChildrenSize()
    end;

    destroy = function (self)
        self.text = safe_destroy(self.text)
        BorderPane.destroy(self)
    end;

    setGreyed = function (self, v)
        self.greyed = v
        if v then
            self.text.colour = vector3(0.5, 0.5, 0.5)
        else
            self.text.colour = self.textColour
        end
    end;
    
    updateChildrenSize = function (self)
        BorderPane.updateChildrenSize(self)
        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
            self.text.position = - vector2(self.size.x/2 -4 - self.text.size.x/2, 0)
        elseif self.alignment == "RIGHT" then
            self.text.position = vector2(self.size.x/2 -4 - self.text.size.x/2, 0)
        end
    end;

})
