hud_class "Ticker" {

    height = 400;
    border = 4;
    bufferSize = 100;
    font = "/common/fonts/misc.fixed";
    messageTime = 8;
    alpha = 0;
    textColour = vec(.75, .75, .75);

    init = function (self)
        self.buffer = self.buffer or {}
        self.timeBuffer = self.timeBuffer or {}
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self
        self.text.shadow = self.shadow
        self.text.letterTopColour = self.textColour
        self.text.letterBottomColour = self.textColour
        self.needsFrameCallbacks = true
        self.needsParentResizedCallbacks = true
    end;

    print = function (self, str)
        table.insert(self.buffer,1,str)
        table.insert(self.timeBuffer,1,seconds())
        if #self.buffer>self.bufferSize then
                table.remove(self.buffer)
                table.remove(self.timeBuffer)
        end
        self:redraw()
    end;

    destroy = function (self)
        safe_destroy(self.text)
    end;

    frameCallback = function (self, elapsed)
        local count = #self.buffer
        local needs_redraw = false
        local i = 1
        while i <= count do
            local time = self.timeBuffer[i]
            if seconds() - time > self.messageTime then
                needs_redraw = true
                table.remove(self.buffer,i)
                table.remove(self.timeBuffer,i)
                i = i - 1
                count = count - 1
            end
            i = i + 1
        end
        if needs_redraw then
            self:redraw()
        end
    end;

    redraw = function (self)
        self.text:clear()
        for i = #self.buffer, 1, -1 do
            self.text:append(self.buffer[i])
            self.text:append("\n")
        end
        self.text.scroll = math.max(0, self.text.bufferHeight - self.text.size.y)
    end;

    parentResizedCallback = function (self, psize)
        self.size = vec(psize.x, self.height)
        self.position = vec(psize.x/2, psize.y - self.height/2)
        self.text.textWrap = self.size - self.border * vec(2,2)
    end;    
}
