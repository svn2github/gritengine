
debug_game_mode = debug_game_mode or {
    camYaw = 0;
    camPitch = 0;
    lastMouseMoveTime = 0;
	spawnPos=vec3(-21, -22, 27);
	spawnOrientation = quat(0.86, -0.3, 0.13, -0.37);
	currentMap = nil;
	
	debugMode = false,
	noClip = false,
	fast = false,
	mouseCapture = false,
	speedSlow = 3,
	speedFast = 100,
	forwards = 0,
	backwards = 0,
	left = 0,
	right = 0,
	ascend = 0,
	descend = 0,	
}

current_map = current_map or nil

function debug_game_mode:openMap(map_file)
	self.currentMap = nil
	self.currentMap = GritMap.new()

	self.currentMap:open(map_file)
	current_map = self.currentMap
end;

function debug_game_mode:load_map(map_file)
	loading_screen.enabled = true
    loading_screen:setMapName('Navigation Demo')
    loading_screen:setStatus('Background loading resources...')

	navigation_debug_option("navmesh_use_tile_colours", true)
	navigation_debug_option("enabled", true)

	self:openMap(`/maps/navigation_demo/navmap.gmap`)
end

function debug_game_mode:toggleBoard(mobj)
    if self.controlObj ~= nil then
        -- Currently controlling an object.  Exit it.
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = false

        self.controlObj:controlAbandon()
        -- When on foot there is no vehicle pitch.
        local v_pitch = pitch((self.controlObj.instance.body.worldOrientation * V_FORWARDS).z)
        self.camPitch = self.camPitch + v_pitch

        self.controlObj = nil

    else
        -- Board object being pointed at, if possible.
        local obj = mobj or pick_obj()
        if obj == nil then return end
        if obj.controllable == "VEHICLE" then
            playing_vehicle_binds.enabled = true
        elseif obj.controllable == "ACTOR" then
            playing_actor_binds.enabled = true
        else
            print("Cannot board object: " .. tostring(obj))
            return
        end
        editor_debug_ghost_binds.enabled = false
        obj:controlBegin()
        self.controlObj = obj
        print('controlObj now '..tostring(obj))
        -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
        -- So we calculate the camPitch necessary for that.
        local v_pitch = pitch((obj.instance.body.worldOrientation * V_FORWARDS).z)
        self.camPitch = self.camPitch - v_pitch
    end
end



function debug_game_mode:init()

	object_all_del()
	
	-- self:load_map()
	
    playing_binds.enabled = true
	playing_actor_binds.enabled = true

	playing_binds:bind("right", function() playing_binds.mouseCapture = true end, function() playing_binds.mouseCapture = false end)
	playing_binds:bind("left",
		function() WeaponEffectManager:primaryEngage(main.camPos, main.camQuat) end,
		function() WeaponEffectManager:primaryDisengage() end
	)

	clock.enabled = true
	compass.enabled = true
	stats.enabled = true
	ticker.text.enabled = true
	
    main.physicsEnabled = true

    playing_binds.mouseCapture = false

    -- self:playerRespawn()

	-- gfx_option("BLOOM_THRESHOLD", 1.5)

	self.info = gfx_hud_text_add(`/common/fonts/Verdana12`)
	self.info.text = "Right mouse: Rotate camera\nLeft Mouse: Use weapon\nMouse Sroll: change weapons"
	self.info.parent = hud_bottom_left
	self.info.position = vec(130, 80)
end

function debug_game_mode:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity
    
    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
    self.playerCamPitch = self.camPitch
        
    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat

    self.lastMouseMoveTime = seconds()
end

function debug_game_mode:receiveButton(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end

    if button == "walkForwards" then
        self.forwards = on_off
    elseif button == "walkBackwards" then
        self.backwards = on_off
    elseif button == "walkLeft" then
        self.left = on_off
    elseif button == "walkRight" then
        self.right = on_off
    elseif button == "walkJump" then
        self.ascend = on_off
    elseif button == "walkCrouch" then
        self.descend = on_off
	elseif button == 'walkRun' then
		self.fast = (state == "+" or state == '=')
	elseif button == "walkZoomIn" then
		if state == '+' then
			WeaponEffectManager:select(WeaponEffectManager:getNext())
		end

	elseif button == "walkZoomOut" then
		if state == '+' then
			WeaponEffectManager:select(WeaponEffectManager:getPrev())
		end

	elseif button == "driveSpecialUp" then
		if state == '+' then
			main.physicsEnabled = not main.physicsEnabled
		end		
	end
end

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function debug_game_mode:frameCallback(elapsed_secs)
	-- Ghosting around
	local right = self.right - self.left
	local forwards = self.forwards - self.backwards
	local ascend = self.ascend - self.descend

	local active_speed = self.fast and self.speedFast or self.speedSlow

	local dist = active_speed * elapsed_secs

	local cam_pos = main.camPos

	-- we now know how far to move (dist)
	-- but not in which directions

	local d = main.camQuat * vec3(dist*right, dist*forwards, 0) + vec3(0, 0, dist*ascend)
	
	if not self.noClip then
		local fraction, n = ghost_cast(cam_pos, d, 1)

		if fraction ~= nil then
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
	end
	-- splendid, now let's move
	cam_pos = cam_pos + d
	main.camPos = cam_pos

    main.streamerCentre = main.camPos
    main.audioCentrePos = main.camPos
    main.audioCentreVel = vec(0, 0, 0);
end

function debug_game_mode:stepCallback(elapsed_secs)

end

function debug_game_mode:destroy()
    playing_binds.enabled = false
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false

	playing_binds:unbind("right")
	playing_binds:unbind("left")
	
	object_all_del()

	safe_destroy(self.info)
end

game_manager:define("Debug Mode", debug_game_mode)
