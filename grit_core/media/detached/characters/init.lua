--[[ TODO:
    *   control while airborne more like projectile

    *   cap horizontal motion while playing landing anim
    *   new jump anims
    *   attach rpg to R_Hand euler(172,172,90)
]]

local function actor_cast (pos, ray, radius, height, body)
        --return physics_sweep_sphere(radius, pos, ray, true, 0, body)
        return physics_sweep_cylinder(radius, height, quat(1,0,0,0), pos, ray, true, 0, body)
end

local function vector_without_component (v, n)
    return v - dot(v, n) * n
end

local function cast_cylinder_with_deflection (body, radius, height, pos, movement)

    --print("cast with "..pos)

    local ret_body, ret_normal, ret_pos

    for i = 0,4 do
    
        local walk_fraction, wall, wall_normal = actor_cast(pos, movement, radius - i*0.0005, height - 0.0001, body)
        if walk_fraction ~= nil then
            if ret_body == nil then
                ret_body = wall
                ret_normal = wall_normal
                ret_pos = pos + walk_fraction*movement
            end
            wall_normal = norm(wall_normal * vector3(1,1,0))
            movement = movement*walk_fraction + vector_without_component(movement*(1-walk_fraction), wall_normal)
        else
            return i, movement, ret_body, ret_normal, ret_pos
        end 
    end 
    
    return false, V_ZERO, ret_body, ret_normal, ret_pos
    
end 

disk_resource_load_indefinitely("/detached/weapons/rocket_launcher/rocket_launcher.mesh")


-- extend ColClass so we have a physics representation that can receive rays, etc
DetachedCharacterClass = extends (ColClass) {

    renderingDistance = 80.0;

    castShadows = true;

    controllable = "ACTOR";
    boomLengthMin = 3;
    boomLengthMax = 15;

    height = 1.8;
    crouchHeight = 1;
    radius = 0.3;
    terminalVelocity = 50;
    camHeight = 1.4;
    stepHeight = 0.3;
    jumpVelocity = 6;
    jumpsAllowed = 2;
    pushForce = 1000;
    runPushForce = 1000;
    
    walkSpeedFactor = 1;
    runSpeedFactor = 1;
    crouchSpeedFactor = 1;

    walkStrideLength = 1.6;
    runStrideLength = 1.866666;
    crouchStrideLength = 1;

    maxGradient = 60;

    maxRideSpeed = 15; 
    maxRideSpeedCrouched = 30; 

    jumpRepeatSpeed = 1; --abs(vel.z) under which a second jump is allowed (apex of last jump)
    
    mass = 80; 
    

    activate = function(self, instance)
        ColClass.activate(self, instance)

        instance.weapons = { }
        instance.weapons[1] = instance.gfx:makeChild("/detached/weapons/rocket_launcher/rocket_launcher.mesh")
        instance.weapons[1].parentBone = "R_Hand"
        instance.weapons[1].localOrientation = euler(172,172,90)

        self.needsStepCallbacks = true

        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2

        instance.isActor = true;
        instance.pushState = 0
        instance.pullState = 0
        instance.strafeLeftState = 0
        instance.strafeRightState = 0
        instance.runState = false
        instance.crouchState = false
        instance.jumpHappened = false
        instance.jumpsDone = 0
        instance.keyboardMove = V_ZERO
        instance.groundBody = nil
        instance.fallVelocity = 0
        instance.slopeAmount = 0
        instance.speed = 0
        instance.bearing = self.bearing or 0
        instance.bearingAim = self.bearing or 0
        instance.timeSinceLastGrounded = nil -- nil if on the ground, non-nil if in the air
        instance.timeSinceLastJump = nil -- nil unless the jump key has been pressed and the jump animation is playing, returns to nil after play
        instance.timeSinceLastLand = nil
        
        instance.controlState = vector3(0,0,0) -- still/move, walk/run, stand/crouch
        instance.stridePos = 0 -- between 0 and 1, where 0.25 is left foot extended, and 0.75 is right foot extended
        instance.fallingPos = 0
        instance.crouchIdlePos = math.random()
        instance.crouchIdleRate = 1/(instance.gfx:getAnimationLength("crouch")*(math.random(1)*0.2+0.9))
        instance.idlePos = math.random()
        instance.idleRate = 1/(instance.gfx:getAnimationLength("idle")*(math.random(1)*0.2+0.9))
        
        instance.walkSpeed = self.walkSpeedFactor * self.walkStrideLength / instance.gfx:getAnimationLength("walk")
        instance.runSpeed = self.runSpeedFactor * self.runStrideLength / instance.gfx:getAnimationLength("run")
        instance.crouchSpeed = self.crouchSpeedFactor * self.crouchStrideLength / instance.gfx:getAnimationLength("crouch_walk")

        self:updateMovementState()
        local body = instance.body
        

        body.ghost = true

        local old_update_callback = body.updateCallback
        body.updateCallback = function (p,q)
            old_update_callback(p,q)
            instance.camAttachPos = p + vector3(0,0,self.camHeight-self.originAboveFeet)
        end

    end;

    deactivate = function (self)
        self.needsStepCallbacks = false;
        ColClass.deactivate(self)
    end;

    stepCallback = function (self, elapsed)

        local instance = self.instance
        local body = instance.body
        local gfx = instance.gfx
        local control_state = instance.controlState
        
        local regular_movement = 1

        -- interpolate movement characteristics based on control state
        local blended_speed = control_state.x * lerp(lerp(instance.walkSpeed,instance.runSpeed,control_state.y), instance.crouchSpeed, control_state.z)
        local blended_stride_length = control_state.x * lerp(lerp(self.walkStrideLength,self.runStrideLength,control_state.y), self.crouchStrideLength, control_state.z)

        local height = lerp(self.height, self.crouchHeight, control_state.z)

        --print('-------------')

        -- check foot and height at source
        -- check pa    t to destination above step hieght
        -- 
        local curr_foot = body.worldPosition - vector3(0,0,self.originAboveFeet)
        local old_foot = curr_foot
        local half_height = height/2

        local radius = self.radius

        local jump_len = gfx:getAnimationLength("jump")
        local jump_glide_len = gfx:getAnimationLength("jump") + gfx:getAnimationLength("glide")

        if instance.timeSinceLastJump ~= nil then
            instance.timeSinceLastJump = instance.timeSinceLastJump + elapsed
            if instance.timeSinceLastJump + elapsed >= jump_len and instance.timeSinceLastJump < jump_len then
                instance.fallVelocity = instance.fallVelocity + self.jumpVelocity
            end
            if instance.timeSinceLastJump >= jump_glide_len then
                instance.timeSinceLastJump = nil
            end
        end

        if instance.timeSinceLastGrounded ~= nil then
            instance.timeSinceLastGrounded = instance.timeSinceLastGrounded + elapsed
        end

        -- HANDLE JUMP (if pressed since last iteration)
        if instance.jumpHappened then
            if instance.jumpsDone == 0 then
                -- on the ground last tick
                instance.timeSinceLastJump = 0
                instance.jumpsDone = 1
            else
                -- repeat jump
                if instance.jumpsDone < self.jumpsAllowed then
                    if math.abs(instance.fallVelocity) > self.jumpRepeatSpeed then
                        -- missed the boost jump
                        instance.jumpsDone = self.jumpsAllowed
                    else
                        instance.jumpsDone = instance.jumpsDone + 1
                        instance.fallVelocity = instance.fallVelocity + self.jumpVelocity
                    end
                end
            end
            instance.jumpHappened = false
        end


        -- VERTICAL MOTION

        local gravity = physics_get_gravity().z
        instance.fallVelocity = clamp(instance.fallVelocity + elapsed * gravity, -self.terminalVelocity, self.terminalVelocity)


        -- cast a thin disc down from the very top to the bottom + the fall distance
        local head_height = 0.1 -- the top part of teh cylinder to cast downwards
        local max_fall_z = elapsed*instance.fallVelocity + instance.slopeAmount -- max distance it can fall (if there is no object in the way)
        -- this allows us to stay 'attached' to a surface, so that forces etc can be applied consistently
        local fall_ray_z = max_fall_z
        if fall_ray_z < 0 and fall_ray_z > -0.1 then
            fall_ray_z = -0.1
        end
        fall_ray_z = fall_ray_z - (height - head_height)
        -- this ground_normal is not necessarily the normal of the triangle you're standing on!  can be on an edge.
        local fall_fraction, ground, ground_normal = actor_cast(curr_foot+vector3(0,0,height-head_height/2), vector3(0,0,fall_ray_z), radius - 0.01, head_height, body)
        local fall_z = (fall_fraction or 1) * fall_ray_z + (height - head_height)
        if fall_z < 0 and fall_z < max_fall_z then
            fall_z = max_fall_z
        end
        instance.groundBody = ground
        curr_foot = curr_foot + vector3(0, 0, fall_z)

        if ground ~= nil then
            -- on the ground

            if instance.timeSinceLastGrounded ~= nil then
                -- wasn't on the ground last tick
                if instance.fallVelocity < -5 or instance.jumpsDone > 0 then
                    instance.timeSinceLastLand = 0
                end
                instance.jumpsDone = 0
                instance.timeSinceLastGrounded = nil
            end

            local landing_momentum = self.mass * instance.fallVelocity
            instance.fallVelocity = 0

            if ground_normal.z > 0.7 then
                -- 'stick' to moving ground
                local ground_vel = ground:getLocalVelocity(curr_foot, true) * vector3(1,1,0)
                local ground_speed = #ground_vel
                if ground_speed > 0 then
                    local max_ride_speed = instance.crouchState and self.maxRideSpeedCrouched or self.maxRideSpeed
                    ground_vel = norm(ground_vel) * math.min(max_ride_speed, ground_speed)
                    curr_foot = curr_foot + ground_vel*elapsed
                end
            end



            -- apply downward force to ground
            -- because the velocity is integrated already, this should already include some approximation of gravity
            if landing_momentum ~= 0 then
                local ground_impulse = vector3(0,0, landing_momentum)
                if ground.mass * 3 < self.mass then
                    -- different logic when standing on small object
                    ground_impulse = math.min(#ground_impulse, ground.mass * elapsed * 5) * norm(ground_impulse)
                else
                    ground_impulse = math.min(#ground_impulse, ground.mass * 5) * norm(ground_impulse)
                end
                ground:impulse(ground_impulse, curr_foot)
            end

        else
            if instance.timeSinceLastGrounded == nil then
                instance.timeSinceLastGrounded = 0
            end

        end

        local dist_try_to_move = blended_speed * elapsed

        -- LATERAL PERSONALLY DIRECTED MOVEMENT (walking, running, etc)
        if dist_try_to_move > 0 then
            local walk_dir = quat(player_ctrl.camYaw, V_DOWN)
            local walk_vect = dist_try_to_move * (walk_dir * norm(instance.keyboardMove))
            if dist_try_to_move > 0.00001 then
                local walk_vect_norm = norm(walk_vect)
                instance.bearingAim = math.deg(math.atan2(walk_vect_norm.x, walk_vect_norm.y))
            end

            local step_height = self.stepHeight

            local curr_centre = curr_foot + vector3(0,0,half_height)
            local walk_cyl_height, walk_cyl_centre
            if ground == nil then
                walk_cyl_height = height
                walk_cyl_centre = curr_centre
            else
                walk_cyl_height = height - step_height
                walk_cyl_centre = curr_centre + vector3(0,0,step_height/2)
            end
            local clear_dist = step_height / self.maxGradient
            local cast_vect = walk_vect
            local retries, new_walk_vect, collision_body, collision_normal, collision_pos = cast_cylinder_with_deflection(body, radius, walk_cyl_height, walk_cyl_centre, cast_vect)

            -- push objects along
            if collision_body~=nil and collision_body ~= ground then
                local push_force = instance.runState and self.runPushForce or self.pushForce
                local magnitude = math.min(self.pushForce, collision_body.mass * 15) * -collision_normal
                collision_body:force(magnitude, collision_pos)
            end

            local cast_foot = curr_foot + new_walk_vect
            local cast_centre = cast_foot + vector3(0,0,height/2)

            -- we also need the normal from the ground to test hte gradient, but can only get the true normal with a ray
            local _, _, floor_normal = physics_cast(cast_centre,  vector3(0,0,-height/2 - step_height), true, 0, body)
            if floor_normal ~= nil then
                instance.lastFloorNormal = floor_normal
            end
            
            -- if retries is false, that means we are jammed in a corner and did not move at all
            if retries and ground~=nil then
                -- just using this position is no good, will ghost through steps
                -- always adding on step_height to z is no good either -- actual step may be less than this (or zero)
                -- so we cast a cylinder down to find the actual amount we have stepped up
                -- if stepped off a cliff, we may not actually hit the ground with this ray
                local step_check_fraction = actor_cast(cast_centre+vector3(0,0,step_height/2), vector3(0,0,-step_height), radius-0.01, height-step_height, body)
                step_check_fraction = step_check_fraction or 1 
                local actual_step_height = step_height*(1-step_check_fraction)

                if floor_normal == nil then
                    -- know nothing about the slope of the floor -- just let step up (or walk forwards if actual_step_height is 0)
                    curr_foot = cast_foot + vector3(0,0, actual_step_height)
                else
                    if dot(floor_normal, walk_vect) > 0 or math.deg(math.acos(floor_normal.z)) <= self.maxGradient then
                        curr_foot = cast_foot + vector3(0,0, actual_step_height)
                    else
                        --print(dot(floor_normal, walk_vect), math.deg(math.acos(floor_normal.z)))
                    end
                end

            else

                curr_foot = cast_foot
    
            end

            if floor_normal ~= nil then
                instance.slopeAmount = math.min(0, -dot(new_walk_vect, floor_normal))
            end

            instance.stridePos = (instance.stridePos + dist_try_to_move/blended_stride_length) % 1

        else

            instance.slopeAmount = 0

            instance.stridePos = 0.0

        end

        instance.speed = #(curr_foot - old_foot) / elapsed


        ------------
        -- ANIMATION
        ------------

        -- transitioning between moving/running/crouching states
        local control_state_desired = vector3(instance.moving and 1 or 0, instance.runState and 1 or 0, (instance.crouchState and not instance.runState) and 1 or 0)
        
        local control_state_dir = control_state_desired - control_state
        local max_dist = elapsed*4
        if #control_state_dir > max_dist then
            control_state_dir = control_state_dir / #control_state_dir * max_dist
        end
        control_state = control_state + control_state_dir
        instance.controlState = control_state

        local airborne = instance.timeSinceLastGrounded ~= nil

        -- two kinds of airborne:
        -- 1) post-jump, holding glide pose until start falling
        -- 2) walked (or thrown) off ledge, keep regular movement until falling

        local glide_mask
        if airborne then
            if instance.jumpsDone > 0 then
                regular_movement = 0
                glide_mask = 1
            else
                glide_mask = 0
            end
        else
            glide_mask = 0
        end

        -- play jump anim
        if instance.timeSinceLastJump ~= nil then

            if instance.timeSinceLastJump < jump_len then
                -- user has pressed the jump key, better play out that anim

                -- fade in the anim over 0.1 seconds
                local mask = math.min(1, instance.timeSinceLastJump / 0.1)
                regular_movement = regular_movement * (1 - mask)
                glide_mask = 0

                gfx:setAnimationMask("jump", mask)
                gfx:setAnimationPos("jump", instance.timeSinceLastJump)

            else

                glide_mask = glide_mask * math.min(1, (instance.timeSinceLastJump-jump_len) / 0.1)
                regular_movement = regular_movement * (1 - glide_mask)

                gfx:setAnimationMask("jump", 1-glide_mask)
                gfx:setAnimationPos("glide", instance.timeSinceLastJump - jump_len)
            end

        end
                
        if instance.timeSinceLastLand ~= nil then

            local landing_len = gfx:getAnimationLength("landing")

            local in_mask = 1
            local out_mask = math.min(1, (landing_len - instance.timeSinceLastLand) / 0.2)

            regular_movement = regular_movement * (1 - out_mask)
            glide_mask = glide_mask * (1 - in_mask)

            gfx:setAnimationMask("landing", in_mask*out_mask)
            gfx:setAnimationPos("landing", instance.timeSinceLastLand)
        
            instance.timeSinceLastLand = instance.timeSinceLastLand + elapsed

            if instance.timeSinceLastLand >= landing_len then
                instance.timeSinceLastLand = nil
            end

        else

            gfx:setAnimationMask("landing", 0)

        end


        local falling_mask = 0
        if airborne then
            falling_mask = clamp((-10-instance.fallVelocity)/5, 0, 1) * clamp((instance.timeSinceLastGrounded or 0)/0.5, 0, 1)
            regular_movement = regular_movement * (1-falling_mask)
            glide_mask = glide_mask * (1-falling_mask)
        end
            
        gfx:setAnimationMask("falling", falling_mask)
        gfx:setAnimationMask("glide", glide_mask)

        gfx:setAnimationMask("idle",        lerp3(1,0,1,0,0,0,0,0, control_state) * regular_movement)
        gfx:setAnimationMask("walk",        lerp3(0,1,0,0,0,0,0,0, control_state) * regular_movement)
        gfx:setAnimationMask("run",         lerp3(0,0,0,1,0,0,0,0, control_state) * regular_movement)
        gfx:setAnimationMask("crouch",      lerp3(0,0,0,0,1,0,1,0, control_state) * regular_movement)
        gfx:setAnimationMask("crouch_walk", lerp3(0,0,0,0,0,1,0,1, control_state) * regular_movement)

        gfx:setAnimationPosNormalised("walk", instance.stridePos)
        gfx:setAnimationPosNormalised("run", instance.stridePos)
        gfx:setAnimationPosNormalised("crouch_walk", instance.stridePos)

        -- two idle anims
        instance.crouchIdlePos = (instance.crouchIdlePos + elapsed * instance.crouchIdleRate) % 1
        gfx:setAnimationPosNormalised("crouch", instance.crouchIdlePos)
        instance.idlePos = (instance.idlePos + elapsed * instance.idleRate) % 1
        gfx:setAnimationPosNormalised("idle", instance.idlePos)
        instance.fallingPos = instance.fallingPos + elapsed
        gfx:setAnimationPos("falling", instance.fallingPos)


        -- update rigid body (and therefore graphics) with new position
        body.worldPosition = curr_foot + vector3(0,0,self.originAboveFeet)
        local bearing_diff = instance.bearingAim - instance.bearing
        while bearing_diff > 180 do bearing_diff = bearing_diff - 360 end
        while bearing_diff < -180 do bearing_diff = bearing_diff + 360 end
        bearing_diff = clamp(bearing_diff, -360*elapsed, 360*elapsed)
        instance.bearing = (instance.bearing + bearing_diff) % 360
        while instance.bearing > 180 do instance.bearing = instance.bearing - 360 end
        while instance.bearing < -180 do instance.bearing = instance.bearing + 360 end
        body.worldOrientation = quat(instance.bearing, V_DOWN)

        
    end;

    updateMovementState = function (self)
        local ins = self.instance
        ins.moving = math.abs(ins.strafeRightState - ins.strafeLeftState)>0.5 or math.abs(ins.pushState - ins.pullState)>0.5
        if ins.moving then
            ins.keyboardMove = (vector3(ins.strafeRightState - ins.strafeLeftState, ins.pushState - ins.pullState, 0))
        end
    end;
    
    getSpeed = function(self)
        return self.instance.speed
    end;

    setForwards=function(self, v)
        self.instance.pushState = v and 1 or 0
        self:updateMovementState()
    end;
    setBackwards=function(self, v)
        self.instance.pullState = v and 1 or 0
        self:updateMovementState()
    end;
    setStrafeLeft=function(self, v)
        self.instance.strafeLeftState = v and 1 or 0
        self:updateMovementState()
    end;
    setStrafeRight=function(self, v)
        self.instance.strafeRightState = v and 1 or 0
        self:updateMovementState()
    end;
    setRun=function(self, v)
        self.instance.runState = v
    end;
    setCrouch=function(self, v)
        if v then
            self.instance.crouchState = not self.instance.crouchState
        end
    end;
    setJump=function(self, v)
        if self.instance.crouchState then
            self.instance.crouchState = false
            if not self.instance.runState then
                return
            end
        end
        if v then
            self.instance.jumpHappened = true
        end
    end;

    controlZoomIn = regular_chase_cam_zoom_in;
    controlZoomOut = regular_chase_cam_zoom_out;
    controlUpdate = regular_chase_cam_update;

    controlBegin = function (persistent)
        return true
    end;
    controlAbandon = function(persistent)
    end;

}

include "robot_heavy/init.lua"
include "robot_med/init.lua"
include "robot_scout/init.lua"

