-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- What character index corresponds to the given pixel position?
-- Returns between 0 and #text inclusive
function text_char_pos (font, text, x)
    local len = #text
    local last_char_pos = 0
    for i=1, len do
        local this_char_pos = gfx_font_text_width(font, text:sub(1, i))
        if this_char_pos > x then
            if math.abs(last_char_pos - x) < math.abs(this_char_pos - x) then
                return i - 1
            else
                return i
            end
        end
        last_char_pos = this_char_pos
    end
    return len
end

-- Value is always text.  Can set .number to restrict input to numbers, but 
-- empty string is still a valid state. If using .number, use tonumber(blah.value) or 0

hud_class `EditBox` {

    textColour = vec(1, 1, 1);
    borderColour = 0.4 * vec(1, 1, 1);
    padding = 4;
    colour = 0.25 * vec(1, 1, 1);
    texture = `CornerTextures/Filled02.png`;
    cornered = true;
    font = `/common/fonts/Verdana12`;
    value = "Text";
    number = false;
    alignment = "CENTER";

    init = function (self)


        self.needsInputCallbacks = true
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self

        self.border = gfx_hud_object_add(`Rect`, {
            texture = `CornerTextures/Border02.png`;
            colour = self.borderColour;
            cornered = true;
            parent = self;
        })

        self.caret = gfx_hud_object_add(`Rect`, {
            texture = `CornerTextures/Caret.png`;
            colour = self.textColour;
            cornered = true;
            parent = self;
        })

        self.inside = false
        self:setGreyed(not not self.greyed)
        self:setEditting(false, true)

        self:setValue(self.value)
    end;

    updateText = function (self)
        self.text.text = self.before .. self.after
        self:updateChildrenSize()
        self.value = self.before .. self.after
    end;
    
    setGreyed = function (self, v, no_callback)
        if v then
            self.text.colour = vec(0.5, 0.5, 0.5)
            self:setEditting(false, no_callback)
        else
            self.text.colour = self.textColour
        end
        self.greyed = v
    end;
    
    destroy = function (self)
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside and local_pos
    end;

    onEditting = function (self, editting)
    end;
    
    setEditting = function (self, editting, no_callback)
        if self.editting == editting then return end
        if self.greyed then return end
        self.editting = editting
        self.caret.enabled = editting
        self.needsFrameCallbacks = editting
        if not no_callback then
            self:onEditting(editting)
        end
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" then
            if self.inside == false then
                self:setEditting(false)
            else
                self:setEditting(true)
                local txt = self.value
                local pos = text_char_pos(self.font, txt, self.inside.x + self.size.x/2 - self.padding)
                self.before = txt:sub(1, pos)
                self.after = txt:sub(pos+1)
                self:updateText()
            end
        elseif self.editting then
            if ev == "+Return" then
                self:setEditting(false)
            elseif ev == "+BackSpace" or ev == "=BackSpace" then
                self.before = self.before:sub(1, -2)
                self:updateText()
                self:onChange(self)
            elseif ev == "+Delete" or ev == "=Delete" then
                self.after = self.after:sub(2)
                self:updateText()
                self:onChange(self)
            elseif ev == "+Left" or ev == "=Left" then
                if #self.before > 0 then
                    local char = self.before:sub(-1, -1)
                    self.before = self.before:sub(1, -2)
                    self.after = char .. self.after
                    self:updateText()
                end
            elseif ev == "+Right" or ev == "=Right" then
                if #self.after > 0 then
                    local char = self.after:sub(1, 1)
                    self.after = self.after:sub(2)
                    self.before = self.before .. char
                    self:updateText()
                end
            elseif ev:sub(1,1) == ":" then
                if self.maxLength == nil or #self.value < self.maxLength then
                    local key = ev:sub(2)
                    local text = self.value
                    if not self.number or
                       key:match("[0-9]") or
                       (key == "." and not text:match("[.]"))
                    then
                        self.before = self.before .. ev:sub(2)
                        self:updateText()
                        self:onChange(self)
                    end
                end
            end
        end
    end;
    
    frameCallback = function (self)
        local state = (seconds() % 0.5) / 0.5
        self.caret.enabled = state < 0.66
    end;

    updateChildrenSize = function (self)
        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
            self.text.position = - vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)
        elseif self.alignment == "RIGHT" then
            self.text.position = vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)
        end
        self.caret.size = vec(self.caret.size.x, self.size.y-4)
        self.border.size = self.size
        local tw = gfx_font_text_width(self.font, self.before)
        self.caret.position = vec(self.text.position.x -self.text.size.x/2 + tw, 0)
    end;
    
    onChange = function (self)
        print("No onChange: "..tostring(self.value))
    end;
    
    setValue = function (self, value)
        self.before = value
        self.after = ""
        self:updateText()
    end;

}

