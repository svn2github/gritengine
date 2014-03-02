-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include "simple/init.lua"
include "Robot/init.lua"
include "Sinbad/init.lua"

include "classes.lua"

local function actor_cast (pos, ray, radius, height, body)
        --return physics_sweep_sphere(radius, pos, ray, true, 0, body)
        return physics_sweep_cylinder(radius, height, quat(1,0,0,0), pos, ray, true, 0, body)
end

local function vector_without_component (v, n)
    return v - dot(v, n) * n
end

local function cast_cylinder_with_deflection (body, radius, height, pos, movement)

    --echo("cast with "..pos)

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

class "Character" (ColClass) {

    controlable = true;
    boomLengthMin = 3;
    boomLengthMax = 15;

    renderingDistance = 100.0;

    castShadows = true;

    height = 1.8;
    radius = 0.3;
    terminalVelocity = 50;
    camHeight = 1.4;
    stepHeight = 0.3;
    jumpVelocity = 6;
    jumpsAllowed = 3; -- how many jumps allowed in a row, before landing (1 = normal jump, 2 = aka double jump, 3 = normal + 2 air jumps, 4 ...etc.)
    runSpeed = 12;
    walkSpeed = 6;
    pushForce = 1000;
    runPushForce = 1000;

    maxGradient = 1.5;
    
    mass = 80; 
    

    activate = function(self, instance)
        ColClass.activate(self, instance)

        instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2

        self.needsStepCallbacks = true

        instance.isActor = true;
        instance.pushState = 0
        instance.pullState = 0
        instance.strafeLeftState = 0
        instance.strafeRightState = 0
        instance.runState = false
        instance.jumpState = false
        instance.crouchState = false
        instance.jumpHappened = false
        instance.jumpsDone = 0
        instance.crouchHappened = false
        instance.localMoveIntended = V_ZERO
        instance.localMove = V_ZERO
        instance.offGround = false
        instance.fallVelocity = 0
		instance.speed = 0
        self:updateMovementState()
        local body = instance.body

        body.ghost = true

        local old_update_callback = body.updateCallback
        body.updateCallback = function (p,q)
            old_update_callback(p,q)
            instance.camAttachPos = p + vector3(0,0,self.camHeight)
        end

    end;

    deactivate = function (self)
        self.needsStepCallbacks = false;
        ColClass.deactivate(self)
    end;

    stepCallback = function (self, elapsed)

        local instance = self.instance
        local body = instance.body

        --echo('-------------')

        -- check foot and height at source
        -- check pat to destination above step hieght
        -- 
        local curr_foot = body.worldPosition
		local old_foot = curr_foot
        local height = self.height
        local half_height = self.height/2
        local curr_centre = curr_foot + vector3(0,0,half_height)

        local radius = self.radius

        
        if instance.jumpHappened then
            if instance.offGround then
                if instance.jumpsDone < self.jumpsAllowed then --check if we have ability to jump in air (aka double-jump)
                    instance.fallVelocity = self.jumpVelocity
                    instance.jumpsDone = instance.jumpsDone + 1

                end
            else
                instance.fallVelocity = self.jumpVelocity -- first aka "normal" jump
                instance.jumpsDone = 1
            end
            instance.jumpHappened = false
        end

        local gravity = physics_get_gravity().z

        local old_fall_velocity = instance.fallVelocity
        instance.fallVelocity = instance.fallVelocity + elapsed * gravity
        if instance.fallVelocity > self.terminalVelocity then
            instance.fallVelocity = self.terminalVelocity
        end

        --echo('fallVelocity: '..instance.fallVelocity)

        -- FALL / JUMP
        -- shoot sphere from centre of capsule
        local fall_vect = elapsed * vector3(0,0,instance.fallVelocity)
        local fall_fraction, floor, floor_normal = actor_cast(curr_centre, fall_vect, radius - 0.01, height, body)
        local floor_impulse = 0
        if fall_fraction == nil then
            instance.offGround = true
            fall_fraction = 1
        else
            instance.offGround = false
            floor_impulse = self.mass * old_fall_velocity
            instance.fallVelocity = 0
        end
        --echo('fall_dist: '..(fall_fraction * fall_vect).."  off_ground: "..tostring(instance.offGround))
        curr_foot = curr_foot + fall_fraction * fall_vect

        local no_step_up = instance.offGround

        if not instance.offGround then
            local floor_gradient = 1/floor_normal.z
            -- special case for vertical walls -- helps going up steps
            if floor_gradient < 5 and floor_gradient > self.maxGradient then
                no_step_up = true
            end

            -- apply force to ground
            --gravity
            local ground_force = vector3(0,0,self.mass * gravity)
            ground_force = math.min(#ground_force, floor.mass * 5) * norm(ground_force)
            floor:force(ground_force, curr_foot)
            if floor_impulse ~= 0 then
                --landing force
                local ground_impulse = vector3(0,0, floor_impulse)
                ground_impulse = math.min(#ground_impulse, floor.mass * elapsed * 100) * norm(ground_impulse)
                floor:impulse(ground_impulse, curr_foot)
            end
        end



        -- WALK/STRAFE in a given direction
        instance.localMove = instance.localMoveIntended
        if instance.moving then
            local speed = (instance.runState and self.runSpeed or self.walkSpeed) * elapsed
            local walk_dir = quat(player_ctrl.camYaw, V_DOWN)
            local walk_vect = speed * (walk_dir * norm(instance.localMove))
            if #walk_vect > 0.003 then
                body.worldOrientation = quat(V_FORWARDS, norm(walk_vect))
            end

            local step_height = self.stepHeight

            local walk_cyl_height = height - step_height
            local walk_cyl_centre = curr_centre + vector3(0,0,step_height/2)
            if no_step_up then
                walk_cyl_height = height
                walk_cyl_centre = curr_centre
            end
            local retries, new_walk_vect, collision_body, collision_normal, collision_pos = cast_cylinder_with_deflection(body, radius, walk_cyl_height, walk_cyl_centre, walk_vect)

            if collision_body then
                local push_force = instance.runState and self.runPushForce or self.pushForce
                local magnitude = math.min(self.pushForce, collision_body.mass * 15) * -collision_normal
                collision_body:force(magnitude, collision_pos)
            end
            --echo('first walk test:   retries: '..tostring(retries).." tried_vect:"..walk_vect.."  vect:"..new_walk_vect)

            curr_foot = curr_foot + new_walk_vect
            curr_centre = curr_foot + vector3(0,0,height/2)

            if retries and not no_step_up then
                -- just using this position is no good, will ghost through steps
                -- always adding on step_height to z is no good either -- actual step may be less than this (or zero)
                -- so we shoot a ray down to find the actual amount we have stepped up
                local step_check_fraction = actor_cast(curr_centre+vector3(0,0,step_height/2), vector3(0,0,-step_height), radius-0.01, height-step_height, body)
                step_check_fraction = step_check_fraction or 1 -- might not hit the ground due to rounding errors etc
                local actual_step_height = step_height*(1-step_check_fraction)

                -- if we hvae an upwards velocity, work out if we would have made the step or not
                -- if not, set velocity to 0 so that we don't give an unnatural boost
                local parabolic_height = instance.fallVelocity^2  / 2 / gravity
                --echo("fail", instance.fallVelocity, parabolic_height, actual_step_height)
                if parabolic_height > 0 and parabolic_height <  actual_step_height then
                    instance.fallVelocity = 0
                end

                --echo('actual step height:'..actual_step_height)
                curr_foot = curr_foot + vector3(0,0, actual_step_height)
            end

        end

        
        body.worldPosition = curr_foot
		
		instance.speed = #(old_foot-curr_foot)/elapsed
    end;
	
	getSpeed = function (self)
		return self.instance.speed
	end;

    updateMovementState = function (self)
        local ins = self.instance
        ins.moving = math.abs(ins.strafeRightState - ins.strafeLeftState)>0.5 or math.abs(ins.pushState - ins.pullState)>0.5
        ins.localMoveIntended = (vector3(ins.strafeRightState - ins.strafeLeftState, ins.pushState - ins.pullState, 0))
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
        self.instance.crouchState = v
        if v then
            self.instance.crouchHappened = true
        end
    end;
    setJump=function(self, v)
        self.instance.jumpState = v
        if v then
            self.instance.jumpHappened = true
        end
    end;

    controlZoomIn = regular_chase_cam_zoom_in;
    controlZoomOut = regular_chase_cam_zoom_out;
    controlUpdate = regular_chase_cam_update;

    controlProcessKey = function(self, key)
        player_ctrl.footBinds:process(key)
    end;

    controlFlush = function (self)
        player_ctrl.footBinds:flush()
    end;

    controlBegin = function (self)
        return true
    end;
    controlAbandon = function(self)
    end;

}

