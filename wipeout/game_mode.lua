local GameMode = extends_keep_existing (game_manager.gameModes['Wipeout'], ThirdPersonGameMode) {
    name = 'Wipeout',
    description = 'Wipeout inspired racing game',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(550, -2227, 109),
    spawnRot = Q_ID,
    seaLevel = -6,
}

function GameMode:init()

    ThirdPersonGameMode.init(self)

    self.protagonist = object `/detached/characters/robot_scout` (0, 0, 0) { }
    self.vehicle = nil
    -- object `/vehicles/Hoverman` (487, -2011, 47) {name = "test_wipeoutcar", rot=quat(-0.4019256, 0.004209109, 0.009588621, -0.9156125)}

    self.sky = gfx_sky_body_make(`SkyBox.mesh`, 255)
    moon_ent.enabled = false
    clouds_ent.enabled = false
    sky_ent.enabled = false

    self:playerRespawn()
end

function GameMode:destroy()
    self.sky:destroy()

    ThirdPersonGameMode.destroy(self)
end

game_manager:register(GameMode)


