-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading player_ctrl.lua")

if playing_binds ~= nil then playing_binds:destroy() end
playing_binds = InputFilter(150, "playing_binds")

if playing_actor_binds ~= nil then playing_actor_binds:destroy() end
playing_actor_binds = InputFilter(170, "playing_actor_binds")

if playing_vehicle_binds ~= nil then playing_vehicle_binds:destroy() end
playing_vehicle_binds = InputFilter(171, "playing_vehicle_binds")

if playing_ghost_binds ~= nil then playing_ghost_binds:destroy() end
playing_ghost_binds = InputFilter(172, "playing_ghost_binds")

playing_binds.mouseCapture = true

playing_actor_binds.enabled = false
playing_vehicle_binds.enabled = false


if ghost ==  nil then
ghost = {
    noClip = false,
    fast = false,
    speedSlow = 3,
    speedFast = 100,
    forwards = 0,
    backwards = 0,
    left = 0,
    right = 0,
    up = 0,
    down = 0,

    -- TODO: move these into some sort of "debug weapon"
    grabThreshold = 200, --max mass we can lift

    shootFast = 100,
    shootSlow = 10,
    shootSpin = vector3(0,0,30),

    prodding = false;

}
else
    physics.stepCallbacks:removeByName("Prod")
end

physics.stepCallbacks:insert("Prod", function (elapsed)
    if ghost.prodding then
        local dist, body, nx, ny, nz, _ = cam_ray()
        if dist~= nil then
            local dir = player_ctrl.camDir*V_FORWARDS
            local pos = player_ctrl.camPos + dist * dir
            body:impulse(elapsed * (ghost.fast and 100 or 10)*body.mass * dir, pos)
        end
    end
end)


local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function ghost:updateGhost (elapsed)
    local right = self.right - self.left
    local forwards = self.forwards - self.backwards
    local up = self.up - self.down

    local active_speed = self.fast and self.speedFast or self.speedSlow

    local dist = active_speed * elapsed

    local cam_pos = player_ctrl.camPos

    -- we now know how far to move (dist)
    -- but not in which directions

    local d = player_ctrl.camDir * vector3(dist*right, dist*forwards, 0) + vector3(0,0,dist*up)
    

    local fraction, n = ghost_cast(cam_pos, d, 1)

    if not self.noClip and fraction ~= nil then
        local n = norm(n)
        d = d - dot(d,n) * n
        local fraction2, n2 = ghost_cast(cam_pos, d, .95)
        if fraction2 ~= nil then
            n2 = norm(n2)
            d = d - dot(d,n2) * n2
            local fraction3, n3 = ghost_cast(cam_pos, d, .9)
            if fraction3 ~= nil then
                return 0
            end
        end
    end

    -- splendid, now let's move
    cam_pos = cam_pos + d
    player_ctrl.camFocus = cam_pos
    player_ctrl.camPos = cam_pos

    player_ctrl.speedoPos = cam_pos
    player_ctrl.speedoSpeed = #d / elapsed
end

function ghost:pickDrive()
        local obj = pick_obj_safe()
        if obj == nil then return end
        player_ctrl:beginControlObj(obj)
end

--[[
function ghost:grab()
    local function grab_callback(elapsed)
        local obj = self.grabbedObj
        if obj == nil then
            echo "dropping object"
            physics.stepCallbacks:removeByName("grabbedObj")
            return true
        end
            
        local target = (player_ctrl.camPos + 3*norm(player_ctrl.camDir*V_FORWARDS))
        local delta = target - obj.worldPosition
                    
        if #delta < 5 then
            obj.linearVelocity = V_ZERO
        else
            obj:force(-physics_get_gravity() * obj.mass, obj.worldPosition)
        end
        
        if #delta > 0.1 then
                obj:force(delta * 1000 * obj.mass, obj.worldPosition)
        end
        
        if input_filter_pressed("left") then
            obj.angularVelocity = V_ZERO
            obj.worldOrientation = slerp(obj.worldOrientation, player_ctrl.camDir, 0.01)
        end
        
        return true
    end

    if self.grabbedObj ~= nil then
        self.grabbedObj = nil
        physics.stepCallbacks:removeByName("grabbedObj")
        return
    end
    
    local obj = pick_obj_safe()
    obj = obj and obj.instance.body or nil
    if obj and obj.mass ~= 0 and obj.mass < self.grabThreshold then
            self.grabbedObj = obj
            physics.stepCallbacks:insert("grabbedObj", grab_callback)
    end
end
]]

if player_ctrl == nil then
    player_ctrl = {
    	mouseRel = vec(0,0), --this holds relative mouse position change from the last update
    	
    	mouseTotalRel = vec(0,0), --this holds summ of all mouse position changes
    	--also this guys (above) are reset when player gets in/out of any controllable object
    
        camYaw = 0,
        camPitch = 0,
        playerCamPitch = 0,
        camDir = quat(1,0,0,0), -- pretty much always derived from pitch and yaw
        lastMouseMoveTime = 0,

        -- these guys updated by object/ghost control logic
        camPos = vector3(0,0,0),
        camFocus = vector3(0,0,0),
        speedoPos = vector3(0,0,0),
        speedoSpeed = 0,

        boomLength = 8,
        currentBoomLength = 8,


    }

end

playing_binds.mouseMoveCallback = function (rel)
    local sens = user_cfg.mouseSensitivity

    player_ctrl.mouseRel = rel * sens
    
	player_ctrl.mouseTotalRel = player_ctrl.mouseTotalRel + rel*sens

    local inv = user_cfg.mouseInvert and -1 or 1
    
    player_ctrl.camYaw = (player_ctrl.camYaw + rel.x*sens) % 360
    player_ctrl.camPitch = clamp(player_ctrl.camPitch + inv*rel.y*sens, -90, 90)
    player_ctrl.playerCamPitch = player_ctrl.camPitch

    player_ctrl.camDir = quat(player_ctrl.camYaw,V_DOWN) * quat(player_ctrl.camPitch,V_EAST)

    player_ctrl.lastMouseMoveTime = seconds()
end


function player_ctrl:update (elapsed)
    local obj = player_ctrl.controlObj

    if obj == nil then
        ghost:updateGhost(elapsed)
    else
        if obj.activated == false then
            self:abandonControlObj()
            return
        end
        -- should update camPos, camFocus, (maybe camYaw, camPitch, camDir), speedoPos, speedoSpeed
        obj:controlUpdate(elapsed)
    end
end

-- Controllable objects all have the field controllable set to one of the
-- strings "ACTOR" or "VEHICLE", indicating the input filter (bindings) to use.
-- controBegin() can return false, indicating that this instance is no-longer controllable (perhaps damaged).
-- controlAbandon() is also called


function player_ctrl:beginControlObj(obj)
    if not obj.activated then error("Can't control a deactivated object") end
    local bindings = obj.controllable
    if bindings == nil then return end
    if obj:controlBegin() then
        if bindings == "ACTOR" then
            playing_ghost_binds.enabled = false
            playing_vehicle_binds.enabled = false
            player_ctrl.controlObj = obj
            playing_actor_binds.enabled = true
        elseif bindings == "VEHICLE" then
            playing_ghost_binds.enabled = false
            playing_actor_binds.enabled = false
            player_ctrl.controlObj = obj
            playing_vehicle_binds.enabled = true
        else
            error("Unrecognised kind of bindings: "..tostring(bindings))
        end
    	player_ctrl.mouseTotalRel = vec(0,0)
    end
end

function player_ctrl:abandonControlObj()
    local obj = self.controlObj
    if obj and obj.activated then
            obj:controlAbandon()
    end
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false
    self.controlObj = nil
    playing_ghost_binds.enabled = true
    self.mouseTotalRel = vec(0,0)
end

-- tell me how far in a given direction i can place the camera without it clipping anything
function cam_box_ray(pos, cam_q, dist, dir, ...)
    local rect = gfx_window_size_in_scene()
    local tolerance = 0.05 -- this is the distance that we use to account for differences between colmesh and gfx mesh, as well as inaccuracies in the algorithm itself
    local box = vector3(rect.x + tolerance, tolerance, rect.y + tolerance) -- y is the direction of the ray
    local fraction = physics_sweep_box(box, cam_q, pos, (dist-tolerance/2)*dir, true, 1, ...) or 1
    return dist * fraction + tolerance/2 + gfx_option("NEAR_CLIP")
end





function player_ctrl:yawQuat()
        return quat(self.camYaw,V_DOWN);
end








function fire (type)
        local speed = ghost.fast and ghost.shootFast or ghost.shootSlow
        local spin = input_filter_pressed("Alt") and ghost.shootSpin
        fire_extended(speed,type,spin)
end

function introduce_obj (type)
        if input_filter_pressed("Ctrl") then
                fire(type)
        else
                place(type)
        end
end


function player_ctrl:warp(pos, orientation)
        if pos ~= nil then
                self.camFocus = pos
                self.camPos = pos
        end
        if orientation ~= nil then
                self.camDir = orientation
        end
end

function player_ctrl:retWarp()
        return "player_ctrl:warp("..tostring(self.camPos)..","..tostring(self.camDir)..")"
end


function cam_ray()
        local d,b,n,m = physics_cast(player_ctrl.camPos, player_ctrl.camDir * (8000 * V_FORWARDS), true, 0)
        if d == nil then return nil end
        return d * 8000, b, n, m
end

function pick_pos(bias, safe)
        local dist,_,normal = cam_ray()
        if dist == nil then
                if safe then return nil end
                error("Not pointing at anything",2)
        end
        local r = player_ctrl.camPos + player_ctrl.camDir*(dist*V_FORWARDS)
        if bias then r = r + bias * normal end
        return r
end

function pick_dist()
        return (cam_ray())
end

function pick_obj_safe()
        local _, body = cam_ray()
        if body == nil then return nil end
        return body.owner
end     

function pick_obj()
        local obj = pick_obj_safe()
        if obj == nil then
                error("Not pointing at anything",2)
        end
        return obj
end             

function fire_extended(v,t,spin)
        v = v or 40
        t = t or "/common/props/debug/crates/Crate"
        local q = player_ctrl.camDir
        local x,y,z = unpack(player_ctrl.camPos)
        local o = object (t) (x,y,z) {rot=q, temporary=true}
        o:activate() -- need this so we can add the linear velocity
        -- may have been an error when activating
        if o.activated then
                o.instance.body.linearVelocity = q * vector3(0,v,0)
                if spin then
                        o.instance.body.angularVelocity = q * spin
                end
                o:beingFired()
        end
end

function place(class,height)
        local cl = class_get(class)
        height = (height or 0) + (cl.placementZOffset or 0)
        local x,y,z = unpack(pick_pos())
        local rot = quat(player_ctrl.camYaw, V_DOWN)*(cl.placementRandomRotation and quat(math.random(360),V_UP) or Q_ID)
        return object (class) (x,y,z+height) {rot=rot, placed=true}
end

function stack(pos,q,height,class)
        pos = pos or pick_pos()
        q = q or player_ctrl:yawQuat()
        object "/common/props/debug/crates/Stack" (unpack(pos)) {rot=q, brickClass=class, height=height}
end             
                
function wall(pos,q,x_min,x_max,height)
        pos = pos or pick_pos()
        q = q or player_ctrl:yawQuat()
        object "/common/props/debug/crates/Wall" (unpack(pos)) {rot=q, xMin=x_min, xMax=x_max, height=height}
end                     

function bowling(class,space,rows,pos,q)
        pos = pos or pick_pos()
        q = q or player_ctrl:yawQuat()
        object "/common/props/bowling/Deck" (unpack(pos)) {rot=q, pinClass=class, space=space, rows=rows}
end

function jenga(h,pos,q)
        pos = pos or pick_pos()
        q = q or player_ctrl:yawQuat()
        object "/common/props/debug/JengaStack" (unpack(pos)) {rot=q, height=h}
end

function cone_line (len, sep, pos, q)
        len = len or 50
        sep = sep or 10
        pos = pos or pick_pos()
        q = q or player_ctrl:yawQuat()
        local inc = sep * (q * V_FORWARDS)
        local dist = 0
        local classname = "/common/props/street/TrafficCone"
        local zoff = class_get(classname).placementZOffset
        while dist <= len do
                object (classname) (pos.x, pos.y, pos.z+zoff) { placed=true }
                dist = dist + sep
                pos = pos + inc
        end
end

function clear_temporary()
        for _,v in ipairs(object_all()) do
                if v.temporary then
                        v:destroy()
                end
        end
end

function clear_placed()
        for _,v in ipairs(object_all()) do
                if v.placed then
                        v:destroy()
                end
        end
end

