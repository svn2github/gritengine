-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include "base.lua"
include "stack.lua"

include "Button/init.lua"
include "label.lua"
include "scale.lua"
include "EnvCycleEditor/init.lua"

include "Compass/init.lua"
include "speedo.lua"

-- Crosshair
ch = gfx_hud_object_add("Rect", {texture="CrossHair.png", parent=hud_center})

-- Compass / Pos / Speedo
compass = gfx_hud_object_add("Compass", {parent=hud_top_right, position=vector2(-64, -64)})
speedo = gfx_hud_object_add("Speedo", {parent=hud_top_right})
speedo.position=vector2(-64, -128 - speedo.size.y/2)

-- EnvCycleEditor
local env_cycle_editor_enabled = false
if env_cycle_editor ~= nil and alive(env_cycle_editor) then
	env_cycle_editor_enabled = env_cycle_editor.enabled
	env_cycle_editor:destroy()
end
env_cycle_editor = gfx_hud_object_add("EnvCycleEditor", { } )
env_cycle_editor.position = env_cycle_editor.size / 2 + vector2(4,36)
env_cycle_editor.enabled = env_cycle_editor_enabled
env_cycle_editor_button = gfx_hud_object_add("Button", {
    pressedCallback = function (self)
        env_cycle_editor.enabled = not env_cycle_editor.enabled
    end;
    caption = "Env Cycle Editor";
    position = vector2(64,16);
    size = vector2(128, 32);
})
