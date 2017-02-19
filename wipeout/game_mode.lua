material `DummyVehicle` {
    diffuseMap = {
        -- Filename on disk.
        image = `DummyVehicle.png`,
        modeU = "CLAMP",
        modeV = "CLAMP",
    },
}

local ACTIVE_SURFACE = `Track`

--[[

The logical model derives a position for the ship relative to the track.  This uses a point on the
track, a direction, and a distance to compute the position and orientation of the ship.  The
distance is fixed, the computation of the point and normal depend on where the vehicle is and what
the track looks like under the vehicle.  There are two logical models currently proposed:

The one-ray logical model shoots one ray from the center of the ship in the ship's -Z axis to find a
point on the track, then uses the normal of the surface that point.  The ship will intersect the
track in places where the track is more concave than the ship is convex for the given hover
distance.

The four-ray logical model shoots a ray from each corner of the ship (modelled as an arbitrary
4-sided convex shape) in the ship's -Z axis.  The four positions and normals are averaged.  This
model will intersect the track if there is a lump between where the rays hit.  There is a question
as to what should happen if only 3 of the rays hit the track.

Both n-ray logical models suffer from discontinuities in ground normal due to the curvature of the
track.  The four-ray logical model has more discontinuities (a four-wheeled car going over a speed
bump can have 4 bumps) but they should be lesser in magnitude because of the averaging.

When the craft is not parallel with the track, small changes in craft position (e.g. thrust or
rotation) will result in large changes in distance to the ground.  The one-ray logical model always
has the ship perpendicular to the ground normal.  If the ship is not moved by the player, subsequent
rays will be in-line with the previous ray.  The 4-ray logical model does not have this property.
Therefore, it can oscillate because after orientating the ship, the rays will not necessarily hit
where they hit before and can get a different normal.

The convex-cast logical model does a convex cast in the ship's -Z direction.  Any collisions are
disregarded except with the track.  The returned normals are that of the triangles hit.  They will
have to be averaged or some other technique used.  This can lead to oscillation.

My conclusion is that the only reliable method is the one-ray logical model, even with the challenge
of having to deal with the inevitable track intersections.


Resolving collisions with barriers, other ships, etc.:

The logical model must have push back from a collision engine of some sort.  Collisions with the
track must be prevented by putting the physics body in a different place to the logical model, or
just ignored.

The PID approach tries to continuously pull the physical body towards the logical model.  Collisions
with the track are likely because PID is too soft to keep the ship a fixed distance from the track.
Sometimes the logical model intersects the track anyway, so the PID loops will pull the ship against
the track.  At high speeds, more collisions are likely.  Collisions with the track can be allowed,
at least at low speed.

The direct update approach sets the physics body position and orientation to the logical model and
then allows collisions and other forces to influence the position further.  Unfortunately, this
results in oscillation due to discontinuities in where the logical model believes the ship should be
(e.g. discontinuities in track normal).  Collisions with the track must therefore be disabled.

The ghost approach is to disable collisions entirely and implement the collision detection manually.
Sweep the hull forwards and see what it intersects.  Collisions with the track are ignored.

2) Other ships.

Need to register only one collision per pair and share momentum.  Collisions with barrier must take
precedence.  Resolving collisions properly requires a solver :(

3) The barrier

Ship must not cross the barrier.  Update position and orientation appropriately (we probably want to
slide along the barrier).  There should be a friction penalty for hitting the barrier.

4) Some other static obstacle?

Can behave just like the barrier as a default.  We may also want to disable ships for greater
penalties (electric shock, etc), depending on the obstacle.  Can even destroy ships.

5) Dynamic obstacles?

Not strictly necessary but would be nice to demonstrate the dynamics engine.  We can apply forces to
represent collisions with these, much like the actor can push a car.


Collision resolution:

Resolve collisions between ships first, transfer momentum.  Then, resolve constraints with immovable
objects.  This will result in momentum being 'lost' but over time hopefully it works out.

]]

--[[

One-ray logical model updates logical position and orientation.  Ship rotation and thrust directly
control logical position and orientation.

At low speeds, a PID loop is used to pull ship towards logical position and orientation.  Physical
position / orientation then copied to logical model for next iteration.  Thrust sets physical
velocity.  Hopefully PID loop dampens any oscillations.  Rotation may have to directly change
orientation (no PID loop) if rotating is not snappy enough.

At high speeds, collision with the track is disabled.  This avoids some collisions and may be enough
to keep using the PID loop at higher speeds.

At very high speeds, when the PID loop is too squishy and we fly through the track, the physical
position / orientation is updated directly every frame, allowed to collide, then set back into the
logical model again.

A final option is to disable collision detection entirely and use convex hull casts.

]]

class `TestShip` (ColClass) {

    gfxMesh = `DummyVehicle.mesh`,
    colMesh = `DummyVehicle.gcol`,
    controllable = 'VEHICLE', 
    boomLengthMin = 5,
    boomLengthMax = 30,
    driverExitPos = vector3(-1.45, -0.24, 0.49),
    driverExitQuat = Q_ID,
    cameraTrack = true,
    -- Can set this higher when we have a solution for not putting the camera in the track.
    camAttachPos = vec(0,0, 1),

    hoverHeight = 1,
    steerMax = 80,  -- degrees/sec
    speedMax = 100,  -- metres/sec
    acceleration = 10,
    initialVelocity = vec(0, 0, 0),
    invertedDrag = 1,  -- Multiple of speed to apply as deceleration
    disconnectionDrag = 0.3,  -- Multiple of speed to apply as deceleration
    resetSpeedMax = 3,  -- metres/sec
    connectedBrakeDrag = 0.5,  -- Proportion of speed lost per second.
    connectedLateralDrag = 0.5,  -- Proportion of speed lost per second.

	frontLeftJet = vec(-1, 4, 0),
	frontRightJet = vec(1, 4, 0),
	rearLeftJet = vec(-2, -2, 0),
	rearRightJet = vec(2, -2, 0),

    activate = function(self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        self.needsStepCallbacks = true
        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2
        instance.push = 0
        instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0
        instance.onGround = false
        instance.velocity = self.initialVelocity
        instance.body.ghost = false
        instance.body.angularDamping = 0.8
        instance.body.linearDamping = 0
        instance.lastPosDev = vec(0, 0, 0)
        instance.lastVelDev = vec(0, 0, 0)
        instance.lastTensorDev = vec(0, 0, 0)
    end,

    deactivate = function(self, instance)
        self.needsStepCallbacks = false
        
        return ColClass.deactivate(self, instance)
    end,

    doRay = function(self, rayFrom, ray)
        local dist, ground, ground_normal, ground_mat = physics_cast(pos, ray, true, 0)
    end,

    -- initial_vel and velocity returned is in in local space, does not have z component.
    logicalUpdate = function(self, initial_pos, initial_ort, initial_vel, elapsed_secs)
        local instance = self.instance
        local body = instance.body
        local gravity = physics_get_gravity()
        local vehicle_up = initial_ort * vec(0, 0, 1)
        local ray = self.hoverHeight * -2 * vehicle_up
        local dist, ground, ground_normal, ground_mat = physics_sweep_sphere(0.001, initial_pos, ray, true, 0, body)
        local pos = initial_pos

        if dist == nil or ground_mat ~= ACTIVE_SURFACE or (instance.handbrake and vehicle_up.z < 10) then
            return
        end

        local ground_pos = initial_pos + dist * ray

        -- Set position and orientation to track hover location.
        pos = ground_pos + self.hoverHeight * ground_normal

        -- Simulate friction
        local vel_fwd = initial_vel.y
        vel_fwd = vel_fwd + instance.push * self.acceleration * elapsed_secs
        if instance.push == 0 then
            -- Implicit brakes
            vel_fwd = vel_fwd * self.connectedBrakeDrag ^ elapsed_secs
        end
        local vel_lat = initial_vel.x
        vel_lat = vel_lat * self.connectedLateralDrag ^ elapsed_secs
        local vel = vec(vel_lat, vel_fwd, 0)
        
        -- Cap speed.
        local speed = #vel
        if speed > self.speedMax then
            vel = vel * self.speedMax / speed
        end

        return pos, ground_normal, vel
    end,
    
    stepCallback = function(self, elapsed_secs)

        local instance = self.instance
        local body = instance.body

        local pos, ort, vel = self:logicalUpdate(
            body.worldPosition, body.worldOrientation, instance.velocity, elapsed_secs)

        -- Store for next iteration.
        instance.velocity = vel

        local on_ground = pos ~= nil
        local upside_down = false

        if not on_ground then

            -- Projectile motion, surrender to physics engine.

            local bvel = body.linearVelocity

            instance.velocity = vec(0, 0, 0)
            instance.lastPosDev = vec(0, 0, 0)
            instance.lastVelDev = vec(0, 0, 0)

            -- Maybe we're inverted, try to hook on to the nearest surface in any direction.
            local max_penetration = -1
            local pos
            local function test_func(body, sz, local_pos, world_pos, normal, penetration, mat)
                if body == instance.body then return end
                if mat ~= ACTIVE_SURFACE then return end
                if penetration > max_penetration then
                    max_penetration = penetration
                    on_ground = true
                    upside_down = true
                    ort = normal
                    pos = world_pos
                end
            end
            physics_test(self.hoverHeight * 2, body.worldPosition, false, test_func)
            local slow_enough = #bvel < self.resetSpeedMax
            local col = vec(1, 1, 1)
            if slow_enough then
                col = vec(1, 0, 0)
            end
            if on_ground then
                -- Drag
                body:force(body.mass * -self.invertedDrag * bvel, body:localToWorld(vec(0, -1, 0)))
                emit_debug_marker(pos, col, elapsed_secs, 1)
            else
                -- Drag
                body:force(body.mass * -self.disconnectionDrag * bvel, body:localToWorld(vec(0, -1, 0)))
            end
        else
            emit_debug_marker(pos, vec(0, 0, 1), elapsed_secs, 1)
            emit_debug_marker(pos - ort * self.hoverHeight, vec(0, 1, 1), elapsed_secs, 1)
        end

        if not on_ground then
            instance.lastTensorDev = vec(0, 0, 0)
            return
        end

        -- Smooth orientation.  Avoid bumpy track problem.
        -- norm(slerp(ort, instance.displayOrientation, 0.001 ^ elapsed_secs)))
        do
            -- Use a PID loop to align body with logical orientation (ground normal).

            local tensor_dev = cross(ort, body.worldOrientation * vec(0, 0, 1))

            local tensor_dev_change = tensor_dev - instance.lastTensorDev
            instance.lastTensorDev = tensor_dev

            local P, D = -10, -100

            local AA = P * tensor_dev + D * tensor_dev_change
            game_manager:debugText(1, 'Normal: %d', #AA)
            body:torque(body.inertia * AA)
        end

        if upside_down then
            return
        end

        do
            -- Use a PID loop to align body with logical position.
            local pos_dev = body.worldPosition - pos
            local pos_dev_change = (pos_dev - instance.lastPosDev) / elapsed_secs
            instance.lastPosDev = pos_dev

            local P, D = -100, -50

            local A = P*pos_dev + D*pos_dev_change
            -- When we clash with collisions, we're not going to win.  So avoid applying huge forces
            -- that make the simulation unstable.
            if #A > 100 then
                A = norm(A) * 100
            end
            game_manager:debugText(2, 'Position: %d', #A)
            body:force(body.mass * A, body.worldPosition)
        end

        do
            -- Use a PID loop to align body with logical velocity.
            local current_vel = (inv(body.worldOrientation) * body.linearVelocity) * vec(1, 1, 0)
            local vel_dev = current_vel - vel
            local vel_dev_change = (vel_dev - instance.lastVelDev) / elapsed_secs
            instance.lastVelDev = vel_dev

            local P, D = -200, 0

            local A = body.worldOrientation * (P*vel_dev + D*vel_dev_change)
            -- When we clash with collisions, we're not going to win.  So avoid applying huge forces
            -- that make the simulation unstable.
            if #A > 100 then
                A = norm(A) * 100
            end
            game_manager:debugText(3, 'Velocity: %d', #A)
            body:force(body.mass * A, body.worldPosition)
        end

        do
            -- Apply steering directly, not with forces but by setting velocity.
            local steering_ang_vel = -math.rad(instance.shouldSteerLeft + instance.shouldSteerRight)

            -- Project angular velocity tensor to remove the "about ground normal" component.
            -- Using the ground normal instead of the ship's normal avoids problems with when the
            -- ship is at a degenerate angle to the track.
            local current_steering_ang_vel = dot(body.angularVelocity, ort)
            local steering_change_needed = steering_ang_vel - current_steering_ang_vel

            local AA = ort * steering_change_needed
            game_manager:debugText(4, 'Steering: %d', #AA)
            body:torqueImpulse(body.inertia * AA)
        end

        body:force(-physics_get_gravity(), pos)
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


