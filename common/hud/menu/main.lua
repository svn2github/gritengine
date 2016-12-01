-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local menu_alpha = 0.7
local menu_bg = vec(0.1, 0.1, 0.1)
local menu_fg = vec(0.5, 0.5, 0.5)
local menu_greyed = vec(0.2, 0.2, 0.2)
local menu_hover = vec(1, 1, 1)
local menu_click = vec(1, 0.6, 0.3)
local menu_font = `/common/fonts/Verdana18`;

local function menu_button(tab)
    local tab2 = {
        size = vec(230,40);

        alpha = menu_alpha;
        backgroundTexture = false;
        backgroundPassiveColour = menu_bg;
        backgroundHoverColour = menu_bg;
        backgroundClickColour = menu_bg * vec(1, 1, 0);
        backgroundGreyedColour = menu_bg;

        borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`;
        borderPassiveColour = menu_fg;
        borderHoverColour = menu_hover;
        borderClickColour = menu_click;
        borderGreyedColour = menu_greyed;

        captionFont = menu_font;
        captionPassiveColour = menu_fg;
        captionHoverColour = menu_hover;
        captionClickColour = menu_click;
        captionGreyedColour = menu_greyed;

    }
    for k, v in pairs(tab) do
        tab2[k] = v
    end
    return hud_object `/common/hud/Button` (tab2)
end

-- For a simple menu, override stackMenu to return a list of buttons.
-- For a custom menu, override buildChildren to build whatever GUI you want.
hud_class `MenuPage` {

    colour = vec(0.2, 0.2, 0.2),

    texture = `background.dds`,

    init = function (self)
        self:buildChildren()
        self.needsInputCallbacks = true
    end,

    stackMenu = function (self)
        -- Subclasses override this.
    end,

    buildChildren = function(self)
        self.stack = hud_object `/common/hud/StackY` {
            parent = self,
            padding = 10,
            hud_object `/common/hud/Rect` {
                size = vec(300, 150);
                texture = `/common/hud/LoadingScreen/GritLogo.png`;
            }, 
            vec(0, 20),
            self:stackMenu()
        }
    end,

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
    end,

    buttonCallback = function (self, ev)
        if ev == "+Escape" then
            self:escapePressed()
        end
    end,

    escapePressed = function (self)
    end,
}

menu_pages = {
    main = function()
        return hud_object `MenuPage` {
            stackMenu = function(self)
                return
                menu_button {
                    caption = "Projects";
                    pressedCallback = function() 
                        menu_show("projects")
                    end
                },
                menu_button {
                    caption = "Debug Mode";
                    pressedCallback = function() 
                        debug_mode()
                    end
                },
                menu_button {
                    caption = "Editor";
                    pressedCallback = function() 
                        game_manager:enter("Map Editor")
                    end
                },
                menu_button {
                    caption = "Settings";
                    pressedCallback = function() 
                        menu_show("settings", "main")
                    end
                },
                menu_button {
                    caption = "Exit";
                    pressedCallback = quit
                }
            end;
        }
    end;

    settings = function(last_menu)
        return hud_object `MenuPage` {
            changePage = function(self, dir)
                -- dir is 1 or -1
                self.pages[self.currentPage].enabled = false
                self.currentPage = math.clamp(1, self.currentPage + dir, #self.pages)
                self.pages[self.currentPage].enabled = true
                self.pagePrevButton:setGreyed(self.currentPage == 1)
                self.pageNextButton:setGreyed(self.currentPage == #self.pages)
            end;
            buildChildren = function(self)

                user_cfg.autoUpdate = false

                self.settings = { }
                for key, typ in pairs(user_cfg.spec) do
                    self.settings[key] = hud_object `SettingEdit` {
                        colour = menu_bg,
                        foregroundColour = menu_fg,
                        hoverColour = menu_hover,
                        clickColour = menu_click,
                        alpha = menu_alpha,
                        font = `/common/fonts/Verdana18`,
                        settingName = key,
                        settingType = typ,
                        settingValue = user_cfg[key],
                        settingChangedCallback = function (self2, v)
                            user_cfg[key] = v
                            self.applyButton:setGreyed(false)
                            self.resetButton:setGreyed(false)
                        end,
                    }
                end

                -- TODO(dcunnin): Replace this with an actual scroll area.
                self.pages = { }
                local page = { }
                for key, typ in spairs(user_cfg.spec) do
                    page[#page + 1] = self.settings[key]
                    if #page == 10 then
                        self.pages[#self.pages + 1] = hud_object `/common/hud/StackY` {
                            parent = self,
                            enabled = false,
                            padding = 0,
                            unpack(page)
                        }
                        page = { }
                    end
                end
                if #page > 0 then
                    while #page < 10 do
                        page[#page + 1] = vec(40, 40)
                    end
                    self.pages[#self.pages + 1] = hud_object `/common/hud/StackY` {
                        parent = self,
                        enabled = false,
                        padding = 0,
                        unpack(page),
                    }
                    page = { }
                end

                self.pages[1].enabled = true
                self.currentPage = 1

                self.pagePrevButton = menu_button {
                    parent = self,
                    caption = "<";
                    position = vec(240, 240);
                    size = vec(40, 40);
                    greyed = true;
                    pressedCallback = function() 
                        self:changePage(-1)
                    end
                }
                
                self.pageNextButton = menu_button {
                    parent = self,
                    caption = ">";
                    position = vec(280, 240);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        self:changePage(1)
                    end
                }
                
                self.backButton = menu_button {
                    parent = self,
                    caption = "<";
                    position = vec(-280, 240);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        user_cfg:abort()
                        menu_show(last_menu)
                    end
                }

                self.applyButton = menu_button {
                    parent = self,
                    greyed = true,
                    caption = "Apply",
                    position = vec(-200, 240);
                    size = vec(80, 40);
                    pressedCallback = function(self2)
                        user_cfg.autoUpdate = true
                        user_cfg.autoUpdate = false
                        self.resetButton:setGreyed(true)
                        self.applyButton:setGreyed(true)
                    end
                }

                self.resetButton = menu_button {
                    parent = self,
                    greyed = true,
                    caption = "Reset",
                    position = vec(-110, 240);
                    size = vec(80, 40);
                    pressedCallback = function(self2)
                        user_cfg:abort()
                        for key, typ in spairs(user_cfg.spec) do
                            self.settings[key]:setValue(user_cfg[key])
                        end
                        self.resetButton:setGreyed(true)
                        self.applyButton:setGreyed(true)
                    end
                }

            end,

            escapePressed = function (self)
                user_cfg:abort()
                menu_show(last_menu)
            end,
        }
    end;

    projects = function()
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local image = hud_object `/common/hud/Rect` {
                    -- texture = `/common/hud/LoadingScreen/GritLogo.png`;
                    colour = vec(0.5, 0.5, 0.5);
                    size = vec(400, 200);
                }
                local description = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTRE";
                    value = "Select a project"; 
                    alpha = 1;
                    enabled = true;
                }
                local game_mode_buttons = {}
                for key, game_mode in spairs(game_manager.gameModes) do
                    if key ~= "Map Editor" then
                        game_mode_buttons[#game_mode_buttons + 1] = menu_button {
                            caption = key,
                            pressedCallback = function(self)
                                game_manager:enter(key)
                            end;
                            stateChangeCallback = function (self, old_state, new_state)
                                if new_state == "HOVER" then
                                    description:setValue(game_mode.description)
                                    image.texture = game_mode.previewImage
                                    image.colour = vec(1, 1, 1)
                                end
                            end;
                        }
                    end
                end
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 40,
                    { align = "TOP" },
                    menu_button {
                        caption = "<";
                        size = vec(40, 40);
                        pressedCallback = function() 
                            menu_show('main')
                        end
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 10,
                        table.unpack(game_mode_buttons),
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        image,
                        description,
                    },
                }
            end,
            escapePressed = function (self)
                menu_show('main')
            end,
        }
    end;

    pause = function()
        game_manager:setPause(true)
        return hud_object `MenuPage` {
            alpha = 0,
            stackMenu = function(self)
                return
                menu_button {
                    caption = "Resume";
                    pressedCallback = function() 
                        self:resume()
                    end
                },
                menu_button {
                    caption = "Settings";
                    pressedCallback = function() 
                        menu_show("settings", "pause")
                    end
                },
                menu_button {
                    caption = "Return to main menu";
                    pressedCallback = function() 
                        game_manager:exit()
                    end
                },
                menu_button {
                    caption = "Exit";
                    pressedCallback = quit
                }
            end;
            escapePressed = function (self)
                self:resume()
            end,
            resume = function (self)
                game_manager:setPause(false)
                menu_show(nil)
            end,
        }
    end;
}

menu_active = menu_active or nil

-- Show the menu of the given name, replacing the current one if there is one.
-- This function handles the overall UI aspects of displaying the menu.
function menu_show(name, ...)
    safe_destroy(menu_active)
    if name == nil then
        menu_binds.modal = false
        return
    end
    local inner_menu = menu_pages[name](...)
    menu_active = hud_object `/common/hud/Stretcher` { child=inner_menu, zOrder=14 }
    menu_binds.modal = true
end
