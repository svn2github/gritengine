map_ghost_spawn(vector3(0,0,30))

include "/common/init.lua"
include "/vehicles/init.lua"

mlockall()

local t

--add_resource_location("gtasa/gta3.img.zip","Zip",false)
--add_resource_location("gtasa/gta_int.img.zip","Zip",false)
--add_resource_location("gtasa/meshes.zip","Zip",false)
--initialise_all_resource_groups()

t = time(function () include "materials.lua" end)
echo("materials.lua: "..t.." seconds")

t = time(function () include "classes.lua" end)
echo("classes.lua: "..t.." seconds")

t = time(function () include "map.lua" end)
echo("map.lua: "..t.." seconds")

