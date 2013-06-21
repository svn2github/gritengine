-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print ("Loading console.lua")

Console = { }

function Console:update()
        local str = console_poll()
        if #str == 0 then return end
        self.text:print(str:sub(1,-2))
        self.ticker:print(str:sub(1,-2))
end

function Console:exec(cmd)
        -- keep the current values of the input line safe while we execute cmd
        local old1, old2 = self.prompt.before, self.prompt.after
        self.prompt.before, self.prompt.after = cmd, ""
        self.prompt:execute()
        self:addToHistory(cmd)
        self.prompt.before, self.prompt.after = old1,old2
           
end
                
function Console.new(buffer, cmdBuffer)
        local self = {
                _border = 2,
                prompt_prefix = "lua> ",
                prompt_after_cursor = "",
                prompt_before_cursor = "",
                cmdBuffer = cmdBuffer or {},
                cmdBufferSize = 1000,
                cmdBufferPos = 0,
                freshFrame = true
        }

        self.frame = get_hud_root():addChild("Pane")
        self.frame.resize = function (pw,ph) return 0,0, pw, 0.45*ph end
        self.borderL = self.frame:addChild("Pane")
        self.borderL.material = "system/ConsoleBorder"
        self.borderL.resize = function (pw,ph) return 0,0,self._border,ph-self._border end

        self.borderR = self.frame:addChild("Pane")
        self.borderR.material = "system/ConsoleBorder"
        self.borderR.resize = function (pw,ph) return -1,-1,self._border,ph-self._border end

        self.borderT = self.frame:addChild("Pane")
        self.borderT.material = "system/ConsoleBorder"
        self.borderT.resize = function (pw,ph) return -1,0,pw-self._border,self._border end

        self.borderB = self.frame:addChild("Pane")
        self.borderB.material = "system/ConsoleBorder"
        self.borderB.resize = function (pw,ph) return 0,-1,pw-self._border,self._border end

        self.centerPane = self.frame:addChild("Pane")
        self.centerPane.material = "system/Console"
        self.centerPane.resize = function (pw,ph)
                return self._border,self._border,pw-2*self._border,ph-2*self._border
        end

        self.text = self.centerPane:addChild("ConsoleText", {textKind="ShadowText", buffer=buffer})

        self.ticker = get_hud_root():addChild("TickerText", {textKind="ShadowText", bufferSize = 8 })
        self.ticker.resize = function(pw,ph)
                return 2*self._border, 2*self._border,
                       pw-4*self._border, ph-4*self._border
        end
        self.ticker.visible = false

        self.prompt = ConsolePrompt.new(self)

        make_instance(self,Console,function(k)
                if k == "border" then
                        return true,self._border
                elseif k=="charHeight" or k=="font" then
                        return true,self.prompt[k]
                elseif k=="visible" then
                        return true,self.frame[k]
                end
        end, function (k,v)
                if k=="border" then
                        if tonumber(v)==nil then error("Not a number: "..v,2) end
                        self._border = tonumber(v)
                        self:triggerResize()
                        return true
                elseif k=="visible" then
                        if v then
                                ui:ungrab()
                                ui:flush()
                        else
                                ui:grab()
                        end
                        self.ticker.visible = not v
                        self.frame[k] = v
                        return true
                elseif k=="charHeight" or k=="font" then
                        self.text[k] = v
                        self.prompt[k] = v
                        self:triggerResize()
                        return true
                end
        end)

        self.border = 3
		self.charHeight = 13

        -- let UI.system process keypresses first so that ui:shift() etc work properly for us
        ui.pressCallbacks:insert("grit_console",
                                 function(key,...) return self.callback(key,self,...) end,
                                 ui.pressCallbacks:getIndexSafe("UI.system")+1)
        main.frameCallbacks:insert("grit_console",function ()
                self.freshFrame = true
                self.ticker:tick()
                self:update()
        end)

        return self
end

function Console:clear()
        self.text:clear()
end

function Console:triggerResize()
        self.frame:triggerResize()
        local padding = 2
        self.prompt.resize = function () return padding,-1-padding end
        self.text.resize = function (pw, ph)
                local height = ph-2*padding-self.prompt.height
                height = math.floor(height/self.text.charHeight)
                height = height * self.text.charHeight
                return padding, -1-padding-self.prompt.height, pw-2*padding, height
        end
end

function Console:destroy()
        get_hud_root():removeChild(self.frame)
        get_hud_root():removeChild(self.ticker)
        ui.pressCallbacks:removeByName("grit_console")
        main.frameCallbacks:removeByName("grit_console")
end

function Console:addToHistory(line)
        table.insert(self.cmdBuffer,1,line)
        -- chop top if too long
        if #self.cmdBuffer > self.cmdBufferSize then
                table.remove(self.cmdBuffer,#self.cmdBuffer+1)
        end
end

function Console.callback(key,self)
        if ui:mouse(key) then return true end -- disregard mouse events
        if not self.frame.visible then return true end -- disregard events while console up

        local key2 = (key:sub(1,1) == '+' or key:sub(1,1)=='=') and key:sub(2) or nil
        --print("\""..key2.."\"")
        if key2=="Return" then
                if self.prompt:get():len() > 0 and
                   self.prompt:get() ~= self.cmdBuffer[1] then
                        self:addToHistory(self.prompt:get())
                end
                self.prompt:execute()
                self.cmdBufferPos = 0
                if self.text:getStartChunk() ~= 1 then
                        self.text:setStartChunk(1)
                end
        elseif ui:ctrl() and key2=="a" then
                self.prompt:first()
        elseif ui:ctrl() and key2=="e" then
                self.prompt:last()
        elseif ui:ctrl() and key2=="k" then
                self.prompt:cut()
        elseif ui:ctrl() and (key2=="v" or key2=="y") then
                self.prompt:paste()
        elseif ui:ctrl() and key2=="w" then
                self.prompt:deleteWord()
        elseif ui:ctrl() and key2=="d" then
                self.prompt:delete()
        elseif key2=="Delete" then
                self.prompt:delete()
        elseif key2=="BackSpace" then
                self.prompt:backspace()
        elseif key2=="Up" then
                if self.cmdBufferPos == 0 and self.prompt:get() ~= "" then
                        table.insert(self.cmdBuffer,1,self.prompt:get())
                        if #self.cmdBuffer > self.cmdBufferSize then
                                table.remove(self.cmdBuffer,#self.cmdBuffer+1)
                        end
                        self.cmdBufferPos = 1
                end
                if self.cmdBuffer[self.cmdBufferPos+1] ~= nil then
                        self.cmdBufferPos = self.cmdBufferPos + 1
                end
                self.prompt:set(self.cmdBuffer[self.cmdBufferPos] or "")
        elseif key2=="Down" then
                if self.cmdBufferPos == 0 and self.prompt:get() ~= "" then
                        table.insert(self.cmdBuffer,1,self.prompt:get())
                        if #self.cmdBuffer > self.cmdBufferSize then
                                table.remove(self.cmdBuffer,#self.cmdBuffer+1)
                        end
                        self.prompt:set("")
                elseif self.cmdBufferPos > 0 then
                        self.cmdBufferPos = self.cmdBufferPos - 1
                        self.prompt:set(self.cmdBuffer[self.cmdBufferPos] or "")
                end
        elseif key2=="Left" then
                self.prompt:left()
        elseif key2=="Right" then
                self.prompt:right()
        elseif key2=="Home" then
                self.text:setStartChunk(#self.text.buffer,self.freshFrame)
        elseif key2=="End" then
                self.text:setStartChunk(1,self.freshFrame)
        elseif key2=="PageUp" then
                local page_qty = self.text:getStartChunk()
                page_qty = page_qty + math.floor(self.text.height/self.text.charHeight - 1)
                if page_qty > #self.text.buffer then page_qty = #self.text.buffer end
                self.text:setStartChunk(page_qty,self.freshFrame)
        elseif key2=="PageDown" then
                local page_qty = self.text:getStartChunk()
                page_qty = page_qty - math.floor(self.text.height/self.text.charHeight - 1)
                if page_qty < 1 then page_qty = 1 end
                self.text:setStartChunk(page_qty,self.freshFrame)
        elseif key:sub(1,1) == ':' then
                self.cmdBufferPos = 0
                self.prompt:append(key:sub(2))
        end
        self.freshFrame = false
        return false
end


do
        local cmdBuffer = {}
        local buffer = {}
        if console ~= nil then
                buffer = console.text.buffer
                cmdBuffer = console.cmdBuffer
                console:destroy()
        end
        console = Console.new(buffer,cmdBuffer)
end

