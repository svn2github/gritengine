------------------------------------------------------------------------------
--  This is the map class, commonly used for "current_map"
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

EditorMap = {}
function EditorMap.new()
    local self = {
        name = "Map_"..math.random();
        description = "";
        author = "";
        
        file_name = "";
        
        env_cubes = {
            dawn = env_cube_dawn;
            noon = env_cube_noon;
            dusk = env_cube_dusk;
            dark = env_cube_dark;
        };

        env_cycle_file = "";

        version = 4;
    }

    make_instance(self, EditorMap)
    return self
end;

function EditorMap:applyEnvCube()
    local tab = self.env_cubes
    env_cube_dawn = tab.dawn
    env_cube_noon = tab.noon
    env_cube_dusk = tab.dusk
    env_cube_dark = tab.dark
    env_recompute()
end

function EditorMap:generateEnvCube(pos, filename, hours)
    if filename == nil then
        math.randomseed(os.clock())
        filename = ("editor/cache/env/myenv_%04d"):format(math.random(1000) - 1)
    end

    hours = hours or { dawn = 6, noon = 12, dusk = 18, dark = 0 }

    local current_time = env.secondsSinceMidnight
    for name, hour in pairs(hours) do
        env.secondsSinceMidnight = hour * 60 * 60
        tex = ("%s.%s.envcube.tiff"):format(filename, name)
        gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
        self.env_cubes['env_cube_'..name] = "/"..tex
    end
    env.secondsSinceMidnight = current_time

    self:applyEnvCube()
end


function EditorMap:open(mapfile)
    local gritmap = include (mapfile)
    
    if gritmap == nil then
        error('File '..mapfile..' is not a Grit Map File')
    end

    for i, object in ipairs(gritmap.objects) do
        object_add(object[1], object[2], object[3] or {})
    end

    if gritmap.properties then
        if gritmap.properties.name ~= nil then
            self.name = gritmap.properties.name
        end
        if gritmap.properties.author ~= nil then
            self.author = gritmap.properties.author
        end
        if gritmap.properties.description ~= nil then
            self.description = gritmap.properties.description
        end
    end
    self.env_cubes = table.clone(gritmap.env_cubes)
    
    self.editor = table.clone(gritmap.editor)
    
    self.file_name = mapfile:sub(2)

    if gritmap.environment then
        env.secondsSinceMidnight = gritmap.environment.time or (12 * 60 * 60)
        env.clockRate = gritmap.environment.clockRate or 0    
        if gritmap.environment.env_cycle_file ~= nil then
            self.env_cycle_file = gritmap.environment.env_cycle_file
            if self.env_cycle_file ~= "" then
                safe_include(self.env_cycle_file)
            end
        end
    end
    
    self:applyEnvCube()
    env_recompute()
    return true
end


local function get_object_properties(obj)
    if obj and not obj.destroyed then
        local obj_prop = obj.dump or {}
        obj_prop.spawnPos = nil
        obj_prop.orientation = nil
        obj_prop.skipNextActivation = nil
        obj_prop.name = obj.name
        obj_prop.rot = obj.rot
        return obj_prop
    end
end


-- reference: http://stackoverflow.com/questions/6075262/lua-table-tostringtablename-and-table-fromstringstringtable-functions by Henrik Ilgen
-- keeps array order and omit functions and userdata
local function table_serialize(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0
    if type(val) == "function" or type(val) == "userdata" then return nil end
    local tmp = string.rep("    ", depth)

    if name then
        if tonumber(name) then
            tmp = tmp .. "["..name .. "] = "
        else
            if not string.match(name, '^[a-zA-z_][a-zA-Z0-9_]*$') then
                name = string.gsub(name, "'", "\\'")
                name = "['".. name .. "']"
            end
            tmp = tmp .. name .. " = "
        end
    end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            local st = table_serialize(v, k, skipnewlines, depth + 1)
            if st ~= nil then
                tmp =  tmp .. st .. ";" .. (not skipnewlines and "\n" or "")
            end
        end

        tmp = tmp .. string.rep("    ", depth) .. "}"
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    else
         tmp = tmp .. tostring(val)
    end

    return tmp
end


function EditorMap:save()
    local output_objects = {}
    for k, obj in pairs(object_all()) do
        if not obj.destroyed and not obj.editorObject then
            output_objects[#output_objects+1] = {
                obj.className:gsub("_LOD", "", 1),
                obj.spawnPos or V_ZERO,
                get_object_properties(obj),
            }
        end
    end    

    local file = io.open(self.file_name, "w")
    if file == nil then error("Could not open file") end
    
    local tmap = {
        version = self.version;
        properties = {
            name = self.name;
            author = self.author;
            description = self.description;
        };
        editor = {
            cam_pos = main.camPos;
            cam_quat = main.camQuat;
        };
        env_cubes = self.env_cubes;
        environment = {
            time = env.secondsSinceMidnight;
            clock_rate = env.clockRate;
            env_cycle_file = self.env_cycle_file;
        };
        objects = output_objects;
    }
    
    file:write('-- Map file generated by Grit Editor.\n')
    file:write('return ')
    file:write(table_serialize(tmap, false))
    return file:close()
end
