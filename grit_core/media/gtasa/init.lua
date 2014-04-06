-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

map_ghost_spawn(vector3(0,0,30))

include "/common/init.lua"
include "/vehicles/init.lua"


--add_resource_location("gtasa/gta3.img.zip","Zip",false)
--add_resource_location("gtasa/gta_int.img.zip","Zip",false)
--add_resource_location("gtasa/meshes.zip","Zip",false)
--initialise_all_resource_groups()

include "definitions.lua"

local t
t = time(function() include "map.lua" end)
print("map.lua: "..t.." seconds")

include "cars.lua"

physics_option("USE_TRIANGLE_EDGE_INFO", false) -- it seems a lot of SA col data expects double sided col polys to work

