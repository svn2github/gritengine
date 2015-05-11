
-- This file is responsible for preloading all required assets and definitions for the editor.
-- It also contains the logic for setting up / destroying the editor (which is represented as a
-- 'game mode').



-- loads all editor configurations, you can delete these files to reset default
-- configurations
include `defaultconfig/config.lua`
safe_include `../config/config.lua`
include `defaultconfig/interface.lua`
safe_include `../config/interface.lua`
include `defaultconfig/recent.lua`
safe_include `../config/recent.lua`

-- [dcunnin] We should put all this stuff in /common, thereby building a reusable asset library.
include `defaultmap/init.lua`

include`default_game_mode.lua`

include `themes/init.lua`

include `widget_manager/init.lua`
include `GritLevel/init.lua`
include `directory_list.lua`
include `hud/init.lua`
include `windows/open_save_level.lua`
include `assets/init.lua`
include `core.lua`

current_level = nil

editor = {
    init = function (self)
        -- [dcunnin] Ideally we would declare things earlier and only instantiate them at this
        -- point.  However all the code is mixed up right now.
		
        GED.currentTheme = editor_themes[editor_interface_cfg.theme]
		
		include `init_editor_interface.lua`

        
        playing_binds.enabled = true
        editor_core_binds.enabled = true

        -- Start location:  Seems as good a place as any...
        main.camPos = vec(0, 0, 10)
        GED.camYaw = 0
        GED.camPitch = 0

        editor_init_windows()

        GED:openLevel(`/editor/core/defaultmap/defaultmap.lvl`)
		
        GED:setWidgetMode(1)
        widget_menu[1]:select(true)

		notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
        
        GED:setDebugMode(false)

    end;

    frameCallback = function (self, elapsed_secs)
        GED:frameCallback(elapsed_secs)
    end;

    stepCallback = function (self, elapsed_secs)
    end;

    mouseMove = function (self, rel)
        local sens = user_cfg.mouseSensitivity

        local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)

        GED.camYaw = (GED.camYaw + rel2.x) % 360
        GED.camPitch = clamp(GED.camPitch + rel2.y, -90, 90)

        main.camQuat = quat(GED.camYaw, V_DOWN) * quat(GED.camPitch, V_EAST)
        main.audioCentreQuat = main.camQuat
    end;

    destroy = function (self)
		widget_manager:unselect()
		
        GED:saveEditorInterface()
        -- current_level = nil
        -- if level ~= nil then
            -- level = nil
        -- end
        
        playing_binds.enabled = false
        editor_core_binds.enabled = false
        editor_edit_binds.enabled = false
        editor_debug_binds.enabled = false

        editor_interface.menubar:destroy()
        editor_interface.toolbar:destroy()
        editor_interface.statusbar:destroy()
        
        destroy_all_editor_menus()		
        destroy_all_editor_windows()
        
		GED.currentWindow = nil
		
        left_toolbar = safe_destroy(left_toolbar)
    end;
}
    
game_manager:define("Map Editor", editor)
