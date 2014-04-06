-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Value is always text.  Can set .number to restrict input to numbers, but 
-- empty string is still a valid state. If using .number, use tonumber(blah.value) or 0

hud_class "EditBox" (extends (BorderPane) {

    textColour = vector3(0,0,0);
    selectedBorderColour = vector3(1,0,0);
    font = "/common/fonts/Verdana12";
    value = "Text";
    number = false;
    alignment = "CENTER";

    init = function (self)
        BorderPane.init(self)
        
        self.originalBorderColour = self.borderColour

        self.value = self.value

        self.needsInputCallbacks = true
        self.text = gfx_hud_text_add(self.font)
        self.text.colour = self.textColour
        self.text.parent = self
        self.text.text = self.value

        self.inside = false
        self.editting = false
        self.anim = 0
        if self.greyed == nil then self.greyed = false end

        self:updateChildrenSize()
    end;
    
    setGreyed = function (self, v)
        if v then
            self.text.colour = vector3(0.5, 0.5, 0.5)
            self:setEditting(false)
        else
            self.text.colour = self.textColour
        end
        self.greyed = v
    end;
    
    destroy = function (self)
        self.text = safe_destroy(self.text)
        BorderPane.destroy(self)
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    onEditting = function (self, editting)
    end;
    
    setEditting = function (self, editting)
        if self.editting == editting then return end
        if self.greyed then return end
        self.editting = editting
        if editting then
            self.anim = 0
            self.needsFrameCallbacks = true
        else
            self:setBorderColour(self.originalBorderColour)
            self.needsFrameCallbacks = false
        end
        self:onEditting(editting)
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" then
            self:setEditting(self.inside)
        elseif self.editting then
            if ev == "+Return" then
                self:setEditting(false)
            elseif ev == "+BackSpace" or ev == "=BackSpace" then
                self:setValue(self.value:sub(1,-2))
                self:onChange(self)
            elseif ev:sub(1,1) == ":" then
                if self.maxLength == nil or #self.value < self.maxLength then
                    local key = ev:sub(2)
                    local text = self.value
                    if not self.number or
                       key:match("[0-9]") or
                       (key == "." and not text:match("[.]"))
                    then
                        self:setValue(text .. ev:sub(2))
                        self:onChange(self)
                    end
                end
            end
        end
    end;
    
    frameCallback = function (self, elapsed)
        self.anim = ( self.anim + elapsed ) % 1
        local alpha = math.pow(math.sin(self.anim * 2 * math.pi)/2+0.5,1/2.2)
        self:setBorderColour(lerp(self.originalBorderColour, self.selectedBorderColour, alpha))
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
    
    onChange = function (self)
        print("No onChange: "..tostring(self.value))
    end;
    
    setValue = function (self, value)
        self.value = value
        self.text.text = self.value
        self:updateChildrenSize()
    end;

})
