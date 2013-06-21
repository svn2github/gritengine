-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading physical_materials.lua")

PhysicalMaterials = PhysicalMaterials or {}

physics.defaultMaterial = {}

function physics:setDefaultMaterial(tab)
        physics.defaultMaterial = {}
        for k,v in pairs(tab) do
                physics.defaultMaterial[k] = v
        end
end

function physics:setMaterial(name, tab)
        name = fqn(name)
        for k,v in pairs(physics.defaultMaterial) do
                tab[k] = tab[k] or v
        end
        physics_set_material(name, tab.interactionGroup)
        local mat = PhysicalMaterials[name]
        if mat == nil then
                -- create material
                mat = {}
                PhysicalMaterials[name] = mat
        else
                -- clear it out
                for k,v in pairs(mat) do
                        mat[k] = nil
                end
        end
        for k,v in pairs(tab) do
                if k == "proceduralObjects" then
                        local t = { }
                        for k2,v2 in ipairs(v) do
                                t[k2] = fqn(v2)
                        end
                        mat[k] = t
                elseif k == "proceduralBatches" then
                        local t = { }
                        for k2,v2 in ipairs(v) do
                                t[k2] = fqn(v2)
                        end
                        mat[k] = t
                else
                        mat[k] = v
                end
        end
        return mat
end

function physics:getMaterial(name)
        name = fqn(name)
        return PhysicalMaterials[name]
end

physical_material "FallbackPhysicalMaterial" { interactionGroup=0; }

