-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Main` {
	colour = vec(1, 1, 1)*0.2;
	texture = `background.dds`;
	padding = 0;
	
	init = function (self)
		self.needsParentResizedCallbacks = true;

		self.selectedOption = ""; --Used for loading projects

		self.activeMenu = "";
		
		self.activeGuis = {};
		
		self.desc = {
			main = function()
				self:clearMenu() --Will clear all active guis
				self.activeMenu = "main"
				self.activeGuis["gritLogo"] = gfx_hud_object_add(`/common/hud/Rect`, {
					size = vec(300, 150);
					texture = `/common/hud/LoadingScreen/GritLogo.png`;
					parent = self;
					position = vec2(0, (gfx_window_size().y / 2) - 250);
				})
				
				local ypos = 0
				self.activeGuis["projectsButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Projects";
					parent = self;
					position = vec2(0, ypos);
					pressedCallback = function() 
						self.desc.projects()
					end
				})
				ypos = ypos - 50
				self.activeGuis["debugmodeButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Debug Mode";
					parent = self;
					position = vec2(0, ypos);
					pressedCallback = function() 
						self.activeGuis = {}
						self.activeMenu = "project"
						game_manager:enter("Debug Mode")
					end
				})
				ypos = ypos - 50
                self.activeGuis["editorButton"] = gfx_hud_object_add(`Button`, {
                    size = vec(230,40);
                    font = `/common/fonts/Impact24`;
                    caption = "Editor";
                    parent = self;
                    position = vec2(0, -100);
                    pressedCallback = function() 
                        self.activeMenu = "editor"
                        game_manager:enter("Map Editor")
                    end
                })
                ypos = ypos - 50
				self.activeGuis["settingsButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Settings";
					parent = self;
					position = vec2(0, ypos);
					pressedCallback = function() 
						self.desc.settings()
					end
				})
				ypos = ypos - 50
				self.activeGuis["exitButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Exit";
					parent = self;
					position = vec2(0, ypos);
					pressedCallback = quit
				})
			end;
			
			settings = function()
				self:clearMenu() --Will clear all active guis
				self.activeMenu = "settings"
				local lastPos = -10;
				
				local mmenu = gui.list({parent=self, align=guialign.bottom, offset=vec(0, 25)})
				mmenu.alpha = 0
				self.activeGuis.menu = mmenu
				
				-- menu.activeGuis.scrollarea = gui.scrollarea({parent=menu, size = vec(gfx_window_size().x - 200, 450), expand=false, align=guialign.bottom})
				
				
				for key,value in pairs(user_cfg.c) do --Not sure what the difference is between user_cfg.p and user_cfg.c
					if(type(value) == "boolean")then
						print("The variable: ".. key .." with the name of ".. key .." is equal to ".. tostring(user_cfg[tostring(key)]) .."!") --Was used for debugging!
						mmenu:addItem(
							gfx_hud_object_add(`SettingEdit`, {
								size = vec(gfx_window_size().x - 200,40);
								font = `/common/fonts/Impact24`;
								caption = tostring(key);
								valueLocation = user_cfg;
								valueKey = tostring(key);
								-- parent = self;
								-- position = vec2(0, lastPos);
							})
						)
						-- lastPos = lastPos - 45
						--self.gui[key].set.position
					end
				end
				
				-- self.activeGuis.scrollarea:setContent(mmenu)
				
				mmenu.position = vec(0, -gfx_window_size().y/2+mmenu.size.y/2+25)
				
				
				self.activeGuis["backButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Go Back";
					parent = self;
					position = vec2(0, 250);
					pressedCallback = function() 
						self.desc.main()
					end
				})
			end;
			
			projects = function()
				self:clearMenu() --Will clear all active guis
				self.activeMenu = "projects"
				local currentPosition = 0 --Starting Y position of game modes buttons
				local first = 0
				for key,value in spairs(game_manager.gameModes) do
					if key ~= "Map Editor" and key ~= "Debug Mode" then
                        local upper_self = self
						print("The gamemode: ".. key .." was loaded!") --Used for debugging
						self.activeGuis[key] = gfx_hud_object_add(`Button`, {
                            needsInputCallbacks = true;
                            inside = false;
							size = vec(230,40);
                            zOrder=1;
							font = `/common/fonts/Impact24`;
							caption = key;
                            image = game_manager.gameThumbs[key];
                            desc = game_manager.gameDescriptions[key];
							parent = self;
							position = vec2(-230, currentPosition*-50);
							isSelected = false;
							pressedCallback = function(self)
								upper_self.selectedOption = key
								for k in pairs (upper_self.activeGuis) do
									safe_destroy(upper_self.activeGuis[k])
								end
								upper_self.activeGuis = {}
								upper_self.activeMenu = "project"
								game_manager:enter(upper_self.selectedOption)
							end;
							eventCallback = function(self,event)
                                upper_self.activeGuis["description"]:setValue(upper_self.activeGuis[self.caption].desc);
                                upper_self.activeGuis["image"].texture=upper_self.activeGuis[self.caption].image;
							end;
						})
						if(first == 0)then first = self.activeGuis[key] end
						currentPosition = currentPosition + 1
					end
				end
				self.activeGuis["image"] = gfx_hud_object_add(`/common/hud/Rect`, {
					alpha = 1;
					texture = `/common/hud/LoadingScreen/GritLogo.png`;
					parent = self;
					position = vec(105, -80);
					size = vec(400, 200);
				})
				self.activeGuis["description"] = gfx_hud_object_add(`/common/hud/Label`, {
					font = `/common/fonts/Impact18`;
  					parent = self;
					size = vec(400, 20);
                    position = vec(105, -190);
					textColour = vec(0,0,0);
					alignment = "CENTER";
					value = "Select a project"; 
					alpha = 1;
                    enabled = true;
				})
				self.activeGuis["backButton"] = gfx_hud_object_add(`Button`, {
					size = vec(230,40);
					font = `/common/fonts/Impact24`;
					caption = "Go Back";
					parent = self;
					position = vec2(0, 100);
					pressedCallback = function() 
						self.desc.main()
					end
				})
				--self:selectOption(first) --Need to implement where the first one is selected
			end
		};
	end;
	
	makeSelection = function(self, v)
		for key,value in pairs(self.activeGuis) do
			if(value.isSelected ~= nil)then
				if(value == v)then
					value.isSelected = true
					self.selectedOption = key
				else
					value.isSelected = false
				end
			end
		end
	end;
	
	clearMenu = function(self)
		for k in pairs (self.activeGuis) do
          safe_destroy(self.activeGuis[k])
		  self.activeGuis[k] = nil
        end
		gc()
	end;
	
	setMenu = function(self, v) --Example: self:setMenu("main")
		if self.desc[v] then
			self.desc[v]()
		end
	end;
	
	setEnabled = function(self, v)
		if(self.activeMenu == "project" or self.activeMenu == "editor")then
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
			size = vec(230,40);
			font = `/common/fonts/Impact24`;
			caption = "Resume";
			parent = self;
			position = vec2(0, 0);
			pressedCallback = function() 
				self:setEnabled(false)
			end
		})
		self.activeGuis["return"] = gfx_hud_object_add(`Button`, {
			size = vec(230,40);
			font = `/common/fonts/Impact24`;
			caption = "Return to main menu";
			parent = self;
			position = vec2(0, -50);
			pressedCallback = function() 
				game_manager:exit()
			end
		})
		self.activeGuis["exitButton"] = gfx_hud_object_add(`Button`, {
			size = vec(230,40);
			font = `/common/fonts/Impact24`;
			caption = "Exit";
			parent = self;
			position = vec2(0, -100);
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

menu = menu or nil

function create_main_menu(v)
	v = v or true

	safe_destroy(menu)
	menu = gfx_hud_object_add(`/common/hud/menu/Main`, { zOrder = 14 })
	menu:setEnabled(v)

	menu:setMenu("main") --Mainly for debugging, may keep it.
end

function create_pause_menu(v)
	v = v or false

	safe_destroy(menu)
	menu = gfx_hud_object_add(`/common/hud/menu/Pause`, { zOrder = 14 })
	menu:setEnabled(v)
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
