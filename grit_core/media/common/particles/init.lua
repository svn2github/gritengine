-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include "gas.lua"
include "debris.lua"

include "fire.lua"
include "explosion.lua"
include "smoke.lua"

function pick_explosion(sz)
    local pos = pick_pos(0.5, true)
    if pos == nil then return end
    explosion(pos, sz)
end

ui:bind("-", function() cast_flame() end, null, true)
ui:bind("C+-", function() cast_flame2() end, null, true)
ui:bind("=", function() pick_explosion() end, nil, true)
ui:bind("C+=", function() pick_explosion(15) end, nil, true)
ui:bind("A+=", function() pick_explosion(3) end, nil, true)
ui:bind("C+F2",function() puff_textured() end, nil, true)
