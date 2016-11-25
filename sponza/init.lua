include `defs.lua`

local GameMode = extends_keep_existing (game_manager.gameModes['Sponza FPS'], FirstPersonGameMode) {
    name = 'Sponza FPS',
    description = 'Sponza (First Person Demo)',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vector3(-12.52798, -4.982235, -10.6575),
    spawnRot = quat(0.7013986, 0.04191646, -0.04244654, -0.7102685),

    playerGfxMesh = `/detached/characters/robot_med/robot_med.mesh`,
    playerColMesh = `/detached/characters/robot_med/robot_med.gcol`,
}

game_manager:register(GameMode)
