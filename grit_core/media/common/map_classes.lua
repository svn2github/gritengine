-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

verbose_receive_damage = false

function light_from_table (l, tab)
        if tab.pos then l.localPosition = tab.pos end
        local sz
        if tab.diff then
                sz = math.max(math.max(math.max(1, tab.diff.x), tab.diff.y), tab.diff.z)
                l.diffuseColour = tab.diff
        end
        if tab.spec then l.specularColour = tab.spec end
        if tab.diff and not tab.spec then
                l.specularColour = tab.diff
        end
        local csz
        if sz then csz = sz / 16 end
        if tab.range then
                l.range = tab.range
                if csz then csz = csz * tab.range end
        end
        if tab.iangle then l.innerAngle = tab.iangle end
        if tab.oangle then l.outerAngle = tab.oangle end
        if tab.ciangle then l.coronaInnerAngle = tab.ciangle end
        if tab.coangle then l.coronaOuterAngle = tab.coangle end
        if tab.aim then l.localOrientation = tab.aim end
        if tab.coronaSize or csz then l.coronaSize = tab.coronaSize or csz end
        if tab.coronaColour then
                l.coronaColour = tab.coronaColour
        else
                if sz then
                        l.coronaColour = tab.diff / sz 
                end
        end
        local clp = tab.coronaPos or tab.pos
        if clp then l.coronaLocalPosition = clp end
        return l
end

BaseClass = {
        renderingDistance=400;
        init = function (persistent)
                local class_name = persistent.className
                local gfxMesh = persistent.gfxMesh or class_name..".mesh"
                persistent:addDiskResource(gfxMesh)
                if persistent.extraResources == nil then return end
                for _,v in ipairs(persistent.extraResources) do
                        persistent:addDiskResource(v)
                end
        end;
        activate=function (persistent, instance)
                if persistent.skipNextActivation then
                        persistent.skipNextActivation = nil
                        instance.activationSkipped = true
                        return true
                end
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                local gfxMesh = persistent.gfxMesh or persistent.className..".mesh"
                local fqmm
                if persistent.materialMap then
                        fqmm = fqmm or {}
                        for k,v in pairs(persistent.materialMap) do
                                fqmm[fqn_ex(k, persistent.className)] = fqn_ex(v, persistent.className)
                        end
                end
                if instance.materialMap then -- allows subclasses to add to the material map
                        fqmm = fqmm or {}
                        for k,v in pairs(instance.materialMap) do
                                fqmm[fqn_ex(k, persistent.className)] = fqn_ex(v, persistent.className)
                        end
                end
                instance.gfx = gfx_body_make(gfxMesh, fqmm)
                instance.gfx.castShadows = persistent.castShadows == true
                if instance.gfx.numBones > 0 and instance.gfx:getAllAnimations() == nil then instance.gfx:setAllBonesManuallyControlled(true) end
                instance.gfx.localPosition = persistent.spawnPos
                instance.gfx.localOrientation = persistent.rot or quat(1,0,0,0)
                
                local lights = persistent.lights
                if lights then
                        instance.lights = {}
                        instance.lightCallbacks = {}
                        instance.lightFlickedOff = {}
                        instance.lightTimeOff = {}
                        for k,tab in ipairs(lights) do
                                local l = light_from_table(gfx_light_make(), tab)
                                instance.lights[k] = l
                                l.parent = instance.gfx
                                if tab.flickering then
                                        -- simulate a broken flourescent tube
                                        future_event(0, function()
                                                if l.destroyed then return end
                                                local off = math.random() < 0.33
                                                instance.lightFlickedOff[k] = off
                                                l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                                                none_one_or_all(tab.emissiveMaterials, function(x)
                                                        instance.gfx:setEmissiveEnabled(fqn_ex(x, persistent.className), l.enabled)
                                                end)
                                                return math.random() * 0.2
                                        end)
                                end
                                if tab.onTime and tab.offTime then
                                        local on_time = parse_time(tab.onTime)
                                        local off_time = parse_time(tab.offTime)
                                        local on_during_night = on_time > off_time
                                        local first_time = on_during_night and off_time or on_time
                                        local last_time = on_during_night and on_time or off_time
                                        if tab.timeOnOffRandomness then
                                                local random_secs = parse_time(tab.timeOnOffRandomness)
                                                first_time = first_time + math.random()*random_secs
                                                last_time = last_time + math.random()*random_secs
                                        end
                                        local cb = function()
                                                local off
                                                if env.secondsSinceMidnight < first_time then
                                                        off = not on_during_night
                                                elseif env.secondsSinceMidnight < last_time then
                                                        off = on_during_night
                                                else
                                                        off = not on_during_night
                                                end
                                                instance.lightTimeOff[k] = off
                                                l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                                                none_one_or_all(tab.emissiveMaterials, function(x)
                                                        instance.gfx:setEmissiveEnabled(fqn_ex(x, persistent.className), l.enabled)
                                                end)
                                        end
                                        instance.lightCallbacks[k] = cb
                                        --env:addClockCallback(cb)
                                        env.tickCallbacks:insert(("lights_callback_"..k), cb)
                                        cb(env.secondsSinceMidnight)
                                end
                        end
                end

                if persistent.colourSpec then
                        persistent:setRandomColour()
                end
        end;
        setRandomColour=function(persistent)
                if not persistent.activated then error("not activated") end
                local cs = persistent.colourSpec
                local prob_total = 0
                for k,v in ipairs(cs) do
                        prob_total = prob_total + (v.probability or 1)
                end
                local r = math.random() * prob_total
                prob_total = 0
                for k,v in ipairs(cs) do
                        prob_total = prob_total + (v.probability or 1)
                        if r < prob_total then
                                persistent:setRandomColourFromSet(v)
                                return
                        end
                end
        end;
        setRandomColourFromSet=function(persistent, colset, indexes)
                if not persistent.activated then error("not activated") end
                local cs = persistent.colourSpec
                if type(colset) == "number" then
                        colset = cs[colset]
                end
                local cols = {}
                for i=1,4 do -- 4 colours to choose
                        if colset[i] == nil or #colset[i] == 0 then
                                cols[i] = "white"
                        else
                                local set = {}
                                local function incorporate_all (tab)
                                        for _,v in ipairs(tab) do
                                                if type(v) == "string" and v:sub(1,1) == "*" then
                                                        incorporate_all(carcol_groups[v:sub(2)])
                                                else
                                                        set[#set+1] = v
                                                end
                                        end
                                end
                                incorporate_all(colset[i])
                                cols[i] = set[indexes and indexes[i] or math.random(#set)]
                        end
                end
                persistent:setColour(cols)
        end;
        setColour=function(persistent, cols)
                if not persistent.activated then error("not activated") end
                assert(type(cols)=="table")
                for i=1,4 do -- 4 colours to choose
                        local col = cols[i]
                        if col ~= nil then
                                if type(col) ~= "table" and type(col) ~= "string" then
                                        error("Expecting table or string for coloured part "..i..", class \""..persistent.className.."\"")
                                end
                                while type(col) == "string" do
                                        local col2 = carcols[col]
                                        if col2==nil then
                                                error("Class \""..persistent.className.."\" could not find colour \""..col.."\"")
                                        end
                                        if type(col2) ~= "table" and type(col2) ~= "string" then
                                                error("Expecting table or string looking up car colour table with name\""..col.."\"")
                                        end
                                        col = col2
                                end
                                local diff = colour_ensure_vector3(col[1])
                                local met = col[2] or 0.5
                                local spec = colour_ensure_vector3(col[3]) or vector3(1,1,1)
                                persistent.instance.gfx:setPaintColour(i-1, diff, met, spec)
                        end
                end
        end;
        setFade=function(persistent, fade)
                local instance = persistent.instance
                if instance.gfx then
                        instance.gfx.fade = fade
                end
                if instance.lights then
                        for k,v in pairs(instance.lights) do
                                v.fade = fade
                        end
                end
        end;
        deactivate=function(persistent)
                local instance = persistent.instance
                --echo("Deactivating: "..persistent.name.." ("..persistent.className..")")
                persistent.pos = persistent.spawnPos
                instance.gfx = safe_destroy(instance.gfx)
                if instance.lights then
                        for k,v in pairs(instance.lights) do
                                instance.lights[k] = safe_destroy(v)
                                if instance.lightCallbacks[k] then
                                        --env:removeClockCallback(instance.lightCallbacks[k])
                                        env.tickCallbacks:removeByName(("lights_callback_"..k))
                                        instance.lightCallbacks[k] = nil
                                end
                        end
                end
        end;
        reload=function(persistent)
                persistent:reloadDiskResources();
        end;
        ignite=function() end;

        getStatistics = function (persistent)
                local instance = persistent.instance
                local gfx = instance.gfx
    
                local tot_triangles, tot_batches = gfx.triangles, gfx.batches

                echo("Mesh: "..gfx.meshName)

                echo(" Triangles: "..gfx.triangles)
                echo(" Batches: "..gfx.batches)

                return tot_triangles, tot_batches
        end;

}


-----------------------
-- REGULAR CHASE CAM --
-----------------------

-- to use these functions, persistent must have a boomLengthMin and Max fields.
-- instance must have boomLengthSelected initialised to something sensible.
-- persistent must be at least of type ColClass
-- 

function regular_chase_cam_zoom_in(persistent)
    local instance = persistent.instance
    instance.boomLengthSelected = clamp(instance.boomLengthSelected*0.83, persistent.boomLengthMin, persistent.boomLengthMax)
end

function regular_chase_cam_zoom_out(persistent)
    local instance = persistent.instance
    instance.boomLengthSelected = clamp(instance.boomLengthSelected*1.2, persistent.boomLengthMin, persistent.boomLengthMax)
end

--[[
-- FOV Scale Trick
if persistent.fovScale then
    local fovPlot = Plot {
        [0] = debug_cfg.FOV;
        [30] = debug_cfg.FOV+25;
        [30.0001] = debug_cfg.FOV+25;
    }
    gfx_option("FOV", fovPlot[self.speedoSpeed])
end
]]
--[[
-- top down cam
    --  local vehicle_point = instance.body.worldOrientation * V_FORWARDS
    --  if vehicle_point.x~=0 or vehicle_point.y~=0 then
    --      player_ctrl.camDir = quat(V_FORWARDS, vehicle_point*vector3(1,1,0))*Q_DOWN
    --  end
    --  player_ctrl.camPos = instance.camAttachPos + V_UP*player_ctrl.boomLength
]]

function regular_chase_cam_update(persistent)

    local instance = persistent.instance

    local body = instance.body

    local vehicle_bearing, vehicle_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
    local vehicle_vel = body.linearVelocity

    -- modify the player_ctrl.camPitch and player_ctrl.camYaw to track the direction a vehicle is travelling
    if user_cfg.vehicleCameraTrack and persistent.cameraTrack and seconds() - player_ctrl.lastMouseMoveTime > 1  and #vehicle_vel > 5 then
    
        player_ctrl.camPitch = lerp(player_ctrl.camPitch, player_ctrl.playerCamPitch + vehicle_pitch, 0.1)
        
        -- test avoids degenerative case where x and y are both 0 
        -- if we are looking straight down at the car then the yaw doesn't really matter
        -- you can't see where you are going anyway
        if math.abs(player_ctrl.camPitch) < 80 then
                --local new_cam_rel = self.camFocus - last_cam_pos
                local ideal_yaw = yaw(vehicle_vel.x, vehicle_vel.y)
                local current_yaw = player_ctrl.camYaw
                if math.abs(ideal_yaw - current_yaw) > 180 then
                    if ideal_yaw < current_yaw then
                        ideal_yaw = ideal_yaw + 360
                    else
                        current_yaw = current_yaw + 360
                    end 
                end 
                local new_yaw = lerp(player_ctrl.camYaw, ideal_yaw, 0.1) % 360
                    
                player_ctrl.camYaw = new_yaw
        end     
        player_ctrl.camDir = quat(player_ctrl.camYaw,V_DOWN) * quat(player_ctrl.camPitch,V_EAST)
    end 
    
    player_ctrl.camFocus = instance.camAttachPos
    local boom_length = math.max(persistent.boomLengthMin, cam_box_ray(player_ctrl.camFocus, player_ctrl.camDir, instance.boomLengthSelected, player_ctrl.camDir*V_BACKWARDS, body))
    player_ctrl.camPos = player_ctrl.camFocus + player_ctrl.camDir * vector3(0, -boom_length, 0)

end

ColClass = extends (BaseClass) {
        receiveImpulse = function (persistent, impulse, wpos)
                if persistent.health and persistent.impulseDamageThreshold then
                        --if impulse > 0 then
                        --        --echo(persistent.name, impulse, pos, poso)
                        --        if (not other.owner.destroyed) and other.owner.className == "/vehicles/Evo" then
                        --                --echo("BOUNCE!", impulse, norm, poso)
                        --                --other:impulse(-impulse * norm, pos)
                        --                persistent:receiveDamage(20000)
                        --        end
                        --end
                        local damage = #impulse
                        if damage > persistent.impulseDamageThreshold then
                                local volume = damage / persistent.impulseDamageThreshold - 1
                                audio_play("/common/sounds/collision.wav", wpos, volume, 3, 1, 1+math.random()*0.3)
                                persistent:receiveDamage(damage)
                        end
                end
        end;
        init = function (persistent)
                local class_name = persistent.className
                local colMesh = persistent.colMesh or class_name..".gcol"
                persistent:addDiskResource(colMesh)
                BaseClass.init(persistent)
        end;
        activate=function (persistent,instance)
                if BaseClass.activate(persistent,instance) then
                        return true
                end
                local colMesh = persistent.colMesh or persistent.className..".gcol"
                --echo("adding: "..tostring(persistent).." with "..colMesh)
                local body = physics_body_make(
                        colMesh,
                        persistent.spawnPos,
                        persistent.rot or quat(1,0,0,0)
                )
                body.owner = persistent;
                instance.body = body
                if persistent.floating then
                        instance.body:deactivate()
                end
                instance.camAttachPos = vector3(0,0,0)
                -- this causes an alloc so do them here where the code is cold
                instance.body.updateCallback = function (p,q)
                        instance.camAttachPos = p
                        instance.gfx.localPosition = p
                        instance.gfx.localOrientation = q
                        persistent.pos = p
                end
                persistent.instance.health = persistent.health
                --persistent.health = persistent.health or 10000000000
                --persistent.impulseDamageThreshold = persistent.impulseDamageThreshold or 10000
                if persistent.instance.health and persistent.impulseDamageThreshold then
                        body.collisionCallback = function (life, impulse, other, m, mo,
                                                           pen, pos, poso, norm)
                                persistent:receiveImpulse(impulse * norm, pos)
                        end
                end
                local pobjs = nil -- will hold the procedural objects (if any)
                local pobjs_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                        local pmat = physics:getMaterial(pmatname)
                        if pmat ~= nil and pmat.proceduralObjects ~= nil then
                                for _, proc_obj_name in ipairs(pmat.proceduralObjects) do
                                        local proc_obj = physics:getProceduralObjectClass(proc_obj_name)
                                        if proc_obj == nil then
                                                error ("Physical material \""..pmatname.."\" references unknown procedural object \""..proc_obj_name.."\"")
                                        end
                                        local t = body:scatter(
                                                pmatname,
                                                proc_obj.density,
                                                proc_obj.minSlope,
                                                proc_obj.maxSlope,
                                                proc_obj.minElevation,
                                                proc_obj.maxElevation,
                                                proc_obj.noZ,
                                                proc_obj.rotate,
                                                proc_obj.alignSlope,
                                                proc_obj.seed or math.random(100000)
                                        )
                                        local n = #t
                                        if n > 0 then pobjs = pobjs or { } end -- create a table only if we have to
                                        local ocl = class_get(proc_obj.class)
                                        local zoff = ocl.placementZOffset or 0
                                        for k=0,(n/7-1) do    
                                                local x,y,z       = t[k*7+1], t[k*7+2], t[k*7+3]
                                                local qw,qx,qy,qz = t[k*7+4], t[k*7+5], t[k*7+6], t[k*7+7]
                                                pobjs[pobjs_counter] = object (proc_obj.class) (x,y,z+zoff) { rot=quat(qw,qx,qy,qz) }
                                                pobjs_counter = pobjs_counter + 1
                                        end
                                end
                        end
                end
                instance.pobjs = pobjs
                local pbats = nil -- will hold the procedural objects (if any)
                local pbats_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                        local pmat = physics:getMaterial(pmatname)
                        if pmat.proceduralBatches ~= nil then
                                for i, proc_bat_name in ipairs(pmat.proceduralBatches) do
                                        pbats = pbats or { } -- create a table only if we have to
                                        local pbat = pbats[proc_bat_name]
                                        local proc_bat = physics:getProceduralBatchClass(proc_bat_name)
                                        if pbat == nil then
                                            pbat = gfx_ranged_instances_make(proc_bat.mesh)
                                            pbat.castShadows = proc_bat.castShadows
                                            pbats[proc_bat_name] = pbat
                                        end
                                        body:rangedScatter(
                                                pmatname,
                                                pbat,
                                                proc_bat.density,
                                                proc_bat.minSlope,
                                                proc_bat.maxSlope,
                                                proc_bat.minElevation,
                                                proc_bat.maxElevation,
                                                proc_bat.noZ,
                                                proc_bat.rotate,
                                                proc_bat.alignSlope,
                                                proc_bat.seed or math.random(100000)
                                        )
                                end
                        end
                end
                instance.pbats = pbats
        end;
        deactivate=function(persistent)
                local instance = persistent.instance
                if instance.body then
                        if instance.body.mass > 0 and #(persistent.spawnPos - player_ctrl.camFocus) < persistent.renderingDistance then
                                -- avoid it respawning directly in front of the camera
                                persistent.skipNextActivation = true
                        end
                end
                                
                instance.body = safe_destroy(instance.body)
                local pobjs = instance.pobjs
                if pobjs ~= nil then
                        for _,v in ipairs(pobjs) do
                                if not v.destroyed then v:destroy() end
                        end
                end
                instance.pobjs = nil
                local pbats = instance.pbats
                if pbats ~= nil then
                        for _,v in ipairs(pbats) do
                                safe_destroy(v)
                        end
                end
                instance.pbats = nil
                BaseClass.deactivate(persistent, instance)
                return persistent.temporary -- don't respawn if it was from a pile
        end;

        getStatistics = function (persistent)
                local tot_triangles, tot_batches = BaseClass.getStatistics(persistent)
                
                local instance = persistent.instance
                local body = instance.body

                if instance.pbats then
                    for proc_bat_name, pbat in pairs(instance.pbats) do
                            echo("  Procedural batch: "..proc_bat_name)
                            echo("    Instances: "..pbat.instances)
                            echo("    Triangles: "..pbat.triangles)
                            echo("    Batches: "..pbat.batches)
                            tot_triangles = tot_triangles + pbat.triangles
                            tot_batches = tot_batches + pbat.batches
                    end
                end

                return tot_triangles, tot_batches
        end;

        getSpeed = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.persistent.name) end
                local rb = persistent.instance.body
                return #rb.linearVelocity
        end;
        flip = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                if rb.mass == 0 then return end
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0)) * quat(0,0,1,0);
                rb.worldPosition = rb.worldPosition + vector3(0,0,1)
                rb:activate() 
        end;
        toggleProceduralBatches = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local pbats = persistent.instance.pbats
                if pbats == nil then return end
                echo("Procedural batches of \""..tostring(persistent).."\" toggled ")
                for k,pbat in pairs(pbats) do
                        pbat.enabled = v
                end
        end;
        realign = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0))
                rb.worldPosition = rb.worldPosition + vector3(0,0,3);
                rb.angularVelocity = V_ZERO
                rb.linearVelocity = V_ZERO
                rb:activate() 
        end;
        special=function(persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0));
                rb.worldPosition = rb.worldPosition - vector3(0,0,3);
                rb.angularVelocity = V_ZERO
                rb.linearVelocity = V_ZERO
                rb:activate() 
        end;
        beingFired=function(persistent)
        end;
        receiveDamage=function(persistent, damage)
                local new_health = persistent.instance.health - damage
                if persistent.instance.health <= 0 then return end
                if verbose_receive_damage then
                        echo(persistent.name.." says OW! "..damage.." ["..new_health.." / "..persistent.health.." = "..math.floor(100*new_health/persistent.health).."%]")
                end
                persistent.instance.health = new_health
                if persistent.instance.health <= 0 then
                        persistent:noHealthLeft()
                end
        end;
        receiveBlast = function (persistent, impulse, wpos, damage_impulse)
                --echo(persistent.name.." caught in explosion", impulse, wpos)
                damage_impulse = damage_impulse or impulse
                persistent.instance.body:impulse(impulse, wpos)
                persistent:receiveImpulse(damage_impulse, wpos)
        end;
        receiveHeat = function (persistent, wpos, amount)
        end;
        onExplode = function (persistent)
                local xi = persistent.explodeInfo
                if xi and xi.deactivate then persistent:deactivate() end
        end;
        explode = function (persistent)
                local instance = persistent.instance
                if instance.exploded then return end
                local xi = persistent.explodeInfo
                if xi then
                        instance.exploded = true
                        if instance.health and instance.health > 0 then instance.health = 0 end
                        explosion(persistent.pos + (xi.offset or vector3(0,0,0)), xi.radius or 4, xi.force)
                        persistent:onExplode()
                end
        end;
        noHealthLeft = function(persistent)
                if persistent.explodeInfo then persistent:explode() end
        end;
        ignite=function(persistent, pname, pos, mat, fertile_life)
                --echo("igniting: "..tostring(persistent))
                if persistent.instance.body.mass==0 then
                        flame_ignite(pname, pos, mat, fertile_life)
                end
        end;
}

PileClass = {
        renderingDistance=400;
        init = function (persistent)
                -- iterate over the guys i will spawn to see what their "advance prepares" should be
                --echo("Initialising: "..persistent.name.." ("..persistent.className..")")
        end;
        activate=function (persistent, instance)
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                instance.children = {}
                for k,v in ipairs(persistent.class.dump) do
                        local oclass, opos, otab = unpack(v)
                        if persistent.rot then
                                opos = persistent.rot * opos
                                otab.rot = persistent.rot * (otab.rot or Q_ID)
                        end
                        otab.temporary = true
                        opos = persistent.spawnPos + opos
                        instance.children[k] = object_add(oclass,opos,otab)
                end
        end;
        deactivate=function(persistent)
                --echo("Deactivating: "..persistent.name.." ("..persistent.className..")")
                -- nothing to do i think
                local instance = persistent.instance
                for k,v in ipairs(instance.children) do
                        if not v.activated then
                                v:destroy()
                        end
                end
        end;
}

ProcPileClass = {
        renderingDistance=400;
        init = function (persistent)
                -- iterate over the guys i will spawn to see what their "advance prepares" should be
                --echo("Initialising: "..persistent.name.." ("..persistent.className..")")
        end;
        spawnObjects = function() end;
        activate=function (persistent, instance)
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                instance.children = {}
                local counter = 1
                persistent:spawnObjects(function(oclass,opos,otab)
                        if persistent.rot then
                                opos = persistent.rot * opos
                                otab.rot = persistent.rot * (otab.rot or Q_ID)
                        end
                        otab.temporary = true
                        opos = persistent.spawnPos + opos
                        instance.children[counter] = object_add(oclass,opos,otab)
                        counter = counter + 1
                end)
        end;
        deactivate=function(persistent)
                --echo("Deactivating: "..persistent.name.." ("..persistent.className..")")
                -- nothing to do i think
                local instance = persistent.instance
                for k,v in ipairs(instance.children) do
                        if not v.activated then
                                v:destroy()
                        end
                end
        end;
}

function dump_object_line(persistent)
        local x,y,z = unpack(persistent.spawnPos)
        return ("object \"%s\" (%f,%f,%f) {name=\"%s\", rot=%s}"):format(persistent.className, x,y,z, persistent.name, tostring(persistent.rot))
end

