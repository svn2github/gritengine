-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading gfx.lua")

if gfx == nil then

    gfx = { }

else

    main.frameCallbacks:removeByName("GFX.frameCallback")

end

gfx.frameTime = RunningStats.new(20);
gfx.count = 0;
gfx.unacctAllocs = 0;
gfx.allocs = 0;
gfx.shadow1 = { 0, 0, 0};
gfx.shadow2 = { 0, 0, 0};
gfx.shadow3 = { 0, 0, 0};
gfx.left = { gbuffer = {0, 0, 0}, deferred = {0, 0, 0} };
gfx.right = { gbuffer = {0, 0, 0}, deferred = {0, 0, 0} };
gfx.allShadowStats = function ()
    return gfx.shadow1[1] + gfx.shadow2[1] + gfx.shadow3[1],
           gfx.shadow1[2] + gfx.shadow2[2] + gfx.shadow3[2],
           gfx.shadow1[3] + gfx.shadow2[3] + gfx.shadow3[3]
end;

local last_time = seconds()

main.frameCallbacks:insert("GFX.frameCallback", function ()

        give_queue_allowance(1 + 1*get_in_queue_size())
        --give_queue_allowance(10)

        if gfx_window_active() then
                physics_update_graphics(physics.enabled and physics.leftOver or 0)
                if physics.debugWorld then physics_draw() end
        end

        local curr_time = seconds()
        local elapsed = curr_time - last_time
        last_time = curr_time

        -- updates camera and some hud things
        player_ctrl:update(elapsed)

        streamer_centre(player_ctrl.camPos)
        object_do_frame_callbacks(elapsed) -- grit objects with frame callbacks

        if gfx_window_active() then
                gfx.frameTime:add(elapsed)
        end

        do -- render a frame
                if user_cfg.lowPowerMode then
                        --sleep_seconds(0.2 - elapsed)
                        sleep(math.floor(1000000*(0.2 - elapsed)))
                        --print("Total frame time: "..elapsed)
                end
                gfx.count, gfx.unacctAllocs = get_alloc_stats()
                reset_alloc_stats()
                gfx_render(elapsed, player_ctrl.camPos, player_ctrl.camDir)
                gfx.count, gfx.allocs = get_alloc_stats()
                reset_alloc_stats()
        end
        --local post_frame_time = seconds()
        --print("Frame render time: "..(post_frame_time - curr_time))

        gfx.shadow1[1], gfx.shadow1[2], gfx.shadow1[3],
        gfx.shadow2[1], gfx.shadow2[2], gfx.shadow2[3],
        gfx.shadow3[1], gfx.shadow3[2], gfx.shadow3[3],
        gfx.left.gbuffer[1], gfx.left.gbuffer[2], gfx.left.gbuffer[3],
        gfx.left.deferred[1], gfx.left.deferred[2], gfx.left.deferred[3],
        gfx.right.gbuffer[1], gfx.right.gbuffer[2], gfx.right.gbuffer[3],
        gfx.right.deferred[1], gfx.right.deferred[2], gfx.right.deferred[3] = gfx_last_frame_stats()

end)
