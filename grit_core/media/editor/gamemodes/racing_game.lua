if in_editor == nil then
	stats.enabled = false
	ch.enabled = false
	clock.enabled = false
	-- speedo.enabled = false
	-- compass.enabled = false
	debug_layer:onKeyPressed(false)
	debug_binds.modal = debug_layer.enabled
	ticker.enabled = true
	menu.alpha = 0.7
end

include `/editor/core/defaultmap/init.lua`

game = {
	player = {};

	play = function()
		playing_binds.mouseCapture = false
		gfx_option("FOV", 90)
		local pos = (current_level.spawn.pos or vector3(0, 0, 0)) + (class_get(`/vehicles/Scarman`).placementZOffset or 0)
		game.player = object `/vehicles/Scarman` (pos) {rot=current_level.spawn.rot, name="player" }
		game.player:activate()
		player_ctrl:beginControlObj(game.player)
		
		local ddir = norm(game.player.instance.body.worldPosition - player_ctrl.camPos)
		player_ctrl.camYaw = ddir.x
		player_ctrl.camPitch = ddir.y
		player_ctrl.camDir = euler(ddir.x, ddir.y, ddir.z)
		for i = 0, 3 do
			player_ctrl.controlObj:controlZoomIn()
		end
		player_ctrl.controlObj:realign()
	end;

	stop = function()
		playing_binds.mouseCapture = true
		gfx_option("FOV", 55)
		player_ctrl:abandonControlObj()
		safe_destroy(game.player)
	end;

	load_level = function()
		local startload = loadstring(current_level.map)
		startload()
		
		if current_level.env_cube ~= nil and current_level.env_cube ~= "" then
			env_cube_dawn = current_level.env_cube_dawn
			gfx_env_cube(current_level.env_cube)
			env_cube_noon = current_level.env_cube_noon
			env_cube_dusk = current_level.env_cube_dusk
			env_cube_dark = current_level.env_cube_dark
		end	
	end;
}