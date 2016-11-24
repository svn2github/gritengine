-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons BY-NC-SA license: http://creativecommons.org/licenses/by-nc-sa/3.0/
-----------------------------------------
---- Project B (Working title)  Init ----
-----------------------------------------

--gfx_bake_env_cube(`projectb_cube.envcube.tif`, 512, vector3(38, 9, 97), 1, vector3(0.0,0.0,0.0))

include `materials.lua`
include `characters/init.lua`
include `comet/init.lua`
include `classes.lua`
include `map/whitebox_definitions.lua`
include `weapons/init.lua`

if detached_binds ~= nil then detached_binds:destroy() end
detached_binds = InputFilter(300, "detached")
detached_binds:bind("F2", function() game_manager.currentMode:toggleSoulMode() end)
detached_binds.enabled = false

local GameMode = extends(BaseGameMode) {
    name = 'Detached',
    description = 'Futuristic floating city',
    previewImage = `GameMode.png`,
    map = `map.gmap`,
    spawnPos = vec(0, -185, 5),
    spawnRot = quat(1, 0, 0, 0),

    soulMode = false,

    init = function(self)
        BaseGameMode.init(self)

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
    end,

    setSoulMode = function(self, v)
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
    end,

    toggleSoulMode = function(self)
        self:setSoulMode(not self.soulMode)
    end,

    destroy = function(self)
        BaseGameMode.destroy(self)
        self.watermark:destroy()
        detached_binds.enabled = false
    end,
}

game_manager:define(GameMode)
