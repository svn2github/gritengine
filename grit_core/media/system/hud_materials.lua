-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local function do_create_hud_material(name)
    local mat = get_material(name)
    if mat==nil then
            mat = Material(name)
    else
            mat:removeAllTechniques()
            mat:createTechnique()
            mat:createPass(0)
    end

    mat:setFog(0,0, true, "NONE", 0, 0, 0, 0, 0, 0)
    mat:setLightingEnabled(0,0, false)
    mat:createTextureUnitState(0,0)

    return mat
end

local mat

-- For overlays.  Get rid of this when we move to new overlay system
mat = do_create_hud_material("system/ConsoleBorder")
mat:setSceneBlending(0,0,"SRC_ALPHA", "ONE_MINUS_SRC_ALPHA")
mat:setColourOperation(0,0,0,"SOURCE1", "MANUAL", "CURRENT", 0, 0,0,0, 0,0,0)
mat:setAlphaOperation(0,0,0,"SOURCE1", "MANUAL", "CURRENT", 0, 0.8, 0)

mat = do_create_hud_material("system/Console")
mat:setSceneBlending(0,0,"SRC_ALPHA", "ONE_MINUS_SRC_ALPHA")
mat:setColourOperation(0,0,0,"SOURCE1", "MANUAL", "CURRENT", 0, 0,0,0.2, 0,0,0)
mat:setAlphaOperation(0,0,0,"SOURCE1", "MANUAL", "CURRENT", 0, 0.7, 0)

