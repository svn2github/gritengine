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
        self:updateChildrenSize()
        if self.greyed == nil then self.greyed = false end
    end;
    
    setValue = function (self, value)
        self.value = value
        self.text.text = self.value
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
    
    setText = function (self, text)
        self.text.text = text
        self:updateChildrenSize()
    end;

    updateChildrenSize = function (self)
        BorderPane.updateChildrenSize(self)
        local centre = self.size/2 - math.floor(self.size/2)
        if self.alignment == "CENTRE" then
            self.text.position = centre
        elseif self.alignment == "LEFT" then
            self.text.position = centre - vector2(self.size.x/2 -4 - self.text.size.x/2, 0)
        elseif self.alignment == "RIGHT" then
            self.text.position = centre + vector2(self.size.x/2 -4 - self.text.size.x/2, 0)
        end
    end;

})

hud_class "EditBox" (extends (BorderPane) {

    textColour = vector3(0,0,0);
    selectedBorderColour = vector3(1,0,0);
    font = "/common/fonts/misc.fixed";
    value = "Text";
    number = false;

    init = function (self)
        BorderPane.init(self)
        
        self.originalBorderColour = self.borderColour

        self.value = self.value
        self.lastValue = self.value

        self.needsInputCallbacks = true
        self.text = gfx_hud_text_add(self.font)
        self.text.colour = self.textColour
        self:refreshText()
        self.text.parent = self

        self.inside = false
        self.editting = false
        self.anim = 0
        if self.greyed == nil then self.greyed = false end

        self:updateChildrenSize()
    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        if v then
            self.text.colour = vector3(0.5, 0.5, 0.5)
            self:setEditting(false)
        else
            self.text.colour = self.textColour
        end
    end;
    
    refreshText = function (self)
        self.text.text = self.value
    end;

    destroy = function (self)
        self.text = safe_destroy(self.text)
        BorderPane.destroy(self)
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;
    
    setEditting = function (self, editting)
        if self.editting == editting then return end
        self.editting = editting
        if editting then
            self.anim = 0
            self.needsFrameCallbacks = true
        else
            self:setBorderColour(self.originalBorderColour)
            self.needsFrameCallbacks = false
            if self.lastValue ~= self.value then
                self:onChange(self)
                self.lastValue = self.value
            end
        end
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
            elseif ev:sub(1,1) == ":" then
                if self.maxLength == nil or #self.value < self.maxLength then
                    local key = ev:sub(2)
                    local text = self.value
                    if not self.number or
                       key:match("[0-9]") or
                       (key == "." and not text:match("[.]"))
                    then
                        self:setValue(text .. ev:sub(2))
                    end
                end
            else
                --echo(ev)
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
        self.text.position = self.size/2 - math.floor(self.size/2)
    end;
    
    onChange = function (self)
        echo("No onChange: "..tostring(self.value))
    end;
    
    setValue = function (self, value)
        self.value = value
        self:refreshText()
    end;

})

local Control = {

    caption = "Unnamed";

    size = vector2(100,20);
    width = 20;
    
    init = function (self)
        self.needsInputCallbacks = true
        self.alpha = 0
        self.label = gfx_hud_object_add("Label", {parent=self, borderColour=vector3(0,0,0), value=self.caption});
        self.inside = false
        self.dragging = false
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
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        self.label:setGreyed(self.greyed)
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside then
                self:clicked()
            end
            self.dragging = false
        end
    end;
    
    updateChildrenSize = function(self)
        self.label:setRect(-self.size.x/2,-self.size.y/2, self.size.x/2-self.width+1,self.size.y/2)
        self.label:updateChildrenSize()
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
        self:updateChildrenSize();
    end;
    destroy = function(self)
        self.square = safe_destroy(self.square)
        Control.destroy(self)
    end;
    updateAppearance = function (self)
        Control.updateAppearance(self)
        if self.greyed then
            self.square.colour = vec(0.5, 0.5, 0.5)
            self.alphaSquare.alpha = 0
        else
            self.square.colour = tone_map(self.colour)
            self.alphaSquare.alpha = 1 - (self.a or 1)
        end
    end;
    setColour = function(self, v, a)
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
    clicked = function (self)
        echo("clicked")
    end;
})

hud_class "ValueControl" (extends(Control) {
    value = "1";
    init = function (self)
        Control.init(self)    
        self.valueDisplay = gfx_hud_object_add("EditBox", {parent=self, borderColour=vector3(1,1,1), number=self.number, maxLength=self.maxLength})
        self:updateChildrenSize()
        self:setValue(self.value)
    end;
    destroy = function(self)
        self.valueDisplay = safe_destroy(self.valueDisplay)
        Control.destroy(self)
    end;
    updateAppearance = function (self)
        Control.updateAppearance(self)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    updateChildrenSize = function(self)
        Control.updateChildrenSize(self)
        self.valueDisplay:setRect(self.size.x/2-self.width+1,-self.size.y/2+1, self.size.x/2-1,self.size.y/2-1)
        self.valueDisplay:updateChildrenSize()
    end;
    setValue = function(self, v)
        self.valueDisplay:setValue(v)
    end;
    clicked = function (self)
        echo("clicked")
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
    destroy = function(self)
        self.valueDisplay = safe_destroy(self.valueDisplay)
        Control.destroy(self)
    end;
    updateAppearance = function (self)
        Control.updateAppearance(self)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    updateChildrenSize = function(self)
        Control.updateChildrenSize(self)
        self.valueDisplay:setRect(self.size.x/2-self.width,-self.size.y/2, self.size.x/2,self.size.y/2)
        self.valueDisplay:updateChildrenSize()
    end;
    setValue = function(self, v)
        self.valueDisplay.text.text = self.options[v] or "???"
        self.value = v
    end;
    advanceValue = function (self)
        local v = self.value + 1
        if v > #self.options then v = 1 end
        self:setValue(v)
    end;
    clicked = function (self)
        echo("clicked")
    end;
})

