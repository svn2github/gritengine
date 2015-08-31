-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Main` {

  --[[Test code
  for k in pairs(game_manager.gameModes) do print(k) end
  
  for key,value in pairs(game_manager.gameModes) do print(key,value) end
  
  ]]--
  colour = vec(1, 1, 1)*0.2;
  --texture = `background.dds`;

  padding = 16;

  init = function (self)
    self.needsParentResizedCallbacks = true;
    self.needsFrameCallbacks = true;

    self.settings = {
      mouseInvert={
        name="Invert Mouse";
        defaut=true;
        --settingValue=user_cfg.mouseInvert;
      }
    };

    self.gui = {

    }

    self.selectedOption = "";

    self.content = ""; --Leave empty as the self.setMenu is what changes this to ensure the menu is setup correctly.
    self.setMenu = "Main Menu";

    self.menuGritTitle = gfx_hud_object_add(`/common/hud/Rect`, {
        size = vec(300, 150);
        texture = `/common/hud/LoadingScreen/GritLogo.png`;
        parent = self;
        position = vec2(0, 0);
      });

    self.gamemodeLoaderButton = gfx_hud_object_add(`Button`, {
        size = vec(210,40);
        font = `/common/fonts/Impact24`;
        caption = "Gamemode Loader";
        parent = self;
        position = vec2(0, 0);
        edgeColour = vec(1, 102/255, 0)*1.0;
        edgePosition = vec2(-(210 / 2) + 5, 0);
        pressedCallback = function() 
          menu.setMenu = "Gamemodes"
        end
      });

    --[[self.playgroundGamemodeLoaderButton = gfx_hud_object_add(`Button`, {
        size = vec(210,40);
        font = `/common/fonts/Impact24`;
        caption = "Playground";
        parent = self;
        position = vec2(0, 0);
        edgeColour = vec(0, 1, 0)*1.0;
        edgePosition = vec2(-(210 / 2) + 5, 0);
        pressedCallback = function() 
          menu.setMenu = "Game Menu"
          game_manager:enter("Playground")
        end
      });]]--

self.editorButton = gfx_hud_object_add(`Button`, {
    size = vec(210,40);
    font = `/common/fonts/Impact24`;
    caption = "Editor";
    parent = self;
    position = vec2(0, -50);
    edgeColour = vec(0, 102/255, 1)*1.0;
    edgePosition = vec2(-(210 / 2) + 5, 0);
    pressedCallback = function() 
      menu.setMenu = "Editor"
      game_manager:enter("Map Editor")
    end
  });

self.settingsButton = gfx_hud_object_add(`Button`, {
    size = vec(210,40);
    font = `/common/fonts/Impact24`;
    caption = "Settings";
    parent = self;
    position = vec2(0, -100);
    edgeColour = vec(1, 1, 0);
    edgePosition = vec2(-(210 / 2) + 5, 0);
    pressedCallback = function() 
      menu.setMenu = "Settings"
    end
  });

self.exitButton = gfx_hud_object_add(`Button`, {
    size = vec(210,40);
    font = `/common/fonts/Impact24`;
    caption = "Exit";
    parent = self;
    position = vec2(0, -150);
    edgeColour = vec(1, 0, 1)*1.0;
    edgePosition = vec2(-(210 / 2) + 5, 0);
    pressedCallback = quit
  });

self.loadSettings = function(self)
  for key,value in pairs(menu.settings) do
    --print("The variable: ".. key .." with the name of ".. value.name .." is equal to ".. tostring(user_cfg[tostring(key)]) .."!") --Was used for debugging!
    menu.gui[key] = gfx_hud_object_add(`SettingEdit`, {
        size = vec(gfx_window_size().x - 200,40);
        font = `/common/fonts/Impact24`;
        caption = value.name;
        valueLocation = user_cfg;
        valueKey = tostring(key);
        parent = menu;
        position = vec2(0, -10);
      })
    --menu.gui[key].set.position
  end
end;

self.loadGamemodes = function(self)
  local currentPosition = 0 --Starting Y position of game modes buttons
  local first = 0
  for key,value in pairs(game_manager.gameModes) do
    if key ~= "Map Editor" then
      print("The gamemode: ".. key .." was loaded!") --Used for debugging
      menu.gui[key] = gfx_hud_object_add(`GameModeButton`, {
          size = vec(200,40);
          font = `/common/fonts/Impact24`;
          caption = key;
          parent = menu;
          position = vec2(-205, currentPosition);
          pressedCallback = function(self)
            menu:selectOption(self)
          end;
        })
      if(first == 0)then first = menu.gui[key] end
      currentPosition = currentPosition - 50
    end
  end
  menu.gui["description"] = gfx_hud_object_add(`/common/hud/Rect`, {
      font = `/common/fonts/Impact50`;
      alpha = 0.5;
      colour = vec(0.1, 0.1, 0.1) * 0.5;
      text = "Choose a game mode to see the description! This game mode menu is incomplete and may have bugs, report the bugs on the Grit Engine forum at www.gritengine.com!";
      parent = menu;
      position = vec(105, -80);
      size = vec(400, 200);
      textWrap = vec(400, 400);
    })
  menu.gui["load"] = gfx_hud_object_add(`Button`, {
      caption = "Load Gamemode";
      font = `/common/fonts/Impact24`;
      size = vec(210, 40);
      position = vec2(215, -(gfx_window_size().y / 2) + 100);
      parent = menu;
      pressedCallback = function(self)
        menu.setMenu = "Game Menu"
        for k in pairs (menu.gui) do
          safe_destroy(menu.gui[k])
        end
        menu.gui = {}
        game_manager:enter(menu.selectedOption)
      end;
    })
  menu:selectOption(first)
end;

self.backButton = gfx_hud_object_add(`Button`, {
    size = vec(210,40);
    font = `/common/fonts/Impact24`;
    caption = "Go Back";
    parent = self;
    position = vec2(0, -(gfx_window_size().y / 2) + 100);
    edgeColour = vec(1, 0, 0)*1.0;
    edgeSize = vec2(10,40);
    edgePosition = vec2(-(210 / 2) + 5, 0);
    pressedCallback = function() 
      menu.setMenu = "Main Menu"
      for k in pairs (menu.gui) do
        safe_destroy(menu.gui[k])
      end
      menu.gui = {}
    end
  });
self.gameResumeButton = gfx_hud_object_add(`Button`, {
    size = vec(210,40);
    font = `/common/fonts/Impact24`;
    caption = "Resume";
    parent = self;
    position = vec2(0, -50);
    edgeColour = vec(1, 1, 1)*1.0;
    edgeSize = vec2(10,40);
    edgePosition = vec2(-(210 / 2) + 5, 0);
    pressedCallback = function() 
      menu:setEnabled(false)
    end
  })
end;

parentResizedCallback = function (self, psize)
  self.position = vec(psize.x/2, psize.y/2)
  self.size = psize
end;

frameCallback = function (self, elapsed)
  if(self.content ~= self.setMenu)then
    self.content = self.setMenu
    self:setUpContent(self.content)
  end
end;

setEnabled = function(self, v)
  if(menu.setMenu == "Game Menu" or menu.setMenu == "Editor")then
    self.enabled = v
    menu_binds.modal = v
    --menu:setContent(menu.mainContent) --Coming soon --Or not, never needed it, doing it a different way
  else
    self.enabled = true
    menu_binds.modal = true
  end
end;

setUpContent = function (self, v)
  self.menuGritTitle.enabled = false
  self.gamemodeLoaderButton.enabled = false
  self.editorButton.enabled = false
  self.settingsButton.enabled = false
  self.exitButton.enabled = false
  self.backButton.enabled = false
  --self.playgroundGamemodeLoaderButton.enabled = false
  self.gameResumeButton.enabled = false
  if(v == "Main Menu")then
    self.menuGritTitle.enabled = true
    self.gamemodeLoaderButton.enabled = true
    self.editorButton.enabled = true
    self.settingsButton.enabled = true
    self.exitButton.enabled = true
    self.menuGritTitle.position = vec2(0, (gfx_window_size().y / 2) - 250)
  elseif(v == "Settings")then
    self.menuGritTitle.enabled = true
    self.menuGritTitle.position = vec2(0, (gfx_window_size().y / 2) - 100)
    self.backButton.enabled = true
    self.loadSettings() -- Leave disabled until the settings loading works properly!
  elseif(v == "Gamemodes")then
    self.menuGritTitle.enabled = true
    self.menuGritTitle.position = vec2(0, (gfx_window_size().y / 2) - 100)
    self.backButton.enabled = true
    --self.playgroundGamemodeLoaderButton.enabled = true --Remove after 7/31/2015
    self.loadGamemodes() -- Leave disabled until the Gamemodes loading works properly!
  elseif(v == "Game Menu")then
    self.settingsButton.enabled = false --Set to true once the settings menu works in game like its supposed to!
    self.gameResumeButton.enabled = true
    self.exitButton.enabled = true
  elseif(v == "Editor")then
    self.settingsButton.enabled = false --Set to true once the settings menu works in game like its supposed to!
    self.gameResumeButton.enabled = true
    self.exitButton.enabled = true
  end
end;

selectOption = function (self, v)
  for key,value in pairs(menu.gui) do
    print(key, value)
    if(value.isSelected ~= nil)then
      if(value == v)then
        value.isSelected = true
        menu.selectedOption = key
      else
        value.isSelected = false
      end
      value.Update(value)
    end
  end
end;

escape = function(self)
end;
}