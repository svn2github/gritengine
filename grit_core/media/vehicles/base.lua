-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

Vehicle = extends (ColClass) {

        castShadows = true;
        renderingDistance=100;

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

        glideDirection = vector3(0,1,0);
        glideFactor = -6;
        glideDampingFactor = 2;

        wheelSpinTractionControlMax = 1;
        wheelSpinTractionControlRate = 4;
        wheelSpinTractionControlMin = 0.01;

        health = 100000;
        impulseDamageThreshold=1000;
        explodeInfo = { radius = 10 };

        brakePlot = { [-10] = 100; [0] = 100; [10] = 2500; [20] = 2500; [40] = 2500; };

        lightDefaults = {
				-- car lights:
                lightHeadLeft = {
                        isHeadLight = true;
                        range = 100; diff = 5*vector3(1,0.9,0.8);
                        coronaSize = 10;
                        iangle = 25; oangle = 35;
                        ciangle = 40; coangle = 70;
                        aim = quat( 2,V_UP)*quat(-20,V_RIGHT);
                };
                lightHeadRight = {
                        isHeadLight = true;
                        range = 60; diff = 5*vector3(1,0.9,0.8);
                        coronaSize = 10;
                        iangle = 25; oangle = 35;
                        ciangle = 40; coangle = 70;
                        aim = quat(-2,V_UP)*quat(-20,V_RIGHT);
                };
                lightBrakeLeft = {
                        diff = 2*vector3(1,0,0);
                        isBrake = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };
                lightBrakeRight = {
                        diff = 2*vector3(1,0,0);
                        isBrake = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };
                lightReverseLeft = {
                        diff = vector3(1,1,1);
                        isReverse = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };
                lightReverseRight = {
                        diff = vector3(1,1,1);
                        isReverse = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };

				-- bike lights:
                lightHeadCenter = {
                        diff = vector3(1,1,1);
                        isHeadLight = true;
                        range = 40;
                        iangle = 0;
                        oangle = 35;
                        aim = quat(0,V_UP); -- TODO: Is this aimed down properly?
                };
                lightBrakeCenter = {
                        diff = vector3(1,0,0);
                        isBrake = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };
                lightReverseCenter = {
                        diff = vector3(1,1,1);
                        isReverse = true;
                        range = 4;
                        iangle = 0;
                        oangle = 90;
                        aim = quat(180,V_UP);
                        coronaSize = 0;
                };
        };

        -- when to use headlights when driving
        lightsOnTime = parse_time("19:00:00");
        lightsOffTime = parse_time("07:00:00");

        engineSmokeVents = { };
        exhaustSmokeVents = { };
}

function Vehicle.init (persistent)
        ColClass.init(persistent)
        if persistent.meshWheelInfo then
                local resources = {}
                for _, info in pairs(persistent.meshWheelInfo) do
                        if info.mesh then
                                resources[info.mesh] = true
                        end
                        if info.brakeMesh then
                                resources[info.brakeMesh] = true
                        end
                end 
                local class_name = persistent.className
                for k,_ in pairs(resources) do
                        persistent:addDiskResource(k)
                end
        end
end

function Vehicle.destroy (persistent)
        ColClass.destroy(persistent)
end

function Vehicle.activate (persistent,instance)
        -- set all the materials to the lights off position
        instance.materialMap = {}
        for name,_ in pairs(Vehicle.lightDefaults) do
                local tab = persistent[name]
                if tab ~= nil then
                        none_one_or_all(tab.materials, function (line)
                                instance.materialMap[line.mesh] = line.off
                        end)
                end
        end

        if ColClass.activate(persistent,instance) then
                return true
        end

        persistent.needsStepCallbacks = true

        local body = instance.body

        instance.handbrake = false
        instance.brake = false
        instance.push = 0
        instance.parked = persistent.parked or true
        instance.lightsOverride = persistent.lightsOverride or false
        if persistent.canDrive == false then instance.canDrive = false else instance.canDrive = true end

        instance.numWheels = 0
        if persistent.bonedWheelInfo then
                for k, info in pairs(persistent.bonedWheelInfo) do
                        instance.numWheels = instance.numWheels + 1
                end
        end
        if persistent.meshWheelInfo then
                for k, info in pairs(persistent.meshWheelInfo) do
                        instance.numWheels = instance.numWheels + 1
                end
        end

        if instance.numWheels == 0 then
                error("A vehicle must have at least one wheel (class \""..persistent.className.."\")")
        end
        
        local mpw = body.mass/instance.numWheels -- mass per wheel (hacky)

        instance.steer, instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0, 0 
        local n = instance.gfx

        instance.engine = Engine.new(persistent.powerPlots)

        
        instance.lastExhaust = {}
        for i,_ in ipairs(persistent.exhaustSmokeVents) do
                instance.lastExhaust[i] = 0;
        end


        instance.brakeCurve = Plot (persistent.brakePlot)

        instance.wheels = {}
        instance.drivenWheels = {}
        instance.handbrakeWheels = {}
        
        if persistent.bonedWheelInfo then
                for k, info in pairs(persistent.bonedWheelInfo) do
                        local wmass = (info.massShare or 1) * mpw
                        instance.wheels[k] = WheelAssembly.newBoned(k, persistent, wmass, info)
                        instance.wheels[k].steerFactor = info.steer or 0
                        instance.wheels[k].drive = info.drive
                        if info.drive then table.insert(instance.drivenWheels,instance.wheels[k]) end
                        if info.handbrake then table.insert(instance.handbrakeWheels,instance.wheels[k]) end
                end 
        end

        if persistent.meshWheelInfo then
                for k, info in pairs(persistent.meshWheelInfo) do
                        if instance.wheels[k]~=nil then
                                error("There is more than one wheel called \""..k.."\" in \""..persistent.className.."\"")
                        end
                        local wmass = (info.massShare or 1) * mpw
                        instance.wheels[k] = WheelAssembly.newMesh(k, persistent, wmass, info)
                        instance.wheels[k].steerFactor = info.steer or 0
                        instance.wheels[k].drive = info.drive
                        if info.drive then table.insert(instance.drivenWheels,instance.wheels[k]) end
                        if info.handbrake then table.insert(instance.handbrakeWheels,instance.wheels[k]) end
                end 
        end

        persistent.instance.numDrivenWheels = #instance.drivenWheels

        local super = body.updateCallback
        body.updateCallback = function (p,q)
                super(p,q)
                for _,wheel in pairs(instance.wheels) do
                        wheel:updateGFX()
                end
                local time = env.secondsSinceMidnight
                local speed = dot(body.linearVelocity, body.worldOrientation * V_FORWARDS)
                for name,v in pairs(Vehicle.lightDefaults) do
                        local l = instance[name]
                        local tab = persistent[name]
                        if l then
                                if instance.exploded then
                                        l.enabled = false
                                else
                                        local night = time > persistent.lightsOnTime or time < persistent.lightsOffTime
                                        local enabled = not instance.parked and night
                                        if instance.lightsOverride then enabled = true end
                                        local dim = false
                                        if tab.isBrake or v.isBrake then
                                                if instance.brake and math.abs(speed) > 0.3 then
                                                        enabled = true
                                                        l.diffuseColour = vector3(3,0,0)
                                                        l.specularColour = vector3(3,0,0)
                                                else
                                                        dim = true
                                                        l.diffuseColour = vector3(1,0,0)
                                                        l.specularColour = vector3(1,0,0)
                                                end
                                        end
                                        if tab.isReverse or v.isReverse then
                                                enabled = (instance.engine:getGear() == -1)  and not instance.handbrake
                                        end
                                        l.enabled = enabled
                                        none_one_or_all(tab.materials, function(x)
                                                local from = fqn_ex(x.mesh, persistent.className)
                                                local mname
                                                if enabled then
                                                        if dim then
                                                                mname = x.dim
                                                        else
                                                                mname = x.on
                                                        end
                                                else
                                                        mname = x.off
                                                end
                                                local to = fqn_ex(mname, persistent.className)
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

                        local sheer = cross(norm(lv), body.worldOrientation * persistent.glideDirection)
                        local torque = persistent.glideFactor * sheer - persistent.glideDampingFactor * body.angularVelocity

                        local clamped_speed = math.min(speed, 125)
                        body:torque(clamped_speed * clamped_speed * torque)
                end
                
        end

        for name,v in pairs(Vehicle.lightDefaults) do
                local tab = persistent[name]
                if tab then
                        tab = extends (v) (tab)
                        local l = light_from_table(gfx_light_make(), tab)
                        instance[name] = l
                        l.parent = instance.gfx
                        l.enabled = false
                end
        end

end

function Vehicle.stepCallback (persistent, elapsed)
        local instance = persistent.instance
        local body = instance.body
        --velocity
        local lv = body.linearVelocity
        local speed = #lv

        local forward_speed = dot(lv, body.worldOrientation * vector3(0,1,0))
        local mph = forward_speed * 60 * 60 / METRES_PER_MILE

        -- STEERING
        local steerTarget = instance.shouldSteerRight + instance.shouldSteerLeft
        local change = steerTarget - instance.steer
        if math.abs(change) > 0.001 then
                local rate
                local fastness = clamp(mph/persistent.steerFastSpeed, 0, 1)
                if between(0,steerTarget,instance.steer) and math.abs(instance.steer) > 0.001 then
                        rate = lerp(persistent.unsteerRate, persistent.unsteerRateFast, fastness)
                else
                        rate = lerp(persistent.steerRate, persistent.steerRateFast, fastness)
                end
                local max = lerp(persistent.steerMax, persistent.steerMaxFast, fastness)
                rate = rate * elapsed
                change = clamp(change, -rate, rate)
                instance.steer = instance.steer + change
                instance.steer = clamp(instance.steer, -max, max)
                for _,w in pairs(instance.wheels) do
                        w:setSteer(w.steerFactor * instance.steer)
                end
        end
        
        -- ENGINE TORQUE
        if instance.push == 0 then
                instance.engine:setGear(0)
                instance.brake = false
        else
                local speed = forward_speed
                local wrong_way = (math.abs(speed) > 1 and sign(speed) ~= sign(instance.push))
                               or (instance.handbrake and math.abs(speed) < 0.01)
                if wrong_way then
                        instance.engine:setGear(0) -- neutral
                        instance.brake = true
                else
                        instance.brake = false
                        instance.engine:setGear(sign(instance.push)) -- either forward(1) or reverse(-1)
                end
        end
        local torque = instance.engine:getTorque(mph)

        for _, wheel in pairs(instance.wheels) do
                wheel.locked = instance.parked
        end
        for _, wheel in ipairs(instance.handbrakeWheels) do
                if instance.handbrake then
                        wheel.locked = true
                end
        end
        for _, wheel in pairs(instance.wheels) do
                if instance.brake then
                        if instance.handbrake then
                                wheel.locked = true
                        else
                                wheel:applyTorque(-sign(mph)*instance.brakeCurve[math.abs(mph)], elapsed)
                        end
                else
                        local drive = wheel.drive or 0
                        wheel:applyTorque(drive * torque / instance.numDrivenWheels, elapsed)
                end
                wheel:process(elapsed)
        end

        local h_smoke_threshold = 0.6
        local h_fire_threshold = 0.25
        local upside_down_time_allowed = 4 -- seconds
        
        local h = persistent.instance.health / persistent.health
        if h > 0 then
            if (body.worldOrientation * V_UP).z < -0.75 and speed < 2 then
                -- upside down this frame
                instance.upsideDownTimer = instance.upsideDownTimer + elapsed
                if instance.upsideDownTimer > upside_down_time_allowed then
                        -- set the car to 25% health if not already less than that
                        local twenty_five_percent = h_fire_threshold * persistent.health
                        if instance.health > twenty_five_percent then
                                persistent:receiveDamage(instance.health - twenty_five_percent + 1)
                        end
                end
            else
                instance.upsideDownTimer = 0
            end

        -- engine and exhaust smoke
                if (not instance.parked) and #body.linearVelocity < 30 then
                        for i,v in ipairs(persistent.exhaustSmokeVents) do
                                if instance.lastExhaust[i] > 0.02 then --comparison against persistent because instance doesn't seem to work o_O
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
                                                persistent:receiveDamage(elapsed * rate * persistent.health)
                                end
                                local engine_smoke_fire_level = 1 - h / h_smoke_threshold
                                for _,v in ipairs(persistent.engineSmokeVents) do
                                        local world_v = body:localToWorld(v)
                                        if h < h_fire_threshold then
                                                for i=1,10 do    
                                                emit_engine_fire(world_v)
                                                end
                                                world_v = world_v + vector3(0, 0, 0.2) -- do smoke slightly above the fire
                                        end
                                        emit_engine_smoke(engine_smoke_fire_level, world_v)
                                end
                end
        end
end

function Vehicle.setFade (persistent,fade)
        ColClass.setFade(persistent,fade)
        local instance = persistent.instance
        if instance.wheels then
                for _,wheel in pairs(instance.wheels) do
                        wheel:setFade(fade)
                end
        end
        for name,_ in pairs(Vehicle.lightDefaults) do
                local l = instance[name]
                if l then
                        l.fade = fade
                end
        end
end

function Vehicle.beingFired (persistent)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.parked = false
end

function Vehicle.deactivate (persistent)
        local instance = persistent.instance
        persistent.needsStepCallbacks = false
        if instance.wheels then
                for name in pairs(instance.wheels) do
                        persistent:removeWheel(name)
                end
        end
        instance.wheels = {}
        instance.drivenWheels = {}
        instance.handbrakeWheels = {}
        return ColClass.deactivate(persistent, instance)
end

function Vehicle.getSpeed (persistent)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        local rb = persistent.instance.body
        return #rb.linearVelocity
end

function Vehicle.setHandbrake (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.handbrake = v
end

function Vehicle.setBoost (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
end

function Vehicle.abandon (persistent)
        if not persistent.activated then return end
        local instance = persistent.instance
        local body = instance.body
		local speed = dot(body.linearVelocity, (body.worldOrientation * V_FORWARDS))
        persistent.instance.parked = speed < 5 and speed > -5
        instance.brake = false
        instance.engine.gear = 0
        instance.push = 0
        instance.handbrake = false
end

function Vehicle.changePush (persistent)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.parked = false -- if we push/pull the vehicle at all then it becomes unparked until abandoned
end

function Vehicle.setPull (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        local change = v and 1 or -1
        persistent.instance.push = persistent.instance.push - change
        persistent:changePush()
end

function Vehicle.setPush (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        local change = v and 1 or -1
        persistent.instance.push = persistent.instance.push + change
        persistent:changePush()
end


-- whether key is pressed
function Vehicle.setShouldSteerLeft (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.shouldSteerLeft = v and -persistent.steerMax or 0
end
        
-- whether key is pressed
function Vehicle.setShouldSteerRight (persistent, v)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        persistent.instance.shouldSteerRight = v and persistent.steerMax or 0
end
        

function Vehicle.realign (persistent)
        ColClass.realign(persistent)
        persistent.instance.broken = false
end

function Vehicle.setMu (persistent, mu_front_side, mu_front_drive, mu_side, mu_drive)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        for _,w in pairs(persistent.instance.wheels) do
                if w.steerFactor ~= 0 then
                        w.sideMu = mu_front_side
                        w.driveMu = mu_front_drive
                else
                        w.sideMu = mu_side
                        w.driveMu = mu_drive
                end
        end
end

function Vehicle.reset (persistent)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        local was_driving = player_ctrl.vehicle == persistent
        persistent.spawnPos = persistent.instance.body.worldPosition
        persistent.rot = persistent.instance.body.worldOrientation
        persistent:deactivate()
        persistent.skipNextActivation = false
        persistent:activate()
        if was_driving then
                player_ctrl:drive(persistent)
        end
end

function Vehicle.reload(persistent)
        ColClass.reload(persistent)
        local instance = persistent.instance
        for _,wheel in pairs(instance.wheels) do
                wheel:reload()
        end
end

function Vehicle.receiveDamage (persistent, damage)
        ColClass.receiveDamage(persistent, damage)
        -- car-specific damage stuff
        -- e.g. knocking off bumpers / doors
end

function Vehicle.removeWheel (persistent, name)
        local instance = persistent.instance
        local wheel = instance.wheels[name]
        safe_destroy(wheel)
        instance.wheels[name] = nil
        instance.drivenWheels[name] = nil
        instance.handbrakeWheels[name] = nil
end

function Vehicle.onExplode (persistent)
        local instance = persistent.instance
        if player_ctrl.vehicle == persistent then
                player_ctrl:abandonVehicle()
        end
        instance.gfx:setAllMaterials("/common/mat/Burnt")
        if instance.wheels then
                for name, wheel in pairs(instance.wheels) do
                        wheel:setBurnt(true)
                        if math.random() > 0.5 then
                                persistent:removeWheel(name)
                        end
                end
        end
        persistent.instance.canDrive = false
        ColClass.onExplode(persistent)
end

function Vehicle.getStatistics (persistent)
        local instance = persistent.instance

        local tot_triangles, tot_batches = ColClass.getStatistics (persistent)

        if instance.wheels then
                for name, wheel in pairs(instance.wheels) do
                        local gfx = wheel.gfx
                        if gfx ~= nil then
                            echo("  Wheel: "..name)
                            echo("    Mesh: "..gfx.meshName)
                            echo("    Triangles: "..gfx.triangles)
                            echo("    Batches: "..gfx.batches)
                            tot_triangles = tot_triangles + gfx.triangles
                            tot_batches = tot_batches + gfx.batches
                        end
                end
        end

        return tot_triangles, tot_batches
end;



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

function Bike.stepCallback (persistent, elapsed)
        Vehicle.stepCallback(persistent, elapsed)

        local instance = persistent.instance

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
                                turn_radius = #dir / (math.atan(instance.steer) * math.cos(math.rad(persistent.canterAngle)))
                        end
                        local desired_lean =
                                math.deg(math.atan((speed*speed) / (#physics_get_gravity()*turn_radius)))
                        --desired_lean = desired_lean / 2
                        desired_lean = clamp(desired_lean,-persistent.maxLean,persistent.maxLean)
                        desired_vector = quat(desired_lean,forwards_ws) * V_UP
                else
                        local dir = fwheel.pos-rwheel.pos
                        local speed = dot(body.linearVelocity, norm(dir.normalised))
                        local turn_radius = #dir
                                 / (math.atan(instance.steer) * math.cos(math.rad(persistent.canterAngle)))
                        local desired_lean =
                                math.deg(math.atan((speed*speed) / (#physics_get_gravity()*turn_radius)))
                        desired_vector = quat(desired_lean,forwards_ws) * V_UP
                        desired_vector =  V_UP
                end

                --echo(desired_vector)

                 --using the actual friction proved too jittery
--[[
                desired_vector = vector3(0,0,0)
                for _,w in pairs{instance.wheels.front, instance.wheels.rear} do
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

                local torque = persistent.stabilisationFactor * sheer
                             - persistent.stabilisationDampingFactor * spin

                if #torque > persistent.fallTorque then
                        instance.broken = true
                        return
                end

                body:torque(torque)
        end
end

