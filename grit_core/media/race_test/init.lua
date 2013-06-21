-- (c) Alexey "Razzeeyy" Shmakov 2013, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
--simple checkpoint race possibility proof :P

include "../urban/init.lua"

local vehicle_spawn_point = vector3(-241, -341, -5)
local player_car = object "/vehicles/Scarman" (-241, -341, -5) {name="player_car"}

local spawnCamPos = vector3(-238, -363, 3)
local spawnCamDir = quat(-0.9937351, 0.1060419, 0.003745079, -0.03509573)
--map_ghost_spawn(spawnCamPos)
player_ctrl:warp(spawnCamPos, spawnCamDir)

local checkpoints = checkpoints or {
    [0] = vector3(-239, -250, -6);
    [1] = vector3(-237, -159, -4);
    [2] = vector3(-96, -179, -2);
    [3] = vector3(90, -177, -2);
    [4] = vector3(89,0,0);
    [5] = vector3(0,0,0);
    [6] = vector3(2,161,2);
    [7] = vector3(92,163,5);
    [8] = vector3(143,277,12);
    [9] = vector3(355,536,50);
}

checkpoints.race_active = true;
checkpoints.current = 0;
checkpoints.finish = 9;

checkpoints.race_time = 0;
checkpoints.start_time = 0;
checkpoints.end_time = 0;

function checkpoints:getCurrPointPos()
    return checkpoints[checkpoints.current]
end

function spawn_checkpoint_object()
    local curr_point_pos = checkpoints:getCurrPointPos()
    return object "/common/props/street/TrafficCone" (curr_point_pos.x, curr_point_pos.y, curr_point_pos.z) {}
end
local checkpoint_object = spawn_checkpoint_object()

function checkpoints:nextPoint()
    self.current = self.current + 1

    if checkpoint_object.instance == nil then
        checkpoint_object = nil
        checkpoint_object = spawn_checkpoint_object()
    else
        checkpoint_object.instance.body.worldPosition = checkpoints:getCurrPointPos()
    end
end

local function vlen(v1, v2)
    return math.sqrt(math.pow(v1.x-v2.x, 2)+math.pow(v1.y-v2.y, 2)+math.pow(v1.z-v2.z, 2))
end

function checkpoints:frameCallback()
    if player_ctrl.mode == 1 and player_ctrl.vehicle then
        if player_ctrl.vehicle.name ~= "player_car" then
            return
        end

        if checkpoints.race_active then
            if vlen(checkpoints[checkpoints.current], player_ctrl.vehicle.instance.body.worldPosition) < 10 then --checkpoint reached
                if checkpoints.current == 0 then
                    checkpoints.start_time = micros()
                elseif checkpoints.current == checkpoints.finish then
                    checkpoints.end_time = micros()
                    checkpoints.race_time = checkpoints.end_time - checkpoints.start_time
                    checkpoints.race_active = false;
                    return
                end
                checkpoints:nextPoint()
                return
            end
        else
            --present race time
            --print("race_time "..checkpoints.race_time)
            race_time_text = nil
            race_time_text = gfx_hud_text_add("/system/misc.fixed")
            race_time_text.colour = vector3(0,0,0)
            race_time_text.parent = hud_center
            race_time_text.text = "race time (ms): "..checkpoints.race_time
            race_event:deinit()
            return
        end
    end
end

function checkpoints:init()
    main.frameCallbacks:insert("race_event", self.frameCallback)
    return self
end

function checkpoints:deinit()
    main.frameCallbacks:removeByName("race_event")
end

if race_event ~= nil then
    race_event:deinit()
end
race_event = checkpoints:init()

hud_class "CP_Arrow" {
    size = vector2(64,64);
    init = function(self)
        self.needsFrameCallbacks = true
        
        self.texture = "arrow.png"
    end;
    frameCallback = function(self, elapsed)
        if player_ctrl.mode == 1 and player_ctrl.vehicle then
            if checkpoints.race_active then
                local cp_pos = checkpoints:getCurrPointPos()
                local car_pos = player_ctrl.vehicle.instance.body.worldPosition

                local cp_yaw = yaw(cp_pos.x - car_pos.x, cp_pos.y - car_pos.y)
                self.orientation = cp_yaw - player_ctrl.camYaw
            else
                safe_destroy(self)
                return
            end
        end
    end;
}

gfx_hud_object_add("CP_Arrow", {parent = hud_top_left, position=vector2(64, -64)})

--can't drive error here, why the heck? :(
--player_ctrl:drive(player_car)
