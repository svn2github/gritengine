
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

include `icons/init.lua`

include `widget_manager/init.lua`
include `GritMap/init.lua`
include `directory_list.lua`
include `assets/init.lua`
include `core.lua`

-- TEMPORARY
include`navigation_system.lua`

current_map = nil

in_editor = false

editor = {
    init = function (self)
        -- [dcunnin] Ideally we would declare things earlier and only instantiate them at this
        -- point.  However all the code is mixed up right now.
		
		
		in_editor = true

		include `init_editor_interface.lua`

        playing_binds.enabled = true
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = false
        editor_core_binds.enabled = true
        editor_edit_binds.enabled = false
        editor_debug_binds.enabled = false

        self.lastMouseMoveTime = seconds()

        -- Start location:  Seems as good a place as any...
        main.camPos = vec(0, 0, 10)
        GED.camYaw = 0
        GED.camPitch = 0
		
		-- set default values/update values for window content
        editor_init_windows()
		
		if editor_cfg.load_startup_map then
			GED:openMap(editor_cfg.startup_map)
		else
			gfx_option("RENDER_SKY", false)
		end
		
		notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
        notify("You need to toggle physics to move an object :(", vec(1, 0, 0), vec(1, 1, 1), 5)
        GED:setDebugMode(false)
		
		ticker.text.enabled = false
		
    end;

    frameCallback = function (self, elapsed_secs)
        GED:frameCallback(elapsed_secs)
    end;

    stepCallback = function (self, elapsed_secs)
        GED:stepCallback(elapsed_secs)
    end;

    mouseMove = function (self, rel)
        local sens = user_cfg.mouseSensitivity

        local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)

        GED.camYaw = (GED.camYaw + rel2.x) % 360
        GED.camPitch = clamp(GED.camPitch + rel2.y, -90, 90)

        main.camQuat = quat(GED.camYaw, V_DOWN) * quat(GED.camPitch, V_EAST)
        main.audioCentreQuat = main.camQuat
        self.lastMouseMoveTime = seconds()
    end;

    receiveButton = function(self, button, state)
        editor_receive_button(button, state)
    end;

    destroy = function (self)
		widget_manager:unselect()
		
		GED:saveEditorConfig()
        -- GED:saveEditorInterface()
		
        -- current_map = nil
        -- if gritmap ~= nil then
            -- gritmap = nil
        -- end
        
        playing_binds.enabled = false
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = false
        editor_core_binds.enabled = false
        editor_core_move_binds.enabled = false
        editor_edit_binds.enabled = false
        editor_debug_binds.enabled = false
        editor_debug_ghost_binds.enabled = false

		ticker.text.enabled = false
		
		gfx_option("RENDER_SKY", true)
		
		editor_interface.map_editor_page:destroy()
		editor_interface:destroy()
    end;
}
    
game_manager:define("Map Editor", editor)
