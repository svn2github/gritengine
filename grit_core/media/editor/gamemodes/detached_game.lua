if detached_binds ~= nil then detached_binds:destroy() end
detached_binds = InputFilter(300, "detached")

include `/detached/characters/init.lua`
include `/detached/weapons/init.lua`
material `/detached/weapons/rocket_launcher/rocket_launcher` { 
	filterMip = "NONE",filterMag="NONE";
	shadowBias = 0.1;
	diffuseMap=`/detached/textures/rocket_launcher.tga`;
}
include `/detached/watermark.lua`
watermark.enabled = false

include `/editor/core/defaultmap/init.lua`

if in_editor == nil then
--	stats.enabled = false
--	ch.enabled = false
--	clock.enabled = false
--	speedo.enabled = false
--	compass.enabled = false
	debug_layer:onKeyPressed(false)
	debug_binds.modal = debug_layer.enabled
	ticker.enabled = true
	menu.alpha = 0.7
end

game = {
	player = {};
	
	play = function()
		local pos = (current_level.spawn.pos or vector3(0, 0, 0)) + (class_get(`/detached/characters/robot_med`).placementZOffset or 0)
		game.player = object (`/detached/characters/robot_med`)(pos) {rot=current_level.spawn.rot, name="player", bearing= math.deg(math.acos(current_level.spawn.rot.w)*2)}
		game.player:activate()
		player_ctrl:beginControlObj(game.player)
		detached_binds:unbind("A+-")
		watermark.enabled = true
		common_binds:bind("left", function() fire_rocket() end)
		common_binds:bind("right", function() gfx_option("FOV", 40) end, function() gfx_option("FOV", 55) end)
		
		-- if current_level.events['BEGIN'] ~= nil then
			-- current_level.events['BEGIN']:start()
		-- end
	end;

	stop = function()
		player_ctrl:abandonControlObj()
		safe_destroy(game.player)
		watermark.enabled = false
		common_binds:unbind("left")
		common_binds:unbind("right")
		
		-- if current_level.events['END'] ~= nil then
			-- current_level.events['END']:start()
		-- end
	end;

	-- used just for the standalone game
	load_level = function()
		local startload = loadstring(current_level.map)
		
		startload()
		
		if current_level.env_cube ~= nil and current_level.env_cube ~= "" then
			env_cube_dawn = current_level.env_cube_dawn
			gfx_env_cube(0, current_level.env_cube)
			env_cube_noon = current_level.env_cube_noon
			env_cube_dusk = current_level.env_cube_dusk
			env_cube_dark = current_level.env_cube_dark
		end
	end;
};