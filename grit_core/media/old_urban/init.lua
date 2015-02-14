-- (c) David Cunningham & Brian Sooy, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php.

if not already_setup_urban then
        player_ctrl:warp(vector3(-0.0, -20.0, 15.0))
        already_setup_urban = true
end

include "materials.lua"
include "classes.lua"
include "placements.lua"
