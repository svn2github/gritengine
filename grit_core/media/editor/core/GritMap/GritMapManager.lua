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
		editor =
		{
			cam_pos = vec(0, 0, 0);
			cam_quat = quat(1, 0, 0, 0);
		};
		environment =
		{
			time = 0;
			clock_rate = 0;
			env_cycle_file = "";
		};
		include = {};
		objects = {};
		object_properties = {};	
	}

	make_instance(self, GritMap)
	return self
end;

function GritMap:registerObject(obj)
	if obj ~= nil and not obj.destroyed then
		self.objects[obj.name] = obj
		-- self.object_properties[obj.name] = {}
	end
end

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

function GritMap:open(mapfile)
	--object_all_del()

	object_all_del()
	safe_include (mapfile)
	if gritmap == nil then
		print(RED.."This file is not a Grit Map File")
		return false
	end
	
	if gritmap.properties.name ~= nil then
		self.name = gritmap.properties.name
	end
	if gritmap.author ~= nil then
		self.author = gritmap.properties.author
	end
	if gritmap.properties.description ~= nil then
		self.description = gritmap.properties.description
	end
	if gritmap.environment ~= nil then
		self.environment = table.clone(gritmap.environment)
	end
	
	self.env_cubes.env_cube = gritmap.env_cubes.env_cube or gfx_env_cube(0)
	self.env_cubes = table.clone(gritmap.env_cubes)
	
	self.environment.time = gritmap.environment.time or (12 * 60 * 60)
	self.file_name = mapfile:sub(2)
	
	if gritmap.include ~= nil then
		self.include = table.clone(gritmap.include)
	end
	
	if self.include ~= nil and #self.include > 0 then
		for i = 1, #self.include do
			safe_include(self.include[i])
		end
	end
	
	for i = 1, #gritmap.objects do
		self.object_properties[gritmap.objects[i].name] = table.clone(gritmap.objects[i].properties)
	end

	for i = 1, #gritmap.objects do
		if(class_has(gritmap.objects[i].class)) then
			self.objects[gritmap.objects[i].name] = object (gritmap.objects[i].class) (gritmap.objects[i].position) (table_concat(gritmap.objects[i].properties, { name = gritmap.objects[i].name, orientation = gritmap.objects[i].orientation }))
		else
			print(RED.."Class: "..gritmap.objects[i].class.." not declared.")
		end
	end	

	-- if(pcall(gritmap.map) ~= true) then
		-- print(RED.."ERROR LOADING MAP")
		-- return false
	-- end
	-- self.objects = object_all()
	
	-- self.spawn_point.instance.body.ghost = true
	if in_editor then
		self:setCamera()
	end
	
	env.secondsSinceMidnight = self.environment.time
	
	if self.environment.env_cycle_file ~= nil and self.environment.env_cycle_file ~= "" then
		safe_include(self.environment.env_cycle_file)
	end
	
	self:applyEnvCube()
	env_recompute()
	gritmap = nil
	return true
end

function GritMap:setCamera()
	self.editor.cam_pos = gritmap.editor.cam_pos or vector3(0, 0, 0)
	self.editor.cam_quat = gritmap.editor.cam_quat or quat(1, 0, 0, 0)
	
	main.camPos = self.editor.cam_pos
	main.camQuat = self.editor.cam_quat

	GED.camPitch = quatPitch(main.camQuat)
	GED.camYaw = cam_yaw_angle()
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
	
	local tmap = {}
	
	file:write(
[[
-- Map file generated by Grit Editor.

gritmap =
]])
	tmap.properties = {}
	tmap.properties.name = self.name
	tmap.properties.author = self.author
	tmap.properties.description = self.description
	
	self.editor.cam_pos = main.camPos
	self.editor.cam_quat = main.camQuat
	
	tmap.editor = self.editor
	tmap.env_cubes = self.env_cubes
	
	self.environment.time = env.secondsSinceMidnight
	
	tmap.environment = self.environment
	tmap.include = self.include

	local map_objects = {}
	
	for k, v in pairs(self.objects) do
		if not self.objects[k].destroyed then
			local cnt = {}
			--local id = self:findClassID(self.objects[k].className:gsub("_LOD", "", 1))
			--if id ~= 0 then
				cnt.class = self.objects[k].className:gsub("_LOD", "", 1)
				cnt.name = self.objects[k].name
				cnt.position = self.objects[k].spawnPos or V_ZERO
				cnt.orientation = self.objects[k].rot or quat(1, 0, 0, 0)
				-- cnt[5] = self.objects[i].scale
				cnt.properties = self.object_properties[k]
			
				map_objects[#map_objects+1] = cnt
			--end
		end
	end	
	
	tmap.objects = map_objects
	
	file:write(dump(tmap, false))
	return file:close()
end

function GritMap:export(file_name)
	local file = io.open(file_name, "w")
	print(file_name)
	if file == nil then print(RED.."Could not open file", 1) return false end
	
	-- maybe will be removed, but for now save all objects
	self.objects = object_all()
	
	file:write(
[[
-- Lua file generated by Grit Editor.
-- WARNING: If you modify this file, your changes will be lost if it is subsequently re-saved from editor]]
)
	file:write("\n")
	for i = 1, #self.objects do
		-- to save deactivated objects too
		self.objects[i]:activate()
		
		if self.objects[i].editorObject == nil then
			-- reset class name for objects using LOD
			local class_name = self.objects[i].className:gsub("_LOD", "", 1)
			
			file:write("\n")
			-- dump_object_line() not used only because LOD object fix
			-- objects with collision
			if self.objects[i].instance.body ~= nil then
				file:write("object \""..class_name.."\" ("..self.objects[i].instance.body.worldPosition..") {".."rot="..self.objects[i].instance.body.worldOrientation..", name=\""..self.objects[i].name.."\" }")
			-- objects without collision
			elseif self.objects[i].instance.gfx ~= nil then
				file:write("object \""..class_name.."\" ("..self.objects[i].instance.gfx.localPosition..") {".."rot="..self.objects[i].instance.gfx.localOrientation..", name=\""..self.objects[i].name.."\" }")
			-- sounds
			elseif self.objects[i].instance.audio then
				file:write("object \""..class_name.."\" ("..self.objects[i].pos..") {".."orientation="..self.objects[i].orientation..", name=\""..self.objects[i].name.."\" }")
			end
		end
	end
	
	file:write("\n")
	return file:close()
end
