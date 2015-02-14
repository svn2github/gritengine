-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print(YELLOW..BOLD.."Initializing Editor")

-- used to indicate if in the editor or not, see a example on map files
in_editor = true
CurrentLevel = {}
default_game_mode = "detached_game"

editor = {}
-- selected object
editor.selected = {}
-- selection mode
editor.selection = {}
editor.selection.mode = 1 -- 0 select, 1 translate, 2 rotate, 3 scale
editor.selection.dragging = nil

-- holds editor camera position and rotation to get back when stop playing
editor_camera = {}
editor_camera.pos = {}
editor_camera.rot = {}

editor.map_dir = "level_templates"
game_mode_dir = "gamemodes"

if editor.directory == nil then
	editor.directory = "editor"
end


include "core.lua"
include "hud/init.lua"

-- loads all editor configurations, you can delete these files to reset default configurations
safe_include "../config/config.lua"
safe_include "../config/interface.lua"
safe_include "../config/recent.lua"

-- destroy all Grit default HUD
--safe_destroy(ch)
safe_destroy(speedo)
safe_destroy(clock)
safe_destroy(compass)
safe_destroy(stats)

-- Create editor interface
include "init_editor_interface.lua"

set_editor_bindings()
new_level()
