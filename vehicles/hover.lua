-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

Hover = extends (ColClass) {
        castShadows = true;
        renderingDistance=100;
        
        health = 100000;
        impulseDamageThreshold=1000; 
        explodeInfo = { radius = 10 };
        
        cameraTrack = true;
        fovScale = true;
        topDownCam = false;
        
        jetsHover = { -- engines in this table processed according to the hover algorythm
            -- { pos = vector3(2,3,1); color = vector3(128,128,128); } -- engine position and color of emitted light
            -- { pos = vector3(3,1,1); color = vector3(128,0,0); };
            -- { pos = vector3(2,3,2); color = vector3(0,0,128); pid = {p = 10, i = 2, d = 3, min = 0, max = 10 }; } -- this engine provides a pid override values
        };
        jetsInfo = { -- this is the rest "pushing" engines and so on
            -- the below is just for example, DO NOT DECLARE HERE actually
            -- { pos = vector3(2,3,1); color = vector3(128,128,128); } -- engine position and color of emitted light
            -- { pos = vector3(3,1,1); color = vector3(128,0,0); };
        };
        jetsControl = { -- this describes which powers to apply to make vehicle moving in the suggested direction
            -- the below is just for example, DO NOT DECLARE HERE actually
            -- forwards = { vector3(0,0,0); vector3(0,0,1) }; -- applies no force to first engine, applies 1UP force to the second
            -- backwards = { vector3(0,0,1); vector3(0,0,0) }; -- applies 1UP to first, applies none to second engine
            -- steerLeft = { }; -- so on, you got it :P
            -- steerRight = { };
            -- strafeLeft = { };
            -- strafeRight = { };
        };

        -- when to use headlights when driving
--        lightsOnTime = parse_time("19:00:00");
--        lightsOffTime = parse_time("07:00:00");

        engineSmokeVents = { };
--        exhaustSmokeVents = { };  -- TODO use rocket smoke
}

function Hover.init (persistent)
        ColClass.init(persistent)
end

function Hover.destroy (persistent)
        ColClass.destroy(persistent)
end

function Hover.activate (persistent,instance)
        if ColClass.activate(persistent,instance) then
                return true
        end
        persistent.needsStepCallbacks = true

        local body = instance.body

        instance.canDrive = true
        instance.health = persistent.health
        
        instance.parked = true
        instance.handbrake = false
        instance.forwards = false
        instance.backwards = false
        instance.steerLeft = false
        instance.steerRight = false
        instance.strafeRight = false
        instance.strafeLeft = false
        
        
        instance.jetsHover = {}
        for i,engine in pairs(persistent.jetsHover) do
            if engine then
                instance.jetsHover[i] = {}

                local enginePos = body:localToWorld(engine.pos)
                local P,I,D,min,max

                if engine.pid then
                    local pid = engine.pid
                    P,I,D,min,max = pid.p, pid.i, pid.d, pid.min, pid.max
                else
                    P = --[[V_ID*--]]10000
                    I = --[[V_ID*--]]20
                    D = --[[V_ID*--]]2500
                    min= --[[V_ID*--]]-2
                    max= --[[V_ID*--]]2
                end

                instance.jetsHover[i].pid = pid_ctrl.new(enginePos,P,I,D,min,max)
            end
        end
        
--[[    --TODO: remake for rocket smoke
        instance.lastExhaust = {}
        for i,_ in ipairs(persistent.exhaustSmokeVents) do
                instance.lastExhaust[i] = 0;
        end
--]]

    --TODO: lights init goes here

        local super = body.updateCallback
        body.updateCallback = function (p,q)
                super(p,q)
                --TODO: updating of lights goes here
        end
end

function Hover.process_force(persistent, name)
            local instance = persistent.instance
            local body = instance.body
            if instance[name] then
                --print("name: "..name)
                if persistent.jetsControl[name] then
                    --print("persistent[name]: "..dump(persistent.jetsControl[name]))
                    for i, force in pairs(persistent.jetsControl[name]) do
                        if force and persistent.jetsInfo[i] then
                            --print("force: "..force)
                            body:force(body.worldOrientation * force, body:localToWorld(persistent.jetsInfo[i].pos))
                        end
                    end
                end
            end
end

function Hover.stepCallback (persistent, elapsed)
        local instance = persistent.instance
        local body = instance.body
        
        if instance.parked then 
            if instance.forwards or instance.backwards then
                instance.parked = false
            else
                return
            end
        end
        
        if not instance.handbrake then
            for i,engine in pairs(persistent.jetsHover) do -- process hovering engines
                if engine then
                    local enginePos = body:localToWorld(engine.pos)
                    local hover_line = 1 --0.5 -- what height we target for hovering
                    
                    -- 1 meter ray down from engine position
                    local dist,_,normal = physics_cast(enginePos, body.worldOrientation*V_DOWN, true, 0, body)
                    
                    if dist and normal then
                        local target_pos = enginePos + dist*V_DOWN + normal * hover_line
                        body:force(instance.jetsHover[i].pid:control(target_pos, enginePos), enginePos)
                    end
                end
            end
        
            -- process responce to input controls
        
            persistent:process_force("forwards")
            persistent:process_force("backwards")
            persistent:process_force("steerLeft")
            persistent:process_force("steerRight")
            persistent:process_force("strafeLeft")
            persistent:process_force("strafeRight")
        end
        
        -- smoke stuff
        local h = persistent.instance.health / persistent.health
        if h > 0 then
            local h_smoke_threshold = 0.6
            local h_fire_threshold = 0.25
            local upside_down_time_allowed = 4 -- seconds
            
            local speed = #body.linearVelocity
            
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
        
            if h < h_smoke_threshold then
                if h < h_fire_threshold then
                    local rate = 0.20 / 5 -- lose 20% of total health every 4 seconds
                    persistent:receiveDamage(elapsed * rate * persistent.health)
                end
                
                local engine_smoke_fire_level = 1 - h / h_smoke_threshold
                for _,v in pairs(persistent.engineSmokeVents) do
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

function Hover.setFade (persistent,fade)
        ColClass.setFade(persistent,fade)
end

function Hover.beingFired (persistent) -- when this happens?
        if not persistent.activated then error("Not activated: "..persistent.name) end
end

function Hover.deactivate (persistent)
        local instance = persistent.instance
        persistent.needsStepCallbacks = false
        return ColClass.deactivate(persistent, instance)
end

function Hover.getSpeed (persistent)
        if not persistent.activated then error("Not activated: "..persistent.name) end
        local rb = persistent.instance.body
        return #rb.linearVelocity
end

function Hover.abandon (persistent)
    if not persistent.activated then return end
    persistent.instance.parked = true -- TODO: if traveled fast leave floating but disable all other engines
end

function Hover.setHandbrake (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.handbrake = v
end

function Hover.setPull (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.backwards = v
end

function Hover.setPush (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.forwards = v
end

function Hover.setShouldSteerLeft (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.steerLeft = v
end

function Hover.setShouldSteerRight (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.steerRight = v
end

function Hover.setSpecialRight (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.strafeRight = v
end

function Hover.setSpecialLeft (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.strafeLeft = v
end

function Hover.reset (persistent) -- what's this for?
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

function Hover.reload(persistent) -- what's this for?
        ColClass.reload(persistent)
end

function Hover.receiveDamage (persistent, damage)
        ColClass.receiveDamage(persistent, damage)
        -- car-specific damage stuff
        -- e.g. knocking off bumpers / doors
end

function Hover.onExplode (persistent)
        local instance = persistent.instance
        if player_ctrl.vehicle == persistent then
                player_ctrl:abandonVehicle()
        end
        
        instance.canDrive = false
        instance.parked = true
        instance.forwards = false
        instance.backwards = false
        instance.gfx:setAllMaterials("/common/mat/Burnt")
        ColClass.onExplode(persistent)
end
