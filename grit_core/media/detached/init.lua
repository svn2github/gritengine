-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons BY-NC-SA license: http://creativecommons.org/licenses/by-nc-sa/3.0/
-----------------------------------------
---- Project B (Working title)  Init ----
-----------------------------------------

function time_of_day()
	include "sky_cycle.lua"
	env.clockTicking = false
	env.secondsSinceMidnight= 36000
end

function visual_settings(enable_settings)
    soul_mode(false)
	--gfx_bake_env_cube("projectb_cube.envcube.tif", 512, vector3(38, 9, 97), 1, vector3(0.0,0.0,0.0))
	gfx_env_cube("projectb_cube.envcube.tiff")
	env_cube_dawn = "/detached/projectb_cube.envcube.tiff"
	env_cube_noon = "/detached/projectb_cube.envcube.tiff"
	env_cube_dusk = "/detached/projectb_cube.envcube.tiff"
	env_cube_dark = "/detached/projectb_cube.envcube.tiff"
	
    if enable_settings then
        -- these guys are to do with the project, should not be in user_cfg
        user_cfg.shadowPCSSEnd0          = 25;                  
        user_cfg.shadowPCSSEnd1          = 50;               
        user_cfg.shadowPCSSEnd2          = 300; 
        user_cfg.shadowFadeStart		 = 250;                  

        -- these guys are to do with the local user config, should not be set here
        user_cfg.shadowFilterDither      = true;                
        user_cfg.shadowFilterTaps        = 36;                  
        user_cfg.visibility              = 2; 
    end
end

local soul_mode_status
function soul_mode(on)
    if on then
        gfx_colour_grade("/common/colour_grade/sepia.lut.png")
        gfx_option("BLOOM_ITERATIONS",3)
        gfx_option("BLOOM_THRESHOLD", 0)
        gfx_global_exposure(2.0)
    else
        gfx_colour_grade("/system/standard.lut.png")
        gfx_option("BLOOM_ITERATIONS",1)
        gfx_option("BLOOM_THRESHOLD", 5)
        gfx_global_exposure(2.0)
    end
    soul_mode_status = on
end

ui:bind("F2", function() soul_mode(not soul_mode_status) end)

time_of_day()
visual_settings(not disable_vince_settings)

include "watermark.lua"
include "materials.lua"
include "characters/init.lua"
include "comet/init.lua"
include "classes.lua"
include "obj_area_a.lua"
include "weapons/init.lua"

--test car
object "/detached/comet" (41, -27, 17.0) { name="test_comet1" }
object "/detached/comet" (70, -36, 20.5) { name="test_comet2" }
object "/detached/comet" (-41.81092, -37.7634, -25.72889) { name="test_comet3", rot=quat(0.9987538, 0.0001587492, 2.030053e-005, -0.04990703) }
object "/detached/comet" (-12.23256, 9.953016, -5.700626) { name="test_comet4", rot=quat(0.6815135, 2.859916e-005, 3.439611e-005, 0.7318055) }
object "/detached/comet" (67.80746, 6.788282, 34.57818) { name="test_comet5", rot=quat(0.6763503, -0.00114412, 0.0005226743, -0.736579) }
	

object "/detached/characters/robot_heavy" (72, -30, 20.89) {bearing=0, name="bot1"} 
object "/detached/characters/robot_heavy" (44, -33, 16.89) {bearing=45, name="bot2"} 

object "/detached/characters/robot_heavy" (58,   13, 40.94) {bearing=30, name="bot5"} 
object "/detached/characters/robot_heavy" (59.5, 14, 40.94) {bearing=-90, name="bot3"} 
object "/detached/characters/robot_heavy" (58,   15, 40.94) {bearing=150, name="bot4"} 

object "/detached/characters/robot_scout" (79, -30, 20.89) { name="bot6" }
object "/detached/characters/robot_scout" (48, -33, 16.89) { bearing=45, name="bot7" }
object "/detached/characters/robot_med" (77, -30, 20.89) { name="bot8" }
object "/detached/characters/robot_med" (46, -33, 16.89) { bearing=45, name="bot9" }
