-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

Vehicle = extends (ColClass) {

    controllable = "VEHICLE";
    boomLengthMin = 3;
    boomLengthMax = 15;

    drag = 0.6 * vec(6, 2, 8);

    castShadows = true;
    renderingDistance = 100;

    driverExitPos = vector3(-1.45, -0.24, 0.49);
    driverExitQuat = Q_ID;

    cameraTrack = true;
    fovScale = true;
    topDownCam = false;
    
    steerMax = 35;
    steerRate = 200;
    unsteerRate = 400;

    steerFastSpeed = 60;

    steerMaxFast = 25;
    steerRateFast = 30;
    unsteerRateFast = 400;

    glideDirection = vector3(0, 1, 0);
    glideFactor = -6;
    glideDampingFactor = 2;

    wheelSpinTractionControlMax = 1;
    wheelSpinTractionControlRate = 4;
    wheelSpinTractionControlMin = 0.01;

    engineInfo = {
        diffRatio=5, -- extra gear ratio due to differential gearbox
        wheelRadius=rad,
        transEff=0.7,
        torqueCurve = {
            [1000] = 410.00,
            [2000] = 600.00,
            [3000] = 750.00,
            [4000] = 955.00,
            [6000] = 800.00,
            [7000] = 500.00,
        },
        gearRatios = {
            [-1] = -4.84, -- reverse
            [0] = 0, -- neutral
            [1] = 3.46,
            [2] = 2.08,
            [3] = 1.40,
            [4] = 1.05,
            [5] = 0.605,
        },
        shiftDownRPM = 2500,
        shiftUpRPM = 6500,
    },

    health = 100000;
    impulseDamageThreshold=1000;
    explodeInfo = { radius = 5 };

    brakePlot = { [-10] = 100; [0] = 100; [10] = 2500; [20] = 2500; [40] = 2500; };

    lightDefaults = {
        -- car lights:
        lightHeadLeft = {
            isHeadLight = true;
            range = 100; diff = 5*vector3(1, 0.9, 0.8);
            coronaSize = 10;
            iangle = 25; oangle = 35;
            ciangle = 40; coangle = 70;
            aim = quat( 2, V_UP)*quat(-20, V_RIGHT);
        };
        lightHeadRight = {
            isHeadLight = true;
            range = 60; diff = 5*vector3(1, 0.9, 0.8);
            coronaSize = 10;
            iangle = 25; oangle = 35;
            ciangle = 40; coangle = 70;
            aim = quat(-2, V_UP)*quat(-20, V_RIGHT);
        };
        lightBrakeLeft = {
            diff = 2*vector3(1, 0, 0);
            isBrake = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };
        lightBrakeRight = {
            diff = 2*vector3(1, 0, 0);
            isBrake = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };
        lightReverseLeft = {
            diff = vector3(1, 1, 1);
            isReverse = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };
        lightReverseRight = {
            diff = vector3(1, 1, 1);
            isReverse = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };

        -- bike lights:
        lightHeadCenter = {
            diff = vector3(1, 1, 1);
            isHeadLight = true;
            range = 40;
            iangle = 0;
            oangle = 35;
            aim = quat(0, V_UP); -- TODO: Is this aimed down properly?
        };
        lightBrakeCenter = {
            diff = vector3(1, 0, 0);
            isBrake = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };
        lightReverseCenter = {
            diff = vector3(1, 1, 1);
            isReverse = true;
            range = 4;
            iangle = 0;
            oangle = 90;
            aim = quat(180, V_UP);
            coronaSize = 0;
        };
    };

    -- when to use headlights when driving
    lightsOnTime = parse_time("19:00:00");
    lightsOffTime = parse_time("07:00:00");

    engineSmokeVents = { };
    exhaustSmokeVents = { };
}

function Vehicle.init (self)
    ColClass.init(self)
    if self.meshWheelInfo then
        local resources = {}
        for _, info in pairs(self.meshWheelInfo) do
            if info.mesh then
                resources[info.mesh] = true
            end
            if info.brakeMesh then
                resources[info.brakeMesh] = true
            end
        end 
        local class_name = self.className
        for k, _ in pairs(resources) do
            self:addDiskResource(k)
        end
    end
    if self.engineInfo then
        local ei = self.engineInfo
        if ei.sound ~= nil then
            if type(ei.sound) == "table" then
                for _, s in ipairs(ei.sound) do
                    self:addDiskResource(s)
                end
            else
                self:addDiskResource(ei.sound)
            end
        end
    end
end

function Vehicle.destroy (self)
    ColClass.destroy(self)
end

function Vehicle.activate (self, instance)
    -- set all the materials to the lights off position
    instance.materialMap = {}
    for name, _ in pairs(Vehicle.lightDefaults) do
        local tab = self[name]
        if tab ~= nil then
            none_one_or_all(tab.materials, function (line)
                instance.materialMap[line.mesh] = line.off
            end)
        end
    end

    if ColClass.activate(self, instance) then
            return true
    end

    self.needsStepCallbacks = true

    local body = instance.body
    body.linearDamping = 0
    body.angularDamping = 0

    instance.handbrake = false
    instance.lightsOverrideOn = false
	instance.lightsEnabled = false
    instance.brake = false
    instance.push = 0
    instance.parked = self.parked or true
    instance.lightsOverride = self.lightsOverride or false
    if self.canDrive == false then instance.canDrive = false else instance.canDrive = true end

    instance.boomLengthSelected = (self.boomLengthMax + self.boomLengthMin)/2

    instance.numWheels = 0
    if self.bonedWheelInfo then
        for k, info in pairs(self.bonedWheelInfo) do
            instance.numWheels = instance.numWheels + 1
        end
    end
    if self.meshWheelInfo then
        for k, info in pairs(self.meshWheelInfo) do
            instance.numWheels = instance.numWheels + 1
        end
    end

    if instance.numWheels == 0 then
        error("A vehicle must have at least one wheel (class \""..self.className.."\")")
    end
    
    local mpw = body.mass/instance.numWheels -- mass per wheel (hacky)

    instance.steer, instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0, 0 
    local n = instance.gfx
    
    instance.engine = Engine.new(self.engineInfo);
    
    instance.lastExhaust = {}
    for i, _ in ipairs(self.exhaustSmokeVents) do
        instance.lastExhaust[i] = 0;
    end


    instance.brakeCurve = Plot (self.brakePlot)

    instance.wheels = {}
    instance.drivenWheels = {}
    instance.handbrakeWheels = {}
    
    if self.bonedWheelInfo then
        for k, info in pairs(self.bonedWheelInfo) do
            local wmass = (info.massShare or 1) * mpw
            instance.wheels[k] = WheelAssembly.newBoned(k, self, wmass, info)
            instance.wheels[k].steerFactor = info.steer or 0
            instance.wheels[k].drive = info.drive
            if info.drive then table.insert(instance.drivenWheels, instance.wheels[k]) end
            if info.handbrake then table.insert(instance.handbrakeWheels, instance.wheels[k]) end
        end 
    end

    if self.meshWheelInfo then
        for k, info in pairs(self.meshWheelInfo) do
            if instance.wheels[k]~=nil then
                error("There is more than one wheel called \""..k.."\" in \""..self.className.."\"")
            end
            local wmass = (info.massShare or 1) * mpw
            instance.wheels[k] = WheelAssembly.newMesh(k, self, wmass, info)
            instance.wheels[k].steerFactor = info.steer or 0
            instance.wheels[k].drive = info.drive
            if info.drive then table.insert(instance.drivenWheels, instance.wheels[k]) end
            if info.handbrake then table.insert(instance.handbrakeWheels, instance.wheels[k]) end
        end 
    end

    self.instance.numDrivenWheels = #instance.drivenWheels

    local super = body.updateCallback
    body.updateCallback = function (p, q)
        super(p, q)
        for _, wheel in pairs(instance.wheels) do
            wheel:updateGFX()
        end
        local time = env.secondsSinceMidnight
        local speed = dot(body.linearVelocity, body.worldOrientation * V_FORWARDS)
        for name, v in pairs(Vehicle.lightDefaults) do
            local l = instance[name]
            local tab = self[name]
            if l then
                if instance.exploded then
                    l.enabled = false
                else
                    local night = time > self.lightsOnTime or time < self.lightsOffTime
                    local enabled = not instance.parked and night
                    if instance.lightsOverride and night == instance.lightsOverrideOn then
						instance.lightsOverride = false
					elseif instance.lightsOverride then
						enabled = instance.lightsOverrideOn
					end
					instance.lightsEnabled = enabled
                    local dim = false
                    if tab.isBrake or v.isBrake then
                        if instance.brake and math.abs(speed) > 0.3 then
                            enabled = true
                            l.diffuseColour = vector3(3, 0, 0)
                            l.specularColour = vector3(3, 0, 0)
                        else
                            dim = true
                            l.diffuseColour = vector3(1, 0, 0)
                            l.specularColour = vector3(1, 0, 0)
                        end
                    end
                    if tab.isReverse or v.isReverse then
                        enabled = instance.engine:reversing() and not instance.handbrake
                    end
                    l.enabled = enabled
                    none_one_or_all(tab.materials, function(x)
                        local from = x.mesh
                        local to
                        if enabled then
                            if dim then
                                to = x.dim
                            else
                                to = x.on
                            end
                        else
                            to = x.off
                        end
                        instance.gfx:setMaterial(from, to)
                    end)    
                end
            end
        end
    end

    body.stabiliseCallback = function ()

        -- tend the travel direction towards the glide direction
        local lv = body.linearVelocity

        local speed = #lv
        if speed > 0 then

            local sheer = cross(norm(lv), body.worldOrientation * self.glideDirection)
            local torque = self.glideFactor * sheer - self.glideDampingFactor * body.angularVelocity

            local clamped_speed = math.min(speed, 125)
            body:torque(clamped_speed * clamped_speed * torque)
        end
            
    end

    for name, v in pairs(Vehicle.lightDefaults) do
        local tab = self[name]
        if tab then
            tab = extends (v) (tab)
            local l = light_from_table(gfx_light_make(), tab)
            instance[name] = l
            l.parent = instance.gfx
            l.enabled = false
        end
    end

end

function Vehicle.stepCallback (self, elapsed)
    local instance = self.instance
    local body = instance.body
    --velocity
    local q = body.worldOrientation
    local lv = body.linearVelocity
    local speed = #lv

    local local_vel = inv(q) * lv
    local forward_speed = local_vel.y
    local mph = forward_speed * 60 * 60 / METRES_PER_MILE

    -- DRAG
    local drag_force = -vec(sign(local_vel.x), sign(local_vel.y), sign(local_vel.z)) * 0.5 * 1.5 * self.drag * local_vel * local_vel
    body:force(q * drag_force, body.worldPosition)
    
    -- STEERING
    local steerTarget = instance.shouldSteerRight + instance.shouldSteerLeft
    local change = steerTarget - instance.steer
    if math.abs(change) > 0.001 then
        local rate
        local fastness = clamp(mph/self.steerFastSpeed, 0, 1)
        if between(0, steerTarget, instance.steer) and math.abs(instance.steer) > 0.001 then
            rate = lerp(self.unsteerRate, self.unsteerRateFast, fastness)
        else
            rate = lerp(self.steerRate, self.steerRateFast, fastness)
        end
        local max = lerp(self.steerMax, self.steerMaxFast, fastness)
        rate = rate * elapsed
        change = clamp(change, -rate, rate)
        instance.steer = instance.steer + change
        instance.steer = clamp(instance.steer, -max, max)
        for _, w in pairs(instance.wheels) do
            w:setSteer(w.steerFactor * instance.steer)
        end
    end

    for _, wheel in pairs(instance.wheels) do
        wheel:setTorque(0)
        wheel.locked = instance.parked
    end

    for _, wheel in ipairs(instance.handbrakeWheels) do
        if instance.handbrake then
            wheel.locked = true
        end
    end

    -- CAR ENGINE UPDATE
    if instance.engine then
        -- RPM of engine is average of all wheels on the ground
        local av, counter = 0, 0
        for k, v in ipairs(instance.drivenWheels) do
            if v.onGround then
                av = av + v.wheelAngularVelocityIgnoringSkid
                counter = counter + 1
            end
        end
        local rpm = nil
        if counter > 0 then
            rpm = av / counter / 2 / math.pi * 60
        end
        local torque = instance.engine:update(body.worldPosition, instance.push, forward_speed, rpm, elapsed)
        
        for _, wheel in pairs(instance.drivenWheels) do
            wheel:setTorque(torque)
        end
    end
    
    if instance.push == 0 then
        instance.brake = false
    else
        local speed = forward_speed
        local wrong_way = (math.abs(speed) > 1 and sign(speed) ~= sign(instance.push))
                       or (instance.handbrake and math.abs(speed) < 0.01)
        instance.brake = wrong_way
    end

    for k, wheel in pairs(instance.wheels) do
        if instance.brake then
            if instance.handbrake then
                wheel.locked = true
            else
                wheel:setTorque(-sign(mph)*instance.brakeCurve[math.abs(mph)])
            end
        end
        wheel:process(elapsed)
    end
    
    local h_smoke_threshold = 0.6
    local h_fire_threshold = 0.25
    local upside_down_time_allowed = 4 -- seconds
    
    local h = self.instance.health / self.health
    if h > 0 then
        if (body.worldOrientation * V_UP).z < -0.75 and speed < 2 then
            -- upside down this frame
            instance.upsideDownTimer = instance.upsideDownTimer + elapsed
            if instance.upsideDownTimer > upside_down_time_allowed then
                -- set the car to 25% health if not already less than that
                local twenty_five_percent = h_fire_threshold * self.health
                if instance.health > twenty_five_percent then
                    self:receiveDamage(instance.health - twenty_five_percent + 1)
                end
            end
        else
            instance.upsideDownTimer = 0
        end

        -- engine and exhaust smoke
        if (not instance.parked) and #body.linearVelocity < 30 then
            for i, v in ipairs(self.exhaustSmokeVents) do
                if instance.lastExhaust[i] > 0.02 then --comparison against self because instance doesn't seem to work o_O
                    emit_exhaust_smoke(#body.linearVelocity, body:localToWorld(v), body.worldOrientation * V_BACKWARDS)
                    instance.lastExhaust[i] = 0
                else
                    instance.lastExhaust[i] = instance.lastExhaust[i] + elapsed
                end
            end
        end
            
        if h < h_smoke_threshold then
            if h < h_fire_threshold then
                local rate = 0.20 / 5 -- lose 20% of total health every 4 seconds
                self:receiveDamage(elapsed * rate * self.health)
            end
            local engine_smoke_fire_level = 1 - h / h_smoke_threshold
            for _, v in ipairs(self.engineSmokeVents) do
                local world_v = body:localToWorld(v)
                if h < h_fire_threshold then
                    for i=1, 10 do    
                        emit_engine_fire(world_v)
                    end
                    world_v = world_v + vector3(0, 0, 0.2) -- do smoke slightly above the fire
                end
                emit_engine_smoke(engine_smoke_fire_level, world_v)
            end
        end
    end
end

function Vehicle.setFade (self, fade)
    ColClass.setFade(self, fade)
    local instance = self.instance
    if instance.wheels then
        for _, wheel in pairs(instance.wheels) do
            wheel:setFade(fade)
        end
    end
    for name, _ in pairs(Vehicle.lightDefaults) do
        local l = instance[name]
        if l then
            l.fade = fade
        end
    end
end

function Vehicle.beingFired (self)
    if not self.activated then error("Not activated: "..self.name) end
    self.instance.parked = false
    self.instance.engine.on = true
end

function Vehicle.deactivate (self)
    local instance = self.instance
    self.needsStepCallbacks = false
    if instance.wheels then
        for name in pairs(instance.wheels) do
            self:removeWheel(name)
        end
    end
    safe_destroy(instance.engine)
    instance.engine = nil
    instance.wheels = {}
    instance.drivenWheels = {}
    instance.handbrakeWheels = {}
    return ColClass.deactivate(self, instance)
end

function Vehicle.getSpeed (self)
    if self.exploded then return 0 end
    if not self.activated then error("Not activated: "..self.name) end
    local rb = self.instance.body
    return #rb.linearVelocity
end

function Vehicle.setHandbrake (self, v)
    if self.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    self.instance.handbrake = v
end

function Vehicle.setLights (self)
    if self.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    
    if self.instance.lightsEnabled then
    self.instance.lightsOverrideOn = false
    else
    self.instance.lightsOverrideOn = true
    end
	if (env.secondsSinceMidnight < self.lightsOnTime and env.secondsSinceMidnight > self.lightsOffTime) and self.instance.lightsOverrideOn == false then
		self.instance.lightsOverride = false
	elseif (env.secondsSinceMidnight > self.lightsOnTime or env.secondsSinceMidnight < self.lightsOffTime) and self.instance.lightsOverrideOn == true then
		self.instance.lightsOverride = false
	else
		self.instance.lightsOverride = true
	end
end

function Vehicle.changePush (self)
    if not self.activated then error("Not activated: "..self.name) end
    self.instance.parked = false -- if we push/pull the vehicle at all then it becomes unparked until abandoned
    self.instance.engine.on = true
end

function Vehicle.setBackwards (self, v)
    if self.instance.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    local change = v and 1 or -1
    self.instance.push = self.instance.push - change
    self:changePush()
end

function Vehicle.setForwards (self, v)
    if self.instance.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    local change = v and 1 or -1
    self.instance.push = self.instance.push + change
    self:changePush()
end


-- whether key is pressed
function Vehicle.setLeft (self, v)
    if self.instance.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    self.instance.shouldSteerLeft = v and -self.steerMax or 0
end
        
-- whether key is pressed
function Vehicle.setRight (self, v)
    if self.instance.exploded then return end
    if not self.activated then error("Not activated: "..self.name) end
    self.instance.shouldSteerRight = v and self.steerMax or 0
end
        

function Vehicle.realign (self)
    ColClass.realign(self)
    self.instance.broken = false
end

function Vehicle.setMu (self, mu_front_side, mu_front_drive, mu_side, mu_drive)
    if not self.activated then error("Not activated: "..self.name) end
    for _, w in pairs(self.instance.wheels) do
        if w.steerFactor ~= 0 then
            w.sideMu = mu_front_side
            w.driveMu = mu_front_drive
        else
            w.sideMu = mu_side
            w.driveMu = mu_drive
        end
    end
end

function Vehicle.reset (self)
    if not self.activated then error("Not activated: "..self.name) end
    local was_driving = player_ctrl.controlObj == self
    self.spawnPos = self.instance.body.worldPosition
    self.rot = self.instance.body.worldOrientation
    self:deactivate()
    self.skipNextActivation = false
    self:activate()
    if was_driving then
        player_ctrl:drive(self)
    end
end

function Vehicle.reload(self)
    ColClass.reload(self)
    local instance = self.instance
    for _, wheel in pairs(instance.wheels) do
        wheel:reload()
    end
end

function Vehicle.receiveDamage (self, damage)
    ColClass.receiveDamage(self, damage)
    -- car-specific damage stuff
    -- e.g. knocking off bumpers / doors
end

function Vehicle.removeWheel (self, name)
    local instance = self.instance
    local wheel = instance.wheels[name]
    safe_destroy(wheel)
    instance.wheels[name] = nil
    instance.drivenWheels[name] = nil
    instance.handbrakeWheels[name] = nil
end

function Vehicle.onExplode (self)
	engine_fire_counter = 0 --Temporary fix for max engine fire emission fix.
    local instance = self.instance
    instance.gfx:setAllMaterials("/common/mat/Burnt")
    if instance.wheels then
        for name, wheel in pairs(instance.wheels) do
            wheel:setBurnt(true)
            if math.random() > 0.5 then
                self:removeWheel(name)
            end
        end
    end
    safe_destroy(instance.engine)
    instance.engine = nil;
    self.instance.canDrive = false
    ColClass.onExplode(self)
end

function Vehicle.getStatistics (self)
    local instance = self.instance

    local tot_triangles, tot_batches = ColClass.getStatistics (self)

    if instance.wheels then
        for name, wheel in pairs(instance.wheels) do
            local gfx = wheel.gfx
            if gfx ~= nil then
                print("  Wheel: "..name)
                print("    Mesh: "..gfx.meshName)
                print("    Triangles: "..gfx.triangles)
                print("    Batches: "..gfx.batches)
                tot_triangles = tot_triangles + gfx.triangles
                tot_batches = tot_batches + gfx.batches
            end
        end
    end

    return tot_triangles, tot_batches
end

Vehicle.controlZoomIn = regular_chase_cam_zoom_in
Vehicle.controlZoomOut = regular_chase_cam_zoom_out
Vehicle.controlUpdate = regular_chase_cam_update


function Vehicle.controlBegin (self)
end
function Vehicle.controlAbandon (self)
    if not self.activated then return end
    local instance = self.instance
    local body = instance.body
    local speed = dot(body.linearVelocity, (body.worldOrientation * V_FORWARDS))
    if speed < 5 and speed > -5 then
        self.instance.parked = true
    end
end



Bike = extends (Vehicle) {

    glideFactor = -0.2;
    glideDampingFactor = 0.1;

    stabilisationFactor = 4000;
    stabilisationDampingFactor = 1000;
    canterAngle = 25;

    maxLean = 30;
    fallTorque = 4000;

    brakePlot = { [-10] = 400; [0] = 400; [10] = 400; [20] = 400; [40] = 400; };

}

function Bike.stepCallback (self, elapsed)
    Vehicle.stepCallback(self, elapsed)

    local instance = self.instance

    local fwheel = instance.wheels.front
    local rwheel = instance.wheels.rear

    if instance.broken then return end

    if instance.fwheel == nil or instance.rwheel == nil then return end

    if fwheel.onGround or rwheel.onGround then


        local body = instance.body
        local q = body.worldOrientation

        local forwards_ws = q * V_FORWARDS

        local desired_vector


        if true or (fwheel.onGround and rwheel.onGround) then
            local dir = fwheel.worldContactPos-rwheel.worldContactPos
            local speed = dot(body.linearVelocity, norm(dir))
            local turn_radius
            if instance.steer == 0 then
                    turn_radius = math.huge
            else
                    turn_radius = #dir / (math.atan(instance.steer) * math.cos(math.rad(self.canterAngle)))
            end
            local desired_lean =
                    math.deg(math.atan((speed*speed) / (#physics_get_gravity()*turn_radius)))
            --desired_lean = desired_lean / 2
            desired_lean = clamp(desired_lean, -self.maxLean, self.maxLean)
            desired_vector = quat(desired_lean, forwards_ws) * V_UP
        else
            local dir = fwheel.pos-rwheel.pos
            local speed = dot(body.linearVelocity, norm(dir.normalised))
            local turn_radius = #dir
                     / (math.atan(instance.steer) * math.cos(math.rad(self.canterAngle)))
            local desired_lean =
                    math.deg(math.atan((speed*speed) / (#physics_get_gravity()*turn_radius)))
            desired_vector = quat(desired_lean, forwards_ws) * V_UP
            desired_vector =  V_UP
        end

        --print(desired_vector)

        --using the actual friction proved too jittery
--[[
        desired_vector = vector3(0, 0, 0)
        for _, w in pairs{instance.wheels.front, instance.wheels.rear} do
            if w.onGround then
                desired_vector:append(w.restitutionForce)
                desired_vector:append(w.frictionForce)
            end
        end
]]--


        desired_vector = norm(desired_vector)

        local vector = q*V_UP

        local sheer = cross(vector, desired_vector)
        sheer = dot(sheer, forwards_ws) * forwards_ws


        local spin = body.angularVelocity
        spin = dot(spin, forwards_ws)
        spin = spin * forwards_ws

        local torque = self.stabilisationFactor * sheer
                     - self.stabilisationDampingFactor * spin

        if #torque > self.fallTorque then
            instance.broken = true
            return
        end

        body:torque(torque)
    end
end

