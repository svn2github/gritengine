game = {}

if detached_binds ~= nil then detached_binds:destroy() end
detached_binds = InputFilter(300, "detached")

include "/detached/characters/init.lua"
include "/detached/weapons/init.lua"

material "/detached/weapons/rocket_launcher/rocket_launcher" { 
	filterMip = "NONE",filterMag="NONE";
	shadowBias = 0.1;
	diffuseMap="/detached/textures/rocket_launcher.tga";
}

game.player = {}

game.play = function()
	game.player = object "/detached/characters/robot_med" (CurrentLevel.spawn_pos or vector3(0, 0, 0)) {rot=quat(0.9962251, 0, 0, 0.086808), name="player" }
	game.player:activate()
	player_ctrl:beginControlObj(game.player)
	detached_binds:unbind("A+-")
	common_binds:bind("left", function () fire_rocket() end )
end;

game.stop = function()
	player_ctrl:abandonControlObj()
	safe_destroy(game.player)
	common_binds:unbind("left")
end;

game.loaded = function()
	player_ctrl:abandonControlObj()
end;

function game.game_load_level()
	local starload = loadstring(level.map)
	starload()
end