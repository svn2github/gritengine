include `img/definitions.lua`
include `img/buildings/definitions.lua`
include `/detached/weapons/init.lua`
include `/detached/characters/init.lua`

playground = playground or {
    camYaw = 0;
    camPitch = 0;
    lastMouseMoveTime = 0;
}


-- TODO(dcunnin): delete this when we have a proper coin class

material `mat_chromeClean` {
	specular = 0.3,
	gloss = 0.5,
	diffuseColour = vec(0.2, 0.2, 0.2),
	shadowBias=0.2,
}

material `mat_basicGlass` {
	specular = 0.5,
	gloss = 1,
	alpha = 0.2,
	diffuseColour = vec(0.1, 0.1, 0.1),
	shadowBias=0.2,
}

material `mat_batteryCoreEffect` {
	specular = 0,
	gloss = 0,
	emissiveColour = vec(0, 2, 0),
	diffuseColour = vec(0, 1, 0),
	shadowBias=0.2,
}	

material `mat_basicPlastic` {
	specular = 0.1,
	gloss = 0.3,
	diffuseColour = vec(0.02, 0.02, 0.02),
	shadowBias=0.2,
}	

PickUpClass = {
    radius = 1;
    renderingDistance = 50;

    init = function (self)
        local class_name = self.className
        local gfx_mesh = self.gfxMesh or class_name..".mesh"
        self:addDiskResource(gfx_mesh)
    end;

    destroy = function (self)
    end;

    activate = function (self, instance)
        local class_name = self.className
        local gfx_mesh = self.gfxMesh or class_name..".mesh"

        instance.angle = 0
        instance.gfx = gfx_body_make(gfx_mesh)
        instance.gfx.localPosition = self.spawnPos
        instance.gfx.enabled = not self.pickedUp
        self.needsStepCallbacks = not self.pickedUp
        self:stepCallback(0)
    end;

    deactivate = function (self)
        local instance = self.instance
        self.needsStepCallbacks = false
        instance.gfx = safe_destroy(instance.gfx)

    end;

    stepCallback = function (self, elapsed_secs)
        local instance = self.instance
        -- rotate
        instance.angle = (instance.angle + (elapsed_secs * 180)) % 360  -- 1 rev per second
        instance.gfx.localOrientation = quat(instance.angle, V_UP)

        -- test for controllable
        physics_test(self.radius, self.spawnPos, true, function(body)
            if self.pickedUp then return end
            self.pickedUp = true
            self.instance.gfx.enabled = false
            self.needsStepCallbacks = false
            local found_obj = body.owner
            if found_obj == nil then return end
            if found_obj == playground.vehicle or found_obj == playground.protagonist then
                playground:coinPickUp()
            end
        end)
    end;
}

class `pickup_gearUpgradeTree1` (PickUpClass) {
    placementZOffset = 1.5
}

class `pickup_energyReplenish` (PickUpClass) {
    placementZOffset = 1.5
}

class `pickup_tool_ioWire` (PickUpClass) {
    placementZOffset = 1.1
}

function playground:init()
    loading_screen.enabled = true
    loading_screen:setProgress(0)
    loading_screen:setMapName('Playground')
    loading_screen:setStatus('Background loading resources...')
    loading_screen:pump()

    include `img/placement.lua`
    include `img/placement_veg.lua`

    self.protagonist = object `/detached/characters/robot_med` (-53.45975, 9.918219, 1.112) {
        rot=quat(-0.3363351, 0, 0, 0.9417424)
    }

    local pos = self.protagonist.spawnPos

    object `/vehicles/Scarman` (-49.45975, 9.918219, 1.112) {
    }

    self.coin = object `pickup_gearUpgradeTree1` (-49.45975, 5.918219, 1.112) {
    }

    self.coinsPickedUp = 0
    self.coinsTotal = 1

    self.vehicle = nil
    playing_binds.enabled = true
    playing_actor_binds.enabled = true
    playing_vehicle_binds.enabled = false

    self.protagonist:activate()

    main.camQuat = Q_ID
    main.audioCentreVel = vec(0, 0, 0);
    main.audioCentreQuat = quat(1, 0, 0, 0);
    self.camYaw = 90;
    self.camPitch = 0;
    self.playerCamPitch = 0;  -- Without vehicle pitch offset

    self.debugText1 = gfx_hud_text_add(`/common/fonts/misc.fixed`)
    self.debugText1.text = ''
    self.debugText1.position = vec(100, 100)
    self.debugText2 = gfx_hud_text_add(`/common/fonts/misc.fixed`)
    self.debugText2.text = ''
    self.debugText2.position = vec(100, 85)

    streamer_centre_full(pos)

    local to_go = get_in_queue_size()
    local init_to_go = to_go
    while to_go > 0 do
        to_go = get_in_queue_size()
        loading_screen:setProgress((init_to_go - to_go) / init_to_go)
        loading_screen:pump()
    end
    loading_screen:setProgress(1)
    loading_screen:setStatus('Activating objects')
    loading_screen:pump()
    streamer_centre_full(pos)

    main.physicsEnabled = true

    playing_binds.mouseCapture = true

    self:mouseMove(vec(0,0))
    self:stepCallback(0)
    self:frameCallback(0)

    loading_screen:setStatus('All done')
    loading_screen:pump()

    loading_screen.enabled = false

end

function playground:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity
    
    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
    self.playerCamPitch = self.camPitch
        
    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat

    self.lastMouseMoveTime = seconds()

end

function playground:coinPickUp()
    self.coinsPickedUp = self.coinsPickedUp + 1
end

function playground:scanForBoard()
    local radius = 3
    local player_body = self.protagonist.instance.body
    local player_pos = player_body.worldPosition
    local best_score = 0
    local best_found_vehicle = nil
    physics_test(radius, player_pos, true, function(body, num, lpos, wpos, normal, penetration, mat)
        local found_vehicle = body.owner
        if found_vehicle == nil then return end
        if found_vehicle.controllable ~= "VEHICLE" then return end
        local from_player = player_body:worldToLocal(wpos)
        local angle = math.deg(math.acos(norm(from_player).y))
        if angle > 45 then return end
        local score = penetration
        if score > best_score then
            best_score = score
            best_found_vehicle = found_vehicle
        end
    end)
    print(best_found_vehicle)
    if best_found_vehicle == nil then return end
    self:board(best_found_vehicle)
end

function playground:board(veh)
    self.vehicle = veh
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = true
    self.protagonist:enterVehicle()
    veh:controlBegin()
    -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
    -- So we calculate the playerCamPitch necessary for that.
    local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
    self.playerCamPitch = self.playerCamPitch - v_pitch
end

function playground:abandonControlObj()
    -- Disable binds before settings vehicle to nil, ensures steering, acceleration etc is reset
    playing_vehicle_binds.enabled = false
    local veh = self.vehicle
    self.vehicle = nil
    self.protagonist:exitVehicle(veh.instance.body:localToWorld(veh.driverExitPos), veh.instance.body.worldOrientation * veh.driverExitQuat)
    veh:controlAbandon()
    playing_actor_binds.enabled = true
    -- When on foot there is no vehicle pitch.
    local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
    self.playerCamPitch = self.playerCamPitch + v_pitch
end

function playground:receiveButton(button, state)
    if state == '=' then return end
    local pressed = state ~= '-'

    local prot = self.protagonist
    local cobj = self.vehicle

    if button == 'walkForwards' then    
        prot:setForwards(pressed)
    elseif button == 'walkBackwards' then
        prot:setBackwards(pressed)
    elseif button == 'walkLeft' then
        prot:setLeft(pressed)
    elseif button == 'walkRight' then
        prot:setRight(pressed)
    elseif button == 'walkBoard' then
        if state == '+' then
            self:scanForBoard()
        end
    elseif button == 'walkJump' then
        prot:setJump(pressed)
    elseif button == 'walkRun' then
        prot:setRun(pressed)
    elseif button == 'walkCrouch' then
        prot:setCrouch(pressed)
    elseif button == 'walkZoomIn' then
        prot:controlZoomIn() 
    elseif button == 'walkZoomOut' then
        prot:controlZoomOut() 
    elseif button == 'walkCamera' then
        -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

    elseif button == 'driveForwards' then    
        cobj:setForwards(pressed)
    elseif button == 'driveBackwards' then
        cobj:setBackwards(pressed)
    elseif button == 'driveLeft' then
        cobj:setLeft(pressed)
    elseif button == 'driveRight' then
        cobj:setRight(pressed)
    elseif button == 'driveZoomIn' then
        cobj:controlZoomIn() 
    elseif button == 'driveZoomOut' then
        cobj:controlZoomOut() 
    elseif button == 'driveCamera' then
        -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

    elseif button == 'driveSpecialUp' then
        cobj:setSpecialUp(pressed)
    elseif button == 'driveSpecialDown' then
        cobj:setSpecialDown(pressed)
    elseif button == 'driveSpecialLeft' then
        cobj:setSpecialLeft(pressed)
    elseif button == 'driveSpecialRight' then
        cobj:setSpecialRight(pressed)
    elseif button == 'driveAltUp' then
        cobj:setAltUp(pressed)
    elseif button == 'driveAltDown' then
        cobj:setAltDown(pressed)
    elseif button == 'driveAltLeft' then
        cobj:setAltLeft(pressed)
    elseif button == 'driveAltRight' then
        cobj:setAltRight(pressed)
    elseif button == 'driveAbandon' then
        if state == '+' then
            self:abandonControlObj()
        end
    elseif button == 'driveHandbrake' then
        cobj:setHandbrake(pressed)
    elseif button == 'driveLights' then
        if state == '+' then
            cobj:setLights()
        end
    elseif button == 'driveSpecialToggle' then
        if state == '+' then
            cobj:special()
        end
    end
end

function playground:frameCallback(elapsed_secs)
end

function playground:stepCallback(elapsed_secs)

    if self.vehicle ~= nil and not self.vehicle.activated then
        self:abandonControlObj()
    end

    local obj = self.vehicle or self.protagonist
    local instance = obj.instance
    local body = instance.body

    local vehicle_bearing, vehicle_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
    local vehicle_vel = body.linearVelocity
    local vehicle_vel_xy_speed = #(vehicle_vel * vector3(1,1,0))

    -- modify the self.camPitch and self.camYaw to track the direction a vehicle is travelling
    if user_cfg.vehicleCameraTrack and obj.cameraTrack and seconds() - self.lastMouseMoveTime > 1  and vehicle_vel_xy_speed > 5 then

        self.camPitch = lerp(self.camPitch, self.playerCamPitch + vehicle_pitch, elapsed_secs * 2)

        -- test avoids degenerative case where x and y are both 0 
        -- if we are looking straight down at the car then the yaw doesn't really matter
        -- you can't see where you are going anyway
        if math.abs(self.camPitch) < 60 then
            local ideal_yaw = yaw(vehicle_vel.x, vehicle_vel.y)
            local current_yaw = self.camYaw
            if math.abs(ideal_yaw - current_yaw) > 180 then
                if ideal_yaw < current_yaw then
                    ideal_yaw = ideal_yaw + 360
                else
                    current_yaw = current_yaw + 360
                end
            end
            local new_yaw = lerp(self.camYaw, ideal_yaw, elapsed_secs * 2) % 360

            self.camYaw = new_yaw
        end
    end

    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)

    local ray_skip = 0.4
    local ray_dir = main.camQuat * V_BACKWARDS
    local ray_start = instance.camAttachPos + ray_skip * ray_dir
    local ray_len = instance.boomLengthSelected - ray_skip
    local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
    local boom_length = math.max(obj.boomLengthMin, ray_hit_len)
    main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)
    main.streamerCentre = instance.camAttachPos
    main.audioCentrePos = main.camPos

    --player_ctrl.speedoPos = instance.camAttachPos
    --player_ctrl.speedoSpeed = #vehicle_vel
    if self.vehicle ~= nil then
        self.protagonist:updateDriven(body.worldPosition, body.worldOrientation)
    end
end

function playground:destroy()
    object_all_del()
    self.protagonist = nil
    self.vehicle = nil
    safe_destroy(self.debugText1)
    safe_destroy(self.debugText2)
end

game_manager:define("Playground", playground)
