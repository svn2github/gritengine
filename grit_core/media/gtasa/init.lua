-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

map_ghost_spawn(vector3(0,0,30))

include `definitions.lua`

local t
t = time(function() include `map.lua` end)
print("map.lua: "..t.." seconds")

include `cars.lua`

physics_option("USE_TRIANGLE_EDGE_INFO", false) -- it seems a lot of SA col data expects double sided col polys to work

