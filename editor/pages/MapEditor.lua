function open_map_dialog()
    gui.open_file_dialog({
        title = "Open Map";
        parent = hud_centre;
        position = vec(0, 0);
        resizeable = true;
        size = vec2(560, 390);
        min_size = vec2(470, 290);
        colour = _current_theme.colours.window.background;
        alpha = 1;
        choices = { "Grit Map (*.gmap)", "Lua Script (*.lua)" };
        callback = function(self, str)
            str = '/' .. str
            if resource_exists(str) then
                local status, msg = pcall(game_manager.currentMode.openMap, game_manager.currentMode, str)
                if status then
                    notify("Loaded!", vec(0, 0.5, 1), V_ID)
                    -- error 'wat'
                    return true
                else
                    error_handler(msg)
                    notify("Error: Could not open map file!", vec(1, 0, 0), V_ID)
                end
            else
                notify("Error: Map file not found!", vec(1, 0, 0), V_ID)
            end
            return false
        end;    
    })
end

function save_map_dialog()
    gui.save_file_dialog({
        title = "Save Map";
        parent = hud_centre;
        position = vec(0, 0);
        resizeable = true;
        size = vec2(560, 390);
        min_size = vec2(470, 290);
        colour = _current_theme.colours.window.background;
        alpha = 1;
        choices = { "Grit Map (*.gmap)", "Lua Script (*.lua)" };
        callback = function(self, str)
            str = '/' .. str
            if resource_exists(str) then
                local save_overwrite = function (boolean)
                    if boolean then
                        local status, msg = pcall(game_manager.currentMode.saveCurrentMapAs, game_manager.currentMode, str)
                        if status then
                            notify("Saved!", vec(0, 1, 0), V_ID)
                            self:destroy()
                        else
                            error_handler(msg)
                            notify("Error!", vec(1, 0, 0), V_ID)
                        end
                    end
                end;
                create_dialog("SAVE", "Would you like to overwrite "..str.."?", "yesnocancel", save_overwrite)
                return false
            else
                local status, msg = pcall(game_manager.currentMode.saveCurrentMapAs, game_manager.currentMode, str)
                if status then
                    notify("Saved!", vec(0, 1, 0), V_ID)
                    return true
                else
                    error_handler(msg)
                    notify("Error!", vec(1, 0, 0), V_ID)
                    return false
                end
            end
        end;    
    })
end

local map_editor_page = {
    windows = {};
    
    select = function(self)
        self.menubar.enabled = true
        self.statusbar.enabled = true
        
        self.mlefttoolbar.enabled = true
    end;
    
    unselect = function(self)
        self.menubar.enabled = false
        self.statusbar.enabled = false

        self.mlefttoolbar.enabled = false
        
        self.menus.fileMenu.enabled = false
        self.menus.editMenu.enabled = false
        self.menus.viewMenu.enabled = false
        self.menus.gameMenu.enabled = false
        self.menus.helpMenu.enabled = false

        self.windows.content_browser.enabled = false
        --safe_destroy(self.windows.content_browser)
        self.windows.event_editor.enabled = false
        self.windows.level_properties.enabled = false
        self.windows.material_editor.enabled = false
        self.windows.object_properties.enabled = false
        self.windows.outliner.enabled = false
        self.windows.settings.enabled = false
    end;
    
    init = function(self)
        self.menubar = gui.menubar({
            parent = hud_centre;
            size = vec(20, 26);
            offset = vec(0, -29);
            expand_x = true;
            align = vec(0, 1);
            enabled = false;
        })
        self.menubar:init()
        self.menubar.enabled = false
        
        self.menus = {}
        self.menus.fileMenu = gui.menubar_menu({
            items = {
                {
                    callback = function()
                        game_manager.currentMode:newMap()
                    end;
                    name = "New";
                    tip = "Creates a new map";
                    icon = map_editor_icons.new15;
                },
                {
                    callback = function() game_manager.currentMode:openMap() end;
                    name = "Open";
                    tip = "Open a map";
                    icon = map_editor_icons.open15;
                },
                {},
                {
                    callback = function() game_manager.currentMode:saveCurrentMap() end;
                    name = "Save";
                    tip = "Save the current map";
                    icon = map_editor_icons.save15;
                },
                {
                    callback = function() game_manager.currentMode:saveCurrentMapAs() end;
                    name = "Save As";
                    tip = "Save as the current map";
                    icon = map_editor_icons.save_as15;
                },
                {},
                {
                    callback = function()
                        -- TODO: prompt if user want to save his work
                        game_manager.currentMode:saveEditorInterface()
                        game_manager:exit()
                    end;
                    name = "Exit";
                    tip = "Exit the editor";
                    icon = _gui_textures.verify.x;
                },
            };
        })
        
        self.menus.editMenu = gui.menubar_menu({
            items = {
                {
                    callback = function() game_manager.currentMode:undo() end;
                    name = "Undo";
                    tip = "Undo last action";
                    icon = map_editor_icons.undo;
                },
                {
                    callback = function() game_manager.currentMode:redo() end;
                    name = "Redo";
                    tip = "Redo last action";
                    icon = map_editor_icons.redo;
                },
                {},
                {
                    callback = function() game_manager.currentMode:cutObject() end;
                    name = "Cut";
                    tip = "Cut selected object";
                },
                {
                    callback = function() game_manager.currentMode:copyObject() end;
                    name = "Copy";
                    tip = "Copy selected object";
                },
                {
                    callback = function() game_manager.currentMode:pasteObject() end;
                    name = "Paste";
                    tip = "Paste object";
                },
                {
                    callback = function() if widget_manager.selectedObj ~= nil then game_manager.currentMode:duplicateSelection() end end;
                    name = "Duplicate";
                    tip = "Duplicate current selection";
                },
                {},
                {
                    callback = function() game_manager.currentMode:generateEnvCube(main.camPos) end;
                    name = "Gen Env Cubes";
                    tip = "Generate and apply env cube";
                    icon = map_editor_icons.solid;
                },    
                {},
                {
                    callback = function() open_window(self.windows.settings)end;
                    name = "Editor Settings";
                    tip = "Open Editor Settings";
                    icon = map_editor_icons.config;
                },
            };
        })

        self.menus.viewMenu = gui.menubar_menu({
            items = {
                {
                    callback = function(self2)
                        self.statusbar.enabled = not self.statusbar.enabled
                        self2.icon.enabled = self.statusbar.enabled
                    end;
                    name = "Show Status bar";
                    tip = "Show Status bar";
                    icon = _gui_textures.verify.v;
                },        
                {},
                -- {
                    -- callback = function()
                        -- open_window(self.windows.content_browser)
                    -- end;
                    -- name = "Content browser";
                    -- tip = "Open Content Browser window";
                    -- icon = map_editor_icons.content_browser;
                -- },
                
                -- {
                    -- callback = function() open_window(self.windows.event_editor) end;
                    -- name = "Event Editor";
                    -- tip = "Open Event Editor window";
                    -- icon = map_editor_icons.event_editor;
                -- },
                -- {
                    -- callback = function() open_window(self.windows.object_properties) end;
                    -- name = "Object Properties";
                    -- tip = "Open Object Properties window";
                    -- icon = map_editor_icons.object_properties;
                -- },
                -- {
                    -- callback = function() open_window(self.windows.material_editor) end;
                    -- name = "Material Editor";
                    -- tip = "Open Material Editor window";
                    -- icon = map_editor_icons.material_editor;
                -- },
                -- {
                    -- callback = function() open_window(self.windows.level_properties) end;
                    -- name = "Map properties";
                    -- tip = "Open Map Properties window";
                    -- icon = map_editor_icons.world_properties;
                -- },
                -- {
                    -- callback = function() open_window(self.windows.outliner) end;
                    -- name = "Outliner";
                    -- tip = "Open Outliner window";
                    -- icon = map_editor_icons.new;
                -- },        
                -- {},
                {
                    callback = function(self)
                        gfx_option("RENDER_SKY", not gfx_option("RENDER_SKY"))
                        self.icon.enabled = gfx_option("RENDER_SKY")
                    end;
                    name = "Render Sky";
                    tip = "Toggle render sky";
                    icon = _gui_textures.verify.v;
                },
                -- {
                    -- callback = function(self)
                        -- lens_flare.enabled = not lens_flare.enabled
                        -- self.icon.enabled = lens_flare.enabled
                    -- end;
                    -- name = "Show Lensflare";
                    -- tip = "Toggle lensflare";
                    -- icon = _gui_textures.verify.v;
                -- },
                {
                    callback = function(self)
                        gfx_option("FULLSCREEN", not gfx_option("FULLSCREEN"))
                        self.icon.enabled = gfx_option("FULLSCREEN")
                    end;
                    name = "Fullscreen";
                    tip = "Toggle fullscreen";
                    icon = _gui_textures.verify.v;
                    icon_enabled = gfx_option("FULLSCREEN");
                },
            };
        })

        self.menus.gameMenu = gui.menubar_menu({
            items = {
                {
                    callback = function() --game_manager.currentMode:play()
                    end;
                    name = "Play";
                    tip = "Play on viewport";
                    icon = map_editor_icons.controller;
                },
                {
                    callback = function() game_manager.currentMode:toggleDebugMode() end;
                    name = "Debug [F5]";
                    tip = "Enter Debug Mode";
                    icon = map_editor_icons.play;
                },        
                -- {},
                -- {
                    -- callback = function() game_manager.currentMode:runGame() end;
                    -- name = "Run game";
                    -- tip = "Run game in a new window";
                    -- icon = map_editor_icons.play;
                -- },
            };
        })

        self.menus.helpMenu = gui.menubar_menu({
            items = {
                {
                    callback = function() os.execute("start http://gritengine.com/grit_book/") end;
                    name = "Grit Book";
                    tip = "Opens Grit Book page";
                    -- icon=`icons/help.png`;
                },
                {},
                {
                    callback = function() os.execute("start http://gritengine.com/game-engine-forum/") end;
                    name = "Grit forums";
                    tip = "Opens Grit forums page";
                    -- icon=`icons/help.png`;
                },
                {
                    callback = function() os.execute("start http://www.gritengine.com/game-engine-wiki/HomePage") end;
                    name = "Grit wiki";
                    tip = "Opens Grit Wiki page";
                    -- icon=`icons/help.png`;
                },
                {
                    callback = function() os.execute("start http://www.gritengine.com/chat") end;
                    name = "Grit IRC";
                    tip = "Opens Grit IRC page";
                    -- icon=`icons/help.png`;
                },
                {},
                {
                    callback = function() os.execute("start http://gritengine.com/game-engine-forum/viewtopic.php?p=5344#p5344") end;
                    name = "Grit Editor Help";
                    tip = "Grit Editor Help";
                    icon = _gui_textures.help;
                },
                {
                    callback = function() os.execute("start http://www.gritengine.com/") end;
                    name = "About";
                    tip = "About Grit Editor";
                    -- icon=`icons/help.png`;
                },
            };
        })        
        
        self.menubar:append(self.menus.fileMenu, "File")
        self.menubar:append(self.menus.editMenu, "Edit")
        self.menubar:append(self.menus.viewMenu, "View")
        self.menubar:append(self.menus.gameMenu, "Game")
        self.menubar:append(self.menus.helpMenu, "Help")
        
        self.toolbar = gui.toolbar({
            parent = self.menubar;
            zOrder = 5;
            align = vec(-1, 0);
            offset = vec(self.menubar.lastButton+self.menubar.buttons[#self.menubar.buttons].size.x/2+20, 0);
            alpha = 0;
        })

        self.toolbar:addTool("New", map_editor_icons.new, (function(self) game_manager.currentMode:newMap() end), "Create new map")
        self.toolbar:addTool("Open", map_editor_icons.open, (function(self) game_manager.currentMode:openMap() end), "Open Map")
        self.toolbar:addTool("Save", map_editor_icons.save, (function(self) game_manager.currentMode:saveCurrentMap() end), "Save Current Map")
        self.toolbar:addTool("Save As", map_editor_icons.save_as, (function(self) game_manager.currentMode:saveCurrentMapAs() end), "Save Map As")
        self.toolbar:addSeparator()
        self.toolbar:addTool("Undo", map_editor_icons.undo, (function(self) game_manager.currentMode:undo() end), "Undo")
        self.toolbar:addTool("Redo", map_editor_icons.redo, (function(self) game_manager.currentMode:redo() end), "Redo")
        self.toolbar:addSeparator()
        
        self.toolbar:addTool("Local, Global", map_editor_icons.w_global, (function(self)
            if self.mode == nil then
                self.mode = "global"
            end
            
            if self.mode == "global" then
                self.texture = map_editor_icons.w_local
                self.mode = "local"
                widget_manager:setSpaceMode("local")
            else
                self.texture = map_editor_icons.w_global
                self.mode = "global"
                widget_manager:setSpaceMode("global")
            end
        end), "Set Widget Mode Global/Local")

        -- self.toolbar:addSeparator()
        self.toolbar:addTool("Pivot", map_editor_icons.pivot_centre, (function(self)
            if self.pivotPoint == nil then
                self.pivotPoint = 'centre point'
            end

            if self.pivotPoint == 'centre point' then
                self.pivotPoint = 'individual origins'
                self.texture = map_editor_icons.pivot_individual
            elseif self.pivotPoint == 'individual origins' then
                self.pivotPoint = 'active object'
                self.texture = map_editor_icons.pivot_selected
            elseif self.pivotPoint == 'active object' then
                self.pivotPoint = 'centre point'
                self.texture = map_editor_icons.pivot_centre
            end
            widget_manager:setPivotPoint(self.pivotPoint)
        end), "Set what to rotate around")

        self.toolbar:addSeparator()
        self.toolbar:addTool("Toggle Postprocessing", map_editor_icons.view_mode,(
            function(self)
                gfx_option("POST_PROCESSING", not gfx_option("POST_PROCESSING"))
            end
        ), "Toggle Postprocessing")
        self.toolbar:addTool("Solid mode", map_editor_icons.solid, (function(self) gfx_option("WIREFRAME", false) gfx_option("RENDER_SKY", true) end), "View Mode: Solid")
        self.toolbar:addTool("Wireframe mode", map_editor_icons.wireframe, (function(self) gfx_option("WIREFRAME_SOLID", false) gfx_option("WIREFRAME", true) gfx_option("RENDER_SKY", false) end), "View Mode: Wireframe")
        self.toolbar:addTool("Solid Wireframe Mode", map_editor_icons.solid_wireframe, (function(self) gfx_option("WIREFRAME_SOLID", true) gfx_option("WIREFRAME", true) gfx_option("RENDER_SKY", true) end), "View Mode: Solid Wireframe")
        self.toolbar:addSeparator()
        -- self.toolbar:addTool("Object properties", `../icons/properties.png`, (function() open_window(self.windows.object_properties) end), "")
        -- self.toolbar:addTool("Content Browser", `../icons/content_browser.png`, (function() open_window(self.windows.content_browser) end), "")
        -- self.toolbar:addTool("Event Editor", `../icons/event_editor.png`, (function() open_window(self.windows.event_editor) end), "")
        -- self.toolbar:addTool("Material Editor", `../icons/material_editor.png`, (function() open_window(self.windows.material_editor) end), "")
        -- self.toolbar:addTool("Level Configuration", `../icons/level_config.png`, (function() open_window(self.windows.level_properties) end), "")
        -- self.toolbar:addSeparator()
        self.toolbar:addTool("Show collision", map_editor_icons.show_collision, (
            function()
                physics_option("DEBUG_WIREFRAME", not physics_option("DEBUG_WIREFRAME"))
            end
        ), "Show Collision")
        self.toolbar:addTool("Toggle Physics", map_editor_icons.toggle_physics, (
            function (self)
                main.physicsEnabled = not main.physicsEnabled
            end
        ), "Toggle Physics")
        self.toolbar:addSeparator()
        self.toolbar:addTool("Editor Settings", map_editor_icons.config, (function() open_window(self.windows.settings) end), "Editor Settings")

        self.mlefttoolbar = gui.toolbar({
            parent = hud_centre;
            zOrder = 5;
            offset = vec(0, 20);
            expand_offset = vec(0, -75);
            expand_y = true;
            align = vec(-1, -1);
            orient = "vertical";
        })
        
        self.widget_menu = {}

        self.widget_menu[0] = self.mlefttoolbar:addTool("Select", map_editor_icons.select, (function(self)
             game_manager.currentMode:setWidgetMode("select")
            editor_interface.map_editor_page:unselectAllWidgets()
            self:select(true)
        end), "Selection Mode")

        self.widget_menu[1] = self.mlefttoolbar:addTool("Translate", map_editor_icons.translate, (function(self)
            game_manager.currentMode:setWidgetMode("translate")
            editor_interface.map_editor_page:unselectAllWidgets()
            self:select(true)
        end), "Translate")

        self.widget_menu[2] = self.mlefttoolbar:addTool("Rotate", map_editor_icons.rotate, (function(self)
            game_manager.currentMode:setWidgetMode("rotate")
            editor_interface.map_editor_page:unselectAllWidgets()
            self:select(true)
        end), "Rotate")

        -- self.widget_menu[3] = self.mlefttoolbar:addTool("Scale", `../icons/scale.png`, (function(self)
            -- game_manager.currentMode:setWidgetMode(3)
            -- editor_interface.map_editor_page:unselectAllWidgets()
            -- self:select(true)
        -- end), "Scale")

        assert(widget_manager.mode == 'translate')
        self.widget_menu[1]:select(true)
        
        self.mlefttoolbar:addSeparator()
        
        self.mlefttoolbar:addTool("Object Properties", map_editor_icons.object_properties, function(self) open_window(editor_interface.map_editor_page.windows.object_properties) end, "Map Properties")
        --self.mlefttoolbar:addTool("Content Browser", map_editor_icons.content_browser, function(self) if editor_interface.map_editor_page.windows.content_browser == nil or editor_interface.map_editor_page.windows.content_browser.destroyed then editor_interface.map_editor_page.windows.content_browser = create_content_browser() end end, "Content Browser")
        self.mlefttoolbar:addTool("Content Browser", map_editor_icons.content_browser, function(self) local wnd = editor_interface.map_editor_page.windows.content_browser if not wnd.destroyed then wnd.enabled = not wnd.enabled end end, "Content Browser")
        self.mlefttoolbar:addTool("Event Editor", map_editor_icons.event_editor, function(self) open_window(editor_interface.map_editor_page.windows.event_editor) end, "Event Editor")
        self.mlefttoolbar:addTool("Map Config", map_editor_icons.world_properties, function(self) open_window(editor_interface.map_editor_page.windows.level_properties) end, "Map Config")
        self.mlefttoolbar:addSeparator()
        
        -- Status bar
        self.statusbar = gui.statusbar({ parent = hud_bottom_left, size = vec(0, 20), needsFrameCallbacks = true })
        self.statusbar.needsFrameCallbacks = true
        
        local fid1, fsz1, fid2, fsz2
        fid1, fsz1 = self.statusbar:addField(" FPS: 000 ")
        --self.statusbar.widths[fid] = fsz+20
        
        fid2, fsz2 = self.statusbar:addField(" X: 0000.000 | Y: 0000.000 | Z: 0000.000 ")
        --self.statusbar.widths[fid] = fsz+20        

        self.statusbar.framecallback = function(self, elapsed)
            self.fields[fid1].text = string.format("FPS: %3.0f", 1/nonzero(main.gfxFrameTime:calcAverage()))
            -- self.fields[fid1].position = vec2(-self.fields[fid1].size.x/2, self.fields[fid1].position.y)
            
            local x,y,z = unpack(main.streamerCentre)
            self.fields[fid2].text = string.format("X: %5.3f | Y: %5.3f | Z: %5.3f", x, y, z)
        end;

        -- Windows
        -- TODO: replace all these windows to dynamic windows (properly declared as a class)
        -- self.windows.content_browser = gui.window('Content Browser', vec2(editor_interface_cfg.content_browser.position[1], editor_interface_cfg.content_browser.position[2]), true, vec2(editor_interface_cfg.content_browser.size[1], editor_interface_cfg.content_browser.size[2]), vec2(640, 400), vec2(800, 600))
        
        self.windows.content_browser = create_content_browser()
        
        self.windows.event_editor = gui.window('Event Editor', vec2(editor_interface_cfg.event_editor.position[1], editor_interface_cfg.event_editor.position[2]), true, vec2(editor_interface_cfg.event_editor.size[1], editor_interface_cfg.event_editor.size[2]), vec2(350, 200), vec2(800, 600))
        self.windows.level_properties = gui.window('Map Properties', vec2(editor_interface_cfg.level_properties.position[1], editor_interface_cfg.level_properties.position[2]), true, vec2(editor_interface_cfg.level_properties.size[1], editor_interface_cfg.level_properties.size[2]), vec2(380, 225), vec2(800, 600))
        self.windows.material_editor = gui.window('Material Editor', vec2(editor_interface_cfg.material_editor.position[1], editor_interface_cfg.material_editor.position[2]), true, vec2(editor_interface_cfg.material_editor.size[1], editor_interface_cfg.material_editor.size[2]), vec2(350, 200), vec2(800, 600))
        self.windows.object_properties = gui.window('Properties', vec2(editor_interface_cfg.object_properties.position[1], editor_interface_cfg.object_properties.position[2]), true, vec2(editor_interface_cfg.object_properties.size[1], editor_interface_cfg.object_properties.size[2]), vec2(350, 200), vec2(800, 600))
        self.windows.outliner = gui.window('Outliner', vec2(editor_interface_cfg.outliner.position[1], editor_interface_cfg.outliner.position[2]), true, vec2(editor_interface_cfg.outliner.size[1], editor_interface_cfg.outliner.size[2]), vec2(350, 200), vec2(800, 600))
        -- self.windows.settings = gui.window('Editor Settings', vec2(editor_interface_cfg.settings.position[1], editor_interface_cfg.settings.position[2]), true, vec2(editor_interface_cfg.settings.size[1], editor_interface_cfg.settings.size[2]), vec2(350, 200), vec2(800, 600))

        
        if self.windows.settings ~= nil and not self.windows.settings.destroyed then
            self.windows.settings:destroy()
        end
        
        self.windows.settings = hud_object `/editor/windows/map_editor/Settings` {
            title = "Editor Settings";
            parent = hud_centre;
            position = vec2(editor_interface_cfg.settings.position[1], editor_interface_cfg.settings.position[2]);
            resizeable = true;
            size = vec2(editor_interface_cfg.settings.size[1], editor_interface_cfg.settings.size[2]);
            min_size = vec2(470, 235);
            colour = _current_theme.colours.window.background;
            alpha = 1;    
        }
        _windows[#_windows+1] = self.windows.settings

        self.windows.event_editor.enabled = editor_interface_cfg.event_editor.opened
        self.windows.level_properties.enabled = editor_interface_cfg.level_properties.opened
        self.windows.material_editor.enabled = editor_interface_cfg.material_editor.opened
        self.windows.object_properties.enabled = editor_interface_cfg.object_properties.opened
        self.windows.outliner.enabled = editor_interface_cfg.outliner.opened
        self.windows.settings.enabled = editor_interface_cfg.settings.opened

        -- not working tools
        self.toolbar.tools[5].alpha = 0.3
        self.toolbar.tools[6].alpha = 0.3

        self.mlefttoolbar.tools[4].alpha = 0.3
        self.mlefttoolbar.tools[6].alpha = 0.3
        
        self:unselect()
        
        -- function show_viewport_context_menu()
            -- show_context_menu(
            -- {
                -- {
                    -- callback = function()
                        -- print("TODO")
                    -- end;
                    -- name = "Edit Properties";
                -- },
                -- {
                    -- callback = function()  end;
                    -- name = "Edit Object in Viewport";
                -- },
                -- {},
                -- {
                    -- callback = function()  end;
                    -- name = "Cut";
                -- },
                -- {
                    -- callback = function()  end;
                    -- name = "Copy";
                -- },
                
                -- {
                    -- callback = function()  end;
                    -- name = "Paste";
                -- },
                -- {
                    -- callback = function()  end;
                    -- name = "Duplicate";
                -- },    
                
                -- {
                    -- callback = function()  end;
                    -- name = "Delete";
                -- },
            -- })
        -- end
    end;
    destroy = function(self)
        safe_destroy(self.menubar)
        safe_destroy(self.statusbar)
        
        safe_destroy(self.mlefttoolbar)
        
        safe_destroy(self.menus.fileMenu)
        safe_destroy(self.menus.editMenu)
        safe_destroy(self.menus.viewMenu)
        safe_destroy(self.menus.gameMenu)
        safe_destroy(self.menus.helpMenu)
        
        safe_destroy(self.windows.content_browser)
        safe_destroy(self.windows.event_editor)
        safe_destroy(self.windows.level_properties)
        safe_destroy(self.windows.material_editor)
        safe_destroy(self.windows.object_properties)
        safe_destroy(self.windows.outliner)
        safe_destroy(self.windows.settings)
    end;
    
    unselectAllWidgets = function(self)
        self.widget_menu[0]:select(false)
        self.widget_menu[1]:select(false)
        self.widget_menu[2]:select(false)
        -- self.widget_menu[3]:select(false)
    end
    
}


-- used for restart editor GUI
local editor_tools = {}

local function restart_editor_tools()
    for i=1, #editor_tools do
        local tl = editor_tools[i]
        editor_interface.map_editor_page.mlefttoolbar:addTool(tl.name, tl.icon, tl.cb, tl.name)
    end
end

function restart_editor_gui()
    safe_include `/common/gui/init.lua`
    editor_interface.map_editor_page:destroy()
    editor_interface.map_editor_page:init()
    editor_interface.map_editor_page:select()
    editor_interface:reloadTheme()
    restart_editor_tools()
end

function add_editor_tool(name, icon, cb)
    editor_tools[#editor_tools+1] = {}
    editor_tools[#editor_tools].name = name
    editor_tools[#editor_tools].icon = icon
    editor_tools[#editor_tools].callback = cb
    editor_interface.map_editor_page.mlefttoolbar:addTool(name, icon, cb, name)
end

function make_map_editor_page()
    local self = make_instance({}, map_editor_page)
    self:init()

    local default_page = editor_interface:addPage({
        caption = "Map Editor",
        edge_colour = vec(1, 0, 0),
        onSelect = function() self:select() end,
        onUnselect =  function() self:unselect() end,
        closebtn = false
    })
    default_page:select()

    return self
end
