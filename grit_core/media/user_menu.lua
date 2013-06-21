simple_menu.Main_menu = {
	Title = "Main menu";
	{"Vehicles", function() simple_menu:show(simple_menu.Vehicles_menu) end};
	{"Maps", function() simple_menu:show(simple_menu.Maps_menu) end};
	{"Characters", function() simple_menu:show(simple_menu.Player_menu) end};
	{"Spawn Objects #1", function() simple_menu:show(simple_menu.Objs_one_menu) end};	
	{"Spawn Objects #2", function() simple_menu:show(simple_menu.Objs_two_menu) end};
	{"Developers'", function() simple_menu:show(simple_menu.Dev_menu) end};
	{"Misc", function() simple_menu:show(simple_menu.Misc_menu) end};
	
	MenuType = "root";
}

simple_menu.Vehicles_menu = {
	Title = "Vehicles";
	{"BO105", function() place("/vehicles/BO105") end};
	{"Bonanza", function() place("/vehicles/Bonanza") end};
	{"Evo", function() place("/vehicles/Evo") end};
	{"Focus", function() place("/vehicles/Focus") end};
	{"Gallardo", function() place("/vehicles/Gallardo") end};
	{"MotorBike", function() place("/vehicles/MotorBike") end};
	{"Nova", function() place("/vehicles/Nova") end};
	{"Scarman", function() place("/vehicles/Scarman") end};
	{"Hoverman", function() place("/vehicles/Hoverman") end};
	{"Seat", function() place("/vehicles/Seat") end};
	
	MenuType = "child";
}

local loadMap = function(map)
		object_all_del();
		unload_all_textures();
		unload_all_materials();
		include "/system/env.lua"
		include(map)
end

simple_menu.Maps_menu = {
	Title = "Maps";
	{"Detached", function() loadMap("/detached/init.lua") end};
	{"Playground", function() loadMap("/playground/init.lua") end};
	{"Project", function() loadMap("/project/init.lua") end};
	{"Sponza", function() loadMap("/sponza/init.lua") end};
	{"Race on Urban", function() loadMap("/race_test/init.lua") end};
	{"Top_gear", function() loadMap("/top_gear/init.lua") end};
	{"Urban", function() loadMap("/urban/init.lua") end};
	{"Wipeout", function() loadMap("/wipeout/init.lua") end};

	MenuType = "child";
}

simple_menu.Objs_one_menu = {
	Title = "Spawn Objects #1";
	{"Log1", function() introduce_obj("/common/props/nature/Log1") end};
	{"Big", function() introduce_obj("/common/props/debug/crates/Big") end};
	{"Brick", function() introduce_obj("/common/props/junk/Brick") end};
	{"CannonBall", function() introduce_obj("/common/props/debug/CannonBall") end};
	{"Ball", function() introduce_obj("/common/props/bowling/Ball") end};
	{"rock", function() introduce_obj("/common/props/nature/rock") end};
	{"JengaBrick", function() introduce_obj("/common/props/debug/JengaBrick") end};
	{"TrafficCone", function() introduce_obj("/common/props/street/TrafficCone") end};
	{"WineBottle1", function() introduce_obj("/common/props/junk/WineBottle1") end};
	
	MenuType = "child";
}

simple_menu.Objs_two_menu = {
	Title = "Spawn Objects #2";
	{"WineBottle2", function() introduce_obj("/common/props/junk/WineBottle2") end};

	MenuType = "child";
}

simple_menu.Player_menu = {
	Title = "Spawn Characters";
	{"Generic Character", function() place ("/common/actors/Character") end};

	MenuType = "child";
}

simple_menu.Dev_menu = {
	Title = "Developers'";
	{"Keyboard verbose", function() set_keyb_verbose(not get_keyb_verbose()) end};
	{"Bounding boxes", function() debug_cfg.boundingBoxes = not debug_cfg.boundingBoxes end};
	{"Clear placed", clear_placed};
	{"Clear projectiles", clear_temporary};
	{"Clear everything", function() object_all_del() end};
	{"Wireframe", function()
		local pm = debug_cfg.polygonMode
		if pm == "SOLID" then
			debug_cfg.polygonMode = "SOLID_WIREFRAME"
		elseif pm == "SOLID_WIREFRAME" then 
			debug_cfg.polygonMode = "WIREFRAME"
		else    
			debug_cfg.polygonMode = "SOLID"
		end
    	end};
	{"Physics wireframe", function() debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame end};
	{"Sky editor", function() env:toggleEditMode(); simple_menu:show(nil) end};	

	MenuType = "child";
}

simple_menu.Misc_menu = {
	Title = "Misc";
    {"Xhair Test", function() include("/common/hud/xhair/init.lua") end};
    {"Compass", function() include("/common/hud/compass/init.lua") end};
	{"Quit game", quit};
	
	MenuType = "child";
}
