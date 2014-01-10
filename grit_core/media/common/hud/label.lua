-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

BorderPane = {
    borderColour = vector3(0,0,0);
    colour = vector3(1,1,1);
    alpha = 1;
}

function BorderPane:init ()
    self.top    = gfx_hud_object_add("/common/hud/Rect", {parent=self})
    self.bottom = gfx_hud_object_add("/common/hud/Rect", {parent=self})
    self.left   = gfx_hud_object_add("/common/hud/Rect", {parent=self})
    self.right  = gfx_hud_object_add("/common/hud/Rect", {parent=self})
    self:setBorderColour(self.borderColour)
    BorderPane.updateChildrenSize(self)
end;

function BorderPane:updateChildrenSize ()
    local sz = self.size

    self.top.size = vector2(sz.x, 1)
    self.top.position = vector2(0, -sz.y/2 + 0.5)

    self.bottom.size = vector2(sz.x, 1)
    self.bottom.position = vector2(0, sz.y/2 - 0.5)

    self.left.size = vector2(1, sz.y)
    self.left.position = vector2(-sz.x/2 + 0.5, 0)

    self.right.size = vector2(1, sz.y)
    self.right.position = vector2(sz.x/2 - 0.5, 0)
end;

function BorderPane:setBorderColour (colour)
    self.top.colour = colour
    self.bottom.colour = colour
    self.left.colour = colour
    self.right.colour = colour
    self.borderColour = colour
end;

function BorderPane:destroy ()
    self.bottom = safe_destroy(self.bottom)
    self.top = safe_destroy(self.top)
    self.left = safe_destroy(self.left)
    self.right = safe_destroy(self.right)
end;



hud_class "BorderPane" (BorderPane)

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


-- Value is always text.  Can set .number to restrict input to numbers, but 
-- empty string is still a valid state. If using .number, use tonumber(blah.value) or 0

hud_class "EditBox" (extends (BorderPane) {

    textColour = vector3(0,0,0);
    selectedBorderColour = vector3(1,0,0);
    font = "/common/fonts/misc.fixed";
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
                echo(self.value)
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
        echo("No onChange: "..tostring(self.value))
    end;
    
    setValue = function (self, value)
        self.value = value
        self.text.text = self.value
        self:updateChildrenSize()
    end;

})

control_being_dragged = nil

local Control = {

    caption = "Unnamed";

    size = vector2(100,20);
    width = 20;
    
    init = function (self)
        self.needsInputCallbacks = true
        self.alpha = 0
        self.label = gfx_hud_object_add("Label", {parent=self, borderColour=vector3(0,0,0), value=self.caption});
        self.inside = false
        self.greyed = not not self.greyed
    end;
    
    destroy = function(self)
        self.label = safe_destroy(self.label)
    end;
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self.label:setGreyed(self.greyed)
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            control_being_dragged = self
        elseif ev == "-left" then
            if control_being_dragged == self then
                if self.inside then
                    self:onClick()
                    control_being_dragged = nil
                end
            else
                if control_being_dragged ~= nil and self.inside then
                    self:receiveDrag(control_being_dragged)
                    control_being_dragged = nil
                end
            end
        end
    end;
    
    updateChildrenSize = function(self)
        self.label:setRect(-self.size.x/2,-self.size.y/2, self.size.x/2-self.width+1,self.size.y/2)
        self.label:updateChildrenSize()
    end;

    receiveDrag = function (self, other)
    end;

    onClick = function (self)
    end;
}

hud_class "ColourControl" (extends(Control) {
    initialColour = vector3(1,1,0.5);
    initialAlpha = 1;
    init = function (self)
        Control.init(self)
        self.square = gfx_hud_object_add("BorderPane", {parent=self, borderColour=vector3(0,0,0)})
        self.alphaSquare = gfx_hud_object_add("Rect", {parent=self, texture = "EnvCycleEditor/bg_alphabox.png"})
        self:setColour(self.initialColour, self.initialAlpha)
        self:updateAppearance()
        self:updateChildrenSize();
    end;
    destroy = function(self)
        self.square = safe_destroy(self.square)
        Control.destroy(self)
    end;
    updateAppearance = function (self)
        if self.greyed then
            self.square.colour = vec(0.5, 0.5, 0.5)
            self.alphaSquare.alpha = 0
        else
            self.square.colour = tone_map(self.colour)
            self.alphaSquare.alpha = 1 - (self.a or 1)
        end
    end;
    setColour = function(self, v, a)
        if type(v) == "vector4" and a == nil then
            a = v.w
            v = v.xyz
        end
        self.colour = v
        self.a = a
        self:updateAppearance()
    end;
    updateChildrenSize = function(self)
        Control.updateChildrenSize(self)
        self.square:setRect(self.size.x/2-self.width,-self.size.y/2, self.size.x/2,self.size.y/2)
        self.square:updateChildrenSize()
        self.alphaSquare:setRect(self.size.x/2-self.width/2+1, -self.size.y/2+1, self.size.x/2-1, self.size.y/2-1)
    end;
    onClick = function (self)
        echo("onClick")
    end;
    receiveDrag = function (self, other)
        if other.className ~= self.className then return end
        self:setColour(other.colour, other.a)
    end;
})

hud_class "ValueControl" (extends(Control) {
    initialValue = 1;
    format = "%0.3f";
    maxValue = 1;
    init = function (self)
        Control.init(self)    
        self.valueDisplay = gfx_hud_object_add("EditBox", {
            parent=self;
            borderColour=vector3(1,1,1);
            number=true;
            text="INIT";
            maxLength=self.maxLength;
            -- from inside out
            onChange = function (self2)
                local v = tonumber(self2.value) or 0
                self.value = v
                self:onChange()
            end;
            onEditting = function(self2, editting)
                if editting == false then
                    local v = tonumber(self2.value) or 0
                    if v > self.maxValue then
                        v = self.maxValue
                        self.valueDisplay:setValue(self:formatValue(v))
                    end
                    self.value = v
                    self:onChange()
                end
                self:onEditting(editting)
            end;
            onClick = function() self:onClick() end;
        })
        self:updateChildrenSize()
        self:setValue(self.initialValue)
    end;
    destroy = function(self)
        self.valueDisplay = safe_destroy(self.valueDisplay)
        Control.destroy(self)
    end;
    setGreyed = function (self, v)
        Control.setGreyed(self, v)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    updateChildrenSize = function(self)
        Control.updateChildrenSize(self)
        self.valueDisplay:setRect(self.size.x/2-self.width+1,-self.size.y/2+1, self.size.x/2-1,self.size.y/2-1)
        self.valueDisplay:updateChildrenSize()
    end;
    -- from outside in
    setValue = function (self, v)
        if type(v) ~= "number" then error("Not a number: "..tostring(type(v))) end
        if v > self.maxValue then v = self.maxValue end
        self.value = v
        self.valueDisplay:setValue(self:formatValue(v))
    end;
    formatValue = function (self,v)
        return self.format:format(v)
    end;
    onClick = function (self)
        echo("ValueControl.onClick")
    end;
    onChange = function (self)
        echo("ValueControl.onChange")
    end;
    onEditting = function (self, editting)
        echo("ValueControl.onEditting")
    end;
    receiveDrag = function (self, other)
        if other.className ~= self.className then return end
        self:setValue(other.value)
    end;
})

hud_class "EnumControl" (extends (Control) {
    value = 1;
    options = { "False", "True" };
    init = function (self)
        Control.init(self)
        self.valueDisplay = gfx_hud_object_add("Label", {parent=self, borderColour=vector3(0,0,0)})
        self:setValue(self.value)
        self:updateChildrenSize()
    end;
    destroy = function (self)
        self.valueDisplay = safe_destroy(self.valueDisplay)
        Control.destroy(self)
    end;
    setGreyed = function (self, v)
        Control.setGreyed(self, v)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    updateChildrenSize = function (self)
        Control.updateChildrenSize(self)
        self.valueDisplay:setRect(self.size.x/2-self.width,-self.size.y/2, self.size.x/2,self.size.y/2)
        self.valueDisplay:updateChildrenSize()
    end;
    setValue = function (self, v)
        self.valueDisplay.text.text = self.options[v] or "???"
        self.value = v
    end;
    getTextValue = function (self, v)
        return self.options[self.value]
    end;
    advanceValue = function (self)
        local v = self.value + 1
        if v > #self.options then v = 1 end
        self:setValue(v)
        self:onChange()
    end;
    onClick = function (self)
        advanceValue()
    end;
    onChange = function (self)
        echo("EnumControl.onChange")
    end;
    
})

