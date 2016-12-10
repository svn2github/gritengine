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


if editor_binds ~= nil then editor_binds:destroy() end
editor_binds = InputFilter(45, `editor_binds`)

if editor_edit_binds ~= nil then editor_edit_binds:destroy() end
editor_edit_binds = InputFilter(46, `editor_edit_binds`)

if editor_cam_binds ~= nil then editor_cam_binds:destroy() end
editor_cam_binds = InputFilter(47, `editor_cam_binds`)

if editor_object_binds ~= nil then editor_object_binds:destroy() end
editor_object_binds = InputFilter(48, `editor_object_binds`)

if editor_debug_binds ~= nil then editor_debug_binds:destroy() end
editor_debug_binds = InputFilter(49, `editor_debug_binds`)


function reset_binds()
    playing_binds.enabled = false
    playing_binds.mouseCapture = true
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false

    editor_binds.enabled = false
    editor_edit_binds.enabled = false
    editor_cam_binds.enabled = false
    editor_object_binds.enabled = false
    editor_debug_binds.enabled = false
end
reset_binds()

game_manager = {
    gameModes = { };
    currentMode = nil;

    register = function (self, mode)
        self.gameModes[mode.name] = mode
    end;

    enter = function (self, name)
        local new_mode = self.gameModes[name]
        if new_mode == nil then
            error('No such game mode: "' .. name .. '"')
        end

        core_option("FOREGROUND_WARNINGS", false)
        if self.currentMode ~= nil then
            self:exit()
        end
        self.currentMode = make_instance({}, new_mode)
        self.currentMode:init()
        self:setPause(false)
        core_option("FOREGROUND_WARNINGS", true)
        menu_show(nil)
    end;

    exit = function (self)
        if self.currentMode ~= nil then
            
            self.currentMode:destroy();
            self.currentMode = nil
            -- TODO(dcunnin): Reset all settings etc to base values.
            -- Reset gfx_option, core_option, physics_option, audio_option
            -- Push config from user_cfg
            -- Reset environment
            -- Reset common/hud stuff (e.g. crosshairs)
            -- env_saturation_mask
            -- global_exposure
            -- visibility / existence of sky bodies
            object_all_del()
            reset_binds()
            -- A lot of objects should now be unreachable, a good time to garbage collect.
            gc()
            menu_show('main')
        end
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

    setPause = function (self, v)
        self.currentMode:setPause(v)
    end;
}

playing_binds.mouseMoveCallback = function (rel)
    game_manager:mouseMove(rel)
end
