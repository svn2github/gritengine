BaseGameMode = BaseGameMode or {
    name = 'Unnamed',
    description = 'No description',
    previewImgae = `/common/hud/LoadingScreen/GritLogo.png`,
    map = `/editor/default_map/defaultmap.gmap`,
    spawnPos = vec(0, 0, 0),
    spawnRot = Q_ID,

    init = function(self)
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
    end,

    setPause = function(self, v)
        main.physicsEnabled = not v
    end,

    mouseMove = function(self, rel)
        local sens = user_cfg.mouseSensitivity
        
        local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
        
        self.camYaw = (self.camYaw + rel2.x) % 360
        self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
        self.playerCamPitch = self.camPitch
            
        main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
        main.audioCentreQuat = main.camQuat

        self.lastMouseMoveTime = seconds()
    end,

    receiveButton = function(self, button, state)
        if state == '=' then return end
        local pressed = state ~= '-'

        local cobj = self.vehicle

        if button == 'walkForwards' then    
        elseif button == 'walkBackwards' then
        elseif button == 'walkLeft' then
        elseif button == 'walkRight' then
        elseif button == 'walkBoard' then
        elseif button == 'walkJump' then
        elseif button == 'walkRun' then
        elseif button == 'walkCrouch' then
        elseif button == 'walkZoomIn' then
        elseif button == 'walkZoomOut' then
        elseif button == 'walkCamera' then
        elseif button == 'driveForwards' then    
        elseif button == 'driveBackwards' then
        elseif button == 'driveLeft' then
        elseif button == 'driveRight' then
        elseif button == 'driveZoomIn' then
        elseif button == 'driveZoomOut' then
        elseif button == 'driveCamera' then
        elseif button == 'driveSpecialUp' then
        elseif button == 'driveSpecialDown' then
        elseif button == 'driveSpecialLeft' then
        elseif button == 'driveSpecialRight' then
        elseif button == 'driveAltUp' then
        elseif button == 'driveAltDown' then
        elseif button == 'driveAltLeft' then
        elseif button == 'driveAltRight' then
        elseif button == 'driveAbandon' then
            if state == '+' then
            end
        elseif button == 'driveHandbrake' then
        elseif button == 'driveLights' then
            if state == '+' then
            end
        elseif button == 'driveSpecialToggle' then
            if state == '+' then
            end
        end
    end,

    frameCallback = function(self, elapsed_secs)
    end,

    stepCallback = function(self, elapsed_secs)
    end,

    destroy = function(self)
    end,
}
