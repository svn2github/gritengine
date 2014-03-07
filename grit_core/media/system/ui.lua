-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading ui.lua")

BindTable = { }

function BindTable.new()
        local self = {
                binds = {},
                shiftBinds = {},
                ctrlBinds = {},
                altBinds = {},
                ctrlShiftBinds = {},
                ctrlAltBinds = {},
                shiftAltBinds = {},
                ctrlShiftAltBinds = {},
                buttonsDown = {},
        }
        return make_instance(self,BindTable,function (k)
                if BindTable[k] then return false end
                if ui:ctrl() then
                        if ui:shift() then
                                if ui:alt() then
                                        if self.ctrlShiftAltBinds[k] then return true, self.ctrlShiftAltBinds[k] end
                                end
                                if self.ctrlShiftBinds[k] then return true, self.ctrlShiftBinds[k] end
                        end
                        if ui:alt() then
                                if self.ctrlAltBinds[k] then return true, self.ctrlAltBinds[k] end
                        end
                        if self.ctrlBinds[k] then return true, self.ctrlBinds[k] end
                else
                        if ui:shift() then
                                if ui:alt() then
                                        if self.shiftAltBinds[k] then return true, self.shiftAltBinds[k] end
                                end
                                if self.shiftBinds[k] then return true, self.shiftBinds[k] end
                        else
                                if ui:alt() then
                                        if self.altBinds[k] then return true, self.altBinds[k] end
                                end
                        end
                end
                return true, self.binds[k]
        end)
end

function BindTable:bind(event, down, up, rep)
        local tab = self.binds
        if event:sub(1,6) == "S+A+C+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,6) == "S+C+A+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,6) == "A+S+C+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,6) == "A+C+S+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,6) == "C+A+S+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,6) == "C+S+A+" then
                event = event:sub(7)
                tab = self.ctrlShiftAltBinds
        end
        if event:sub(1,4) == "S+A+" then
                event = event:sub(5)
                tab = self.shiftAltBinds
        end
        if event:sub(1,4) == "A+S+" then
                event = event:sub(5)
                tab = self.shiftAltBinds
        end
        if event:sub(1,4) == "A+C+" then
                event = event:sub(5)
                tab = self.ctrlAltBinds
        end
        if event:sub(1,4) == "C+A+" then
                event = event:sub(5)
                tab = self.ctrlAltBinds
        end
        if event:sub(1,4) == "S+C+" then
                event = event:sub(5)
                tab = self.ctrlShiftBinds
        end
        if event:sub(1,4) == "C+S+" then
                event = event:sub(5)
                tab = self.ctrlShiftBinds
        end
        if event:sub(1,2) == "A+" then
                event = event:sub(3)
                tab = self.altBinds
        end
        if event:sub(1,2) == "S+" then
                event = event:sub(3)
                tab = self.shiftBinds
        end
        if event:sub(1,2) == "C+" then
                event = event:sub(3)
                tab = self.ctrlBinds
        end

        local path = path_stack_top()
        tab["+"..event] = {down, path}
        tab["-"..event] = {up, path}
        if rep == true then
                rep = down
        end
        tab["="..event] = {rep, path}
end

function BindTable:notify(event)
        local tab = self[event]
        if tab == nil then return true end
        local func, path = unpack(tab)
        if func == nil then return true end
        path_stack_push_dir(path)
        xpcall(function()func(event)end, error_handler)
        path_stack_pop()
        return false
end

function BindTable:flush(key)
        if key == nil then
                for k,_ in pairs(self.buttonsDown) do
                        local event = "-"..k
                        self:notify(event)
                end
                self.buttonsDown = {}
        else
                if self.buttonsDown[key] then
                        local event = "-"..key
                        self:notify(event)
                        self.buttonsDown[key] = nil
                end
        end
end

function BindTable:process(event)
        local c = event:sub(1,1)
        if c == "+" then
                self.buttonsDown[event:sub(2)] = true
        elseif c == "-" then
                self.buttonsDown[event:sub(2)] = nil
        end
        return self:notify(event)
end


UI = { }

function UI.new()
        local self = {
                buttonsDown = {},
                pressCallbacks = CallbackReg.new(),
                coreBinds = BindTable.new(),
                binds = BindTable.new(),
                pointerGrabCallbacks = CallbackReg.new(),
                pointerCallbacks = CallbackReg.new(),
                priorGrabX =0, priorGrabY = 0,
                lastX = 0, lastY = 0,
                grabbed = false,
                shouldBeGrabbed = false,
        }

        main.frameCallbacks:insert("UI.frameCallback",UI.frameCallback)

        return make_instance(self,UI)
end

function UI:destroy()
        main.frameCallbacks:removeByName("UI.frameCallback")
end


function UI:alt() return self.buttonsDown.Alt end
function UI:shift() return self.buttonsDown.Shift end
function UI:ctrl() return self.buttonsDown.Ctrl end

function UI:down(key) return self.buttonsDown[key] end
function UI:keys() return pairs(self.buttonsDown) end

function UI:bind(...) return self.binds:bind(...) end
function UI:coreBind(...) return self.coreBinds:bind(...) end

function UI:flush()
        if player_ctrl ~= nil then
                player_ctrl:flush()
        end
        self.coreBinds:flush()
        self.binds:flush()
end

function UI:mouse(key)
        key = key:sub(2)
        for _,key2 in ipairs{"left","right","middle","up","down"} do
                if key == key2 then return true end
                if key == key2 then return true end
        end
end


function UI:getGrab() return self.grabbed end
function UI:getShouldBeGrabbed() return self.shouldBeGrabbed end

function UI:grab()
        self.shouldBeGrabbed = true
        self:updateGrabbed()
end

function UI:ungrab()
        self.shouldBeGrabbed = false
        self:updateGrabbed()
end     

function UI:updateGrabbed()
        local should_be_grabbed = have_focus() and self.shouldBeGrabbed
        if should_be_grabbed == self.grabbed then return end
        if should_be_grabbed then
                self.priorGrabX = self.lastX
                self.priorGrabY = self.lastY 
                set_mouse_grab(true)
                set_mouse_hide(true)
        else
                set_mouse_grab(false)
                set_mouse_pos(self.priorGrabX,self.priorGrabY)
                set_mouse_hide(false)
        end
        self.grabbed = should_be_grabbed
end


function UI:manageButtonsDown (v)
    local c = v:sub(1,1)
    if c == "+" then
        self.buttonsDown[v:sub(2)] = true
    elseif c == "-" then
        self.buttonsDown[v:sub(2)] = nil
    end
end

function UI.frameCallback ()

    local presses = get_keyb_presses()
    local moved,buttons,x,y,rel_x,rel_y = get_mouse_events()

    if moved then
        ui.lastX, ui.lastY = x, y
        ui.lastRelX, ui.lastRelY = rel_x, rel_y
        if ui:getGrab() then
            ui.pointerGrabCallbacks:execute(rel_x, rel_y)
        else
            ui.pointerCallbacks:execute(rel_x, rel_y)
            input_filter_trickle_mouse_move(vec(rel_x, rel_y), vec(x, y))
        end
    end

    for _,key in ipairs(presses) do
        if get_keyb_verbose() then echo("Lua key event: "..key) end
        ui:manageButtonsDown(key)
        if ui.coreBinds:process(key) ~= false then
            if not ui:getGrab() then
                input_filter_trickle_button(key)
            else
                if ui.pressCallbacks:execute(key) ~= false then
                    ui.binds:process(key)
                end
            end
        end
    end

    for _,button in ipairs(buttons) do
        if get_keyb_verbose() then echo("Lua mouse event: "..button) end
        if not ui:getGrab() then
            if ui.coreBinds:process(button) ~= false then
                ui:manageButtonsDown(button)
                input_filter_trickle_button(button)
            end
        else
            if ui.coreBinds:process(button) ~= false then
                ui:manageButtonsDown(button)
                if ui.pressCallbacks:execute(button) ~= false then
                    ui.binds:process(button)
                end
            end
        end
    end
end




if ui ~= nil then
        ui:destroy()
end
ui = UI.new()

