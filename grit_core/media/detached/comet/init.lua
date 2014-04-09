--test vehicle

material "greybox" { diffuseColour= {.4,.4,.4}, vertexDiffuse=true }

material "car_generic_a" {
    filterMip = "NONE",
    filterMag = "POINT",

    diffuseMap = "../textures/car_generic_a.tga",
    glossMap = "../textures/car_generic_a_spec.tga",

    paintByDiffuseAlpha = true,
    paintColour = 1,

    emissiveMap="../textures/car_generic_a_em.tga",
    emissiveColour = {4,4,4},

    shadowBias = 0.1,
    vertexDiffuse = true
}

material "car_generic_glass" {
    diffuseColour = {0.01,0.01,0.01};
	glossMap = "../textures/car_generic_glass_spec.dds";
    alpha = 0.8;
    shadowBias =0.1;
}

FlyingCar = extends (ColClass) {
    renderingDistance=100;
    castShadows = true;
    cameraTrack = true;
    fovScale = true;

    controllable = "VEHICLE";
    boomLengthMin = 3;
    boomLengthMax = 15;

    wobblePeriod = 4; -- seconds
    wobbleAmplitude = 0.04; -- metres
    floatingHeightDeviationAllowed = 0.06; -- move more than this in 1 tick, and vehicle 'forgets' where it used to be

    climbPitch = 10; -- degrees
    fallPitch = -10; -- degrees
    climbAccel = 20;
    fallAccel = -20;
    rollRate = 3; -- rate at which vehicle leans into curves (degrees per second)

    forwardsMaxSpeed = 40;
    forwardsAccelJerk = 30; -- acceleration at very low speeds (10% of max)
    forwardsAccel = 15; -- regular acceleration

    backwardsMaxSpeed = -5;
    backwardsAccel = -10; -- reversing acceleration

    longitudinalDrag = -2; -- acceleration as a factor of speed

    steerSpeed = 50; -- degrees per second
    steerAccel = 1; -- degrees/s/s
    steerDrag = 0.1; -- degrees per second of rotation speed lost as a factor of steer speed

    activate = function (persistent, instance)
        -- initialise the super class state (basic physics)
        if ColClass.activate (persistent, instance) then
            return true
        end
        persistent.needsStepCallbacks = true;

        instance.canDrive = true;
        instance.boomLengthSelected = (persistent.boomLengthMax + persistent.boomLengthMin)/2

        instance.wantHeight = instance.body.worldPosition.z
        instance.wantBearing = 0

        instance.totalTime = 0
        instance.lastHeightDev = 0
        instance.cumulativeHeightDev = 0

        instance.lastOrientationDev = quat(1,0,0,0)
        instance.cumulativeOrientationDev = quat(1,0,0,0)

        instance.body.angularDamping = 0.5
        instance.body.linearDamping = 0

        instance.actualRoll = 0

        local dir = instance.body.worldOrientation * V_FORWARDS
        instance.lastBearing = math.deg(math.atan2(dir.x, dir.y))
    end;

    deactivate = function (persistent)
        local instance = persistent.instance
        persistent.needsStepCallbacks = false;

        return ColClass.deactivate (persistent)
    end;

    stepCallback = function (persistent, elapsed)

        local instance = persistent.instance
        local body = instance.body
        local mass, inertia = body.mass, body.inertia
        local wp = body.worldPosition
        local dir = body.worldOrientation * V_FORWARDS
        local current_bearing = math.deg(math.atan2(dir.x, dir.y))
        local local_vel = inv(body.worldOrientation) * body.linearVelocity

        local vert_input = (instance.higher and 1 or 0) + (instance.lower and -1 or 0)
        local pitch = (instance.higher and persistent.climbPitch or 0) + (instance.lower and persistent.fallPitch or 0)
        local steer_input = (instance.steerRight and 1 or 0) + (instance.steerLeft and -1 or 0)
        local roll_input = steer_input + (instance.strafeRight and 0.2 or 0) + (instance.strafeLeft and -0.2 or 0)

        if instance.actualRoll < roll_input then
            instance.actualRoll = math.min(instance.actualRoll+persistent.rollRate*elapsed, roll_input)
        else
            instance.actualRoll = math.max(instance.actualRoll-persistent.rollRate*elapsed, roll_input)
        end

        local roll = instance.actualRoll * 7

        do -- steering
            local z_spin = math.deg(-body.angularVelocity.z)
            if steer_input == 0 then    
                body:torque(vector3(0, 0, persistent.steerDrag*inertia.z*z_spin))
            else
                local steer = persistent.steerSpeed * steer_input
                local spin_dev = z_spin - steer
                body:torque(vector3(0, 0, persistent.steerAccel * inertia.z * spin_dev))
            end

        end


        do -- forward velocity control
            if instance.forward and not instance.backward then
                local want_speed = persistent.forwardsMaxSpeed
                if local_vel.y < 0.1 * want_speed then
                    body:force(body.worldOrientation * vector3(0, persistent.forwardsAccelJerk * mass, 0), wp)
                elseif local_vel.y < want_speed then
                    body:force(body.worldOrientation * vector3(0, persistent.forwardsAccel * mass, 0), wp)
                end
            elseif instance.backward and not instance.forward then
                local want_speed = persistent.backwardsMaxSpeed
                if local_vel.y > want_speed then
                    body:force(body.worldOrientation * vector3(0, persistent.backwardsAccel * mass, 0), wp)
                end
            else
                local f = body.worldOrientation * vector3(0, persistent.longitudinalDrag * mass * local_vel.y, 0)
                body:force(f, wp)
            end
        end

        do -- lateral control / stability (in sailing, the daggerboard)
            if instance.strafeRight and not instance.strafeLeft then
                local want_speed = 1 -- m/s
                if local_vel.x < want_speed then
                    body:force(body.worldOrientation * (10*mass * V_RIGHT), wp)
                end
            elseif instance.strafeLeft and not instance.strafeRight then
                local want_speed = -1 --m/s
                if local_vel.x > want_speed then
                    body:force(body.worldOrientation * (10*mass * V_LEFT), wp)
                end
            else
                body:force(body.worldOrientation * (2 * mass * local_vel.x * V_LEFT), wp)
            end
        end


        do -- stabilise rotation (avoid roll and pitch)
            local want_orientation = euler(pitch,roll,-current_bearing)
            --want_orientation = quat(1,0,0,0)
            --print(want_orientation)

            local orientation_dev = norm(body.worldOrientation * inv(want_orientation))
            --print(body.worldOrientation, want_orientation, inv(want_orientation), body.worldOrientation * inv(want_orientation))

            local tensor_dev = vector3(0,0,0)
            if vector3(orientation_dev.x, orientation_dev.y, orientation_dev.z) ~= V_ZERO then
                local angle = orientation_dev.angle
                local axis = orientation_dev.axis
                if angle > 180 then
                    angle = angle - 360
                end
                tensor_dev = angle * axis
            end

            local tensor_cumulative = vector3(0,0,0)

            local orientation_dev_change = norm(orientation_dev * inv(instance.lastOrientationDev))
            instance.lastOrientationDev = orientation_dev
            local tensor_dev_change = vector3(0,0,0)
            if #vector3(orientation_dev_change.x, orientation_dev_change.y, orientation_dev_change.z) > 0 then
                local angle = orientation_dev_change.angle
                local axis = orientation_dev_change.axis
            
                if angle > 180 then
                    angle = angle - 360
                end
                tensor_dev_change = angle * axis / elapsed
            end

            local P, I, D = -0.3, 0, -0.05

            body:torque(inertia*(P*tensor_dev + I*tensor_cumulative + D*tensor_dev_change))
        end


        do -- implement higher/lower control, otherwise stabilise height (i.e. implement floating behaviour)
            local gravity_z = -physics_option("GRAVITY_Z")
            if instance.higher and not instance.lower then

                local want_speed = 15 -- m/s
                if local_vel.z < want_speed then
                    body:force((gravity_z+persistent.climbAccel) * mass * V_UP, wp)
                end

                instance.lastHeightDev = 0
                instance.cumulativeHeightDev = 0
                instance.wantHeight = wp.z

            elseif not instance.higher and instance.lower then

                local want_speed = -15
                if local_vel.z > want_speed then
                    -- let gravity do the work
                    body:force((gravity_z+persistent.fallAccel) * mass * V_UP, wp)
                else
                    -- counteract gravity a bit
                    body:force(gravity_z * mass * V_UP, wp)
                end

                instance.lastHeightDev = 0
                instance.cumulativeHeightDev = 0
                instance.wantHeight = wp.z

            else

                local want_height = instance.wantHeight + math.sin(instance.totalTime/persistent.wobblePeriod *2* math.pi) * persistent.wobbleAmplitude
                instance.totalTime = math.mod(instance.totalTime + elapsed, persistent.wobblePeriod)

                local height_dev = wp.z - want_height
                local height_dev_change = (height_dev - instance.lastHeightDev) / elapsed

                instance.lastHeightDev = height_dev
                instance.cumulativeHeightDev = clamp(instance.cumulativeHeightDev + height_dev*elapsed, -1, 1)

                local P, I, D = -2000, 0, -20

                local A = P*height_dev + I*instance.cumulativeHeightDev + D*height_dev_change
                A = clamp(A, -20, 20)
                body:force(vector3(0, 0, mass * A), wp)

                instance.wantHeight = wp.z - clamp(wp.z - instance.wantHeight, -persistent.floatingHeightDeviationAllowed, persistent.floatingHeightDeviationAllowed)
            end
        end
    end;

    setPush = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.forward = v
    end;

    setPull = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.backward = v
    end;

    setShouldSteerLeft = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.steerLeft = v
    end;

    setShouldSteerRight = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.steerRight = v
    end;

    setBoost = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.lower = v
    end;

    setHandbrake = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.higher = v
    end;

    setSpecialLeft = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.strafeLeft = v
    end;

    setSpecialRight = function (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.strafeRight = v
    end;

    setSpecial = do_nothing;
    setSpecialUp = do_nothing;
    setSpecialDown = do_nothing;
    setAltUp = do_nothing;
    setAltDown = do_nothing;
    setAltLeft = do_nothing;
    setAltRight = do_nothing;

    controlZoomIn = regular_chase_cam_zoom_in;
    controlZoomOut = regular_chase_cam_zoom_out;
    controlUpdate = regular_chase_cam_update;

    controlBegin = function (persistent)
        if not persistent.activated then return end
        if persistent.instance.canDrive then
            return true
        end
    end;
    controlAbandon = function(persistent)
    end;


}

class "." (FlyingCar) {
    gfxMesh=`comet.mesh`;
    colMesh=`comet.gcol`;
    placementZOffset = 0.35;

    colourSpec = {
            { probability=1, { "ice_silver",  },
            },
            { probability=1, { "velvet_red",  },
            },
            { probability=1, { "carbon_gray",  },
            },
            { probability=1, { "midnight_black",  },
            },
            { probability=1, { "cream_white",  },
            },
            { probability=1, { "crystal_blue",  },
            },
    },

}
