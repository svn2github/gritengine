------------------------------------------------------------------------------
--  This is the map class, commonly used for "current_map"
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

gritmap = nil

GritMap = {}
function GritMap.new()
	local self = {
		name = "Map_"..math.random();
		description = "";
		author = "";
		
		file_name = "";
		
		env_cubes =
		{
			env_cube = '';
			env_cube_dawn = '';
			env_cube_noon = '';
			env_cube_dusk = '';
			env_cube_dark = '';		
		};

		env_cycle_file = "";

		version = 4;
	}

	make_instance(self, GritMap)
	return self
end;

function GritMap:applyEnvCube()
	if self.env_cubes.env_cube ~= nil and self.env_cubes.env_cube ~= "" then
		if resource_exists(self.env_cubes.env_cube_dawn) then
			env_cube_dawn = self.env_cubes.env_cube_dawn
		end
		if resource_exists(self.env_cubes.env_cube) then
			gfx_env_cube(0, self.env_cubes.env_cube)
			env_cube_noon = self.env_cubes.env_cube_noon
		end
		if resource_exists(self.env_cubes.env_cube_dusk) then
			env_cube_dusk = self.env_cubes.env_cube_dusk
		end
		if resource_exists(self.env_cubes.env_cube_dark) then
			env_cube_dark = self.env_cubes.env_cube_dark
		end
	end
end

-- all temporary textures are saved inside 'cache/env'
function GritMap:generateEnvCube(pos)
	local current_time = env.secondsSinceMidnight
	local current_clockRate = env.clockRate
	env.clockRate = 0
	
	math.randomseed(os.clock())
	
	-- dawn
	env.secondsSinceMidnight = 6 * 60 * 60
	local tex = GED.directory.."/cache/env/".."myenv_dawn"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
	self.env_cubes.env_cube_dawn = "/"..tex

	-- noon/default
	env.secondsSinceMidnight = 12 * 60 * 60
	tex = GED.directory.."/cache/env/".."myenv"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
	self.env_cubes.env_cube = "/"..tex
	-- noon use the same as default
	self.env_cubes.env_cube_noon = "/"..tex
	
	-- dusk
	env.secondsSinceMidnight = 18 * 60 * 60
	tex = GED.directory.."/cache/env/".."myenv_dusk"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
	self.env_cubes.env_cube_dusk = "/"..tex	

	-- dark
	env.secondsSinceMidnight = 0
	tex = GED.directory.."/cache/env/".."myenv_dark"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
	self.env_cubes.env_cube_dark = "/"..tex

	self:applyEnvCube()
	env.secondsSinceMidnight = current_time
	env.clockRate = current_clockRate
end

in_editor = in_editor or false

gritmap = gritmap or nil

function GritMap:open(mapfile)
	object_all_del()
	
	local mapreturn = safe_include (mapfile)
	
	if gritmap == nil and not mapreturn then
		print(RED.."This file is not a Grit Map File")
		return false
	end

	safe_include(mapfile:match("(.*/)").."init.lua")

	 -- gritmap = mapreturn
	for i = 1, #gritmap.objects do
		local randomname = math.random(10000)
		if(class_has(gritmap.objects[i][1])) then
			object (gritmap.objects[i][1]) (gritmap.objects[i][2]) (gritmap.objects[i][3] or {})
		else
			print(RED.."Class: "..gritmap.objects[i].class.." not declared.")
		end
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
	self.env_cubes.env_cube = gritmap.env_cubes.env_cube or gfx_env_cube(0)
	
	self.file_name = mapfile:sub(2)

	if in_editor then
		self:setCamera(gritmap.editor.cam_pos, gritmap.editor.cam_quat)
	end
	
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
	gritmap = nil
	return true
end

function GritMap:setCamera(pos, orient)
	main.camPos = pos
	main.camQuat = orient
	if in_editor then
		GED.camPitch = quatPitch(main.camQuat)
		GED.camYaw = cam_yaw_angle()
	end
end

function GritMap:findClassID(name)
	for i = 1, #self.classes do
		if self.classes[i] == name then
			return i
		end
	end
	return 0
end

function GritMap:save()
	local file = io.open(self.file_name, "w")
	if file == nil then print(RED.."Could not open file", 1) return false end
	
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
		objects = {};
	}
	
	local objects = object_all()

	for k, v in pairs(objects) do
		if not objects[k].destroyed and not objects[k].editorObject then
			local cnt = {}
			--local id = self:findClassID(self.objects[k].className:gsub("_LOD", "", 1))
			--if id ~= 0 then
				cnt[1] = objects[k].className:gsub("_LOD", "", 1)
				cnt[2] = objects[k].spawnPos or V_ZERO
				cnt[3] = get_object_properties(objects[k])

				tmap.objects[#tmap.objects+1] = cnt
			--end
		end
	end	

	file:write(
[[
-- Map file generated by Grit Editor.

gritmap =
]])	
	
	file:write(table.serialize(tmap, false))
	return file:close()
end

function get_object_properties(obj)
	if obj and not obj.destroyed then
		local obj_prop = obj.dump or {}
		obj_prop.spawnPos = nil
		obj_prop.orientation = nil
		obj_prop.skipNextActivation = nil
		obj_prop.name = obj.name
		obj_prop.rot = obj.orientation
		return obj_prop
	end
end

-- reference: http://stackoverflow.com/questions/6075262/lua-table-tostringtablename-and-table-fromstringstringtable-functions by Henrik Ilgen
-- keeps array order and omit functions and userdata
function table.serialize(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0
	if type(val) == "function" or type(val) == "userdata" then return nil end
    local tmp = string.rep("	", depth)

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
			local st = table.serialize(v, k, skipnewlines, depth + 1)
			if st ~= nil then
				tmp =  tmp .. st .. ";" .. (not skipnewlines and "\n" or "")
			end
        end

        tmp = tmp .. string.rep("	", depth) .. "}"
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    else
		 tmp = tmp .. tostring(val)
    end

    return tmp
end

function GritMap:export(file_name)
	-- maybe will be removed, but for now save all objects
	local objects = object_all()
	if objects == nil or not next(objects) then return end
	
	local file = io.open(file_name, "w")
	print(file_name)
	if file == nil then print(RED.."Could not open file", 1) return false end
	
	file:write(
[[
-- Lua file generated by Grit Editor.
-- WARNING: If you modify this file, your changes will be lost if it is subsequently re-exported from editor]]
)
	file:write("\n")
	for i = 1, #objects do
		if objects[i] ~= nil and not objects[i].destroyed and objects[i].editorObject == nil then
			-- to save deactivated objects too
			objects[i]:activate()
		
			-- reset class name for objects using LOD
			local class_name = objects[i].className:gsub("_LOD", "", 1)
			
			file:write("\n")
			-- dump_object_line() not used only because LOD object fix

			if objects[i].instance.body ~= nil or objects[i].instance.gfx ~= nil then
				file:write("object \""..class_name.."\" ("..(objects[i].spawnPos or V_ZERO)..") "..table.serialize(get_object_properties(objects[i])))
			-- sounds
			elseif objects[i].instance.audio then
				file:write("object \""..class_name.."\" ("..objects[i].instance.audio.position..") { orientation = "..objects[i].instance.audio.orientation..", name = \""..objects[i].name.."\" }")
			end
		end
	end
	
	file:write("\n")
	return file:close()
end
