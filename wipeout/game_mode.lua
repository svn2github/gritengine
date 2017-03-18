material `DummyVehicle` {
    diffuseMap = {
        -- Filename on disk.
        image = `DummyVehicle.png`,
        modeU = "CLAMP",
        modeV = "CLAMP",
    },
}


shader `DummyVehicleJet` {

    map = uniform_texture_2d(1, 1, 1);

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
    ]],

    dangsCode = [[
        out.diffuse = 0;
        out.alpha = 0;
    ]],

    -- alphaMask is not used to attenuate the emissive lighting here, allowing you to use it
    -- to attenuate the diffuse component only, for glowing gasses, etc.
    additionalCode = [[
        var uv = vert.coord0.xy;
        var c = sample(mat.map, uv);
        out.colour = gamma_decode(c.rgb) * body.paintDiffuse0;
    ]],
}



material `DummyVehicleJet` {
    shader = `DummyVehicleJet`,
    sceneBlend = 'ALPHA',
    backfaces = true,
    additionalLighting = true,
    castShadows = false,

    map = `DummyVehicle.png`,
}

local ACTIVE_SURFACE = `Track`

--[[

General notes on wipeout ship dynamics
======================================

Logical model
-------------

The logical model derives a position for the ship when it is glued to the track.  This computes a
new position, alignment (expressed as a track normal) and 2d velocity from the previous values of
those variables.  Experiments indicated that the best logical model involved a single ray.  from the
center of the ship in the ship's -Z axis to find a point on the track, then uses the normal of the
surface that point.  The ship will inevitably intersect the track in places where the track is more
concave than the ship is convex for the given hover distance.  In order to avoid falling down tiny
gaps between polygons, if the ray hits nothing, it is followed by a sphere cast.  Using the sphere
cast in the first pass turned out to cause oscillations.

We also tried a four ray model shooting a ray from each corner of the ship (modelled as an arbitrary
trapezoid) in the ship's -Z axis.  This has the following challenges:  1) How to combine the ray
results to position the ship.  2) What happens if not all the rays hit.  3) A ship going over a bump
has 4 "bumps" instead of 1.  The model can also still intersect the track if it is too convex.

We did not try cube or hull sweeps.  These will make combining normals even harder.  However, in the
case of the hull sweep, the ship will never intersect the track.

The normal from the track must be smoothed over time before updating the ship's position because the
discontinuities from one polygon to another cause a headache-inducing jarring effect when travelling
at speed.

The one ray model was attractive despite its various challenges because it was relatively free from
oscillations.  Oscillations are avoided because the ship is always positioned in a location where
the next ray overlays the previous ray, therefore gets the same result.  Even the sphere cast did
not have this property.

Two modes
---------

The logical model inevitably results in positioning the ship such that it intersects the track.
This happens because of the "curbs" at the sides of the track are too convex / concave to fit the
ship.  This can be fixed by, rather than updating the ship's position, orientaiton, and velocity
directly from the logical level, we instead apply forces using a PID loop to encourage the ship to
be in the right places.  These forces are then combined with other forces from collisions (e.g. with
the track).  This produces quite natural and appealing ship behavior.  However, the system fails at
speed when going into the loop-the-loops.

The loop-the-loops are highly concave and the velocities are high.  Any kind of normal smoothing to
avoid the jarring effect of polygon transitions means that the ship intersects the track going
through the loop-the-loops, at anything over about 30mph.  To fix this, we have a second mode of
control which is used at high speed only and only when properly aligned with the track.

In the high speed mode, the ship's position and orientation are updated directly from the physical
model.  Collision detection for the ship is disabled (ghost mode) to avoid fighting with collision
resolution impulses.  A convex hull sweep test is used to detect collisions with anything other than
the track.  When a collision is detected, control returns to the PID system for at least 1 second.
This typically results in a "real" collision which sufficiently interferes with the motion of the
ship that we do not return to fast mode until everything is fully resolved.

]]

class `TestShip` (ColClass) {

    gfxMesh = `DummyVehicle.mesh`,
    jetMesh = `DummyVehicleJet.mesh`,
    colMesh = `DummyVehicle.gcol`,
    controllable = 'VEHICLE', 
    boomLengthMin = 5,
    boomLengthMax = 30,
    driverExitPos = vector3(-1.45, -0.24, 0.49),
    driverExitQuat = Q_ID,
    cameraTrack = true,
    -- Can set this higher when we have a solution for not putting the camera in the track.
    camAttachPos = vec(0,0, 0.3),

    jetColourThrustSlow = vec(.7, .13, .1) * 0.8,
    jetColourThrustFast = vec(2, .23, .18)* 1.5,
    jetColourCoastSlow = vec(.01, .01, .01),
    jetColourCoastFast = vec(.4, .01, 0.005),
    jetColourBrakeSlow = vec(.01, .01, .04),
    jetColourBrakeFast = vec(0, .1, .3),
    jetScaleMax = 3,
    jetPosition = vec(0, -2.09617, 0.18313),

    hoverHeight = 1.5,
    steerMax = 80,  -- degrees/sec
    speedModeSwitch = 20,  -- metres/sec
    speedMax = 100,  -- metres/sec
    acceleration = 10,
    invertedDrag = 1,  -- Multiple of speed to apply as deceleration
    disconnectionDrag = 0.5,  -- Multiple of speed to apply as deceleration
    resetSpeedMax = 3,  -- metres/sec
    connectedBrakeDrag = 0.4,  -- Proportion of speed lost per second.
    connectedCoastDrag = 0.2,  -- Proportion of speed lost per second.
    connectedLateralDrag = 0.3,  -- Proportion of speed lost per second.

    activate = function(self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        self.needsStepCallbacks = true
        instance.jet = gfx_body_make(self.jetMesh)
        instance.jet.parent = instance.gfx
        instance.jet.localPosition = self.jetPosition
        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2
        instance.push = 0
        instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0
        instance.onGround = false
        instance.velocity = vec(0, 0, 0)
        instance.body.ghost = false
        instance.body.angularDamping = 0.8
        instance.body.linearDamping = 0
        instance.lastPosDev = vec(0, 0, 0)
        instance.lastVelDev = vec(0, 0, 0)
        instance.lastTensorDev = vec(0, 0, 0)
        -- In slow mode, this is the same as body.worldOrientation.
        -- In fast mode, this is the orientation of the craft if it were perfectly aligned.
        -- We smooth this out because it is too bumpy.  The reason it is too bumpy is inherent to
        -- having a track defined by polygons.  The lighting may be smooth, but the physics is not.
        -- In slow mode the PID loop provides the smoothing.
        instance.groundOrientation = self.rot or Q_ID
        instance.body.collisionCallback = function (...) self:collisionCallback(...) end
        instance.lastCollided = 0
        instance.lastPosition = instance.body.worldPosition
    end,

    setJetColour = function(self, colour)
        self.instance.jet:setPaintColour(0, colour, 0, 0, 0)
    end,

    collisionCallback = function (self, life, impulse, other, m, mo, pen, pos, poso, norm)
        if impulse <= 1000 then
            return
        end
        self.instance.lastCollided = seconds()
        --[[
        printf('Collision, speed %d, impulse %d',
               #self.instance.body.linearVelocity * 60 * 60 / METRES_PER_MILE,
               impulse)
        ]]
    end,

    deactivate = function(self, instance)
        self.needsStepCallbacks = false
        
        return ColClass.deactivate(self, instance)
    end,

    doRay = function(self, rayFrom, ray)
        local dist, ground, ground_normal, ground_mat = physics_cast(pos, ray, true, 0)
    end,

    --[[
    Compute a new logical position, orientation, and velocity.

    Logical update assumes we are approximately on the road.  It computes the position /
    orientation that would put us the correct distance from the road in the correct
    direction and with the correct orientation.

    initial_vel and velocity returned is in in local space, does not have z component.
    Params:
        initial_pos: Position from the last update.
        initial_up: vector3, current vertical normal
        initial_vel: vector2, velocity in local space (y forwards)
        elapsed_secs: Time since last update.
    Returns:
        new values for the 3 initial parameters (pos, up, vel)
        or no return values if we're not approximately on the road
    ]]
    logicalUpdate = function(self, initial_pos, initial_up, initial_vel, elapsed_secs)
        local instance = self.instance
        local gravity = physics_get_gravity()
        local ray = self.hoverHeight * -2 * initial_up
        local dist, ground, ground_normal, ground_mat =
            physics_cast(initial_pos, ray, true, 0, instance.body)
        if dist == nil then
            -- We may have shot a ray down a crack.  Cracks sometimes happen when the polys don't
            -- mesh properly.
            dist, ground, ground_normal, ground_mat =
                physics_sweep_sphere(0.04, initial_pos, ray, true, 0, instance.body)
        end

        if dist == nil or ground_mat ~= ACTIVE_SURFACE then
            self:setJetColour(vec(0, 0, 0))
            return
        end

        local ground_pos = initial_pos + dist * ray

        -- Set position and orientation to track hover location.
        local pos = ground_pos + self.hoverHeight * ground_normal

        -- Simulate friction
        local vel_fwd = initial_vel.y
        local speed_factor = math.abs(vel_fwd / self.speedMax)
        if vel_fwd > 0 then
            if instance.push < 0 then
                -- Braking
                self:setJetColour(lerp(self.jetColourBrakeSlow, self.jetColourBrakeFast, speed_factor))
                vel_fwd = vel_fwd * self.connectedBrakeDrag ^ elapsed_secs
            elseif instance.push == 0 then
                -- Coasting
                self:setJetColour(lerp(self.jetColourCoastSlow, self.jetColourCoastFast, speed_factor))
                vel_fwd = vel_fwd * self.connectedCoastDrag ^ elapsed_secs
            else
                -- Accelerating (no drag).
                self:setJetColour(lerp(self.jetColourThrustSlow, self.jetColourThrustFast, speed_factor))
            end
        else
            if instance.push >= 0 then
                -- Braking
                self:setJetColour(lerp(self.jetColourBrakeSlow, self.jetColourBrakeFast, speed_factor))
                vel_fwd = vel_fwd * self.connectedBrakeDrag ^ elapsed_secs
            elseif instance.push == 0 then
                -- Coasting
                self:setJetColour(lerp(self.jetColourCoastSlow, self.jetColourCoastFast, speed_factor))
                vel_fwd = vel_fwd * self.connectedCoastDrag ^ elapsed_secs
            else
                -- Accelerating (no drag).
                self:setJetColour(lerp(self.jetColourThrustSlow, self.jetColourThrustFast, speed_factor))
            end
        end
        instance.jet.localScale = vec(1, lerp(1, self.jetScaleMax, speed_factor), 1)
        vel_fwd = vel_fwd + instance.push * self.acceleration * elapsed_secs
        local vel_lat = initial_vel.x
        vel_lat = vel_lat * self.connectedLateralDrag ^ elapsed_secs
        local vel = vec(vel_lat, vel_fwd)
        
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
        instance.lastPosition = body.worldPosition

        local pos, up, vel = self:logicalUpdate(
            body.worldPosition,
            instance.groundOrientation * vec(0, 0, 1),
            instance.velocity,
            elapsed_secs)

        -- If we're near enough to a surface to hook on.
        local on_ground = pos ~= nil

        -- If we're near enough to a surface to hook on, but not the right way up.
        local upside_down = false

        if not on_ground then

            -- Projectile motion, surrender to physics engine.

            local bvel = body.linearVelocity

            instance.velocity = instance.velocity * self.connectedBrakeDrag ^ elapsed_secs
            if #bvel < #instance.velocity then
                instance.velocity = #bvel * norm(instance.velocity)
            end
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
                    up = normal
                    pos = world_pos
                end
            end
            physics_test(self.hoverHeight * 2, body.worldPosition, false, test_func)
            local slow_enough = #bvel < self.resetSpeedMax
            if on_ground then
                -- Drag
                body:force(body.mass * -self.invertedDrag * bvel, body:localToWorld(vec(0, -1, 0)))
                -- local col = vec(1, 0, 0)
                -- if slow_enough then
                --     col = vec(1, 1, 1)
                -- end
                -- emit_debug_marker(pos, col, elapsed_secs, 1)
            else
                -- Drag
                body:force(body.mass * -self.disconnectionDrag * bvel, body:localToWorld(vec(0, -1, 0)))
            end
        else
            -- Store for next iteration.
            instance.velocity = vel

            -- emit_debug_marker(pos, vec(0, 0, 1), elapsed_secs, 1)
            -- emit_debug_marker(pos - up * self.hoverHeight, vec(0, 1, 1), elapsed_secs, 1)
        end

        if not on_ground then
            instance.lastTensorDev = vec(0, 0, 0)
            return
        end

        local vel = instance.velocity
        local speed = #vel

        body.ghost = false
        if on_ground and not upside_down and speed > self.speedModeSwitch and seconds() - instance.lastCollided > 1 then
            -- Fast mode.
            body.ghost = true
            body:force(-physics_get_gravity(), pos)

            local current_ort = body.worldOrientation
            local current_up = current_ort * vec(0, 0, 1)
            local desired_ort = quat(current_up, up) * current_ort

            if speed > self.speedMax then
                vel = vel * self.speedMax / speed
            end
            local world_vel = current_ort * vec3(vel, 0)

            local steering_angular_velocity = (instance.shouldSteerLeft + instance.shouldSteerRight) * elapsed_secs
            local steering_angular_quat = quat(steering_angular_velocity, desired_ort * vec(0, 0, -1))


            local ray = world_vel * elapsed_secs
            local colliding = false
            local function cb(dist, body, normal, mat)
                if mat == ACTIVE_SURFACE then return end
                colliding = true
            end
            -- Cast the ship forwards.
            physics_sweep_col_mesh(body.meshName, desired_ort, pos, ray, false, 0, cb, body)

            if not colliding then
                -- Proceed with the fast-mode simulation.
       
                instance.groundOrientation = steering_angular_quat * desired_ort
                body.worldOrientation =
                    steering_angular_quat * slerp(desired_ort, current_ort, 0.0001 ^ elapsed_secs)
                body.linearVelocity = world_vel
                -- Note that the body.worldOrientation may not actually be "correct" as it is
                -- smoothed.

                -- Do not interpolate the position, instead set the velocity and let Bullet
                -- interpolate it for us.  However, change the position to the right distance
                -- from the track.
                body.worldPosition = pos
                return
            end

            -- We're going to hit something.  Fall through to the regular logic now.
            instance.lastCollided = seconds()
        end

        -- Slow mode.

        instance.groundOrientation = body.worldOrientation

        do
            -- Use a PID loop to align body with logical orientation (ground normal).

            local actual_up = body.worldOrientation * vec(0, 0, 1)
            local tensor_dev = cross(up, actual_up)
            if dot(up, actual_up) < 0 and #tensor_dev > 0.01 then
                -- Avoid a problem where we don't have enough strength to flip the craft when
                -- dot(up, actual_up) is approximately -1.
                -- Artificially inflate the tensor to its max amount when we're upside down.
                tensor_dev = norm(tensor_dev)
            end

            local tensor_dev_change = tensor_dev - instance.lastTensorDev
            instance.lastTensorDev = tensor_dev

            local P, D = -15, -300

            local AA = P * tensor_dev + D * tensor_dev_change
            -- game_manager:debugText(1, 'Normal: %d', #AA)
            -- if #AA > 100 then
            --     printf('Normal: %d', #AA)
            -- end
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

            local P, D = -300, -50

            local A = P*pos_dev + D*pos_dev_change
            -- When we clash with collisions, we're not going to win.  So avoid applying huge forces
            -- that make the simulation unstable.
            if #A > 100 then
                A = norm(A) * 100
            end
            -- game_manager:debugText(2, 'Position: %d', #A)
            body:force(body.mass * A, body.worldPosition)
        end

        do
            -- Use a PID loop to align body's velocity with logical velocity.
            local current_vel = (inv(body.worldOrientation) * body.linearVelocity) * vec(1, 1, 0)
            local vel_dev = current_vel - vec3(vel, 0)
            local vel_dev_change = (vel_dev - instance.lastVelDev) / elapsed_secs
            instance.lastVelDev = vel_dev

            local P, D = -200, 0

            local A = body.worldOrientation * (P*vel_dev + D*vel_dev_change)
            -- When we clash with collisions, we're not going to win.  So avoid applying huge forces
            -- that make the simulation unstable.
            if #A > 200 then
               --  game_manager:debugText(3, 'Velocity: %d', #A)
                A = norm(A) * 200
            end
            body:force(body.mass * A, body.worldPosition)
        end

        do
            -- Apply steering directly, not with forces but by setting velocity.
            local steering_ang_vel = -math.rad(instance.shouldSteerLeft + instance.shouldSteerRight)

            -- Project angular velocity tensor to remove the "about ground normal" component.
            -- Using the ground normal instead of the ship's normal avoids problems with when the
            -- ship is at a degenerate angle to the track.
            local current_steering_ang_vel = dot(body.angularVelocity, up)
            local steering_change_needed = steering_ang_vel - current_steering_ang_vel

            local AA = up * steering_change_needed / elapsed_secs
            if #AA > 20 then
                AA = norm(AA) * 20
            end
            -- game_manager:debugText(4, 'Steering: %d', #AA)
            body:torque(body.inertia * AA)
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


function GameMode:frameCallback(elapsed_secs)
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


