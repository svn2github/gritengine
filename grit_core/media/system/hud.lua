-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("loading hud.lua")

Hud = {}

str = "The quick [31mbrown[0m fox\tjumped over the lazy dog.  "

function Hud.TOP_LEFT(w,h)
        return function (pw,ph)
                return 0,0,w,h
        end
end
function Hud.TOP_RIGHT(w,h)
        return function (pw,ph)
                return -1,0,w,h
        end
end
function Hud.BOTTOM_LEFT(w,h)
        return function (pw,ph)
                return 0,-1,w,h
        end
end
function Hud.BOTTOM_RIGHT(w,h)
        return function ()
                return -1,-1,w,h
        end
end
function Hud.TOP(x,w,h)
        return function ()
                return x,0,w,h
        end
end
function Hud.BOTTOM(x,w,h)
        return function ()
                return x,-1,w,h
        end
end
function Hud.LEFT(y,w,h)
        return function ()
                return 0,y,w,h
        end
end
function Hud.RIGHT(y,w,h)
        return function ()
                return -1,y,w,h
        end
end
function Hud.CENTER(bx,by)
        return function (pw,ph)
                return bx,by,pw-2*bx,ph-2*by
        end
end

--add_font2("BerlinSansMono","BerlinSans.png",512,512,32,32,6,6)

--include("berlin_sans.lua")

include("misc.fixed.lua")


Hud.ShadowText = Hud.ShadowText or { type =  "ShadowText" } do
        function Hud.ShadowText:triggerResize()
                self.root:triggerResize()
        end
        function Hud.ShadowText:commit()
                self.fg:commit()
                self.bg:commit()
        end
        function Hud.ShadowText:append(str)
                self.fg:append(str)
                self.bg:append(str)
        end
        function Hud.ShadowText:reset()
                self.fg:reset()
                self.bg:reset()
        end
        function Hud.ShadowText:getColourTop()
                return self.fg:getColourTop()
        end
        function Hud.ShadowText:setColourTop(...)
                self.fg:setColourTop(...)
        end
        function Hud.ShadowText:getColourBottom()
                return self.fg:getColourBottom()
        end
        function Hud.ShadowText:setColourBottom(...)
                self.fg:setColourBottom(...)
        end
        function Hud.ShadowText:setColourBottom(...)
                self.fg:setColourBottom(...)
        end
        function Hud.ShadowText:setOffset(x,y)
                self.offsetX = x
                self.offsetY = y
        end
        function Hud.ShadowText:getOffset()
                return self.offsetX,self.offsetY
        end
        function Hud.ShadowText.new (parent,opt)
                opt = opt or {}
                opt.font = opt.font or "misc.fixed"
                opt.charHeight = opt.charHeight or 13
                opt.offsetX = opt.offsetX or 1
                opt.offsetY = opt.offsetY or 1
                local text_opt = {font=opt.font, charHeight=opt.charHeight}
                local self = {}
                self.offsetX, self.offsetY = opt.offsetX, opt.offsetY
                self.parent = parent
                self.root = parent:addChild("Pane")
                self.bg = self.root:addChild("Text",text_opt)
                self.fg_root = self.root:addChild("Pane")
                self.fg = self.fg_root:addChild("Text",text_opt)
                self.fg.resize=Hud.TOP_LEFT()
                self.bg.resize=function() return self.offsetX,self.offsetY end
                self.bg:setColourTop(0,0,0,1)
                self.bg:setColourBottom(0,0,0,1)

                make_instance(self,Hud.ShadowText,function (k)
                        if k=="x" or k=="y" or k=="width" or k=="height" or k=="visible" then 
                                return true, self.root[k]
                        elseif k=="text" or k=="font" or k=="charHeight" then
                                return true, self.fg[k]
                        end
                end, function (k,v)
                        if k=="visible" then
                                self.root[k] = v
                                return true
                        elseif k=="resize" then
                                self.root.resize = function(pw,ph)
                                        local x,y = v(pw,ph,self)
                                        x = x or 0
                                        y = y or 0
                                        local w = self.offsetX+self.fg.width
                                        local h = self.offsetY+self.fg.height
                                        return x,y,w,h
                                end
                                return true
                        elseif k=="charHeight" or k=="font" or k=="text" then
                                self.bg[k] = v
                                self.fg[k] = v
                                self:triggerResize()
                                return true
                        end
                end, function()
                        return "Hud.ShadowText: \""..self.text.."\""
                end)

                self.text = "No text entered."
                self.visible = opt.visible or true
                self.resize = function () return end
				self.charHeight = 13
				
                return self
        end
        function Hud.ShadowText:destroy()
                self.parent:removeChild(self.root)
        end
end

function colour_mutate(cmd,colour)
        cmd = tonumber(cmd) or -1
        local r = table.clone(colour)

        local fgtab = {[30]="black";[31]="red";    [32]="green";[33]="yellow";
                       [34]="blue"; [35]="magenta";[36]="cyan"; [37]="white"}
        local bgtab = {[40]="black";[41]="red";    [42]="green";[43]="yellow";
                       [44]="blue"; [45]="magenta";[46]="cyan"; [47]="white"}
        local boldtab = {[1]=true; [22]=false}
        r = cmd==0 and {} or r
        if boldtab[cmd]~=nil then r.bold = boldtab[cmd] end
        r.fgcol = fgtab[cmd] or r.fgcol
        r.bgcol = bgtab[cmd] or r.fgcol
        return r
end

--function replace_tabs(input,tabwidth,char)
--        tabwidth = tabwidth or 8
--        char = char or " "
--        while true do
--                local pos = input:find("\t")
--                if pos == nil then break end
--                input = input:sub(1,pos-1)..string.rep(char,tabwidth-(pos%tabwidth)+1)..input:sub(pos+1,-1)
--        end
--        return input
--end

function parse_colours(input, colour)
        colour = colour or {}
        local result = {}

        local pos = 1
        while true do
                local b,e,cmds = input:find("\\e\\[([\\d;]*)m",pos)
                if b==nil then
                        table.insert(result,{colour,input:sub(pos)})
                        break
                end
                table.insert(result,{colour,input:sub(pos,b-1)})
                for cmd in cmds:gmatch("(\\d+)") do
                        colour = colour_mutate(cmd,colour)
                end
                pos = e+1
        end
        return result
end

function print_chunks(chunks)
        for k,v in pairs(chunks) do
                if v[1] == nil then
                        print("new line")
                else
                        local colour = v[1].fgcol
                        local bold = not not v[1].bold
                        local text = "\""..tostring(v[2]).."\""
                        local xpos = v[3] or ""
                        print(k,colour,bold,text,xpos)
                end
        end
end

function xterm_colour (colour,bold)
        local r,g,b 
        if bold and colour=="black" then r,g,b = .5,.5,.5
        elseif colour=="black" then r,g,b = 0,0,0
        elseif bold and colour=="red" then r,g,b = 1,0,0
        elseif colour=="red" then r,g,b = .8,0,0
        elseif bold and colour=="green" then r,g,b = 0,1,0
        elseif colour=="green" then r,g,b = 0,.8,0
        elseif bold and colour=="yellow" then r,g,b = 1,1,0
        elseif colour=="yellow"then r,g,b = .8,.8,0 
        elseif bold and colour=="blue" then r,g,b = .36,.36,1
        elseif colour=="blue" then r,g,b = 0,0,.93
        elseif bold and colour=="magenta" then r,g,b = 1,0,1
        elseif colour=="magenta"then r,g,b = .8,0,.8
        elseif bold and colour=="cyan" then r,g,b = 0,1,1
        elseif colour=="cyan" then r,g,b = 0,.8,.8 
        elseif bold and colour=="white" then r,g,b = 1,1,1
        elseif colour=="white" then r,g,b = .75,.75,.75
        end     
        return r,g,b,1
end

-- called by c code
function console_tostring(item)
        if type(item) == 'string' then
                return item
        end
        return dump(item)
end




Hud.TickerText = {type = "Hud.TickerText"}

function Hud.TickerText.new (parent,opts)

        opts = opts or {}
        local self = {
                textKind = opts.textKind or "Text",
                wordWrap = opts.wordWrap or true,
                buffer = opts.buffer or {},
                timeBuffer = opts.timeBuffer or {},
                bufferSize = opts.bufferSize or 8,
                startChunk = opts.startChunk or 1,
                messageTime = opts.messageTime or 8
        }
        self.parent = parent;

        self.root = parent:addChild("Pane")

        self.display = self.root:addChild(self.textKind)
        self.display.font = opts.font or "misc.fixed"
        self.display.charHeight = opts.charHeight or 13

        make_instance(self, Hud.TickerText,
                function(k)
                        if k=="height" or k=="width" or k=="visible" then
                                return true, self.root[k]
                        elseif k=="charHeight" or k=="font" then
                                return true, self.display[k]
                        end
                end,
                function(k,v)
                        if k=="resize" then
                                self.root.resize = function (pw,ph)
                                        local x,y,w,h = v(pw,ph,self)
                                        -- resize pane
                                        x,y,w,h = coroutine.yield(x,y,w,h)
                                        -- draw into new pane
                                        self:redraw()
                                        return x,y,w,h
                                end
                                return true
                        elseif k=="charHeight" or k=="font" then
                                self.display[k] = v
                                return true
                        elseif k=="visible" then
                                self.root[k] = v
                                return true
                        end
                end,
                function()
                        return self.type
                end
        )

        --self.resize = function (pw,ph) return 0,0,pw,#self.buffer end

        return self
end

function Hud.TickerText:destroy()
        self.parent:removeChild(self.root)
end

function Hud.TickerText:print(text)
        for _,l in ipairs (text:split("\n")) do
                self:write(l)
        end
        self:redraw()
end

function Hud.TickerText:write(string)
        table.insert(self.buffer,1,string)
        table.insert(self.timeBuffer,1,seconds())
        if #self.buffer>self.bufferSize then
                table.remove(self.buffer)
                table.remove(self.timeBuffer)
        end
end

function Hud.TickerText:tick()
        local count = #self.buffer
        local needs_redraw = false
        for i = 1, count do
                local timer = self.timeBuffer[i]
                if timer == nil then return end
                if seconds() - timer > self.messageTime then
                        needs_redraw = true
                        table.remove(self.buffer,i)
                        table.remove(self.timeBuffer,i)
                        i = i - 1
                end
        end
        if needs_redraw then
                self:redraw()
        end
end

function Hud.TickerText:triggerResize()
        return self.root:triggerResize()
end

function Hud.TickerText:redraw()
        local text = ""
        for i = #self.buffer, 1, -1 do
                local line = self.buffer[i] or ""
                local prefix = i==#self.buffer and "" or "\n"
                text = text .. prefix .. line
        end

        local visible, rest = text_wrap(text,self.width,#self.buffer,true,true,8,true,
                                        self.font,self.charHeight)

        local start_colour = {}

        self.display:reset()

        for _,chunk in ipairs(parse_colours(visible,start_colour)) do
                local r,g,b,a = xterm_colour(chunk[1].fgcol or "white", chunk[1].bold)
                self.display:setColourTop(r,g,b,a)
                self.display:setColourBottom(r,g,b,a)
                self.display:append(chunk[2])
        end

        self.display:commit()
end





Hud.ConsoleText = Hud.ConsoleText or {type = "Hud.ConsoleText"} do
        function Hud.ConsoleText:print(text)
                for _,l in ipairs (text:split("\n")) do
                        self:write(l)
                end
                self:redraw()
        end
        function Hud.ConsoleText:write(string)
                table.insert(self.buffer,1,string)
                if #self.buffer>self.bufferSize then
                        table.remove(self.buffer)
                end
                if self.startChunk ~= 1 then
                        self.startChunk = self.startChunk + 1
                end
        end
        function Hud.ConsoleText:clear()
                self.buffer = {}
                self:redraw()
        end
        function Hud.ConsoleText:triggerResize()
                return self.root:triggerResize()
        end
        function Hud.ConsoleText:getStartChunk()
                return self.startChunk
        end
        function Hud.ConsoleText:setStartChunk(v,b)
                self.startChunk = v
                if b==nil or b then
                        self:redraw()
                end
        end
        function Hud.ConsoleText:redraw()
                local upper_bound = ""
                local lines = math.floor(self.height / self.display.charHeight)
                local first = true
                for i = self.startChunk+lines,self.startChunk,-1 do
                        upper_bound = upper_bound..(first and "" or "\n")..(self.buffer[i] or "")
                        first = false
                end
                --print("text length: "..upper_bound:len())
                --t:reset()
                -- i just realised we should obviously call text_wrap lots of times
                -- i.e. keep calling it until we run out of space to fill with text
                local visible, rest = text_wrap(upper_bound,self.width,lines,true,true,8,true,
                                                self.font,self.charHeight)
                --print("text_wrap time: "..(t.us/1000).."ms")
                --t:reset()
                --local chunks = parse_colours(rest)
                --local chunk = chunks[#chunks]
                local start_colour = {}
                --start_colour.fgcol = chunk[1].fgcol
                --start_colour.bold = chunk[2].bold
                --if start_colour.bold == nil or start_colour.fgcol == nil then
                --        for i = self.startChunk-1,1,-1 do
                --                if self.buffer[i] == nil then break end
                --                local this_colour = {}
                --                for _,chunk in ipairs(parse_colours(self.buffer[i])) do
                --                        --
                --                end
                --        end
                --end
                --print("parse_colours time: "..(t.us/1000).."ms")
                --t:reset()
                self.display:reset()
                for _,chunk in ipairs(parse_colours(visible,start_colour)) do
                        local r,g,b,a = xterm_colour(chunk[1].fgcol or "white", chunk[1].bold)
                        self.display:setColourTop(r,g,b,a)
                        self.display:setColourBottom(r,g,b,a)
                        self.display:append(chunk[2])
                end
                --print("append time: "..(t.us/1000).."ms")
                self.display:commit()

        end
        local meta_table = {
                __newindex = function(self,k,v)
                        if k=="resize" then
                                self.root.resize = function (pw,ph)
                                        local x,y,w,h = v(pw,ph,self)
                                        -- resize pane
                                        x,y,w,h = coroutine.yield(x,y,w,h)
                                        -- draw into new pane
                                        self:redraw()
                                        return x,y,w,h
                                end
                        elseif k=="charHeight" or k=="font" then
                                self.display[k] = v
                        elseif k=="visible" then
                                self.root[k] = v
                        else
                                rawset(self,k,v)
                        end
                end;
                __index = function(self,k)
                        if k=="height" or k=="width" or k=="visible" then
                                return self.root[k]
                        elseif k=="charHeight" or k=="font" then
                                return self.display[k]
                        else
                                return rawget(self,k) or Hud.ConsoleText[k]
                        end
                end;
                __tostring = function(self)
                        return "Hud.ConsoleText"
                end
        }


        function Hud.ConsoleText.new (parent,opts)

                opts = opts or {}
                local self = {
                        textKind = opts.textKind or "Text",
                        wordWrap = opts.wordWrap or true,
                        buffer = opts.buffer or {},
                        bufferSize = opts.bufferSize or 1000,
                        startChunk = opts.startChunk or 1
                }
                self.parent = parent;
                self.root = parent:addChild("Pane")
                self.display = self.root:addChild(self.textKind)
                self.display.font = opts.font or "misc.fixed"
                self.display.charHeight = opts.charHeight or 13
                setmetatable(self,meta_table)
                self.resize = function (pw,ph) return 0,0 end
                return self
        end
        function Hud.ConsoleText:destroy()
                self.parent:removeChild(self.root)
        end
end

