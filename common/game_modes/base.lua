BaseGameMode = BaseGameMode or {
    name = 'Unnamed',
    description = 'No description',
    previewImgae = `/common/hud/LoadingScreen/GritLogo.png`,
    map = `/editor/default_map/defaultmap.gmap`,
    spawnPos = vec(0, 0, 0),
    spawnRot = Q_ID,
}

-- Define them outside of the object to allow re-reading the file to hot-swap out functions.

function BaseGameMode:init()
    loading_screen:setMapName(self.name)
    loading_screen:setStatus('Background loading resources...')

    include_map(self.map)

    playing_binds.enabled = true
    playing_binds.mouseCapture = true
    
    main.audioCentreVel = vec(0, 0, 0)
    main.audioCentreQuat = self.spawnRot
    self.camYaw = 0
    self.camPitch = 0
    self.lastMouseMoveTime = seconds()

    main.camPos = self.spawnPos
    main.camQuat = self.spawnRot
end

function BaseGameMode:loadAtLocation()
    streamer_centre_full(self.spawnPos)

    if get_in_queue_size() == 0 then
        -- Everything loaded so don't bother with the loading screen.
        return
    end

    -- Use loading screen while we go back to spawn pos
    loading_screen.enabled = true
    loading_screen:setProgress(0)

    loading_screen:pump()

    local to_go = get_in_queue_size()
    local init_to_go = to_go
    while to_go > 0 do
        to_go = get_in_queue_size()
        loading_screen:setProgress((init_to_go - to_go) / init_to_go)
        loading_screen:pump()
        give_queue_allowance(1 + to_go)
    end
    loading_screen:setProgress(1)
    loading_screen:setStatus('Activating objects')
    loading_screen:pump()
    streamer_centre_full(self.spawnPos)

    loading_screen:setStatus('All done')
    loading_screen:pump()
    loading_screen.enabled = false
end

function BaseGameMode:setPause(v)
    main.physicsEnabled = not v
end

function BaseGameMode:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity
    
    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
    self.playerCamPitch = self.camPitch
        
    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat

    self.lastMouseMoveTime = seconds()
end

function BaseGameMode:receiveButton(button, state)
end

function BaseGameMode:frameCallback(elapsed_secs)
end

function BaseGameMode:stepCallback(elapsed_secs)
end

function BaseGameMode:destroy()
end
