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

playing_binds.enabled = false
playing_actor_binds.enabled = false
playing_vehicle_binds.enabled = false

playing_binds.mouseCapture = true

system_layer = system_layer or nil

game_manager = {
    gameModes = { };
    gameDescriptions = { };
    gameThumbs = { };
    currentMode = nil;

    description = function (self, name, desc)
        self.gameDescriptions[name] = desc
    end;

    thumb = function (self, name, thumb )
        self.gameThumbs[name] = thumb
    end;

    define = function (self, name, mode )
        self.gameDescriptions[name] = "no description!"
        self.gameThumbs[name] = `/common/hud/LoadingScreen/GritLogo.png`
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
        core_option("FOREGROUND_WARNINGS", true)
    end;

    exit = function (self)
        if self.currentMode ~= nil then
            self.currentMode:destroy();
            self.currentMode = nil
        end
        menu_show('main')
    end;

    frameUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            if not xpcall(self.currentMode.frameCallback, error_handler, self.currentMode, elapsed_secs) then
                print('During game mode\'s frameCallback, exiting gamemode')
                self:exit()
            end
        end
    end;

    stepUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            if not xpcall(self.currentMode.stepCallback, error_handler, self.currentMode, elapsed_secs) then
                print('During game mode\'s stepCallback, exiting gamemode')
                self:exit()
            end
        end
    end;

    receiveButton = function (self, button, state)
        if button == "menu" then
            if state == '+' then
                menu_show('pause')
            end
        else
            if self.currentMode ~= nil then
                self.currentMode:receiveButton(button, state)
            end
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

function enter_gamemode(gm)
	game_manager:enter(gm)
end
