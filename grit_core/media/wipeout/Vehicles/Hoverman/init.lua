--WIPEOUT CAR PROJECT
--Car model is taken from JostVice's Scarman

WipeoutCar = extends(ColClass)
{
    renderingDistance=100;
    castShadows = true;
    cameraTrack = true;
    fovScale = true;

    pid = {
        p = 10000,
        i = 20,
        d = 2500,
        min = -2,
        max = 2
    };

    hoverHeight = 1;

    setPid = function(persistent, P,I,D,min,max)
        local instance = persistent.instance
        for i, jet in ipairs(persistent.jetsHover) do
            instance.jetsHoverPids[i] = pid_ctrl.new(vector3(0,0,0),P,I,D,min,max)
        end
    end;

    activate = function(persistent, instance)
        if ColClass.activate(persistent, instance) then
            return true
        end
        persistent.needsStepCallbacks = true;

        instance.canDrive = true;

        local global_pid = persistent.pid
        local P,I,D,min,max = global_pid.p, global_pid.i, global_pid.d, global_pid.min, global_pid.max
        
        instance.jetsHoverPids = {}
        for i, jet in ipairs(persistent.jetsHover) do 
            if jet.pid then
                P,I,D,min,max = jet.pid.p, jet.pid.i, jet.pid.d, jet.pid.min, jet.pid.max
            end

            instance.jetsHoverPids[i] = pid_ctrl.new(vector3(0,0,0),P,I,D,min,max)
        end
    end;
    
    deactivate = function(persistent, instance)
        persistent.needsStepCallbacks = false;
        return ColClass.deactivate(persistent)
    end;

    stepCallback = function(persistent, instance)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        
        local instance = persistent.instance
        local body = instance.body
        local mass, inertia = body.mass, body.inertia
        local wp = body.worldPosition
        local wo = body.worldOrientation
        --local dir = body.worldOrientation * V_FORWARDS
        local gravity_z = physics_option("GRAVITY_Z")

        do --hovering
            body:force(vector3(0,0,-(gravity_z*mass)),wp) --negate gravity for the whole vehicle
            
            local hover_height = persistent.hoverHeight

            local jets = persistent.jetsHover
            local jets_count = #jets
            local mass_per_jet = mass/jets_count

            local jetsPids = instance.jetsHoverPids

            for i,jet in ipairs(jets) do
                local jp = jet.pos
                local jwp = body:localToWorld(jp)

                local target_pos = wo * (2 * hover_height * V_DOWN)
                local fraction_dist = physics_cast(jwp, target_pos, true, 0, body)
                if not fraction_dist then
                    body:force(vector3(0,0,gravity_z*mass_per_jet),jwp)
                else
                    local real_dist = fraction_dist * 2 * hover_height

                    local response = jetsPids[i]:control(vector3(0,0,hover_height), vector3(0,0,real_dist))
                    print("real_dist "..real_dist)
                    print("response "..response)
                    --[[
                    if real_dist < hover_height then
                        body:force(wo*vector3(0,0,mass_per_jet), jwp)
                    elseif real_dist > hover_height then
                        body:force(wo*vector3(0,0,-mass_per_jet), jwp)
                    end
                    --]]
                    body:force(wo*response, jwp)
                end
            end
        end

        do --forward/backward
            local forward_force = mass*10
            local backward_force = mass*10

            if instance.forward and not instance.backward then
                body:force((wo*V_FORWARDS)*forward_force, wp)
            elseif instance.backward and not instance.forward then
                body:force((wo*V_BACKWARDS)*backward_force, wp)
            end
        end

        do --turning left/right
            local torque_factor = 3*mass

            if instance.steerLeft and not instance.steerRight then
                body:torque(torque_factor*(wo*V_UP))
            elseif instance.steerRight and not instance.steerLeft then
                body:torque(-torque_factor*(wo*V_UP))
            end
        end
    end;

    setPush = function(persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.forward = v
    end;

    setPull = function(persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.backward = v
    end;

    setShouldSteerLeft = function(persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.steerLeft = v
    end;

    setShouldSteerRight = function(persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.steerRight = v
    end;

    setHandbrake = function(persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.handbrake = v
    end;

    setBoost = function(persistent, v) --should use weapon
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.boost = v
    end;

    setSpecialLeft = do_nothing;
    setSpecialRight = do_nothing;
    setSpecial = do_nothing;
    setSpecialUp = do_nothing;
    setSpecialDown = do_nothing;
    setAltUp = do_nothing;
    setAltDown = do_nothing;
    setAltLeft = do_nothing;
    setAltRight = do_nothing;
}

class "." (WipeoutCar) {
        gfxMesh = `Hoverman/Body.mesh`;
        colMesh = `Hoverman/Body.gcol`;
        placementZOffset=1.4;
        
		colourSpec = {
                { probability=1, { "velvet_red",},},
				{ probability=1, { "ice_silver",},},
				{ probability=1, { "carbon_gray",},},
				{ probability=1, { "midnight_black",},},
				{ probability=1, { "cream_white",},},
				{ probability=1, { "crystal_blue",},},
        };

        jetsHover = {
            {pos = vector3(-0.9, 1.08, -0.19)}; --hovering front left
            {pos = vector3(0.9, 1.08, -0.19)}; --hovering font right
            {pos = vector3(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vector3(-0.9, -1.6, -0.19)}; --hovering rear left
        };
}

-- most materials are temporal and will probably joined
material "Carpaint" { paintColour = 1; specular=.04; gloss = .75; microFlakes=true; }
material "LightPlastic" { diffuseColour=vector3(0.2, 0.2, 0.2); specular=0.04; gloss = .5; }
material "Chrome" { diffuseColour =V_ZERO; specular=1; gloss = 1; }
material "Pattern" { diffuseColour=vector3(0.05, 0.05, 0.05); specular=0.04; gloss = .5; }
material "Blacky" { diffuseColour =V_ZERO; specular=0.5; gloss = 1; }
material "Headlight" { gloss = .75; specular=0.04; alpha =0.7 }
material "Brakelight" { diffuseColour=vector3(1,0,0), gloss = .75; specular=0.04; alpha =0.7 }
material "Turnlight" { diffuseColour=vector3(1.0,0.597,0), gloss = .75; specular=0.04; alpha =0.7 }
