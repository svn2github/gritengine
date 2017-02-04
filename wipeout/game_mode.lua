material `DummyVehicle` {
    diffuseMap = {
        -- Filename on disk.
        image = `DummyVehicle.png`,
        modeU = "CLAMP",
        modeV = "CLAMP",
    },
}


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

At low speeds, a PID loop is used to pull ship towards logical position and orientation.  There may
need to be a cap on how much the orientation can deviate in a single frame.

At high speeds, collision with the track is disabled.  This avoids some collisions and may be enough
to keep using the PID loop.

At very high speeds, when the PID loop is too squishy, the physical position / orientation is updated
directly every frame, allowed to collide, then set back into the logical model again.

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
    camAttachPos = vec(0,0, 3),

    hoverHeight = 1,
    steerMax = 80,  -- degrees/sec
    speedMax = 100,  -- metres/sec
    acceleration = 10,
    initialVelocity = vec(0, 0, 0),

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

    doRay = function(self, rayFrom, ray)
        local dist, ground, ground_normal, ground_mat = physics_cast(pos, ray, true, 0)
    end,
    
    stepCallback = function(self, elapsed_secs)
        local instance = self.instance
        local body = instance.body
        local pos = instance.pos
        --local pos = body.worldPosition
        local ort = instance.groundOrientation
        --local ort = body.worldOrientation
        local vel = instance.velocity
        local gravity = physics_get_gravity()
        local vehicle_up = ort * vec(0, 0, 1)

        local ray = self.hoverHeight * -2 * vehicle_up
        local distFL, groundFL, ground_normalFL, ground_matFL = physics_cast(body:localToWorld(self.frontLeftJet), ray, true, 0, body)
        local distFR, groundFR, ground_normalFR, ground_matFR = physics_cast(body:localToWorld(self.frontRightJet), ray, true, 0, body)
        local distRL, groundRL, ground_normalRL, ground_matRL = physics_cast(body:localToWorld(self.rearLeftJet), ray, true, 0, body)
        local distRR, groundRR, ground_normalRR, ground_matRR = physics_cast(body:localToWorld(self.rearRightJet), ray, true, 0, body)
        local total_hits = 0
        local hit_dist = self.hoverHeight * 10
        local hit_normal = vec3(0, 0, 0)
        local active_surface = `Track`
        if distFL ~= nil and ground_matFL == active_surface then
            total_hits = total_hits + 1
            hit_dist = math.min(hit_dist, distFL)
            hit_normal = hit_normal + ground_normalFL
            emit_debug_marker(body:localToWorld(self.frontLeftJet) + ray * distFL, vec(0, 1, 0), 1/100, 0.4)
        end
        if distFR ~= nil and ground_matFR == active_surface then
            total_hits = total_hits + 1
            hit_dist = math.min(hit_dist, distFR)
            hit_normal = hit_normal + ground_normalFR
            emit_debug_marker(body:localToWorld(self.frontRightJet) + ray * distFR, vec(0, 1, 0), 1/100, 0.4)
        end
        if distRL ~= nil and ground_matRL == active_surface then
            total_hits = total_hits + 1
            hit_dist = math.min(hit_dist, distRL)
            hit_normal = hit_normal + ground_normalRL
            emit_debug_marker(body:localToWorld(self.rearLeftJet) + ray * distRL, vec(0, 1, 0), 1/100, 0.4)
        end
        if distRR ~= nil and ground_matRR == active_surface then
            total_hits = total_hits + 1
            hit_dist = math.min(hit_dist, distRR)
            hit_normal = hit_normal + ground_normalRR
            emit_debug_marker(body:localToWorld(self.rearRightJet) + ray * distRR, vec(0, 1, 0), 1/100, 0.4)
        end
        instance.onGround = total_hits >= 3
        local hit_pos
        if instance.onGround then
            hit_normal = norm(hit_normal)
            hit_pos = pos + hit_dist * ray
        else
            --[[
            local max_penetration = -1
            -- Maybe we're inverted, try to hook on to the nearest surface in any direction.
            physics_test(self.hoverHeight, pos, false, function (body, sz, local_pos, world_pos, normal, penetration, mat)
                if body == instance.body then return end
                if penetration > max_penetration then
                    max_penetration = penetration
                    instance.onGround = true
                    hit_pos = world_pos
                    hit_normal = normal
                end
            end)
            ]]
        end
        if instance.onGround and not (instance.handbrake and vehicle_up.z < 0) then
            pos = hit_pos + self.hoverHeight * hit_normal
            ort = quat(vehicle_up, hit_normal) * ort
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

        -- Collision detection goes here.

        local angular_velocity = (instance.shouldSteerLeft + instance.shouldSteerRight) * elapsed_secs
        ort = norm(quat(angular_velocity, ort * vec(0, 0, -1)) * ort)
        instance.groundOrientation = ort
        instance.displayOrientation = norm(slerp(ort, instance.displayOrientation, 0.001 ^ elapsed_secs))
        instance.velocity = vel
        pos = pos + vel * elapsed_secs
        instance.pos = pos
        body.linearVelocity = vel
        body.worldPosition = pos
        body.worldOrientation = instance.displayOrientation
        body:force(-gravity, pos)
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


