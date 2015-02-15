------------------------------------------------------------------------------
--  This is the level class, commonly used for "current_level"
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

GritLevel = {}
function GritLevel.new()
	local self = {
		name = "Level_"..math.random();
		description= "";		
		game_mode = default_game_mode;
		objects = {};
		file_name = "";
		env_cube = "";
		env_cube_dawn = "";
		env_cube_noon = "";
		env_cube_dusk = "";
		env_cube_dark = "";
		cam_pos = {};
		cam_dir= {};
		cam_Pitch = {};
		cam_Yaw = {};
		author = "";
		
		spawn = {
			pos = {};
			rot = {};
		};
		time = {};
		clock_rate = 0;
		include = {};
	}

	make_instance(self, GritLevel)
	return self
end;

function GritLevel:apply_env_cube()
	if self.env_cube ~= nil and self.env_cube ~= "" then
		if resource_exists(self.env_cube_dawn) then
			env_cube_dawn = self.env_cube_dawn
		end
		if resource_exists(self.env_cube) then
			gfx_env_cube(0, self.env_cube)
			env_cube_noon = self.env_cube_noon
		end
		if resource_exists(self.env_cube_dusk) then
			env_cube_dusk = self.env_cube_dusk
		end
		if resource_exists(self.env_cube_dark) then
			env_cube_dark = self.env_cube_dark
		end
	end
end

-- all temporary textures are saved inside 'cache/env'
function GritLevel:generate_env_cube()
	local current_time = env.secondsSinceMidnight
	local current_clockRate = env.clockRate
	env.clockRate = 0
	
	math.randomseed(os.clock())
	
	-- dawn
	env.secondsSinceMidnight = 6 * 60 * 60
	local tex = GED.directory.."/cache/env/".."myenv_dawn"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, player_ctrl.camPos, 0.7, vector3(0.0, 0.0, 0.0))
	self.env_cube_dawn = "/"..tex

	-- noon/default
	env.secondsSinceMidnight = 12 * 60 * 60
	tex = GED.directory.."/cache/env/".."myenv"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, player_ctrl.camPos, 0.7, vector3(0.0, 0.0, 0.0))
	self.env_cube = "/"..tex
	-- noon use the same as default
	self.env_cube_noon = "/"..tex
	
	-- dusk
	env.secondsSinceMidnight = 18 * 60 * 60
	tex = GED.directory.."/cache/env/".."myenv_dusk"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, player_ctrl.camPos, 0.7, vector3(0.0, 0.0, 0.0))
	self.env_cube_dusk = "/"..tex	

	-- dark
	env.secondsSinceMidnight = 0
	tex = GED.directory.."/cache/env/".."myenv_dark"..math.random(1000)..".envcube.tiff"
	gfx_bake_env_cube(tex, 128, player_ctrl.camPos, 0.7, vector3(0.0, 0.0, 0.0))
	self.env_cube_dark = "/"..tex

	self:apply_env_cube()
	env.secondsSinceMidnight = current_time
	env.clockRate = current_clockRate
end

function GritLevel:open(levelfile)
	--object_all_del()

	-- you can just create a new level and include a lua that cointains object placements
	local level_ext = levelfile:reverse():match("..."):reverse()
	if level_ext == "lua" then
		print(levelfile)
		include (levelfile)
		self.objects = object_all()
		self.spawn.pos = vector3(0, 0, 0)
		self.spawn.rot = quat(1, 0, 0, 0)
		return true
	elseif level_ext == "lvl" then
		object_all_del()
		safe_include (levelfile)
		if level == nil then
			print(RED.."This file is not a Grit Level File")
			return false
		end
		
		if level.name ~= nil then
			self.name = level.name
		end
		if level.author ~= nil then
			self.author = level.author
		end
		if level.description ~= nil then
			self.description = level.description
		end
		if level.game_mode ~= nil then
			self.game_mode = level.game_mode
		end
		if level.clock_rate ~= nil then
			self.clock_rate = level.clock_rate
		end
		
		self.env_cube = level.env_cube or gfx_env_cube(0)
		self.env_cube_dawn = level.env_cube_dawn or env_cube_dawn
		self.env_cube_noon = level.env_cube_noon or env_cube_noon
		self.env_cube_dusk = level.env_cube_dusk or env_cube_dusk
		self.env_cube_dark = level.env_cube_dark or env_cube_dark
		
		self.time = level.time or (12 * 60 * 60)
		self.file_name = levelfile:sub(2)
		
		if level.include ~= nil then
			self.include = level.include
		end
		
		if self.include ~= nil and #self.include > 0 then
			for i = 1, #self.include do
				safe_include(self.include[i])
			end
		end
		
		local loadmap
		if(pcall(function()loadmap = loadstring(level.map) end) ~= true) then return false
		end
		
		local lm, err = pcall(function() loadmap() end)
		if(err ~= nil) then
			print(RED.."ERROR LOADING LEVEL"..err[2]:match(": .*"))
			return false
		end
		self.objects = object_all()
		self.spawn.pos = level.spawn_pos or level.spawn.pos or vector3(0, 0, 0)
		if level.spawn ~= nil then
			self.spawn.rot = level.spawn.rot or quat(1, 0, 0, 0)
		else
			self.spawn.rot = quat(1, 0, 0, 0)
		end
		
		self.spawn_point = object (`../assets/spawn_point`) (self.spawn.pos) {
			rot = self.spawn.rot
		}
		
		-- self.spawn_point.instance.body.ghost = true
		self:set_camera()
		
		env.secondsSinceMidnight = self.time
		self:apply_env_cube()
		env_recompute()
		return true
	else
		print(RED.."File name cannot be handled!")
		return false
	end
end

function GritLevel:set_camera()
	self.cam_pos = level.cam_pos or vector3(0, 0, 0)
	self.cam_Yaw = level.cam_Yaw or 0
	self.cam_Pitch = level.cam_Pitch or 0
	self.cam_dir = level.cam_dir or quat(1, 0, 0, 0)
	
	player_ctrl.camPos = self.cam_pos 
	player_ctrl.camYaw = self.cam_Yaw 
	player_ctrl.camPitch = self.cam_Pitch
	player_ctrl.camDir = self.cam_dir
end

function GritLevel:load_game_mode(gamemode)
	gamemode = gamemode or self.game_mode
	safe_include ("/"..GED.directory.."/"..GED.game_mode_dir.."/"..self.game_mode..".lua")
end

function GritLevel:save()
	local file = io.open(self.file_name, "w")
	print(self.file_name)
	if file == nil then error("Could not open file", 1) end
	
	-- maybe will be removed, but for now save all objects
	self.objects = object_all()

	if self.spawn_point ~= nil then
		self.spawn.pos = self.spawn_point.spawnPos
		self.spawn.rot = self.spawn_point.rot
	end

	file:write(
[[
-- Level file generated by Grit Editor.
-- WARNING: If you modify this file, your changes will be lost if it is
-- subsequently re-saved from editor

level = {
	name = ']]..self.name.."';"..
"\n	author = '"..self.author.."';"..
"\n	description = '"..self.description.."';"..
"\n	game_mode = '"..self.game_mode.."';"..

"\n\n	env_cube = '"..self.env_cube.."';"..
"\n	env_cube_dawn = '"..self.env_cube_dawn.."';"..
"\n	env_cube_noon = '"..self.env_cube_noon.."';"..
"\n	env_cube_dusk = '"..self.env_cube_dusk.."';"..
"\n	env_cube_dark = '"..self.env_cube_dark.."';"..

"\n\n	time = "..env.secondsSinceMidnight..";"..
"\n	clock_rate = "..self.clock_rate..";"..

"\n\n	spawn = {"..
"\n		pos = vector3("..self.spawn.pos.x..", "..self.spawn.pos.y..", "..self.spawn.pos.z..");"..
"\n		rot = quat("..self.spawn.rot.w..", "..self.spawn.rot.x..", "..self.spawn.rot.y..", "..self.spawn.rot.z..");\n	};"
)
	file:write("\n};")
	
	if self.include ~= nil then
		file:write("\n\nlevel.include = {")
		for i = 1, #self.include do
			file:write("\n	'"..self.include[i].."';")
		end
		file:write("\n};")
	end
	
	file:write("\n\nenv_cycle = ")
	file:write(dump(env_cycle, false))

	file:write("\n\nlevel.map = [[")
	
	for i = 1, #self.objects do
		-- to save deactivated objects too
		self.objects[i]:activate()
		
		if self.objects[i].editor_object == nil then
			-- reset class name for objects using LOD
			local class_name = self.objects[i].className:gsub("_LOD", "", 1)
			
			file:write("\n")
			-- dump_object_line() not used only because LOD object fix
			-- objects with collision
			if self.objects[i].instance.body ~= nil then
				file:write("object \""..class_name.."\" ("..self.objects[i].instance.body.worldPosition..") {".."rot="..self.objects[i].instance.body.worldOrientation..", name=\""..self.objects[i].name.."\" }")
			-- objects without collision
			elseif self.objects[i].instance.gfx ~= nil then
				file:write("object \""..class_name.."\" ("..self.objects[i].spawnPos..") {".."rot="..self.objects[i].instance.gfx.localOrientation..", name=\""..self.objects[i].name.."\" }")
			-- sounds
			elseif self.objects[i].instance.audio then
				file:write("object \""..class_name.."\" ("..self.objects[i].pos..") {".."orientation="..self.objects[i].orientation..", name=\""..self.objects[i].name.."\" }")
			end
		end
	end
	
	file:write("\n]]\n\n")
	file:write([[
if in_editor ~= nil then
	-- Editor level definitions:]])
	file:write("\n	level.cam_pos = vector3("..player_ctrl.camPos.x..", "..player_ctrl.camPos.y..", "..player_ctrl.camPos.z..")")
	file:write("\n	level.cam_dir = quat("..player_ctrl.camDir.w..", "..player_ctrl.camDir.x..", "..player_ctrl.camDir.y..", "..player_ctrl.camDir.z..")")
	file:write("\n	level.cam_Pitch = "..player_ctrl.camPitch)
	file:write("\n	level.cam_Yaw = "..player_ctrl.camYaw.."\n\n")
	
	file:write([[
	level.events = {
		
	};

else
	-- in-game level initialization
	current_level = level
	level = nil
	]])

	file:write(	"safe_include('/"..GED.game_data_dir.."/"..GED.game_mode_dir.."/'..current_level.game_mode..'.lua')\n\n")

	file:write([[
	if current_level.include ~= nil and #current_level.include > 0 then
		for i = 1, #current_level.include do
			safe_include(current_level.include[i])
		end
	end
	
	if game ~= nil then
		game:load_level()
		game:play()
	else
		print(RED..'No gameplay defined!')
	end
end
]])
	file:close()
end

function GritLevel:export(file_name)
	local file = io.open(file_name, "w")
	print(file_name)
	if file == nil then error("Could not open file", 1) end
	
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
		
		if self.objects[i].editor_object == nil then
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
	file:close()
end