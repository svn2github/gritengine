-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `base.lua`

include `stack.lua`

include `Button/init.lua`
include `label.lua`
include `editbox.lua`
include `scale.lua`
include `EnvCycleEditor/init.lua`
include `ColourPicker/init.lua`
include `controls/init.lua`
include `console/init.lua`
include `menu/init.lua`

include `Compass/init.lua`
include `speedo.lua`
include `clock.lua`
include `stats.lua`

include `MusicPlayer/init.lua`

-- Ticker
local buffer
local other_buffer
if ticker ~= nil then
    buffer = ticker.buffer
    other_buffer = ticker.timeBuffer
    safe_destroy(ticker)
end
ticker = gfx_hud_object_add(`console/Ticker`, {buffer=buffer, timeBuffer=other_buffer, shadow=vec(1,-1), zOrder=7})
ticker.enabled = false

-- Console
local console_focused = true
if console ~= nil then
    console_focused = hud_focus == console
    buffer = console.buffer
    other_buffer = console.cmdBuffer
    safe_destroy(console)
else
    buffer = nil
end
console = gfx_hud_object_add(`console/Console`, {buffer=buffer, cmdBuffer=other_buffer, shadow=vec(1,-1)})
console_frame = gfx_hud_object_add(`Stretcher`, {
    child=console, zOrder=7, position=vec(500, 300);
    calcRect = function (self, psize)
        return 40, psize.y * 0.6, psize.x, psize.y
    end;
})
if console_focused then
    hud_focus_grab(console)
end

-- Menu
if menu ~= nil then
    buffer = menu.enabled
    safe_destroy(menu)
end
menu = gfx_hud_object_add(`menu/Main`, {zOrder=6})
menu.enabled = (buffer or false)

-- Crosshair
safe_destroy(ch)
ch = gfx_hud_object_add(`Rect`, {texture=`CrossHair.png`, parent=hud_center})

-- Music player
safe_destroy(music_player)
music_player = gfx_hud_object_add(`MusicPlayer`, {parent=hud_bottom_left})
music_player.position = music_player.size / 2 + vec(50,10)

-- Compass / Pos / Speedo
safe_destroy(compass)
compass = gfx_hud_object_add(`Compass`, {parent=hud_top_right, position=vec(-64, -64)})

safe_destroy(speedo)
speedo = gfx_hud_object_add(`Speedo`, {parent=hud_top_right})
speedo.position=vec(-64, -128 - speedo.size.y/2)

safe_destroy(clock)
clock = gfx_hud_object_add(`Clock`, { parent=hud_top_right, size=vec(190,50) })
clock.position = -clock.size/2 - vec(130, 4)

safe_destroy(stats)
stats = gfx_hud_object_add(`Stats`, {
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
            local colour = vec(red, green, 0)
            return text, colour
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
                    "HRAM | GRAM || QI | HO | GO: %d/%dMB | %d/%dMB || I:%d | HO:%d | GO:%d",
                    host_ram_used(),
                    host_ram_available(),
                    gfx_gpu_ram_used(),
                    gfx_gpu_ram_available(),
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
            self:setSelection{"fps", "micros", "streamer", "mem", "shadow", "gbuffer", "deferred", "total", "lua" }
        else
            self:setSelection{"fps"}
        end
        self.minimal = not self.minimal
    end;
})

if env_cycle_editor ~= nil and not env_cycle_editor.destroyed then
    safe_destroy(env_cycle_editor)
end
env_cycle_editor = gfx_hud_object_add(`EnvCycleEditor`, { } )
env_cycle_editor.position = env_cycle_editor.size/2 + vec(50, 10)

include `debug.lua`
