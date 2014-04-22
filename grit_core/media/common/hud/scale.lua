-- (c) 2013 Dave Cunningham and the Grit Game Engine Project, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Scale" {

    size = vector2(400,20);

    bgColour = vector3(0.5, 0.5, 0.5);
    bgTexture = nil;
    mgAlpha = 0;
    mgColour = vector3(0.5, 0.5, 0.5);
    mgTexture = nil;

    fgColour = vector3(1,1,1);

    value = 1;
    maxValue = 1;
    format = "%0.3f";
    
    init = function (self)
        self.needsInputCallbacks = true

        self.editBox = gfx_hud_object_add("EditBox", {
            parent=self, number=true, maxLength=5, borderColour=vector3(1,1,1),
            onChange = function(self2) self:editChanged() end,
            onEditting = function(self2, v) self:editEditting(v) end
        })

        self.colour = vector3(0, 0, 0)
        self.greyed = false

        self.sliderBackground = gfx_hud_object_add("Rect")
        self.sliderBackground.parent = self
        self.sliderBackground.colour = self.bgColour
        self.sliderBackground.texture = self.bgTexture
        self.sliderBackground.zOrder = 0

        self.sliderMidground = gfx_hud_object_add("Rect")
        self.sliderMidground.parent = self
        self.sliderMidground.colour = self.mgColour
        self.sliderMidground.alpha = self.mgAlpha
        self.sliderMidground.texture = self.mgTexture
        

        self.slider = gfx_hud_object_add("Rect", {parent=self.sliderMidground, colour=vector3(0,0,0)})
        self.sliderInside = gfx_hud_object_add("Rect", {parent=self.slider, colour=self.fgColour})
        self:updateChildrenSize()

        self.inside = false
        self.dragging = false
        self.localPos = vector2(0,0)

        self:setValue(self.value);
    end;

    destroy = function (self)
    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self.editBox:setGreyed(v)
        self:updateAppearance()
    end;

    setBackgroundColour = function (self, c)
        self.bgColour = c
        self:updateAppearance()
    end;
    
    setMidgroundColour = function (self, c)
        self.mgColour = c
        self:updateAppearance()
    end;
    
    setBackgroundAlpha = function (self, v)
        self.bgAlpha = v
        self:updateAppearance()
    end;
    
    setMidgroundAlpha = function (self, v)
        self.mgAlpha = v
        self:updateAppearance()
    end;
    
    setGamma = function (self, v)
        self.gamma = v
        self:updateAppearance()
    end;
    
    drag = function (self)
        local val = (self.localPos + self.size.x/2 - 1) / self.sliderBackground.size.x
        val = clamp(val, 0, 1)
        if self.gamma then val = math.pow(val, 2.2) end
        self.value = val * self.maxValue
        self.editBox:setValue(self.format:format(self.value))
        self:updateAppearance()
        self:onChange()
    end;
        
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        self.localPos = local_pos.x
        if self.dragging then
            self:drag()
        end
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            self.dragging = true
            if self.inside then
                self:drag()
            end
        elseif ev == "-left" then
            self.dragging = false
        elseif ev == "+up" and self.inside then
            self.value = math.clamp(self.value + 0.001, 0, self.maxValue)
            self.editBox:setValue(self.format:format(self.value))
            self:updateAppearance()
            self:onChange()
        elseif ev == "+down" and self.inside then
            self.value = math.clamp(self.value - 0.001, 0, self.maxValue)
            self.editBox:setValue(self.format:format(self.value))
            self:updateAppearance()
            self:onChange()
        end
    end;
    
    editChanged = function (self)
        self.value = tonumber(self.editBox.value)
        if self.value > self.maxValue then
            self.value = self.maxValue
        end
        self:updateAppearance()
        self:onChange()
    end;

    editEditting = function (self, editting)
        if editting then return end
        self:editChanged()
        self.editBox:setValue(self.format:format(self.value))
    end;

    updateAppearance = function (self)
        local val = math.clamp(self.value / self.maxValue, 0, 1)
        if self.gamma then
            val = math.pow(val, 1/2.2)
        end
        self.slider.position = vector2((val - 0.5) * (self.sliderMidground.size.x-1),0)
        if self.greyed then
            self.sliderBackground.colour = vector3(0.5, 0.5, 0.5)
            self.sliderBackground.texture = nil
            self.sliderMidground.enabled = false
            self.slider.colour = vector3(0.35, 0.35, 0.35)
            self.sliderInside.colour = vector3(0.65, 0.65, 0.65)
        else
            self.sliderBackground.colour = self.bgColour
            self.sliderBackground.texture = self.bgTexture
            self.sliderMidground.colour = self.mgColour
            self.sliderMidground.texture = self.mgTexture
            self.sliderMidground.alpha = self.mgAlpha
            self.sliderMidground.enabled = true
            self.slider.colour = vector3(0,0,0)
            self.sliderInside.colour = self.fgColour
        end        
    end;

    setValue = function (self, v)
        if v > self.maxValue then v = self.maxValue end
        self.value = v
        self.editBox:setValue(self.format:format(self.value))
        self:updateAppearance()
    end;

    updateValue = function (self)
    end;

    updateChildrenSize = function (self)
        local sz = self.size
        local left   = -sz.x/2
        local right  =  sz.x/2
        local bottom = -sz.y/2
        local top    =  sz.y/2
        self.sliderBackground:setRect(left+1, bottom+1, right-1-40-1, top-1)
        self.sliderMidground:setRect(left+1, bottom+1, right-1-40-1, top-1)
        self.editBox:setRect(right-1-40, bottom+1, right-1, top-1)
        self.editBox:updateChildrenSize()
        self.slider.size = vector2(3, sz.y-2)
        self.sliderInside.size = vector2(1, sz.y-2)
        self:updateAppearance()
    end;
    
    onChange = function (self)
        print("Changed to: "..self.value)
    end;
}
