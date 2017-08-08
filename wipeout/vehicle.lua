material `DummyVehicle` {
    diffuseMap = {
        -- Filename on disk.
        image = `DummyVehicle.png`,
        modeU = "CLAMP",
        modeV = "CLAMP",
    },
}


shader `DummyVehicleJet` {

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
        var pi = asin(1.0) * 2;

        var uv = vert.coord0.xy;
        var colour = body.paintDiffuse0;
        var long_anim_state = body.paintMetallic0;
        var circ_anim_state = body.paintGloss0;
        var num_features = body.paintSpecular0;

        // uv.x is 1 near the engine and fades out to 0
        out.colour = pow(uv.x, 3.0) * colour;

        // longitudinal oscillation
        out.colour = out.colour * (sin((uv.x * num_features + long_anim_state) * pi * 2) / 3 + 0.6666);

        // circumference oscillation
        out.colour = out.colour * (sin((uv.y * num_features + circ_anim_state) * pi * 2) / 4 + 0.75);
    ]],
}


material `DummyVehicleJet` {
    shader = `DummyVehicleJet`,
    sceneBlend = 'ALPHA',
    backfaces = true,
    additionalLighting = true,
    castShadows = false,
}

    
--[[
]]

particle `JetSmoke` {
    map = `/common/particles/GenericParticleSheet.dds`,

    frames = { 896,640, 128, 128, },
    frame = 0,

    diffuse = vec(.23, 2, .18),
    velocity = vec(0, 0, 0),

    life = 1,

    alphaCurve = Plot {
        [0] = 1,
        [0.2] = 0.3,
        [0.5] = 0.1,
        [1] = 0,
    },
	alphaMask = 1,

    -- Acceleration over lifetime.
    convectionCurve = PlotV3 {
        [0] = vec(0, 0, 25),
        [0.25] = vec(0, 0, 25),
        [1] = vec(0, 0, 0),
    },


    behaviour = function (tab, elapsed)
        tab.age = tab.age + elapsed / tab.life
        if tab.age > 1 then
            return false
        end 

        if tab.velocity then
            local vel = tab.velocity
            if tab.convectionCurve then
				local accel = tab.convectionCurve[tab.age]
                vel = vel + accel * elapsed
            end
            tab.position = tab.position + vel * elapsed
            tab.velocity = math.pow(0.01, elapsed) * tab.velocity
        end

        tab.volume = lerp(tab.initialVolume, tab.maxVolume, tab.age)
        local radius = math.pow(tab.volume/math.pi*3/4, 1/3) -- sphere: V = 4/3πr³
        tab.dimensions = (2 * radius) * vec(1, 1, 0.5)
        
        local alpha = tab.alphaCurve[tab.age]
        tab.alpha = alpha * tab.alphaMask

        -- colour is constant, but attenuate it with alpha
        tab.diffuse = tab.initialDiffuse * alpha
    end,
}

--[[
  Args:
    pos: Where to emit the smoke
	time: How long have we been emitting smoke (0 to 1).
]]
function emit_jet_smoke(pos, time)
	local r1 = .3
	local r2 = 2
	local speed_colour = vec(.23, 2, .18)
	gfx_particle_emit(`JetSmoke`, pos, {
		angle = 360 * math.random(),
		initialVolume = 4/3 * math.pi * r1*r1*r1,  -- volume of sphere
		maxVolume = 4/3 * math.pi * r2*r2*r2,  -- volume of sphere
		diffuse = speed_colour,
		initialDiffuse = speed_colour,
		age = 0,
		alphaMask = 1 - time,
	})
end


SPEED_PAD_SURFACE = `SpeedPad`
SPEED_PAD_MULTIPLIER = 1.5
SPEED_PAD_TIMEOUT = 4
SPEED_PAD_IMPULSE = 20
WEAPON_PAD_SURFACE = `SpeedPad`

local ACTIVE_SURFACES = {
    [`Track`] = true,
    [SPEED_PAD_SURFACE] = true,
    [WEAPON_PAD_SURFACE] = true,
}

--[[

General notes on wipeout ship dynamics
======================================

Logical model
-------------

The logical model derives a position for the ship when it is glued to the track.  This computes a
new position, alignment (expressed as a track normal) and 2d velocity from the previous values of
those variables.  Experiments indicated that the best logical model involved a single ray from the
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
    boomLengthMin = 3,
    boomLengthMax = 20,
    driverExitPos = vector3(-1.45, -0.24, 0.49),
    driverExitQuat = Q_ID,
    cameraTrack = true,
    -- Can set this higher when we have a solution for not putting the camera in the track.
    camAttachPos = vec(0,0, 0.3),

    jetColourThrustSlow = vec(.7, .13, .1) * 0.8,
    jetColourThrustFast = vec(2, .23, .18)* 1.5,
    jetColourSpeedPadSlow = vec(.13, .7, .1) * 0.8,
    jetColourSpeedPadFast = vec(.23, 2, .18)* 1.5,
    jetScaleMax = 3,
    jetPosition = vec(0, -2.09617, 0.18313),

    trails = {
        leftBack = {
            pos = vec(-1.2, -2, 0.1),
        },
        rightBack = {
            pos = vec(1.2, -2, 0.1),
        },
    },

    hoverHeight = 1.5,
    steerMax = 80,  -- degrees/sec
    tiltFactor =  0.10,  -- factor of steering used for tilt
    speedModeSwitch = 20,  -- metres/sec
    speedFast = 70,  -- special visual effects begin
    speedMax = 100,  -- metres/sec
    acceleration = 10,
    attachedDrag = 1,  -- Multiple of speed to apply as deceleration
    disconnectionDrag = 0.5,  -- Multiple of speed to apply as deceleration
    resetSpeedMax = 3,  -- metres/sec
    connectedBrakeDrag = 0.4,  -- Proportion of speed lost per second.
    connectedCoastDrag = 0.2,  -- Proportion of speed lost per second.
    connectedLateralDrag = 0.3,  -- Proportion of speed lost per second.
    floatAnimFreq = 0.3,
    floatAnimMagnitude = 0.1,

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
        instance.longAnimState = 0
        instance.circAnimState = 0
        instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0
        instance.steeringControl = DigitalControl.new(self.steerMax, 400, 700, 1000)
        instance.tilt = 0
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
        instance.secondsSinceLastAttached = 0
        instance.secondsSinceLastAirborne = 0
        instance.floatAnimPos = 0
        instance.timeSinceSpeedPad = SPEED_PAD_TIMEOUT  -- Avoid it triggering immediately.
        if self.trails then
            instance.trails = {}
            for k, trail in pairs(self.trails) do
                instance.trails[k] = gfx_tracer_body_make()
                instance.trails[k].texture = `/system/Tracer.png`
                instance.trails[k].diffuseColour = vec(1, 1, 1)
                instance.trails[k].alpha = 0.3
                instance.trails[k].length = 0.3
                instance.trails[k].size = 0.1
            end
            instance.body.stepCallback = function()
                local instance = self.instance
                local alpha = clamp((instance.velocity.y - self.speedFast) / 30, 0, 0.1)
                for k, trail in pairs(instance.trails) do
                    trail.alpha = alpha
                    trail.localPosition = instance.body:localToWorld(self.trails[k].pos)
                end
            end
        end
        instance.body.updateCallback = function(p, q)
            instance.camAttachPos = p + q * self.camAttachPos
            instance.gfx.localPosition = p
            instance.gfx.localOrientation = q * quat(instance.tilt, vec(0, 1, 0))
            self.pos = p
        end

    end,

    speedEffect = function (self)
        local instance = self.instance
        return instance.timeSinceSpeedPad < SPEED_PAD_TIMEOUT
    end,

    --[[
    Args:
        airborne: bool
        speed_factor: 0 -> 1, stationary to max speed
        push: -1, 0 or 1
    --]]
    setJetEffect = function(self, elapsed_secs, airborne, speed_factor, push)
        local colour = vec(0, 0, 0)
        local instance = self.instance

        local long_freq = speed_factor * push * 10
        local circ_freq = lerp(speed_factor, 0.3, 3)
        local features = 3
        if speed_factor * self.speedMax > self.speedFast then
            features = 5
            long_freq = long_freq * 2
            circ_freq = circ_freq * 3
        end
        instance.longAnimState = (instance.longAnimState + elapsed_secs * long_freq) % 1
        instance.circAnimState = (instance.circAnimState + elapsed_secs * circ_freq) % 1
        
        colour = lerp(self.jetColourThrustSlow, self.jetColourThrustFast, speed_factor)

        if self:speedEffect() then
            colour = lerp(self.jetColourSpeedPadSlow, self.jetColourSpeedPadFast, speed_factor / SPEED_PAD_MULTIPLIER)
        end

        -- Fade jet in / out according to whether we are attached to the track.
        if airborne then
            self.instance.secondsSinceLastAirborne = 0
            self.instance.secondsSinceLastAttached =
                self.instance.secondsSinceLastAttached + elapsed_secs
            colour = colour * clamp(1 - self.instance.secondsSinceLastAttached, 0, 1)
        else
            self.instance.secondsSinceLastAttached = 0
            self.instance.secondsSinceLastAirborne =
                self.instance.secondsSinceLastAirborne + elapsed_secs
            colour = colour * clamp(self.instance.secondsSinceLastAirborne * 3, 0, 1)
        end

        -- index, diff, met, gloss, spec
        instance.jet:setPaintColour(0, colour, instance.longAnimState, instance.circAnimState, features)

        local jet_scale = lerp(1, self.jetScaleMax, speed_factor)
        instance.jet.localScale = vec(1, jet_scale, 1)
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

    deactivate = function(self)
        self.needsStepCallbacks = false

        local instance = self.instance

        if instance.trails then
            for k, trail in pairs(instance.trails) do
                safe_destroy(trail)
            end
        end
        
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

        local vel_fwd = initial_vel.y
        local speed_factor = math.abs(vel_fwd / self.speedMax)
        local thrust_dir 
        if vel_fwd > 0 then
            if instance.push < 0 then
                -- Braking
                thrust_dir = -1
            elseif instance.push == 0 then
                -- Coasting
                thrust_dir = 0
            else
                -- Accelerating
                thrust_dir = 1
            end
        else
            if instance.push >= 0 then
                thrust_dir = -1
                -- Braking
            elseif instance.push == 0 then
                -- Coasting
                thrust_dir = 0
            else
                -- Accelerating
                thrust_dir = 1
            end
        end

        if dist == nil or not ACTIVE_SURFACES[ground_mat] then
            self:setJetEffect(elapsed_secs, true, speed_factor, instance.push)
            return
        else
            self:setJetEffect(elapsed_secs, false, speed_factor, instance.push)
        end

        if ground_mat == SPEED_PAD_SURFACE then
            if instance.timeSinceSpeedPad > 0.1 then
                vel_fwd = vel_fwd + SPEED_PAD_IMPULSE
            end
            instance.timeSinceSpeedPad = 0
        end

        local ground_pos = initial_pos + dist * ray

        -- Set position and orientation to track hover location.
        local pos = ground_pos + self.hoverHeight * ground_normal

        -- Simulate friction
        if thrust_dir > 0 then
            -- Accelerating (no drag).
        elseif thrust_dir == 0 then
            -- Coasting
            vel_fwd = vel_fwd * self.connectedCoastDrag ^ elapsed_secs
        else
            -- Braking
            vel_fwd = vel_fwd * self.connectedBrakeDrag ^ elapsed_secs
        end
        vel_fwd = vel_fwd + instance.push * self.acceleration * elapsed_secs
        local vel_lat = initial_vel.x
        vel_lat = vel_lat * self.connectedLateralDrag ^ elapsed_secs
        local vel = vec(vel_lat, vel_fwd)
        
        -- Cap speed.
        local speed = #vel
        local max_speed = self.speedMax
        if self:speedEffect() then
            max_speed = max_speed * SPEED_PAD_MULTIPLIER
        end
        if speed > max_speed then
            vel = vel * max_speed / speed
        end

        instance.timeSinceSpeedPad = instance.timeSinceSpeedPad + elapsed_secs

        return pos, ground_normal, vel
    end,
    
    stepCallback = function(self, elapsed_secs)

        local instance = self.instance

        local steering_digital_control = instance.shouldSteerLeft + instance.shouldSteerRight

        local smoothed_steering = instance.steeringControl:pump(elapsed_secs, steering_digital_control)
        game_manager:debugText(1, 'Steer: %f', smoothed_steering)

        -- calc desired_tilt as a multiple of smoothed_steering
        instance.tilt = smoothed_steering * self.tiltFactor

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
            -- Projectile motion, make our own values for pos, vel, up using projectile model.

            pos = body.worldPosition
            local bvel = body.linearVelocity

            vel = instance.velocity
            vel = vel * self.connectedBrakeDrag ^ elapsed_secs
            if #bvel < #vel then
                vel = #bvel * norm(vel)
            end
            instance.lastPosDev = vec(0, 0, 0)
            instance.lastVelDev = vec(0, 0, 0)

            -- Maybe we're inverted, try to hook on to the nearest surface in any direction.
            local max_penetration = -1
            local function test_func(body, sz, local_pos, world_pos, normal, penetration, mat)
                if body == instance.body then return end
                if not ACTIVE_SURFACES[mat] then return end
                if penetration > max_penetration then
                    max_penetration = penetration
                    on_ground = true
                    upside_down = true
                    up = normal
                end
            end
            physics_test(self.hoverHeight * 2, pos, false, test_func)

            local drag = on_ground and self.attachedDrag or self.disconnectionDrag
            body:force(body.mass * -drag * bvel, body:localToWorld(vec(0, -1, 0)))

            if not on_ground then
                instance.lastTensorDev = vec(0, 0, 0)
                -- Store for next iteration.
                instance.velocity = vel
                instance.groundOrientation = body.worldOrientation
                return
            end
        end

        local smoke_length = 0.3  -- How many seconds to emit speed pad smoke.
        if instance.timeSinceSpeedPad < smoke_length then
            local ppos = body:localToWorld(self.jetPosition)
			emit_jet_smoke(ppos, instance.timeSinceSpeedPad /  smoke_length)
        end

        -- Store for next iteration.
        instance.velocity = vel

        local speed = #vel

        if on_ground and not upside_down and speed > self.speedModeSwitch and seconds() - instance.lastCollided > 1 then
            -- Fast mode.
            body.ghost = true
            body:force(-physics_get_gravity(), pos)

            local current_ort = body.worldOrientation
            local current_up = current_ort * vec(0, 0, 1)
            local desired_ort = quat(current_up, up) * current_ort

            -- speed should already be clipped by logicalUpdate
            -- if speed > self.speedMax then
            --   vel = vel * self.speedMax / speed
            --nd
            local world_vel = current_ort * vec3(vel, 0)

            local steering_angular_quat = quat(-smoothed_steering * elapsed_secs, desired_ort * vec(0, 0, 1))


            local ray = world_vel * elapsed_secs
            local colliding = false
            local function cb(dist, body, normal, mat)
                if ACTIVE_SURFACES[mat] then return end
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

        body.ghost = false
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

        -- TODO(dcunnin): offset pos according to float animation
        instance.floatAnimPos = (instance.floatAnimPos + elapsed_secs * self.floatAnimFreq) % 1
        local float_amount = math.sin(instance.floatAnimPos * math.pi * 2) * self.floatAnimMagnitude

        pos = pos + float_amount * up

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
            -- Project angular velocity tensor to remove the "about ground normal" component.
            -- Using the ground normal instead of the ship's normal avoids problems with when the
            -- ship is at a degenerate angle to the track.
            local current_steering_ang_vel = dot(body.angularVelocity, up)
            local steering_change_needed = math.rad(-smoothed_steering) - current_steering_ang_vel

            -- Angular acceleration required to set the angular velocity appropriately.
            local AA = up * steering_change_needed / elapsed_secs
            if #AA > 20 then
                -- Put a cap on it.
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



