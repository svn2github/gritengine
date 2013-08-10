-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading player_ctrl.lua")

if player_ctrl == nil then
	player_ctrl = {
		fast = false,

		speedSlow = 3,
		speedFast = 100,

		forwards = 0,
		backwards = 0,
		left = 0,
		right = 0,
		up = 0,
		down = 0,

		grabThreshold = 200, --max mass we can lift

		ghostMode = false,

		shootFast = 100,
		shootSlow = 10,
		shootSpin = vector3(0,0,30),

		boomLength = 8,
		currentBoomLength = 8,
		boomRayRadius = 0.1,
		camYaw = 0,
		camPitch = 0,
		playerCamPitch = 0,
		camPos = vector3(0,0,0),
		camFocus = vector3(0,0,0),
		camDir = quat(1,0,0,0),
		
		speedoPos = vector3(0,0,0),
		speedoSpeed = 0,

		mode = 0, -- modes are 0 (ghost)  1 (drive)   2 (foot)
		ghostBinds = BindTable.new(),
		driveBinds = BindTable.new(),
		footBinds = BindTable.new(),

		lastMouseMoveTime = 0
	}

else
	ui.pressCallbacks:removeByName("player_ctrl")
	ui.pointerGrabCallbacks:removeByName("player_ctrl")
	player_ctrl.speedo = safe_destroy(player_ctrl.speedo)
end

ui.pressCallbacks:insert("player_ctrl",function (key)
	if player_ctrl.mode == 0 then
		return player_ctrl.ghostBinds:process(key)
	elseif player_ctrl.mode == 1 then
		return player_ctrl.driveBinds:process(key)
	elseif player_ctrl.mode == 2 then
		return player_ctrl.footBinds:process(key)
	else
		error("player_ctrl.mode unrecognised! ("..player_ctrl.mode..")")
	end
end)

ui.pointerGrabCallbacks:insert("player_ctrl",function (rel_x,rel_y)

	local sens = user_cfg.mouseSensitivity
	local inv = user_cfg.mouseInvert and -1 or 1

	player_ctrl.camYaw = (player_ctrl.camYaw + rel_x*sens) % 360
	player_ctrl.camPitch = clamp(player_ctrl.camPitch + inv*rel_y*sens, -90, 90)
	player_ctrl.playerCamPitch = player_ctrl.camPitch

	player_ctrl.camDir = quat(player_ctrl.camYaw,V_DOWN) * quat(player_ctrl.camPitch,V_EAST)

	player_ctrl.lastMouseMoveTime = seconds()
end)

local function ghost_cast (pos, ray, radius)
	local fraction, _, n = physics_sweep_sphere(radius*.15, pos, ray, true, 1)
	return fraction, n
end

function player_ctrl:update (elapsed)

	-----------
	-- GHOSTING
	-----------
	if self.mode == 0 then
		local active_speed
		-- STRAFE
		do
			local right = self.right - self.left
			local forwards = self.forwards - self.backwards
			local up = self.up - self.down

			active_speed = self.fast and self.speedFast or self.speedSlow

			local dist = active_speed * elapsed

			-- we now know how far to move (dist)
			-- but not in which directions

			local d = self.camDir * vector3(dist*right, dist*forwards, 0) + vector3(0,0,dist*up)
			

			local fraction, n = ghost_cast(self.camFocus, d, 1)

			if not self.ghostMode and fraction ~= nil then
				local n = norm(n)
				d = d - dot(d,n) * n
				local fraction2, n2 = ghost_cast(self.camFocus, d, .95)
				if fraction2 ~= nil then
					n2 = norm(n2)
					d = d - dot(d,n2) * n2
					local fraction3, n3 = ghost_cast(self.camFocus, d, .9)
					if fraction3 ~= nil then
						echo("nowhere to go")
						return 0
					end
				end
			end
			
			-- splendid, now let's move
			self.camFocus = self.camFocus + d
			self.camPos = self.camFocus

			self.speedoPos = self.camFocus
			self.speedoSpeed = #d / elapsed
		end

	----------------------
	-- CONTROLLING VEHICLE
	----------------------
	elseif self.mode == 1 then

		local vehicle = self.vehicle

		if vehicle.activated == false then
			self:abandonVehicle()
			return
		end
		
		local bearing, vehicle_pitch = yaw_pitch(vehicle.instance.body.worldOrientation * V_FORWARDS)

		if user_cfg.topDownCam or vehicle.topDownCam then --topdown cam
			local vehicle_point = vehicle.instance.body.worldOrientation * V_FORWARDS
			if vehicle_point.x~=0 or vehicle_point.y~=0 then
				self.camDir = quat(V_FORWARDS, vehicle_point*vector3(1,1,0))*Q_DOWN
			end
			self.camPos = vehicle.instance.camAttachPos + V_UP*self.boomLength
		else -- classic cam
			self:handleChaseCam(vehicle_pitch, vehicle.instance.camAttachPos, self.vehicle.instance.body)
		end

		local x,y,z = unpack(self.camPos)
		self.speedoPos = self.camPos

		if vehicle.getSpeed ~= nil then

			self.speedoSpeed = vehicle:getSpeed()
		
			-- FOV Scale Trick
			if vehicle.fovScale then
				local fovPlot = Plot {
					[0] = debug_cfg.FOV;
					[30] = debug_cfg.FOV+25;
					[30.0001] = debug_cfg.FOV+25;
				}
				gfx_option("FOV", fovPlot[self.speedoSpeed])
			end
			
		end

	----------
	-- ON FOOT
	----------
	elseif self.mode == 2 then

		local actor = self.actor

		if actor.activated == false then
			self:abandonVehicle()
			return
		end

		local bearing, pitch = yaw_pitch(actor.instance.body.worldOrientation * V_FORWARDS)

		self:handleChaseCam(pitch, actor.instance.camAttachPos, self.actor.instance.body)

		self.speedoPos = self.camPos
		self.speedoSpeed = actor:getSpeed()

	end
end

function player_ctrl:grab()
    local function grab_callback(elapsed)
        local obj = self.grabbedObj
        if obj == nil then
            echo "dropping object"
            physics.stepCallbacks:removeByName("grabbedObj")
            return true
        end
            
        local target = (self.camPos + 3*norm(self.camDir*V_FORWARDS))
        local delta = target - obj.worldPosition
                    
        if #delta < 5 then
            obj.linearVelocity = V_ZERO
        else
            obj:force(-physics_get_gravity() * obj.mass, obj.worldPosition)
        end
        
        if #delta > 0.1 then
                obj:force(delta * 1000 * obj.mass, obj.worldPosition)
        end
        
        if ui:down("left") then
            obj.angularVelocity = V_ZERO
            obj.worldOrientation = slerp(obj.worldOrientation, self.camDir, 0.01)
        end
        
        return true
    end

	if self.grabbedObj ~= nil or self.mode ~= 0 then -- use another mode, when implemented
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

-- tell me how far in a given direction i can place the camera without it clipping anything
-- also tell me the normal so i can use that to slide along obstacles
function player_ctrl:camRay(pos, q, ray, min_dist, ...)
    local nc = gfx_option("NEAR_CLIP")
    local rect = gfx_window_size_in_scene()
    local tolerance = 0.05 -- this is the distance that we use to account for differences between colmesh and gfx mesh, as well as inaccuracies in the algorithm itself
    local box = vector3(rect.x + tolerance, tolerance, rect.y + tolerance) -- y is the direction of the ray
    local fraction, normal = physics_sweep_box(box, q, pos, ray, true, 1, ...)
    if fraction == nil then return end
    return math.max(min_dist, (#ray * fraction + tolerance/2 + nc))
end

function player_ctrl:handleChaseCam(pitch, cam_attach_pos, ...)

    local last_cam_focus = self.camFocus
    self.camFocus = cam_attach_pos


    -- handle chase cam

    local last_cam_pos = last_cam_focus + self.camDir * vector3(0,-self.currentBoomLength,0)
    local new_cam_rel = self.camFocus - last_cam_pos

    self.currentBoomLength = clamp(#new_cam_rel, self.boomLength, self.boomLength)

    if self.mode == 1 and user_cfg.vehicleCameraTrack and player_ctrl.vehicle.cameraTrack and seconds() - self.lastMouseMoveTime > 1 then

        self.camPitch = lerp(self.camPitch, self.playerCamPitch + pitch, 0.1)
        -- test avoids degenerative case where x and y are both 0
        -- if we are looking straight down at the car then the yaw doesn't really matter
        -- you can't see where you are going anyway
        if math.abs(self.camPitch) < 80 then
                self.camYaw = yaw(new_cam_rel.x, new_cam_rel.y)
        end
        self.camDir = quat(self.camYaw,V_DOWN) * quat(self.camPitch,V_EAST)
        --echo(self.camYaw, self.camPitch, self.camDir)
    end


    self.currentBoomLength = self:camRay(self.camFocus, self.camDir, self.camDir * vector3(0,-self.currentBoomLength,0), 0.5, ...) or self.currentBoomLength

    self.camPos = self.camFocus + self.camDir * vector3(0, -self.currentBoomLength, 0)

end

function player_ctrl:pickDrive()
        local obj = pick_obj_safe()
        if obj == nil then return end
        self:drive(obj)
end

function player_ctrl:drive(subject)
        if not subject.activated then error("Can't drive a vehicle that isn't activated") end
        if subject.instance.isActor then
                self.actor = subject
                self.mode = 2
                self.camFocus = subject.instance.camAttachPos
        elseif subject.instance.canDrive then
                self.vehicle = subject
                self.mode = 1
                self.camFocus = subject.instance.camAttachPos
                local v_pitch = pitch((subject.instance.body.worldOrientation * V_FORWARDS).z)
                self.playerCamPitch = self.playerCamPitch - v_pitch
        end
end

function player_ctrl:abandonVehicle()
        if self.mode == 2 then
                local actor = self.actor
                if actor and actor.activated then
                        if actor.abandon ~= nil then
                                actor:abandon()
                        end
                end
                self.actor = nil
        elseif self.mode == 1 then
                local vehicle = self.vehicle
                if vehicle and vehicle.activated then
                        if vehicle.abandon ~= nil then
                                vehicle:abandon()
                        end
                        local v_pitch = pitch((vehicle.instance.body.worldOrientation * V_FORWARDS).z)
                        self.playerCamPitch = self.playerCamPitch + v_pitch
                end
                self.vehicle = nil
        end
        self.mode = 0
        self.camFocus = self.camPos
        
        gfx_option("FOV", debug_cfg.FOV) --revert the vehicle FOV scale effect
end

function player_ctrl:zoom()
        if ui:shift() then
                self:zoomOut()
        else
                self:zoomIn()
        end
end

function player_ctrl:zoomIn()
        self.boomLength = clamp(self.boomLength * 0.833333333,0,40)
end

function player_ctrl:zoomOut()
        self.boomLength = clamp(self.boomLength * 1.200000000,0,40)
end


function fire (type)
        local speed = player_ctrl.fast and player_ctrl.shootFast or player_ctrl.shootSlow
        local spin = ui:alt() and player_ctrl.shootSpin
        fire_extended(speed,type,spin)
end

function introduce_obj (type)
        if ui:ctrl() then
                fire(type)
        else
                place(type)
        end
end


function player_ctrl:flush()
        if self.mode == 0 then
                self.ghostBinds:flush()
        elseif self.mode == 1 then
                self.driveBinds:flush()
        elseif self.mode == 2 then
                self.footBinds:flush()
        else
                error("player_ctrl.mode unrecognised! ("..self.mode..")")
        end
end


function player_ctrl:toggleChaseCamTrack()
end

function player_ctrl:yawQuat()
        return quat(self.camYaw,V_DOWN);
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

