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
include `game_mode.lua`

if detached_binds ~= nil then detached_binds:destroy() end
detached_binds = InputFilter(300, "detached")
detached_binds:bind("F2", function() game_manager.currentMode:toggleSoulMode() end)
detached_binds.enabled = false
