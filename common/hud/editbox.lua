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

EditBox = {
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
	editing = false;
	isPassword = false;
	selection = vec(0, 0); -- begin, end
	selectionBG = nil;
	clickedInside = false;
	
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

		self.selectionBG = gfx_hud_object_add(`Rect`, {
            colour = 1 - self.textColour;
            parent = self;
        })
		self.selectionBG.enabled = false
		
        self.inside = false
        self:setGreyed(not not self.greyed)
        self.caret.enabled = false

        self:setValue(self.value)
    end;

    updateText = function (self)
		if self.isPassword then
			self.text.text = string.rep("*", #self.before+#self.after)
		else
			self.text.text = self.before .. self.after
		end
        self:updateChildrenSize()
        self.value = self.before .. self.after
    end;
    
    setGreyed = function (self, v, no_callback)
        if v then
            self.text.colour = vec(0.5, 0.5, 0.5)
            self:setEditing(false, no_callback)
        else
            self.text.colour = self.textColour
        end
        self.greyed = v
    end;
    
    destroy = function (self)
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside and local_pos
		if inside then
			if self.clickPos then
				local pos = text_char_pos(self.font, self.value, self.inside.x + self.size.x/2 - self.padding)
				if pos ~= self.clickPos then
					self:select(self.clickPos, pos)
					-- print("second pos: "..pos)
				end
			end
		end
    end;

    setEditing = function (self, editing, no_callback)
        local currently_editing = hud_focus == self
        if currently_editing == editing then return end
        if self.greyed then return end
        hud_focus_grab(editing and self or nil)
		if not self.editing then
			self:onEditing(editing)
		end
		self.editing = editing
		if not editing then self:onStopEditing() end
    end;

    setFocus = function (self, editing)
        self.caret.enabled = editing
        self.needsFrameCallbacks = editing
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" then
            if not self.inside then
				if self.editing then
					self:setEditing(false)
					-- self.clickPos = nil
				end
            else
                self:setEditing(true)
                local txt = self.value
                local pos = text_char_pos(self.font, txt, self.inside.x + self.size.x/2 - self.padding)
				if not self.clickPos then
					self.clickPos = pos
					self.selection = vec(0, 0)
					-- print("init pos: "..pos)
				end
                self.before = txt:sub(1, pos)
                self.after = txt:sub(pos+1)
                self:updateText()
            end
		elseif ev == "-left" then
			self.clickPos = nil
        elseif hud_focus == self then
            if ev == "+Return" then
                self:setEditing(false)
				self:enterCallback()
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
			-- TODO: implement copy, paste and cut for selection
			elseif input_filter_pressed("Ctrl") and ev == "+v" then
				-- local str = get_clipboard()
				-- self.promptBefore = self.promptBefore..str
			elseif input_filter_pressed("Ctrl") and ev == "+c" then
				set_clipboard(self:getSelectedText())
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
		local alignment_r = vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)

        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
			-- when the text is larger than the containing box invert the alignment
			if self.size.x-self.padding > self.text.size.x then
				self.text.position = -alignment_r
			else
				self.text.position = alignment_r
			end
        elseif self.alignment == "RIGHT" then
			if self.size.x-self.padding > self.text.size.x then
				self.text.position = alignment_r
			else
				self.text.position = -alignment_r
			end
        end
        self.caret.size = vec(self.caret.size.x, self.size.y-4)
        self.border.size = self.size
        local tw = gfx_font_text_width(self.font, self.before)
        self.caret.position = vec(self.text.position.x -self.text.size.x/2 + tw, 0)
    end;

    select = function (self, a, b)
		-- TODO: set selection background
		-- self.selectionBG:setRect(vec(self.caret.position.x, self.text.position.y-self.text.size.y), vec(, self.text.position.y+self.text.size.y))
		if a < b then
			self.selection = vec(a, b)
		else
			self.selection = vec(b, a)
		end
		-- print(self:getSelectedText())
    end;
	
    getSelectedText = function (self)
		return self.value:sub(self.selection.x+1, self.selection.y)
    end;
	
    removeSelectedText = function (self)
		self.selection = vec(0, 0)
    end;	
	
	-- called when anything is typed
    onChange = function (self)
        -- By default, do nothing, since often people will only care when enter is pressed.
    end;
	
	--called when begin editing
    onEditing = function (self, editing)
		
    end;
	
	-- called when stop editing
    onStopEditing = function (self, editing)
		
    end;
	
	-- called when enter is pressed
	enterCallback = function(self)

	end;
    
    setValue = function (self, value)
        self.before = value
        self.after = ""
        self:updateText()
    end;

}

hud_class `EditBox` (extends(EditBox)
{
	init = function (self)
		EditBox.init(self)
	end;
	
	destroy = function (self)
		EditBox.destroy(self)
	end;
})