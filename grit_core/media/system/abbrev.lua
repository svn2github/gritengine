-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("loading abbrev.lua")

-- use globals to avoid memory allocation and subsequent GC overhead when creating a closure
local curried_name
local pile_curried_name

local class_ext
local function class3 (tab)
        return class_add(curried_name,class_ext,tab)
end
local function class2 (ext)
        class_ext = ext
        return class3
end
function class (name)
        curried_name = name
        return class2
end
        
local function hud_class2 (tab)
        return gfx_hud_class_add(curried_name,tab)
end
function hud_class (name)
        curried_name = name
        return hud_class2
end
        
local inside_pile = false
local function pile2 (tab)
        inside_pile = false
        return class_add(pile_curried_name,PileClass,tab)
end
function pile (name)
        pile_curried_name = name
        inside_pile = true
        return pile2
end

local obj_off = vector3(0,0,0)
local obj_pos
local function object3 (tab)
        if not class_has(curried_name) then
                error("Trying to create an object using non-existent class \""..curried_name.."\"",2)
        end
        if inside_pile then
                return { curried_name, obj_pos, tab }
        end
        local hid = object_add(curried_name, obj_pos, tab)
        local lod = class_get(curried_name).lod
        if lod == true then
                if curried_name:find("/") then
                        lod = curried_name:reverse():gsub("/","_dol/",1):reverse()
                else
                        lod = "lod_"..curried_name
                end
        end
        if lod then
                if class_get(lod) then
                        tab.near = hid
                        if tab.name then tab.name = tab.name.."_lod" end
                        object_add(lod, obj_pos, tab)
                else
                        error("Class \""..curried_name.."\" referred to a lod class \""..lod.."\" that does not exist.")
                end
        end
        return hid
end
local function object2 (x,y,z)
        if type(x) == "vector3" then
                obj_pos = obj_off + x
        else
                obj_pos = obj_off + vector3(x,y,z)
        end
        return object3
end
function object (class)
        curried_name = class
        return object2
end
function offset_exec (off, f, ...)
        obj_off = obj_off + off
        f(...)
        obj_off = obj_off - off
end
function offset_include (x,y,z, str) offset_exec(vector3(x,y,z),include,str) end
        
local function physical_material2 (tab) 
        return physics:setMaterial(curried_name,tab)
end
function physical_material (name)
        curried_name = name
        return physical_material2
end

local function procedural_batch2 (tab) 
        return physics:setProceduralBatchClass(curried_name,tab)
end
function procedural_batch (name)
        curried_name = name
        return procedural_batch2
end

local function procedural_object2 (tab) 
        return physics:setProceduralObjectClass(curried_name,tab)
end
function procedural_object (name)
        curried_name = name
        return procedural_object2
end

local function sky_material2(tab)
        local name = curried_name
        tab = tab or {}
        register_sky_material(name,tab)
end
function sky_material(name)
        curried_name = name
        return sky_material2
end

local function sky_shader2(tab)
        local name = curried_name
        tab = tab or {}
        register_sky_shader(name,tab)
end
function sky_shader(name)
        curried_name = name
        return sky_shader2
end

local function uniform_texture2(tab)
        tab = tab or {}
        tab.name = curried_name
        return tab
end
function uniform_texture(tab)
        tab.uniformKind = "TEXTURE2D";
        return tab
end

function uniform_float(...)
        local tab = { ... }
        tab.uniformKind = "PARAM"
        tab.valueKind = "FLOAT"
        return tab
end

local function material2(tab)
        local name = curried_name
        tab = tab or {}
        local function qualify(t)
                for _,k in ipairs{"diffuseMap", "normalMap", "glossMap", "translucencyMap", "emissiveMap", "paintColour"} do
                        if type(t[k])=="string" then
                                t[k] = fqn_ex(t[k], fqn(name))
                        end
                end
        end
        qualify(tab)
        if tab.blend then
                for _,v in ipairs(tab.blend) do
                        qualify(v)
                end
        end

        -- paint colour
        do_create_material(fqn(name),tab)
        register_material(name,tab)
end
function material(name)
        curried_name = name
        return material2
end

local function particle2(tab)
        local name = curried_name
        tab = tab or {}
        gfx_particle_define(name,tab)
end
function particle(name)
        curried_name = name
        return particle2
end

