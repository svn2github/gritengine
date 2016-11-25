local GameMode = extends_keep_existing (game_manager.gameModes['Detached'], ThirdPersonGameMode) {
    name = 'Detached',
    description = 'Futuristic floating city',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(675.0886, -60.01787, 21.1625),
    spawnRot = quat(0.9256727, 0, 0, 0.3783255),

    seaLevel = -300,
    soulMode = false,
}

function GameMode:init()
    ThirdPersonGameMode.init(self)

    self.protagonist = object_add(`characters/robot_med`, vec(0, 0, 0), {name = 'Protagonist'})

    self.watermark = hud_object `/common/hud/Rect` {
        parent = hud_top_left,
        position = vector2(128, -32), 
        texture = `textures/logo_detached_prealpha.png`,
    }
    self:setSoulMode(false)

    gfx_option('SHADOW_END0', 25)
    gfx_option('SHADOW_END1', 50)
    gfx_option('SHADOW_END2', 300)
    gfx_option('SHADOW_FADE_START', 250)
    gfx_option('SHADOW_FILTER_DITHER', true)
    gfx_option('SHADOW_FILTER_TAPS', 36)

    detached_binds.enabled = true

    self:playerRespawn()
end

function GameMode:setSoulMode(v)
    if v then
        gfx_colour_grade(`/common/colour_grade/sepia.lut.png`)
        gfx_option("BLOOM_ITERATIONS", 3)
        gfx_option("BLOOM_THRESHOLD", 0)
        gfx_global_exposure(2.0)
    else
        gfx_colour_grade(`/system/standard.lut.png`)
        gfx_option("BLOOM_ITERATIONS", 1)
        gfx_option("BLOOM_THRESHOLD", 5)
        gfx_global_exposure(2.0)
    end
    self.soulMode = v
end

function GameMode:toggleSoulMode()
    self:setSoulMode(not self.soulMode)
end

function GameMode:destroy()
    ThirdPersonGameMode.destroy(self)
    detached_binds.enabled = false
end

game_manager:register(GameMode)
