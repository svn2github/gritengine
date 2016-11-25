map_ghost_spawn(vector3(500, -2000, 50))

include `materials.lua`
include `classes.lua`
include `map.lua`
env_cycle = include `env_cycle.lua`

include `/vehicles/Hoverman/init.lua`

object `/vehicles/Hoverman` (487, -2011, 47) {name = "test_wipeoutcar", rot=quat(-0.4019256, 0.004209109, 0.009588621, -0.9156125)}
