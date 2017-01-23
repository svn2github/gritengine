material `DummyVehicle` {
    diffuseMap = {
        -- Filename on disk.
        image = `DummyVehicle.png`,
        modeU = "CLAMP",
        modeV = "CLAMP",
    },
}

class `DummyVehicle2` (ColClass) {

    gfxMesh = `DummyVehicle.mesh`,
    colMesh = `DummyVehicle.gcol`,
    controllable = 'VEHICLE', 
    boomLengthMin = 5;
    boomLengthMax = 30;
    driverExitPos = vector3(-1.45, -0.24, 0.49);
    driverExitQuat = Q_ID;
    cameraTrack = true;

    hoverHeight = 1,
    steerMax = 80,  -- degrees/sec
    speedMax = 100,  -- metres/sec
    acceleration = 10,
    initialVelocity = vec(0, 0, 0),

	frontLeftJet = vec(-0.2, 4, 0),
	frontRightJet = vec(0.2, 4, 0),
	rearLeftJet = vec(-2, 2, 0),
	rearRightJet = vec(2, 2, 0),

    activate = function(self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        self.needsStepCallbacks = true
        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2
        instance.push = 0
        instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0
        instance.onGround = false
        instance.pos = self.pos
        instance.displayOrientation = self.rot or Q_ID
        instance.groundOrientation = instance.displayOrientation
        instance.velocity = self.initialVelocity
        instance.body.ghost = true
    end,

    deactivate = function(self, instance)
        self.needsStepCallbacks = false
        
        return ColClass.deactivate(self, instance)
    end,
    
    stepCallback = function(self, elapsed_secs)
        local instance = self.instance
        local pos = instance.pos
        local ort = instance.groundOrientation
        local vel = instance.velocity
        local gravity = physics_get_gravity()
        local vehicle_up = ort * vec(0, 0, 1)

        local ray = self.hoverHeight * -2 * vehicle_up
        local dist, ground, ground_normal, ground_mat = physics_cast(pos, ray, true, 0)
        instance.onGround = dist ~= nil
        local hit_pos
        if instance.onGround then
            hit_pos = pos + dist * ray
        else
            local max_penetration = -1
            -- Maybe we're inverted, try to hook on to the nearest surface in any direction.
            physics_test(self.hoverHeight, pos, false, function (body, sz, local_pos, world_pos, normal, penetration, mat)
                if body == instance.body then return end
                if penetration > max_penetration then
                    max_penetration = penetration
                    ground = body
                    instance.onGround = true
                    hit_pos = world_pos
                    ground_normal = normal
                    ground_mat = mat
                end
            end)
        end
        if instance.onGround and not (instance.handbrake and vehicle_up.z < 0) then
            pos = hit_pos + self.hoverHeight * ground_normal
            ort = quat(vehicle_up, ground_normal) * ort
            local local_vel = inv(ort) * vel
            local vel_fwd = local_vel.y
            vel_fwd = vel_fwd + instance.push * self.acceleration * elapsed_secs
            if instance.push == 0 then
                -- Implicit brakes
                vel_fwd = vel_fwd * 0.5 ^ elapsed_secs
            end
            local vel_lat = local_vel.x
            vel_lat = vel_lat * 0.5 ^ elapsed_secs
            vel = ort * vec(vel_lat, vel_fwd, 0)

        else
            -- Projectile motion
            vel = vel + gravity * elapsed_secs
            ort = quat(ort * V_FORWARDS, vel) * ort
        end

        local speed = #vel
        if speed > self.speedMax then
            vel = vel * self.speedMax / speed
        end

        local angular_velocity = (instance.shouldSteerLeft + instance.shouldSteerRight) * elapsed_secs
        ort = norm(quat(angular_velocity, ort * vec(0, 0, -1)) * ort)
        instance.groundOrientation = ort
        instance.displayOrientation = norm(slerp(ort, instance.displayOrientation, 0.001 ^ elapsed_secs))
        instance.velocity = vel
        pos = pos + vel * elapsed_secs
        instance.pos = pos
        instance.body.linearVelocity = vel
        instance.body.worldPosition = pos
        instance.body.worldOrientation = instance.displayOrientation
        instance.body:force(-gravity, pos)
    end,

    controlBegin = function(self)
    end,

    controlAbandon = function(self)
    end,

    changePush = function(self)
        if not self.activated then error("Not activated: "..self.name) end
    end,

    setBackwards = function(self, v)
        if self.instance.exploded then return end
        if not self.activated then error("Not activated: "..self.name) end
        local change = v and 1 or -1
        self.instance.push = self.instance.push - change
        self:changePush()
    end,

    setForwards = function(self, v)
        if self.instance.exploded then return end
        if not self.activated then error("Not activated: "..self.name) end
        local change = v and 1 or -1
        self.instance.push = self.instance.push + change
        self:changePush()
    end,

    setLeft = function(self, v)
        if self.instance.exploded then return end
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.shouldSteerLeft = v and -self.steerMax or 0
    end,

    setRight = function(self, v)
        if self.instance.exploded then return end
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.shouldSteerRight = v and self.steerMax or 0
    end,

    getSpeed = function(self)
        if self.exploded then return 0 end
        if not self.activated then error("Not activated: "..self.name) end
        local rb = self.instance.body
        return #rb.linearVelocity
    end,

    setHandbrake = function(self, v)
        if self.exploded then return end
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.handbrake = v
    end,
}


--[[
class `DummyVehicle` (ColClass) {

    ...

    activate = function(self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        self.needsStepCallbacks = true
        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2
        instance.push = 0
        instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0
        instance.onGround = false
    end,

    deactivate = function(self, instance)
        self.needsStepCallbacks = false
        
        return ColClass.deactivate(self, instance)
    end,
    
    stepCallback = function(self, elapsed_secs)
        local instance = self.instance
        local body = instance.body
        local mass, inertia = body.mass, body.inertia
        local vehicle_up = body.worldOrientation * vec(0, 0, 1)
        local dist, ground, ground_normal, ground_mat = physics_cast(body.worldPosition, self.hoverHeight * -2 * vehicle_up, true, 0, body)
        instance.onGround = dist ~= nil
        if dist then
            dist = dist * self.hoverHeight * 2
            local extension = dist - self.hoverHeight
            body:force((-100 * mass * extension) * vehicle_up, body.worldPosition)
            body:torque(cross(vehicle_up, ground_normal) * 20 * inertia)
        end

        if instance.onGround and self:getSpeed() <= self.speedMax then
            body:force(body.worldOrientation * vec(0, 1000 * mass * instance.push, 0), body.worldPosition)
        end
        if math.abs(body.angularVelocity.z) < self.steerMax then
            body:torque(body.worldOrientation * vec(0, 0, -0.1 * (instance.shouldSteerLeft + instance.shouldSteerRight)) * inertia)
        end
    end,

    ...
}
]]

local GameMode = extends_keep_existing (game_manager.gameModes['Wipeout'], ThirdPersonGameMode) {
    name = 'Wipeout',
    description = 'Wipeout inspired racing game',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(550, -2227, 109),
    spawnRot = Q_ID,
    seaLevel = -6,
}

function GameMode:init()

    ThirdPersonGameMode.init(self)

    self.protagonist = object `/detached/characters/robot_scout` (0, 0, 0) { }
    self.vehicle = nil
    -- object `/vehicles/Hoverman` (487, -2011, 47) {name = "test_wipeoutcar", rot=quat(-0.4019256, 0.004209109, 0.009588621, -0.9156125)}

    self:playerRespawn()
end


function ThirdPersonGameMode:frameCallback(elapsed_secs)
    BaseGameMode.frameCallback(self, elapsed_secs)
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

    main.speedoPos = instance.camAttachPos 
    main.speedoSpeed = #vehicle_vel
    if self.vehicle ~= nil then
        self.protagonist:updateDriven(instance.camAttachPos, Q_ID)
    end

    -- TODO(dcunnin): If reducing this to 0 worked then remove it.
    local ray_skip = 0
    local ray_dir = main.camQuat * V_BACKWARDS
    local ray_start = instance.camAttachPos + ray_skip * ray_dir
    if obj.boomLengthMin == nil or obj.boomLengthMax == nil then
        error('Controlling %s of class %s, needed boomLengthMin and boomLengthMax, got: %s, %s'
              % {obj, obj.className, obj.boomLengthMin, obj.boomLengthMax})
    end
    local ray_len = self:boomLength(obj.boomLengthMin, obj.boomLengthMax) - ray_skip
    local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
    local boom_length = math.max(obj.boomLengthMin, ray_hit_len)

    main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)
    main.streamerCentre = instance.camAttachPos
    main.audioCentrePos = main.camPos
end

game_manager:register(GameMode)


