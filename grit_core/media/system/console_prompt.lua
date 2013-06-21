-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print ("Loading console_prompt.lua")

ConsolePrompt = { }
function ConsolePrompt.new(console)
        local self = {
                prefix = "lua> ",
                before = "",
                after = "",
                console = console,
                freshFrame = true
        }
        local white = {xterm_colour("white")} --actually more like grey but never mind
        self.root = console.centerPane:addChild("Pane")

        self.line = self.root:addChild(console.text.textKind,console.text)
        self.line:setColourTop(unpack(white))
        self.line:setColourBottom(unpack(white))
        self.line.resize = Hud.TOP_LEFT()

        self.cursor = self.root:addChild(console.text.textKind,self.line)
        self.cursor:setColourTop(unpack(white))
        self.cursor:setColourBottom(unpack(white))
        self.cursor.text = "_" 
        self.cursor.resize = function()
                return text_width(self.prefix..self.before, self.line.font,self.line.charHeight)
        end

        make_instance(self,ConsolePrompt,function(k)
                if k=="height" or k=="width" or k=="visible" or k=="type" then
                        return true,self.root[k]
                elseif k=="charHeight" or k=="font" then
                        return true,self.line[k]
                end
        end,function (k,v)
                if k=="charHeight" or k=="font" then
                        self.line[k] = v
                        self.cursor[k] = v
                        self:triggerResize()
                        return true
                elseif k=="visible" then
                        self.root[k] = v
                        return true
                elseif k=="resize" then
                        self.root.resize = function (pw,ph)
                                local x,y,w = v(pw,ph)
                                return x,y,w,self.line.height
                        end
                        return true
                end
        end)

        self:update()

        local last_flash_time = seconds()

        main.frameCallbacks:insert("grit_console",function ()
                local old
                old, self.freshFrame = self.freshFrame, true
                if old == nil then self:update() end
                local curr_time = seconds()
                if curr_time - last_flash_time > (self.cursor.visible and 0.3 or 0.15) then
                        self.cursor.visible = not self.cursor.visible
                        last_flash_time = curr_time
                end
        end)

        return self
end
function ConsolePrompt:triggerResize()
        self.root:triggerResize()
end
function ConsolePrompt:update()
        if not self.freshFrame then
                self.freshFrame = nil
                return
        else self.freshFrame = false end
        self.line.text = self.prefix..self.before..self.after
        self.cursor:triggerResize() -- move cursor to the right place
end
function ConsolePrompt:get()
        return self.before .. self.after
end
function ConsolePrompt:set(str)
        self.before = str
        self.after = ""
        self:update()
end
function ConsolePrompt:cut()
        set_clipboard(self.after)
        self.after = ""
        self:update()
end     
function ConsolePrompt:paste()
        local str = get_clipboard()
        self.before = self.before .. str
        self:update()
end     
function ConsolePrompt:deleteWord()
        self.before = self.before:gsub(" [^ ]* ?$"," ")
        self:update()
end     
function ConsolePrompt:delete(str)
        self.after = self.after:sub(2)
        self:update()
end     
function ConsolePrompt:backspace(str)
        self.before = self.before:sub(1,self.before:len()-1)
        self:update()
end     
function ConsolePrompt:first(str)
        self.before, self.after = "", self.before..self.after
        self:update()
end     
function ConsolePrompt:last(str)
        self.before, self.after = self.before..self.after, ""
        self:update()
end     
function ConsolePrompt:left(str)
        if self.before == "" then return end
        self.after = self.before:sub(-1)..self.after
        self.before = self.before:sub(1,-2)
        self:update()
end     
function ConsolePrompt:right(str)
        if self.after == "" then return end
        self.before = self.before .. self.after:sub(1,1)
        self.after = self.after:sub(2)
        self:update()
end     
function ConsolePrompt:append(str)
        self.before = self.before .. str
        self:update()
end     
function ConsolePrompt:execute()
        echo(self.prefix..self.before..self.after)

        -- this parses and compiles the string
        local f, err
        f = loadstring("return "..self.before..self.after)
        if f == nil then
            f, err = loadstring(self.before..self.after)
        end
        
        if f == nil then
                echo(BOLD..YELLOW.."Syntax error: "..err..RESET)
        else
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
        end
        self.before = ""
        self.after = ""
        self:update()
        console:update()
end

