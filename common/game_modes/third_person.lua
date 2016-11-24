ThirdPersonGameMode = extends(BaseGameMode) {

    seaLevel = -6,

    init = function(self)
        BaseGameMode.init(self)

        main.speedoPos = main.camPos
        main.speedoSpeed = 0

        safe_destroy(self.speedo)
        self.speedo = hud_object `/common/hud/Speedo` { parent = hud_top_right }
        self.speedo.position = vec(-64, -128 - self.speedo.size.y/2)

        self.centreNotify = hud_text_add(`/common/fonts/Impact50`)
        self.centreNotify.text = ''
        self.centreNotify.position = vec(0, 100)
        self.centreNotify.parent = hud_centre
        self.centreNotify.shadow = vec(6, -3)
        self.centreNotify.colour = vec(1, .7, .3)
    end,

    destroy = function(self)
        self.protagonist = nil
        safe_destroy(self.centreNotify)
        safe_destroy(self.speedo)
    end,

    playerRespawn = function(self)

        self.centreNotify.text = ''

        for _, obj in ipairs(object_all()) do
            obj:deactivate()
            obj.skipNextActivation = false
        end

        self.protagonist.spawnPos = self.spawnPos
        self.protagonist.pos = self.spawnPos
        self.protagonist.rot = self.spawnRot
        self.vehicle = nil
        self.playerDeathTimer = nil
        env_saturation_mask = 1

        playing_actor_binds.enabled = true
        playing_vehicle_binds.enabled = false

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


        main.camQuat = Q_ID
        main.audioCentreVel = vec(0, 0, 0);
        main.audioCentreQuat = quat(1, 0, 0, 0);
        self.camYaw = 90;
        self.camPitch = 0;
        self.playerCamPitch = 0;  -- Without vehicle pitch offset
        self.lastMouseMoveTime = seconds()

        self.protagonist:activate()

        env.secondsSinceMidnight = 12 * 60 * 60

        self:mouseMove(vec(0,0))
        self:stepCallback(0)
        self:frameCallback(0)
    end,

	playerKill = function(self)
		self.playerDeathTimer = 0
		self.centreNotify.text = 'WASTED!'
		playing_actor_binds.enabled = false
		playing_vehicle_binds.enabled = false
	end,

    mouseMove = function(self, rel)
        if self.playerDeathTimer then return end
        BaseGameMode.mouseMove(self, rel)
    end,

    scanForBoard = function(self)
        local radius = 3
        local player_body = self.protagonist.instance.body
        local player_pos = player_body.worldPosition
        local best_score = 0
        local best_found_vehicle = nil
        physics_test(radius, player_pos, true, function(body, num, lpos, wpos, normal, penetration, mat)
            local found_vehicle = body.owner
            if found_vehicle == nil then return end
            if found_vehicle.controllable ~= "VEHICLE" then return end
            local from_player = player_body:worldToLocal(wpos)
            local angle = math.deg(math.acos(norm(from_player).y))
            if angle > 45 then return end
            local score = penetration
            if score > best_score then
                best_score = score
                best_found_vehicle = found_vehicle
            end
        end)
        if best_found_vehicle == nil then return end
        self:board(best_found_vehicle)
    end,

    board = function(self, veh)
        self.vehicle = veh
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = true
        self.protagonist:enterVehicle()
        veh:controlBegin()
        
        main.controlObj = veh
        
        -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
        -- So we calculate the playerCamPitch necessary for that.
        local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
        self.playerCamPitch = self.playerCamPitch - v_pitch
    end,

    abandonControlObj = function(self)
        -- Disable binds before settings vehicle to nil, ensures steering, acceleration etc is reset
        local veh = self.vehicle
        self.vehicle = nil
        self.protagonist:exitVehicle(veh.instance.body:localToWorld(veh.driverExitPos), veh.instance.body.worldOrientation * veh.driverExitQuat)
        veh:controlAbandon()
        
        main.controlObj = nil
        
        playing_vehicle_binds.enabled = false
        playing_actor_binds.enabled = true

        -- When on foot there is no vehicle pitch.
        local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
        self.playerCamPitch = self.playerCamPitch + v_pitch
    end,

    receiveButton = function(self, button, state)
        if state == '=' then return end
        local pressed = state ~= '-'

        local prot = self.protagonist
        local cobj = self.vehicle

        if button == 'walkForwards' then    
            prot:setForwards(pressed)
        elseif button == 'walkBackwards' then
            prot:setBackwards(pressed)
        elseif button == 'walkLeft' then
            prot:setLeft(pressed)
        elseif button == 'walkRight' then
            prot:setRight(pressed)
        elseif button == 'walkBoard' then
            if state == '+' then
                self:scanForBoard()
            end
        elseif button == 'walkJump' then
            prot:setJump(pressed)
        elseif button == 'walkRun' then
            prot:setRun(pressed)
        elseif button == 'walkCrouch' then
            prot:setCrouch(pressed)
        elseif button == 'walkZoomIn' then
            prot:controlZoomIn() 
        elseif button == 'walkZoomOut' then
            prot:controlZoomOut() 
        elseif button == 'walkCamera' then
            -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

        elseif button == 'driveForwards' then    
            cobj:setForwards(pressed)
        elseif button == 'driveBackwards' then
            cobj:setBackwards(pressed)
        elseif button == 'driveLeft' then
            cobj:setLeft(pressed)
        elseif button == 'driveRight' then
            cobj:setRight(pressed)
        elseif button == 'driveZoomIn' then
            cobj:controlZoomIn() 
        elseif button == 'driveZoomOut' then
            cobj:controlZoomOut() 
        elseif button == 'driveCamera' then
            -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

        elseif button == 'driveSpecialUp' then
            cobj:setSpecialUp(pressed)
        elseif button == 'driveSpecialDown' then
            cobj:setSpecialDown(pressed)
        elseif button == 'driveSpecialLeft' then
            cobj:setSpecialLeft(pressed)
        elseif button == 'driveSpecialRight' then
            cobj:setSpecialRight(pressed)
        elseif button == 'driveAltUp' then
            cobj:setAltUp(pressed)
        elseif button == 'driveAltDown' then
            cobj:setAltDown(pressed)
        elseif button == 'driveAltLeft' then
            cobj:setAltLeft(pressed)
        elseif button == 'driveAltRight' then
            cobj:setAltRight(pressed)
        elseif button == 'driveAbandon' then
            if state == '+' then
                self:abandonControlObj()
            end
        elseif button == 'driveHandbrake' then
            cobj:setHandbrake(pressed)
        elseif button == 'driveLights' then
            if state == '+' then
                cobj:setLights()
            end
        elseif button == 'driveSpecialToggle' then
            if state == '+' then
                cobj:special()
            end
        end
    end,

    frameCallback = function(self, elapsed_secs)
        local obj = self.vehicle or self.protagonist
        local instance = obj.instance
        local body = instance.body

        local boom_length

        if self.playerDeathTimer then
            self.playerDeathTimer = self.playerDeathTimer + elapsed_secs

            local stage = self.playerDeathTimer / 4

            if stage > 1 then
                self:playerRespawn()
                return
            end
            env_saturation_mask = (1 - stage) * (1 - stage)

            self.camYaw = self.camYaw + elapsed_secs * 60
            self.camPitch = math.max(-90, self.camPitch - elapsed_secs * 60)
            main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
            local curr_dist = #(main.camPos - instance.camAttachPos)
            boom_length = curr_dist + elapsed_secs * 2
        else

            local vehicle_bearing, vehicle_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
            local vehicle_vel = body.linearVelocity
            local vehicle_vel_xy_speed = #(vehicle_vel * vector3(1,1,0))

            -- modify the self.camPitch and self.camYaw to track the direction a vehicle is travelling
            if user_cfg.vehicleCameraTrack and obj.cameraTrack and seconds() - self.lastMouseMoveTime > 1  and vehicle_vel_xy_speed > 5 then

                self.camPitch = lerp(self.camPitch, self.playerCamPitch + vehicle_pitch, elapsed_secs * 2)

                -- test avoids degenerative case where x and y are both 0 
                -- if we are looking straight down at the car then the yaw doesn't really matter
                -- you can't see where you are going anyway
                if math.abs(self.camPitch) < 60 then
                    local ideal_yaw = yaw(vehicle_vel.x, vehicle_vel.y)
                    local current_yaw = self.camYaw
                    if math.abs(ideal_yaw - current_yaw) > 180 then
                        if ideal_yaw < current_yaw then
                            ideal_yaw = ideal_yaw + 360
                        else
                            current_yaw = current_yaw + 360
                        end
                    end
                    local new_yaw = lerp(self.camYaw, ideal_yaw, elapsed_secs * 2) % 360

                    self.camYaw = new_yaw
                end
            end

            main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)

            main.speedoPos = instance.camAttachPos
            main.speedoSpeed = #vehicle_vel
            if self.vehicle ~= nil then
                self.protagonist:updateDriven(instance.camAttachPos, Q_ID)
            end

            local ray_skip = 0.4
            local ray_dir = main.camQuat * V_BACKWARDS
            local ray_start = instance.camAttachPos + ray_skip * ray_dir
            local ray_len = instance.boomLengthSelected - ray_skip
            local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
            boom_length = math.max(obj.boomLengthMin, ray_hit_len)
        end

        main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)
        main.streamerCentre = instance.camAttachPos
        main.audioCentrePos = main.camPos
    end,

	stepCallback = function(self, elapsed_secs)
		if self.playerDeathTimer then
			-- Already dead.
			return
		end
		if self.vehicle ~= nil and self.vehicle.instance.exploded then
			-- In vehicle that exploded.
			self:playerKill()
		end
		if self.protagonist.pos.z < self.seaLevel then
			-- Drowned.
			self:playerKill()
		end
	end,
}

