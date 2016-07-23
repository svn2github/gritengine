-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `classes.lua`

material `Small` { diffuseMap = `side.dds` }

material `Big` { diffuseMap = `red_side.dds`, normalMap = `red_side_N.dds` }

material `Long` { diffuseMap = `Panel.dds`, normalMap = `PanelN.dds`, emissiveMap = `PanelE.dds`, emissiveMask=vec(6, 6, 6), additionalLighting=true }

class `Wall` (ProcPileClass) {
    spawnObjects = function(persistent, spawn)
        local x_min = persistent.xMin
        local x_max = persistent.xMax
        local height = persistent.height
        for z=0,height-1 do
            local x_min_, x_max_ = x_min, x_max
            if z % 2 == 1 then
                x_min_, x_max_ =x_min+1, x_max-1
            end
            for x=x_min_,x_max_,2 do
                local pos = (0.6*vector3(x, 0, z+class_get(persistent.brickClass).placementZOffset))
                spawn(persistent.brickClass, pos, {})
            end
        end
    end;
    renderingDistance=110;
    xMin = -8;
    xMax = 8;
    height = 15;
    brickClass = `Long`
}

class `Stack` (ProcPileClass) {
    spawnObjects = function(persistent, spawn)
        local height = persistent.height
        local dim = 2 * class_get(persistent.brickClass).placementZOffset
        for i=0.5,height-0.5 do
            spawn(persistent.brickClass, vector3(0,0,dim*i), {})
        end

    end;
    renderingDistance=110;
    height = 15;
    brickClass = `Small`
}

