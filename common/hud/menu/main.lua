-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

GED = GED or nil

hud_class `Main` {
	colour = vec(1, 1, 1)*0.2;
	texture = `background.dds`;
	padding = 0;
	
	init = function (self)
		self.needsParentResizedCallbacks = true;

		self.selectedOption = ""; --Used for loading projects

		self.activeMenu = "";
		
		self.activeGuis = {};
		
		self.menu = {
			main = function()
				menu.clearMenu() --Will clear all active guis
				menu.activeMenu = "main"
				self.activeGuis["gritLogo"] = gfx_hud_object_add(`/common/hud/Rect`, {
					size = vec(300, 150);
					texture = `/common/hud/LoadingScreen/GritLogo.png`;
					parent = self;
					position = vec2(0, (gfx_window_size().y / 2) - 250);
				})
				
				local ypos = 0
				self.activeGuis["projectsButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Projects";
					parent = self;
					position = vec2(0, ypos);
					edgeColour = vec(1, 102/255, 0)*1.0;
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = function() 
						menu.menu.projects()
					end
				})
				ypos = ypos - 50
				self.activeGuis["debugmodeButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Debug Mode";
					parent = self;
					position = vec2(0, ypos);
					edgeColour = vec(0, 1, 0);
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = function() 
						menu.activeGuis = {}
						menu.activeMenu = "project"
						game_manager:enter("Debug Mode")
					end
				})
				ypos = ypos - 50
				if GED then
					self.activeGuis["editorButton"] = gfx_hud_object_add(`Button`, {
						size = vec(210,40);
						font = `/common/fonts/Impact24`;
						caption = "Editor";
						parent = self;
						position = vec2(0, -100);
						edgeColour = vec(0, 102/255, 1)*1.0;
						edgePosition = vec2(-(210 / 2) + 5, 0);
						pressedCallback = function() 
							menu.activeMenu = "editor"
							game_manager:enter("Map Editor")
						end
					})
					ypos = ypos - 50
				end
				self.activeGuis["settingsButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Settings";
					parent = self;
					position = vec2(0, ypos);
					edgeColour = vec(1, 1, 0);
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = function() 
						menu.menu.settings()
					end
				})
				ypos = ypos - 50
				self.activeGuis["exitButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Exit";
					parent = self;
					position = vec2(0, ypos);
					edgeColour = vec(1, 0, 1)*1.0;
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = quit
				})
			end;
			
			settings = function()
				menu.clearMenu() --Will clear all active guis
				menu.activeMenu = "settings"
				local lastPos = -10;
				for key,value in pairs(user_cfg.c) do --Not sure what the difference is between user_cfg.p and user_cfg.c
					if(type(value) == "boolean")then
						print("The variable: ".. key .." with the name of ".. key .." is equal to ".. tostring(user_cfg[tostring(key)]) .."!") --Was used for debugging!
						menu.activeGuis[key] = gfx_hud_object_add(`SettingEdit`, {
							size = vec(gfx_window_size().x - 200,40);
							font = `/common/fonts/Impact24`;
							caption = tostring(key);
							valueLocation = user_cfg;
							valueKey = tostring(key);
							parent = menu;
							position = vec2(0, lastPos);
						})
						lastPos = lastPos - 45
						--menu.gui[key].set.position
					end
				end
				menu.activeGuis["backButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Go Back";
					parent = self;
					position = vec2(0, 100);
					edgeColour = vec(1, 0, 0)*1.0;
					edgeSize = vec2(10,40);
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = function() 
						menu.menu.main()
					end
				})
			end;
			
			projects = function()
				menu.clearMenu() --Will clear all active guis
				menu.activeMenu = "projects"
				local currentPosition = 0 --Starting Y position of game modes buttons
				local first = 0
				for key,value in pairs(game_manager.gameModes) do
					if key ~= "Map Editor" and key ~= "Debug Mode" then
						print("The gamemode: ".. key .." was loaded!") --Used for debugging
						menu.activeGuis[key] = gfx_hud_object_add(`GameModeButton`, {
							size = vec(200,40);
							font = `/common/fonts/Impact24`;
							caption = key;
							parent = menu;
							position = vec2(-205, currentPosition);
							edgePosition = vec2(-(210 / 2) + 5, 0);
							edgeColour = vec(1, 1, 1);
							isSelected = false;
							pressedCallback = function(self)
								menu.makeSelection(self)
							end;
						})
						if(first == 0)then first = menu.activeGuis[key] end
						currentPosition = currentPosition - 50
					end
				end
				menu.activeGuis["description"] = gfx_hud_object_add(`/common/hud/Rect`, {
					font = `/common/fonts/Impact50`;
					alpha = 0.5;
					colour = vec(0.1, 0.1, 0.1) * 0.5;
					text = "Choose a game mode to see the description! This game mode menu is incomplete and may have bugs, report the bugs on the Grit Engine forum at www.gritengine.com!";
					parent = menu;
					position = vec(105, -80);
					size = vec(400, 200);
					textWrap = vec(400, 400);
				})
				menu.activeGuis["load"] = gfx_hud_object_add(`Button`, {
					caption = "Load Gamemode";
					font = `/common/fonts/Impact24`;
					size = vec(210, 40);
					position = vec2(215, -(gfx_window_size().y / 2) + 100);
					parent = menu;
					pressedCallback = function(self)
						for k in pairs (menu.activeGuis) do
							safe_destroy(menu.activeGuis[k])
						end
						menu.activeGuis = {}
						menu.activeMenu = "project"
						game_manager:enter(menu.selectedOption)
					end;
				})
				menu.activeGuis["backButton"] = gfx_hud_object_add(`Button`, {
					size = vec(210,40);
					font = `/common/fonts/Impact24`;
					caption = "Go Back";
					parent = self;
					position = vec2(0, 100);
					edgeColour = vec(1, 0, 0)*1.0;
					edgeSize = vec2(10,40);
					edgePosition = vec2(-(210 / 2) + 5, 0);
					pressedCallback = function() 
						menu.menu.main()
					end
				})
				--menu:selectOption(first) --Need to implement where the first one is selected
			end
		};
	end;
	
	makeSelection = function(v)
		for key,value in pairs(menu.activeGuis) do
			if(value.isSelected ~= nil)then
				if(value == v)then
					value.isSelected = true
					menu.selectedOption = key
				else
					value.isSelected = false
				end
			end
		end
	end;
	
	clearMenu = function(self)
		for k in pairs (menu.activeGuis) do
          safe_destroy(menu.activeGuis[k])
		  menu.activeGuis[k] = nil
        end
		gc()
	end;
	
	setMenu = function(v) --Example: menu.setMenu("main")
		if menu.menu[v] then
			menu.menu[v]()
		end
	end;
	
	setEnabled = function(self, v)
		if(menu.activeMenu == "project" or menu.activeMenu == "editor")then
			self.enabled = false
			menu_binds.modal = false
			--self.enabled = v
			--menu_binds.modal = v
		else
			self.enabled = true
			menu_binds.modal = true
		end
	end;
	
	parentResizedCallback = function (self, psize)
		self.position = vec(psize.x/2, psize.y/2)
		self.size = psize
	end;

	escape = function(self)
	end;
}

hud_class `Pause` {
	colour = vec(1, 1, 1)*0.2;
	-- texture = `background.dds`;
	alpha = 0.8;
	padding = 0;
	
	init = function (self)
		self.needsParentResizedCallbacks = true;

		self.activeGuis = {};
		
		self.activeGuis["gritLogo"] = gfx_hud_object_add(`/common/hud/Rect`, {
			size = vec(300, 150);
			texture = `/common/hud/LoadingScreen/GritLogo.png`;
			parent = self;
			position = vec2(0, (gfx_window_size().y / 2) - 250);
		})
		self.activeGuis["resume"] = gfx_hud_object_add(`Button`, {
			size = vec(210,40);
			font = `/common/fonts/Impact24`;
			caption = "Resume";
			parent = self;
			position = vec2(0, 0);
			edgeColour = vec(1, 102/255, 0)*1.0;
			edgePosition = vec2(-(210 / 2) + 5, 0);
			pressedCallback = function() 
				menu:setEnabled(false)
			end
		})
		self.activeGuis["return"] = gfx_hud_object_add(`Button`, {
			size = vec(210,40);
			font = `/common/fonts/Impact24`;
			caption = "Return to main menu";
			parent = self;
			position = vec2(0, -50);
			edgeColour = vec(0, 102/255, 1)*1.0;
			edgePosition = vec2(-(210 / 2) + 5, 0);
			pressedCallback = function() 
				game_manager:exit()
			end
		})
		self.activeGuis["exitButton"] = gfx_hud_object_add(`Button`, {
			size = vec(210,40);
			font = `/common/fonts/Impact24`;
			caption = "Exit";
			parent = self;
			position = vec2(0, -100);
			edgeColour = vec(1, 0, 1)*1.0;
			edgePosition = vec2(-(210 / 2) + 5, 0);
			pressedCallback = quit
		})
	end;

	setEnabled = function(self, v)
		self.enabled = v
		menu_binds.modal = v
		main.physicsEnabled = not v
	end;
	
	parentResizedCallback = function (self, psize)
		self.position = vec(psize.x/2, psize.y/2)
		self.size = psize
	end;
}

menu = {}

function create_main_menu(v)
	safe_destroy(menu)
	v = v or true
	
	menu = gfx_hud_object_add(`/common/hud/menu/Main`, { zOrder = 14 })
	menu:setEnabled(v)

	menu.setMenu("main") --Mainly for debugging, may keep it.
end

function create_pause_menu(v)
	safe_destroy(menu)
	v = v or false
	menu = gfx_hud_object_add(`/common/hud/menu/Pause`, { zOrder = 14 })
	menu:setEnabled(v)
end