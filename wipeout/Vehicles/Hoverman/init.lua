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

    setPid = function(self, P,I,D,min,max)
        local instance = self.instance
        for i, jet in ipairs(self.jetsHover) do
            instance.jetsHoverPids[i] = pid_ctrl.new(vector3(0,0,0),P,I,D,min,max)
        end
    end;

    activate = function(self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        self.needsStepCallbacks = true;

        instance.canDrive = true;

        local global_pid = self.pid
        local P,I,D,min,max = global_pid.p, global_pid.i, global_pid.d, global_pid.min, global_pid.max
        
        instance.jetsHoverPids = {}
        for i, jet in ipairs(self.jetsHover) do 
            if jet.pid then
                P,I,D,min,max = jet.pid.p, jet.pid.i, jet.pid.d, jet.pid.min, jet.pid.max
            end

            instance.jetsHoverPids[i] = pid_ctrl.new(vector3(0,0,0),P,I,D,min,max)
        end
    end;
    
    deactivate = function(self, instance)
        self.needsStepCallbacks = false;
        return ColClass.deactivate(self)
    end;

    stepCallback = function(self, instance)
        if not self.activated then error("Not activated: "..self.name) end
        
        local instance = self.instance
        local body = instance.body
        local mass, inertia = body.mass, body.inertia
        local wp = body.worldPosition
        local wo = body.worldOrientation
        --local dir = body.worldOrientation * V_FORWARDS
        local gravity_z = physics_option("GRAVITY_Z")

        do --hovering
            body:force(vector3(0,0,-(gravity_z*mass)),wp) --negate gravity for the whole vehicle
            
            local hover_height = self.hoverHeight

            local jets = self.jetsHover
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

    setPush = function(self, v)
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.forward = v
    end;

    setPull = function(self, v)
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.backward = v
    end;

    setShouldSteerLeft = function(self, v)
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.steerLeft = v
    end;

    setShouldSteerRight = function(self, v)
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.steerRight = v
    end;

    setHandbrake = function(self, v)
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.handbrake = v
    end;

    setBoost = function(self, v) --should use weapon
        if not self.activated then error("Not activated: "..self.name) end
        self.instance.boost = v
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

class `.` (WipeoutCar) {
        gfxMesh = `Body.mesh`;
        colMesh = `Body.gcol`;
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
local g, s = 0.6, 0.04
-- when using paint, set spec and gloss to 1, they will be masked by the paint colour
material `Blacky` {
    shader = `/common/Paint`,
    microFlakesMap = `/common/MicroFlakes.dds`,
    paintSelectionMap = vec(1, 0, 0, 1),
    specularMask = 1,
    glossMask = 1,
    shadowBias = 0.05,
}
material `Carpaint` {
    shader = `/common/Paint`,
    microFlakesMap = `/common/MicroFlakes.dds`,
    paintSelectionMap = vec(1, 0, 0, 1),
    specularMask = 1,
    glossMask = 1,
    shadowBias = 0.05,
}
material `LightPlastic` {
    diffuseMask = vec(0.2, 0.2, 0.2),
    specularMask = 0.04,
    glossMask = 0.5,
}
material `Chrome` {
    diffuseMask = 0.09 * vec(1, 1, 1),
    specularMask = 0.15,
    glossMask = 1,
}
material `Pattern` {
    diffuseMask = vec(0.1, 0.1, 0.1),
    specularMask = 0.04,
    glossMask = 0.25,
}
material `Interior` {
    diffuseMask = vec(0.1, 0.1, 0.1),
    specularMask = 0.04,
    glossMask = 0.2,
}
material `Rubber` {
    diffuseMask = vec(0.05, 0.05, 0.05),
    specularMask = 0.04,
}
material `Headlight` {
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Brakelight` {
    diffuseMask = vec(1,0,0),
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Turnlight` {
    diffuseMask = vec(1.0,0.597,0),
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Windows` {
    diffuseMask = vec(0.035, 0.035, 0.035),
    glossMask = 1,
    specularMask = 0.045,
    alphaMask = 0.8,
    sceneBlend = "ALPHA",
}
