
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

include `widget_manager.lua`
include `GritMapManager.lua`
include `directory_list.lua`
include `Pickle.lua`
include `util.lua`
include `core.lua`

current_map = nil

in_editor = false

-- Temporary
-- Test navmesh
test = function()
	navigation_add_gfx_body(pick_obj().instance.gfx)
	navigation_update_params()
	navigation_build_nav_mesh()
end
-- Test navmesh
test2 = function()
	local objal = object_all()
	local gfxobjs = {}
	for i = 1, #objal do
		if not objal[i].destroyed and objal[i].instance ~= nil and objal[i].instance.gfx ~= nil then
			gfxobjs[#gfxobjs+1] = objal[i].instance.gfx
		end
	end
	
	navigation_add_gfx_bodies(gfxobjs)
	navigation_update_params()
	navigation_build_nav_mesh()
end

editor = {
    init = function (self)
		navigation_reset()
	
		gfx_option("WIREFRAME_SOLID", true) -- i don't know why but when selecting a object it just shows wireframe, so TEMPORARY?
		-- fix glow in the arrows
		gfx_option("BLOOM_THRESHOLD", 3)
	
        -- [dcunnin] Ideally we would declare things earlier and only instantiate them at this
        -- point.  However all the code is mixed up right now.
		
		ticker.text.colour = V_ID*2
		
		self.debug_mode_text = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.debug_mode_text.parent = hud_bottom_left
		self.debug_mode_text.text = "Mouse left: Use Weapon\nMouse Scroll: Change Weapon\nF: Controll Object\nTab: Console\nF1: Open debug mode menu (TODO)\nF5: Return Editor"
		self.debug_mode_text.position = vec(self.debug_mode_text.size.x/2+10, self.debug_mode_text.size.y)
		
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
		end
		
		notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
        GED:setDebugMode(false)
		
		ticker.text.enabled = false
		env.clockRate = 0
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
		widget_manager:unselectAll()
		
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
		
		safe_destroy(self.debug_mode_text)
		
		gfx_option("RENDER_SKY", true)
		
		editor_interface.map_editor_page:destroy()
		editor_interface:destroy()
		env.clockRate = 30
		navigation_reset()
		
		gfx_option("BLOOM_THRESHOLD", 1)
    end;
}
    
game_manager:define("Map Editor", editor)

function init_editor(map)
	game_manager:enter('Map Editor')
	if map ~= nil then
		GED:openMap(map)
	end
end
