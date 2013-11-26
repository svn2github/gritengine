-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

echo ("Loading common assets")

include "map_classes.lua"
include "sound_emitter_class.lua"
include "MoveSpinClass.lua"

include "fonts/init.lua"

include "hud/init.lua"

include "particles/init.lua"

include "pmat/init.lua"

include "mat/init.lua"

include "actors/init.lua"

include "carcols.lua"

include "props/init.lua"
include "veg/init.lua"
include "ramps/init.lua"


-- Object placement bindings...

local tab = {
--[[
	-- can be accessed through simple menu
    ["1"] = "props/nature/Log1";
    ["2"] = "props/debug/crates/Big";
    ["3"] = "props/junk/Brick";
    ["4"] = "props/debug/CannonBall";
    ["5"] = "props/bowling/Ball";
    ["6"] = "props/nature/rock";
    ["7"] = "props/debug/JengaBrick";
    ["8"] = "props/street/TrafficCone";
    ["9"] = "props/junk/WineBottle1";
    ["0"] = "props/junk/WineBottle2";
--]]
  	["t"] = "props/junk/Money";
    ["y"] = "props/race_track/Tyre";
    ["u"] = "props/junk/PizzaBox";
    ["i"] = "props/furniture/WorkBench";
    ["o"] = "/vehicles/Evo";
    ["p"] = "/vehicles/Scarman";
    ["["] = "/vehicles/Focus";
    ["]"] = "/vehicles/Nova";
    ["\\"]= "/vehicles/Komar";
    ["m"] = "/vehicles/Bonanza";
    ["\'"] = "/vehicles/Gallardo";
    ["g"] = "props/industry/OilBarrel";
    ["b"] = "props/street/RoadBarrel";
}

for k,v in pairs(tab) do
    ui:bind(k, function() echo(v) ; introduce_obj(v) end, nil, function() echo(v) ; introduce_obj(v,true) end)
end

ui:bind("k", function() place("ramps/Small") end)
ui:bind("C+k", function() place("ramps/Large") end)
ui:bind("A+k", function() place("ramps/HalfPipeSmall") end)
ui:bind("C+A+k", function() place("ramps/HalfPipeLarge") end)

ui:bind(".", function() place("veg/TropPlant1", nil, true) end)
ui:bind("C+.", function() place("veg/GrassTuft1", nil, true) end)
ui:bind("A+.", function() place("veg/TinyPalmT", nil, true) end)
ui:bind("C+A+.", function() place("veg/GrassMesh", nil, true) end)

ui:bind(",", function() place("veg/Tree_aelm") end)
ui:bind("C+,", function() place("veg/prxtree") end)


ui:bind("j", function() place("props/junk/TrashCanShite") end)
ui:bind("C+j", function() place("props/street/Lamp") end)

