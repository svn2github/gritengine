-- (c) David Cunningham 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

if system_binds ~= nil then system_binds:destroy() end
system_binds = InputFilter(2, `system_binds`)

if menu_binds ~= nil then menu_binds:destroy() end
menu_binds = InputFilter(5, `menu_binds`)


if playing_binds ~= nil then playing_binds:destroy() end
playing_binds = InputFilter(170, `playing_binds`)

if playing_actor_binds ~= nil then playing_actor_binds:destroy() end
playing_actor_binds = InputFilter(171, `playing_actor_binds`)

if playing_vehicle_binds ~= nil then playing_vehicle_binds:destroy() end
playing_vehicle_binds = InputFilter(172, `playing_vehicle_binds`)

playing_binds.mouseCapture = true

game_manager = {
    gameModes = { };
    currentMode = nil;

    define = function (self, name, mode)
        self.gameModes[name] = mode
    end;

    enter = function (self, name)
        local new_mode = self.gameModes[name]
        if new_mode == nil then
            error('No such game mode: "' .. name .. '"')
        end
        if self.currentMode ~= nil then
            self.currentMode:destroy();
        end
        core_option("FOREGROUND_WARNINGS", false)
        self.currentMode = new_mode
        new_mode:init();
        menu:setEnabled(false)
        core_option("FOREGROUND_WARNINGS", true)
    end;

    exit = function (self)
        if self.currentMode ~= nil then
            self.currentMode:destroy();
            self.currentMode = nil
        end
        debug_layer:setEnabled(false)
        menu:setEnabled(true)
    end;

    frameUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            self.currentMode:frameCallback(elapsed_secs)
        end
    end;

    stepUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            self.currentMode:stepCallback(elapsed_secs)
        end
    end;

    receiveButton = function (self, button, state)
        if self.currentMode ~= nil then
            self.currentMode:receiveButton(button, state)
        end
    end;

    mouseMove = function (self, rel)
        if self.currentMode ~= nil then
            self.currentMode:mouseMove(rel)
        end
    end;
}

playing_binds.mouseMoveCallback = function (rel)
    game_manager:mouseMove(rel)
end
