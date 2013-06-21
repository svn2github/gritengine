-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading gfx.lua")

GFX = GFX or { }

function GFX:showStats(b)
        self.timeCounter.visible = b
        self.fpsCounter.visible = b
        self.microsCounter.visible = b
        self.streamerCounter.visible = b
        self.luaCounter.visible = b
        self.memCounter.visible = b
        self.gbufferTriangleBatchCounter.visible = b
        self.deferredTriangleBatchCounter.visible = b
        self.shadowTriangleBatchCounter.visible = b
        self.reflectionTriangleBatchCounter.visible = b
        self.totalTriangleBatchCounter.visible = b
end

function GFX.new()
        local self = { }

        self.queueAggressiveness = function () return 1 + 1*get_in_queue_size() end

        -- OVERLAY STUFF

        local opt = {font = "misc.fixed", charHeight = 13}

        self.timeCounter = get_hud_root():addChild("ShadowText",opt)
        self.timeCounter.resize = Hud.RIGHT(-130-1)

        self.fpsCounter = get_hud_root():addChild("ShadowText",opt)
        self.fpsCounter.resize = Hud.RIGHT(-117-1)

        self.microsCounter = get_hud_root():addChild("ShadowText",opt)
        self.microsCounter.resize = Hud.RIGHT(-104-1)

        self.streamerCounter = get_hud_root():addChild("ShadowText",opt)
        self.streamerCounter.resize = Hud.RIGHT(-91-1)

        self.luaCounter = get_hud_root():addChild("ShadowText",opt)
        self.luaCounter.resize = Hud.RIGHT(-78-1)

        self.memCounter = get_hud_root():addChild("ShadowText",opt)
        self.memCounter.resize = Hud.RIGHT(-65-1)

        self.gbufferTriangleBatchCounter = get_hud_root():addChild("ShadowText",opt)
        self.gbufferTriangleBatchCounter.resize = Hud.RIGHT(-52-1)

        self.deferredTriangleBatchCounter = get_hud_root():addChild("ShadowText",opt)
        self.deferredTriangleBatchCounter.resize = Hud.RIGHT(-39-1)

        self.shadowTriangleBatchCounter = get_hud_root():addChild("ShadowText",opt)
        self.shadowTriangleBatchCounter.resize = Hud.RIGHT(-26-1)

        self.reflectionTriangleBatchCounter = get_hud_root():addChild("ShadowText",opt)
        self.reflectionTriangleBatchCounter.resize = Hud.RIGHT(-13-1)

        self.totalTriangleBatchCounter = get_hud_root():addChild("ShadowText",opt)
        self.totalTriangleBatchCounter.resize = Hud.RIGHT(-1)


        self.frameTime = RunningStats.new(20)

        local last_time = seconds()
        local elapsed = 0

        local function frameCallback()

                give_queue_allowance(self:queueAggressiveness())
                --give_queue_allowance(10)

                if get_main_win().isActive then
                        physics_update_graphics(physics.enabled and physics.leftOver or 0)
                        if physics.debugWorld then physics_draw() end
                end

                local curr_time = seconds()
                elapsed = curr_time - last_time

                -- updates camera and some hud things
                player_ctrl:update(elapsed)

                streamer_centre(player_ctrl.camPos)
                object_do_frame_callbacks(elapsed) -- grit objects with frame callbacks

                local count, gfx_allocs, unacct_allocs
                do -- render a frame
                        if user_cfg.lowPowerMode then
                                --sleep_seconds(0.2 - elapsed)
                                sleep(math.floor(1000000*(0.2 - elapsed)))
                                --echo("Total frame time: "..elapsed)
                        end
                        count,unacct_allocs = get_alloc_stats()
                        reset_alloc_stats()
                        gfx_render(elapsed, player_ctrl.camPos, player_ctrl.camDir)
                        count, gfx_allocs = get_alloc_stats()
                        reset_alloc_stats()
                end
                local post_frame_time = seconds()
                --echo("Frame render time: "..(post_frame_time - curr_time))

                if get_main_win().isActive then
                        self.frameTime:add(elapsed)
                        last_time = curr_time

                        if self.timeCounter and self.timeCounter.visible then
                                self.timeCounter.text = "Time of day: "..format_time(env.secondsSinceMidnight)
                        end
                        if self.microsCounter and self.microsCounter.visible then
                                local max_ft = nonzero(1000000*self.frameTime:calcMax())
                                local avg_ft = nonzero(1000000*self.frameTime:calcAverage())
                                local min_ft = nonzero(1000000*self.frameTime:calcMin())
                                self.microsCounter.text = string.format("Frame micros min / avg / max: %3.0f / %3.0f / %3.0f",min_ft,avg_ft,max_ft)
                        end
                        if self.fpsCounter and self.fpsCounter.visible then
                                local max_ft = nonzero(self.frameTime:calcMax())
                                local avg_ft = nonzero(self.frameTime:calcAverage())
                                local min_ft = nonzero(self.frameTime:calcMin())
                                self.fpsCounter.text = string.format("FPS min / avg / max: %3.0f / %3.0f / %3.0f",1/max_ft,1/avg_ft,1/min_ft)
                                local fail = 0.015 / min_ft -- 15ms is frame max time
                                local green = clamp(fail,0,1)
                                local red = clamp(1-fail,0,1)
                                self.fpsCounter:setColourTop(red,green,0,1)
                                self.fpsCounter:setColourBottom(red,green,0,1)
                        end
                        if self.streamerCounter and self.streamerCounter.visible then
                                self.streamerCounter.text = string.format(
                                        "Classes / Objects / Activated: %6.0f / %6.0f / %6.0f",
                                        class_count(), object_count(), object_count_activated())
                        end
                        if self.memCounter and self.memCounter.visible then
                                self.memCounter.text = string.format(
                                        "Mesh | Tex | Max || QI | QO: %dMB | %dMB | %dMB || I:%d | HO:%d | GO:%d",
                                        get_mesh_usage()/1024/1024,
                                        get_texture_usage()/1024/1024,
                                        (get_mesh_budget()+get_texture_budget())/1024/1024,
                                        get_in_queue_size(),
                                        get_out_queue_size_host(),
                                        get_out_queue_size_gpu());
                        end

                        local shadow1_bats, shadow1_tris, shadow1_micros,
                              shadow2_bats, shadow2_tris, shadow2_micros,
                              shadow3_bats, shadow3_tris, shadow3_micros,
                              left_gbuffer_bats, left_gbuffer_tris, left_gbuffer_micros,
                              left_deferred_bats, left_deferred_tris, left_deferred_micros,
                              right_gbuffer_bats, right_gbuffer_tris, right_gbuffer_micros,
                              right_deferred_bats, right_deferred_tris, right_deferred_micros = gfx_last_frame_stats()

                        local shadow_tris = shadow1_tris + shadow2_tris + shadow3_tris
                        local shadow_bats = shadow1_bats + shadow2_bats + shadow3_bats

                        if self.shadowTriangleBatchCounter and self.shadowTriangleBatchCounter.visible then
                                self.shadowTriangleBatchCounter.text = string.format("Shad Tris / Bats: %d / %d",shadow_tris, shadow_bats)
                        end
                        if self.gbufferTriangleBatchCounter and self.gbufferTriangleBatchCounter.visible then
                                self.gbufferTriangleBatchCounter.text = string.format("Gbuf Tris / Bats: %d / %d", left_gbuffer_tris, left_gbuffer_bats)
                        end
                        if self.deferredTriangleBatchCounter and self.deferredTriangleBatchCounter.visible then
                                self.deferredTriangleBatchCounter.text = string.format("Deff Tris / Bats: %d / %d", left_deferred_tris, left_gbuffer_bats)
                        end
                        if self.reflectionTriangleBatchCounter and self.reflectionTriangleBatchCounter.visible then
                                local reflection_tris, reflection_bats = 0,0
                                self.reflectionTriangleBatchCounter.text = string.format(
                                        "Refl Tris / Bats: %d / %d",reflection_tris, reflection_bats)
                        end

                        if self.totalTriangleBatchCounter and self.totalTriangleBatchCounter.visible then
                                local total_tris = shadow_tris + left_gbuffer_tris + left_deferred_tris + right_gbuffer_tris + right_deferred_tris
                                local total_bats = shadow_bats + left_gbuffer_bats + left_deferred_bats + right_gbuffer_bats + right_deferred_bats
                                self.totalTriangleBatchCounter.text = string.format(
                                        "Total Tris / Bats: %d / %d",total_tris, total_bats)
                        end

                        if self.luaCounter and self.luaCounter.visible then
                                self.luaCounter.text = string.format(
                                        "Lua: %.1fMB (%dK) (G+%d) (P+%d) (U+%d)",
                                        collectgarbage("count")/1024,
                                        count/1000,
                                        gfx_allocs,
                                        physics and physics.allocs or 0,
                                        unacct_allocs)
                        end

                end

        end

        main.frameCallbacks:insert("GFX.frameCallback",frameCallback)

        make_instance(self, GFX)

        return self

end

function GFX:destroy()
        safe_destroy(self.microsCounter) self.microsCounter = nil
        safe_destroy(self.timeCounter) self.timeCounter = nil
        safe_destroy(self.fpsCounter) self.fpsCounter = nil
        safe_destroy(self.streamerCounter) self.streamerCounter = nil
        safe_destroy(self.deferredTriangleBatchCounter) self.deferredTriangleBatchCounter = nil
        safe_destroy(self.reflectionTriangleBatchCounter) self.reflectionTriangleBatchCounter = nil
        safe_destroy(self.shadowTriangleBatchCounter) self.shadowTriangleBatchCounter = nil
        safe_destroy(self.totalTriangleBatchCounter) self.totalTriangleBatchCounter = nil
        safe_destroy(self.memCounter) self.memCounter = nil
        safe_destroy(self.luaCounter) self.luaCounter = nil
        main.frameCallbacks:removeByName("GFX.frameCallback")
end

if gfx ~= nil then
        gfx:destroy()
end
gfx = GFX.new()

