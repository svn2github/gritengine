

hud_class "Console" (extends (BorderPane) {

    promptPrefix = "lua> ";

    height = 0.45; -- proportion of the screen's height
    alpha = 0.5;
    border = 4;
    colour = vec(0,0,0.25);
    textColour = vec(.75, .75, .75);
    bufferSize = 10000;
    cmdBufferSize = 1000;
    font = "/common/fonts/misc.fixed";
    messageTime = 8;

    init = function (self)
        BorderPane.init(self)
        self.buffer = self.buffer or {}

        self.pinToBottom = true

        self.text = gfx_hud_text_add(self.font)
        self.text.shadow = self.shadow
        self.text.parent = self
        self.text.letterTopColour = self.textColour
        self.text.letterBottomColour = self.textColour

        self.prompt = gfx_hud_text_add(self.font)
        self.prompt.shadow = self.shadow
        self.prompt.parent = self
        self.prompt.colour = self.textColour
        self.prompt.text = self.promptPrefix

        self.cursor = gfx_hud_text_add(self.font)
        self.cursor.shadow = self.shadow
        self.cursor.parent = self
        self.cursor.colour = self.textColour
        self.cursor.text = "|"
        self.cmdBuffer = self.cmdBuffer or {}
        self.cmdBufferPos = 0

        self.promptBefore = ""
        self.promptAfter = ""

        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        self.needsParentResizedCallbacks = true

        self.lastCompletionsList = nil
        self.lastCompletionIndex = 0

    end;

    print = function (self, str)
        table.insert(self.buffer,1,str)
        if #self.buffer>self.bufferSize then
                table.remove(self.buffer)
        end
        self:redraw()
    end;

    clear = function (self)
        self.buffer = {}
        self:redraw()
    end;

    exec = function (self, cmd)
        self:recordCommand(cmd)
        self:execute(cmd)
    end;

    setEnabled = function (v)
        self.enabled = v
        ticker.enabled = not v
    end;

    destroy = function (self)
        safe_destroy(self.text)
    end;

    poll = function (self)
        local str = console_poll()
        if #str > 0 then
            str = str:sub(1,-2) -- cut off \n
            self:print(str)
            ticker:print(str)
        end
    end;

    frameCallback = function (self, elapsed)
        -- blinking cursor
        local state = (seconds() % 0.5) / 0.5
        self.cursor.enabled = state < 0.66

        self:poll()
    end;

    redraw = function (self)
        self.text:clear()
        for i = #self.buffer, 1, -1 do
            if i < #self.buffer then self.text:append("\n") end
            self.text:append(self.buffer[i])
        end
        if self.pinToBottom then
            self.text.scroll = self.text.bufferHeight - math.floor(self.text.size.y)
        end
    end;

    parentResizedCallback = function (self, psize)
        self.size = vec(psize.x, psize.y * self.height)
        self:updateChildrenSize()

        local font_height = gfx_font_line_height(self.font)
        self.position = vec(psize.x/2, psize.y - self.size.y/2)

        self.text.textWrap = self.size - self.border * vec(2,2) - vec(0,font_height)
        self.text.position = vec(0,font_height/2)

        self.prompt.textWrap = vec(self.size.x - self.border * 2, font_height)
        self.prompt.position = vec(0, -self.size.y/2 + self.border + font_height/2)

        self:redraw()
        self:positionCursor()
    end;    

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    cmd = function (self)
        return self.promptBefore .. self.promptAfter
    end;

    recordCommand = function (self, cmd)
        cmd = cmd or self:cmd()
        if cmd:len() > 0 and cmd ~= self.cmdBuffer[1] then
            table.insert(self.cmdBuffer,1,cmd)
            -- chop top if too long
            if #self.cmdBuffer > self.cmdBufferSize then
                    table.remove(self.cmdBuffer,#self.cmdBuffer+1)
            end
        end
    end;

    buttonCallback = function (self, ev)

        local ev2 = (ev:sub(1,1) == '+' or ev:sub(1,1)=='=') and ev:sub(2) or nil

        local reset_completions = true

        if ev2 == "Return" then
            self:recordCommand()
            self:execute()
            -- the above can execute arbitrary code, which can involve destroying the console... test for that!
            -- note, this is especially common with things like include "common/init.lua"
            if self.destroyed then return end

            self.cmdBufferPos = 0
            self.promptBefore = ""
            self.promptAfter = ""
        elseif ev2 == "BackSpace" then
            self.promptBefore = self.promptBefore:sub(1,self.promptBefore:len()-1)
        elseif ev2 == "Delete" then
            self.promptAfter = self.promptAfter:sub(2)
        elseif ev2 == "Left" then
            if self.promptBefore:len() > 0 then
                self.promptAfter = self.promptBefore:sub(-1)..self.promptAfter
                self.promptBefore = self.promptBefore:sub(1,-2)
            end
        elseif ev2 == "Right" then
            if self.promptAfter:len() > 0 then
                self.promptBefore = self.promptBefore .. self.promptAfter:sub(1,1)
                self.promptAfter = self.promptAfter:sub(2)
            end
        elseif input_filter_pressed("Ctrl") and ev2 == "d" then
            self.promptAfter = self.promptAfter:sub(2)
        elseif input_filter_pressed("Ctrl") and ev2 == "a" then
            self.promptBefore, self.promptAfter = "", self.promptBefore..self.promptAfter
        elseif input_filter_pressed("Ctrl") and ev2 == "e" then
            self.promptBefore, self.promptAfter = self.promptBefore..self.promptAfter, ""
        elseif input_filter_pressed("Ctrl") and ev2 == "w" then
            self.promptBefore = self.promptBefore:gsub(" [^ ]* ?$"," ")
        elseif input_filter_pressed("Ctrl") and ev2 == "k" then
            set_clipboard(self.promptAfter)
            self.promptAfter = ""
        elseif input_filter_pressed("Ctrl") and (ev2 == "y" or ev2 == "v") then
            local str = get_clipboard()
            self.promptBefore = self.promptBefore .. str
        elseif ev:sub(1,1) == ":" then
            self.cmdBufferPos = 0
            self.promptBefore = self.promptBefore .. ev:sub(2)
        elseif ev2=="Up" then
            if self.cmdBufferPos == 0 and self:cmd():len() > 0 then
                self:recordCommand()
                self.cmdBufferPos = 1
            end
            if self.cmdBuffer[self.cmdBufferPos+1] ~= nil then
                self.cmdBufferPos = self.cmdBufferPos + 1
            end
            self.promptBefore = self.cmdBuffer[self.cmdBufferPos] or ""
            self.promptAfter = ""
        elseif ev2=="Down" then
            if self.cmdBufferPos == 0 then
                self:recordCommand()
                self.promptBefore = ""
                self.promptAfter = ""
            elseif self.cmdBufferPos > 0 then
                self.cmdBufferPos = self.cmdBufferPos - 1
                self.promptBefore = self.cmdBuffer[self.cmdBufferPos] or ""
                self.promptAfter = ""
            end
        elseif ev2=="Home" then
            self.text.scroll = math.floor(-self.size.y/2)
            self.pinToBottom = false
        elseif ev2=="End" then
            self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
            self.pinToBottom = true
        elseif ev2=="PageUp" then
            self.text.scroll = math.floor(math.max(self.text.scroll - self.size.y/2, -self.size.y/2))
            self.pinToBottom = false
        elseif ev2=="PageDown" then
            self.text.scroll = self.text.scroll + math.floor(self.size.y/2)
            if self.text.scroll > self.text.bufferHeight - math.floor(self.text.size.y) then
                self.text.scroll = math.ceil(self.text.bufferHeight - self.text.size.y)
                self.pinToBottom = true
            end
        elseif input_filter_pressed("Ctrl") and ev2 == "Space" then
            self:autocomplete()
            reset_completions = false
        end
        self.prompt.text = self.promptPrefix..self.promptBefore..self.promptAfter
        self:positionCursor()
        
        if reset_completions and ev:sub(1,1) == ':' then
            self.lastCompletionList = nil
            self.lastCompletionIndex = 0
        end
    end;

    positionCursor = function (self)
        local tw = gfx_font_text_width(self.font, self.promptPrefix .. self.promptBefore)
        self.cursor.position = vec(-self.size.x/2 + self.border + tw, self.prompt.position.y)
    end;

    execute = function (self, str)
        str = str or self:cmd()

        echo(self.promptPrefix .. str)
        self:poll()

        -- this parses and compiles the string
        local f, err
        f = loadstring("return "..str)
        if f == nil then
            f, err = loadstring(str)
        end

        if f == nil then
            echo(BOLD..YELLOW.."Syntax error: "..err..RESET)
            return
        end
        -- to execute, use coroutine to remove irrelevent lines from stacktrace
        local coro = coroutine.create(function ()
            path_stack_push_dir("/");
            (function (status, ...)
                -- use this closure to collect return values from xpcall.
                -- if call not successful, do nothing as the error handler would have fixed our woes.
                if status then
                    -- call was successful
                    if select("#",...) > 0 then
                        echo(...)
                    end
                end
            end)(xpcall(f,--[[error_handler]]function(msg)
                local level = 0
                if type(msg)=="table" then
                    level,msg = unpack(msg)
                end
                level = level + 1 -- error handler
                level = level + 1 -- the first line is included in the message so don't print it again
                local tb = debug.traceback(msg,level+1) -- error handler
                tb = tb:gsub("\n[^\n]*\n[^\n]*$","")
                tb = tb:gsub("^[^\n]*\n","") -- msg
                tb = tb:gsub("^[^\n]*\n","") -- "stack trace:"
                echo(BOLD..RED..msg)
                if tb ~= "stack traceback:" then echo(RED..tb) end
            end))
            path_stack_pop()
        end)
        coroutine.resume(coro)
    end;

    autocomplete = function (self)
        --incremental upon last result
        if self.lastCompletionList then
            local i = self.lastCompletionIndex + 1
            if i > #self.lastCompletionList then --loop around
                i = 1
            end
            self.promptBefore = self.promptBefore:gsub(self.lastCompletionList[self.lastCompletionIndex].."$", self.lastCompletionList[i])
            self.lastCompletionIndex = i
            return
        end

        local splits = {}
        for m in self.promptBefore:gmatch("[^\\.:]+")  do
            splits[#splits+1] = m
        end
        if self.promptBefore:find("[\\.:]$") then
            splits[#splits+1] = ""
        end
        
        local parent = _G

        for i,v in ipairs(splits) do
            if i == #splits then
                local completionList = {}
                for k in pairs(parent) do
                    if v == "" or k:find(v, 1, true) == 1 then
                        completionList[#completionList+1] = k
                    end
                end

                if #completionList == 0 then
                    return
                end

                table.sort(completionList)

                self.lastCompletionList = completionList

                for ii, completion in ipairs(completionList) do
                    if v == "" then
                        --first suggestion if the last character was . or :
                        self.promptBefore = self.promptBefore .. completion
                        self.lastCompletionIndex = ii
                        return
                    end
                    if completion ~= v then
                        self.promptBefore = self.promptBefore:gsub(v.."$", completion)
                        self.lastCompletionIndex = ii
                        return
                    end
                end
            end

            local c = rawget(parent, v)
            if (not c) or (type(c) ~= "table") then
                return
            end
            parent = c
        end
    end;
})
