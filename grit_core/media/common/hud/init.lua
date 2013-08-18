-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include "base.lua"
include "stack.lua"

include "Button/init.lua"
include "label.lua"
include "scale.lua"
include "EnvCycleEditor/init.lua"

include "Compass/init.lua"
include "speedo.lua"
include "stats.lua"

-- Crosshair
ch = gfx_hud_object_add("Rect", {texture="CrossHair.png", parent=hud_center})

-- Compass / Pos / Speedo
compass = gfx_hud_object_add("Compass", {parent=hud_top_right, position=vector2(-64, -64)})
speedo = gfx_hud_object_add("Speedo", {parent=hud_top_right})
speedo.position=vector2(-64, -128 - speedo.size.y/2)

safe_destroy(stats)
stats = gfx_hud_object_add("Stats", {
    width = 440,
    parent = hud_bottom_right,
    stats = {
        fps = function ()
            local max_ft = nonzero(gfx.frameTime:calcMax())
            local avg_ft = nonzero(gfx.frameTime:calcAverage())
            local min_ft = nonzero(gfx.frameTime:calcMin())
            local text = string.format("FPS min / avg / max: %3.0f / %3.0f / %3.0f",1/max_ft,1/avg_ft,1/min_ft)
            local fail = 0.015 / min_ft -- 15ms is frame max time
            local green = clamp(fail,0,1)
            local red = clamp(1-fail,0,1)
            local colour = vector3(red, green, 0)
            return text, colour
        end;

        time = function() 
            local secs = env.secondsSinceMidnight
            return string.format("Time of day: %02d:%02d:%02d", math.mod(math.floor(secs/60/60),24),
                                                   math.mod(math.floor(secs/60),60),
                                                   math.mod(secs,60))
        end;


        micros = function()
            local max_ft = nonzero(1000000*gfx.frameTime:calcMax())
            local avg_ft = nonzero(1000000*gfx.frameTime:calcAverage())
            local min_ft = nonzero(1000000*gfx.frameTime:calcMin())
            return string.format("Frame micros min / avg / max: %3.0f / %3.0f / %3.0f",min_ft,avg_ft,max_ft)
        end;

        streamer = function()
            return string.format("Classes / Objects / Activated: %6.0f / %6.0f / %6.0f", class_count(), object_count(), object_count_activated())
        end;

        mem = function()
            return string.format(
                    "Mesh | Tex | Max || QI | QO: %dMB | %dMB | %dMB || I:%d | HO:%d | GO:%d",
                    get_mesh_usage()/1024/1024,
                    get_texture_usage()/1024/1024,
                    (get_mesh_budget()+get_texture_budget())/1024/1024,
                    get_in_queue_size(),
                    get_out_queue_size_host(),
                    get_out_queue_size_gpu());
        end;
        
        shadow = function()
            local shadow_bats, shadow_tris = gfx:allShadowStats()
            return string.format("Shad Tris / Bats: %d / %d", shadow_tris, shadow_bats)
        end;
        gbuffer = function()
            return string.format("Gbuf Tris / Bats: %d / %d", gfx.left.gbuffer[2], gfx.left.gbuffer[1])
        end;
        deferred = function()
            return string.format("Deff Tris / Bats: %d / %d", gfx.left.deferred[2], gfx.left.gbuffer[1])
        end;
        total = function()
            local shadow_tris, shadow_bats = gfx:allShadowStats()
            local total_tris = shadow_tris + gfx.left.gbuffer[2] + gfx.left.deferred[2] + gfx.right.gbuffer[2] + gfx.right.deferred[2]
            local total_bats = shadow_bats + gfx.left.gbuffer[1] + gfx.left.deferred[1] + gfx.right.gbuffer[1] + gfx.right.deferred[1]
            return string.format("Total Tris / Bats: %d / %d", total_tris, total_bats)
        end;

        lua = function ()
            return string.format(
                    "Lua: %.1fMB (%dK) (G+%d) (P+%d) (U+%d)",
                    collectgarbage("count")/1024,
                    gfx.count/1000,
                    gfx.allocs,
                    physics and physics.allocs or 0,
                    gfx.unacctAllocs)
        end;
                
    };
    keys = { "fps" };
    minimal = true;
    onClick = function (self)
        if self.minimal then
            self:setSelection{"fps", "time", "micros", "streamer", "mem", "shadow", "gbuffer", "deferred", "total", "lua" }
        else
            self:setSelection{"fps"}
        end
        self.minimal = not self.minimal
    end;
})
--stats.position=vector2(-1,1) * stats.size / 2

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
