-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local function add_button_to(parent, ypos, tab)
    local tab2 = {
        size = vec(230,40);
        parent = parent;
        position = vec2(0, ypos);

        alpha = 0.4;
        backgroundTexture = false;
        backgroundPassiveColour = vec(0.25, 0.25, 0.25);
        backgroundHoverColour = vec(0.25, 0.25, 0.25);
        backgroundClickColour = vec(0.25, 0.25, 0.0);
        backgroundGreyedColour = vec(0.25, 0.25, 0.25);

        borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`;
        borderPassiveColour = vec(0.75, 0.75, 0.75);
        borderHoverColour = vec(1, 1, 1);
        borderClickColour = vec(1, 0.6, 0.3);

        captionFont = `/common/fonts/Verdana18`;
        captionPassiveColour = vec(0.75, 0.75, 0.75);
        captionHoverColour = vec(1, 1, 1);
        captionClickColour = vec(1, 0.6, 0.3);

    }
    for k, v in pairs(tab) do
        tab2[k] = v
    end
    return gfx_hud_object_add(`/common/hud/Button`, tab2)
end

hud_class `Main` {
	colour = vec(1, 1, 1)*0.2;
	texture = `background.dds`;
	padding = 0;
	
	init = function (self)
		self.needsParentResizedCallbacks = true;

        local function add_button(...) return add_button_to(self, ...) end

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
				self.activeGuis["projectsButton"] = add_button(ypos, {
					caption = "Projects";
					pressedCallback = function() 
						self.desc.projects()
					end
				})
				ypos = ypos - 50
				self.activeGuis["debugmodeButton"] = add_button(ypos, {
					caption = "Debug Mode";
					pressedCallback = function() 
						self.activeMenu = "project"
						game_manager:enter("Debug Mode")
					end
				})
				ypos = ypos - 50
                self.activeGuis["editorButton"] = add_button(ypos, {
                    caption = "Editor";
                    pressedCallback = function() 
                        self.activeMenu = "editor"
                        game_manager:enter("Map Editor")
                    end
                })
                ypos = ypos - 50
				self.activeGuis["settingsButton"] = add_button(ypos, {
					caption = "Settings";
					pressedCallback = function() 
						self.desc.settings()
					end
				})
				ypos = ypos - 50
				self.activeGuis["exitButton"] = add_button(ypos, {
					caption = "Exit";
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
				
				
				self.activeGuis["backButton"] = add_button(0, {
					caption = "<";
					parent = self;
                    position = vec(-400, 220);
                    size = vec(40, 40);
					pressedCallback = function() 
						self.desc.main()
					end
				})
			end;
			
			projects = function()
				self:clearMenu() --Will clear all active guis
				self.activeMenu = "projects"
				local currentPosition = -3 --Starting Y position of game modes buttons
				local first = 0
				for key,value in spairs(game_manager.gameModes) do
					if key ~= "Map Editor" and key ~= "Debug Mode" then
						self.activeGuis[key] = add_button(0, {
                            zOrder=1;
							caption = key;
                            image = game_manager.gameThumbs[key];
                            desc = game_manager.gameDescriptions[key];
							parent = self;
							position = vec2(-230, currentPosition * -50);
							isSelected = false;
							pressedCallback = function(button)
								for k in pairs (self.activeGuis) do
									safe_destroy(self.activeGuis[k])
								end
								self.activeGuis = {}
								self.activeMenu = "project"
								game_manager:enter(key)
							end;
                            stateChangeCallback = function (button, old_state, new_state)
                                if new_state == "HOVER" then
                                    self.activeGuis["description"]:setValue(button.desc);
                                    self.activeGuis["image"].texture=button.image;
                                    self.activeGuis["image"].colour = vec(1, 1, 1)
                                end
							end;
						})
						if first == 0 then first = self.activeGuis[key] end
						currentPosition = currentPosition + 1
					end
				end
				self.activeGuis["image"] = gfx_hud_object_add(`/common/hud/Rect`, {
					-- texture = `/common/hud/LoadingScreen/GritLogo.png`;
					colour = vec(0.5, 0.5, 0.5);
					parent = self;
					position = vec(105, 70);
					size = vec(400, 200);
				})
				self.activeGuis["description"] = gfx_hud_object_add(`/common/hud/Label`, {
					font = `/common/fonts/ArialBold18`;
  					parent = self;
					size = vec(400, 24);
                    position = vec(105, -40);
					textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
					alignment = "CENTER";
					value = "Select a project"; 
					alpha = 1;
                    enabled = true;
				})
				self.activeGuis["backButton"] = add_button(0, {
					caption = "<";
                    position = vec(-400, 150);
                    size = vec(40, 40);
					pressedCallback = function() 
						self.desc.main()
					end
				})
				--self:selectOption(first) --Need to implement where the first one is selected
			end
		};
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

        local function add_button(...) add_button_to(self, ...) end

		self.activeGuis = {};
		
		self.activeGuis["gritLogo"] = gfx_hud_object_add(`/common/hud/Rect`, {
			size = vec(300, 150);
			texture = `/common/hud/LoadingScreen/GritLogo.png`;
			parent = self;
			position = vec2(0, (gfx_window_size().y / 2) - 250);
		})
		self.activeGuis["resume"] = add_button(0, {
			caption = "Resume";
			pressedCallback = function() 
				self:setEnabled(false)
			end
		})
		self.activeGuis["return"] = add_button(-50, {
			caption = "Return to main menu";
			pressedCallback = function() 
				game_manager:exit()
			end
		})
		self.activeGuis["exitButton"] = add_button(-100, {
			caption = "Exit";
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
