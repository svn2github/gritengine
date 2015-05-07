
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

        editor_core_binds.enabled = true
        editor_edit_binds.enabled = true
        editor_debug_binds.enabled = true


        -- disable all Grit default HUD
        --speedo.enabled = false
        clock.enabled = false
        compass.enabled = false
        stats.enabled = false
        ch.enabled = false

        editor_init_windows()

        main.physicsEnabled = false
        main.streamerCentre = vec(0, 0, 0)
        --main.camPos = vec(0, 0, 0)
        --main.camQuat = Q_ID
        main.audioCentrePos = vec(0, 0, 0);
        main.audioCentreVel = vec(0, 0, 0);
        main.audioCentreQuat = quat(1, 0, 0, 0);
		-- TODO: user select if want to open a default map or not
		if true and not next(object_all()) then
			GED:openLevel(`/editor/core/defaultmap/defaultmap.lvl`)
		else
			GED:newLevel(next(object_all()))
		end
		
        GED:setWidgetMode(1)
        widget_menu[1]:select(true)

        print(BOLD..GREEN..[[
            ╭────────────────────────────────────╮
            │  Welcome to Grit Editor! (v0.001)  │
            ╰────────────────────────────────────╯
        ]])
		notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
		-- TEMPORARY
		main.physicsEnabled = true
		ticker.enabled=false
    end;

    frameCallback = function (self, elapsed_secs)
        GED:frameCallback(elapsed_secs)
    end;

    stepCallback = function (self, elapsed_secs)
    end;

    mouseMove = function (self, rel)
    end;

    destroy = function (self)
		widget_manager:unselect()
		
        GED:saveEditorInterface()
        -- current_level = nil
        -- if level ~= nil then
            -- level = nil
        -- end
        
        editor_core_binds.enabled = false
        editor_edit_binds.enabled = false
        editor_debug_binds.enabled = false

        editor_interface.menubar:destroy()
        editor_interface.toolbar:destroy()
        editor_interface.statusbar:destroy()
        
        destroy_all_editor_menus()		
        destroy_all_editor_windows()
        
		GED.currentWindow = nil
		
        safe_destroy(left_toolbar)
        left_toolbar = nil
    end;
}
    
game_manager:define("Integrated Development Environment", editor)
