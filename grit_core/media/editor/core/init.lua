in_editor = true
if current_level == nil then
	current_level = {}
end
level = nil
default_game_mode = "detached_game"

function vlen(v1, v2)
    return math.sqrt(math.pow(v1.x-v2.x, 2)+math.pow(v1.y-v2.y, 2)+math.pow(v1.z-v2.z, 2))
end

-- loads all editor configurations, you can delete these files to reset default
-- configurations
if not pcall(function()include(`../config/config.lua`) end) then
	include `defaultconfig/config.lua`
end
if not pcall(function() include(`../config/interface.lua`) end) then
	include `defaultconfig/interface.lua`
end
if not pcall(function() include(`../config/recent.lua`) end) then
	include `defaultconfig/recent.lua`
end

include `widget_manager/init.lua`
include `GritLevel/init.lua`
include `directory_list.lua`
include `hud/init.lua`
include `windows/open_save_level.lua`
include `assets/init.lua`

include `defaultmap/init.lua`

include `core.lua`

include `edenv.lua`
env_recompute()

gfx_option("BLOOM_ITERATIONS", 4)
gfx_global_exposure(1.3)
gfx_option("BLOOM_THRESHOLD", 5.7)

-- disable all Grit default HUD
speedo.enabled = false
clock.enabled = false
compass.enabled = false
stats.enabled = false
ch.enabled = false
debug_layer.colour = vec(0.3, 0.35, 0.4)
debug_layer.texture = `icons/softdeg2.png`

console.alpha = 0.6
console.text.colour = vec(2, 2, 2)

debug_layer:selectConsole(false)

-- Create editor interface
include `init_editor_interface.lua`

GED:set_editor_bindings()

-- if doesn't have any object on scene, load default map
if next(object_all()) == nil then
	GED:open_level("/editor/core/defaultmap/default2.lvl")
	current_level.file_name = ""
elseif current_level == nil then
	GED:new_level()
end

GED:set_widget_mode(1)
widget_menu[1]:select(true)

include`welcome_msg.lua`