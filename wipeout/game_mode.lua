local GameMode = extends_keep_existing (game_manager.gameModes['Wipeout'], ThirdPersonGameMode) {
    name = 'Wipeout',
    description = 'Wipeout inspired racing game',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(550, -2227, 109),
    spawnRot = Q_ID,
    seaLevel = -6,
}

material `DummyVehicle` {
    diffuseMap = `DummyVehicle.png`,
}

class `DummyVehicle` (ColClass) {

    controllable = 'VEHICLE', 
    boomLengthMin = 3;
    boomLengthMax = 15;
    driverExitPos = vector3(-1.45, -0.24, 0.49);
    driverExitQuat = Q_ID;
    cameraTrack = true;

    hoverHeight = 1,
    steerMax = 35,
    speedMax = 30,  -- metres/sec

    init = function(self)
        ColClass.init(self)
    end,
    
    destroy = function(self)
        ColClass.destroy(self)
    end,

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

    controlBegin = function(self)
    end,

    controlAbandon = function(self)
    end,
    controlZoomIn = regular_chase_cam_zoom_in,
    controlZoomOut = regular_chase_cam_zoom_out,
    controlUpdate = regular_chase_cam_update,


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

function GameMode:init()

    ThirdPersonGameMode.init(self)

    self.protagonist = object `/detached/characters/robot_scout` (0, 0, 0) { }
    self.vehicle = nil
    -- object `/vehicles/Hoverman` (487, -2011, 47) {name = "test_wipeoutcar", rot=quat(-0.4019256, 0.004209109, 0.009588621, -0.9156125)}

    self:playerRespawn()
end

game_manager:register(GameMode)


