include `defs.lua`

local GameMode = extends (FirstPersonGameMode) {
    map = `map.gmap`,
    playerGfxMesh = `/detached/characters/robot_med/robot_med.mesh`,
    playerColMesh = `/detached/characters/robot_med/robot_med.gcol`,
    spawnRot = quat(0.7013986, 0.04191646, -0.04244654, -0.7102685),
    spawnPos = vector3(-12.52798, -4.982235, -10.6575),
}

game_manager:define("Sponza", GameMode)
game_manager:description("Sponza", "Sponza (First Person Demo)")
game_manager:thumb("Sponza", `GameMode.png`)
