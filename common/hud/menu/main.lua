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

hud_class `MenuPage` {
    colour = vec(1, 1, 1)*0.2;
    texture = `background.dds`;
    init = function (self)
        self:buildChildren()
    end;
    buildChildren = function (self)
        -- Subclasses override this.
    end;
}

menu_pages = {
    main = function()
        return gfx_hud_object_add(`MenuPage`, {
            buildChildren = function(self)

                self.gritLogo = gfx_hud_object_add(`/common/hud/Rect`, {
                    size = vec(300, 150);
                    texture = `/common/hud/LoadingScreen/GritLogo.png`;
                    parent = self;
                    position = vec2(0, (gfx_window_size().y / 2) - 250);
                })
                
                local ypos = 0
                self.projectsButton = add_button_to(self, ypos, {
                    caption = "Projects";
                    pressedCallback = function() 
                        menu_show("projects")
                    end
                })
                ypos = ypos - 50
                self.debugmodeButton = add_button_to(self, ypos, {
                    caption = "Debug Mode";
                    pressedCallback = function() 
                        menu_show(nil)
                        debug_mode()
                    end
                })
                ypos = ypos - 50
                self.editorButton = add_button_to(self, ypos, {
                    caption = "Editor";
                    pressedCallback = function() 
                        menu_show(nil)
                        game_manager:enter("Map Editor")
                    end
                })
                ypos = ypos - 50
                self.settingsButton = add_button_to(self, ypos, {
                    caption = "Settings";
                    pressedCallback = function() 
                        menu_show("settings")
                    end
                })
                ypos = ypos - 50
                self.exitButton = add_button_to(self, ypos, {
                    caption = "Exit";
                    pressedCallback = quit
                })
            end;
        })
    end;

    settings = function()
        return gfx_hud_object_add(`MenuPage`, {
            buildChildren = function(self)
                local lastPos = -10;
                local mmenu = gui.list({parent=self, align=guialign.bottom, offset=vec(0, 25)})
                mmenu.alpha = 0
                self.menu = mmenu
                
                -- menu.activeGuis.scrollarea = gui.scrollarea({parent=menu, size = vec(gfx_window_size().x - 200, 450), expand=false, align=guialign.bottom})
                
                
                for key,value in pairs(user_cfg.c) do --Not sure what the difference is between user_cfg.p and user_cfg.c
                    if type(value) == "boolean" then
                        print("The variable: ".. key .." with the name of ".. key .." is equal to ".. tostring(user_cfg[tostring(key)]) .."!") --Was used for debugging!
                        mmenu:addItem(
                            gfx_hud_object_add(`SettingEdit`, {
                                size = vec(gfx_window_size().x - 200, 40);
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
                
                self.backButton = add_button_to(self, 0, {
                    caption = "<";
                    position = vec(-400, 220);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        menu_show("main")
                    end
                })
            end;
        })
    end;

    projects = function()
        return gfx_hud_object_add(`MenuPage`, {
            buildChildren = function(self)
                local currentPosition = -3 --Starting Y position of game modes buttons
                self.gameModeButtons = {}
                for key,value in spairs(game_manager.gameModes) do
                    if key ~= "Map Editor" and key ~= "Debug Mode" then
                        self[key] = add_button_to(self, 0, {
                            caption = key;
                            image = game_manager.gameThumbs[key];
                            desc = game_manager.gameDescriptions[key];
                            position = vec2(-230, currentPosition * -50);
                            pressedCallback = function(button)
                                menu_show(nil)
                                game_manager:enter(key)
                            end;
                            stateChangeCallback = function (button, old_state, new_state)
                                if new_state == "HOVER" then
                                    self.description:setValue(button.desc);
                                    self.image.texture = button.image;
                                    self.image.colour = vec(1, 1, 1)
                                end
                            end;
                        })
                        currentPosition = currentPosition + 1
                    end
                end
                self.image = gfx_hud_object_add(`/common/hud/Rect`, {
                    -- texture = `/common/hud/LoadingScreen/GritLogo.png`;
                    colour = vec(0.5, 0.5, 0.5);
                    parent = self;
                    position = vec(105, 70);
                    size = vec(400, 200);
                })
                self.description = gfx_hud_object_add(`/common/hud/Label`, {
                    font = `/common/fonts/Verdana18`;
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
                self.backButton = add_button_to(self, 0, {
                    caption = "<";
                    position = vec(-400, 150);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        menu_show('main')
                    end
                })
            end;
        })
    end;

    pause = function()
        main.physicsPaused = true
        return gfx_hud_object_add(`MenuPage`, {
            buildChildren = function(self)
                self.gritLogo = gfx_hud_object_add(`/common/hud/Rect`, {
                    size = vec(300, 150);
                    texture = `/common/hud/LoadingScreen/GritLogo.png`;
                    parent = self;
                    position = vec2(0, (gfx_window_size().y / 2) - 250);
                })
                self.resume = add_button_to(self, 0, {
                    caption = "Resume";
                    pressedCallback = function() 
                        main.physicsPaused = false
                        menu_show(nil)
                    end
                })
                self.mainMenu = add_button_to(self, -50, {
                    caption = "Return to main menu";
                    pressedCallback = function() 
                        game_manager:exit()
                        menu_show("main")
                    end
                })
                self.exitButton = add_button_to(self, -100, {
                    caption = "Exit";
                    pressedCallback = quit
                })
            end;
        })
    end;
}

menu_active = nil

-- Show the menu of the given name, replacing the current one if there is one.
-- This function handles the overall UI aspects of displaying the menu.
function menu_show(name)
    safe_destroy(menu_active)
    if name == nil then
        menu_binds.modal = false
        return
    end
    local inner_menu = menu_pages[name]()
    menu_active = gfx_hud_object_add(`/common/hud/Stretcher`, { child=inner_menu, zOrder=14 })
    menu_binds.modal = true
end
