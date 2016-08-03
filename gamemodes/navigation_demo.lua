navigation_demo = navigation_demo or {
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

function navigation_demo:playerRespawn()

    -- Use loading screen while we go back to spawn pos
    loading_screen.enabled = true
    loading_screen:setProgress(0)
    loading_screen:pump()
    streamer_centre_full(self.spawnPos)

	give_queue_allowance(1 + 1*get_in_queue_size())
	
    local to_go = get_in_queue_size()
    local init_to_go = to_go
    while to_go > 0 do
        to_go = get_in_queue_size()
        loading_screen:setProgress((init_to_go - to_go) / init_to_go)
        loading_screen:pump()
    end
	
    loading_screen:setProgress(1)
    loading_screen:setStatus('Activating objects')
    loading_screen:pump()
    streamer_centre_full(self.spawnPos)

    loading_screen:setStatus('All done')
    loading_screen:pump()
    loading_screen.enabled = false

	main.camPos = self.spawnPos
	
    main.camQuat = self.spawnOrientation
    main.audioCentreVel = vec(0, 0, 0);
    main.audioCentreQuat = quat(1, 0, 0, 0);

    self.camYaw = cam_yaw_angle();
    self.camPitch = quatPitch(main.camQuat);
    self.playerCamPitch = 0;

    env.secondsSinceMidnight = 12 * 60 * 60
	env.clockRate = 0
	
	if current_map ~= nil then
		if navigation_load_navmesh("./maps/navigation_demo/navmap.navmesh") then
			for i = 1, #current_map.aicharacters do
				if not current_map.aicharacters[i].destroyed then
					current_map.aicharacters[i]:activate()
					current_map.aicharacters[i]:restartAgent()
				end
			end
			future_event(0.1, function()crowd_move(navigation_random_navmesh_point()) end)
		end
	end

    self:mouseMove(vec(0,0))
    self:stepCallback(0)
    self:frameCallback(0)

end

function navigation_demo:openMap(map_file)
	self.currentMap = nil
	self.currentMap = GritMap.new()

	self.currentMap:open(map_file)
	current_map = self.currentMap
end;


function navigation_demo:init()
	navigation_reset()
	object_all_del()
	
	loading_screen.enabled = true
    loading_screen:setMapName('Navigation Demo')
    loading_screen:setStatus('Background loading resources...')

	navigation_debug_option("navmesh_use_tile_colours", true)
	navigation_debug_option("enabled", true)

	include `/editor/core/edenv.lua`
	env_recompute()

	self:openMap(`/maps/navigation_demo/navmap.gmap`)
	
    playing_binds.enabled = true
	playing_actor_binds.enabled = true
    editor_core_binds.enabled = false
    editor_edit_binds.enabled = false
    editor_debug_binds.enabled = false

	
	playing_binds:bind("right", function() playing_binds.mouseCapture = true end, function() playing_binds.mouseCapture = false end)
	
	playing_binds:bind("left", function() local pos = mouse_pick_pos() if pos then pos = navigation_nearest_point_on_navmesh(pos) end if pos then crowd_move(pos) end end)

	clock.enabled = false
	compass.enabled = false
	
	
    main.physicsEnabled = true

    playing_binds.mouseCapture = false

    self:playerRespawn()
	gfx_option("RENDER_SKY", false)

	self.info = create_guitext({value = "Left Mouse: Move Crowd", parent = hud_bottom_left, position = vec(150, 20)})
	
end

function navigation_demo:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity
    
    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
    self.playerCamPitch = self.camPitch
        
    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat

    self.lastMouseMoveTime = seconds()

end

function navigation_demo:receiveButton(button, state)
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
	end
end

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end


function navigation_demo:frameCallback(elapsed_secs)

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

function navigation_demo:stepCallback(elapsed_secs)

end

function navigation_demo:destroy()
    playing_binds.enabled = false
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false
    editor_core_binds.enabled = false
    editor_edit_binds.enabled = false
    editor_debug_binds.enabled = false
	
	playing_binds:unbind("right")
	playing_binds:unbind("left")
	
	object_all_del()
	
	gfx_option("RENDER_SKY", true)
	
	navigation_debug_option("enabled", false)	
	
	safe_destroy(self.info)
	navigation_reset()
end

game_manager:define("Navigation Demo", navigation_demo)
