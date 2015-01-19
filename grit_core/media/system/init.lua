-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--lua5.2 it's so amazingly compatible
math.mod = math.fmod

print "Initialising script..."
io.stdout:setvbuf("no") -- no output buffering
collectgarbage("setpause",110) -- begin a gc cycle after blah% increase in ram use
collectgarbage("setstepmul",150) -- collect at blah% the rate of new object creation

--set_texture_verbose(false)
--set_mesh_verbose(false)
--set_keyb_verbose(true)

initialise_all_resource_groups()

include `strict.lua` 

include `abbrev.lua` 

include `util.lua` 

if audio_master_volume == nil then audio_master_volume = function() end end

print("Starting game engine...")

main = {
        shouldQuit = false,
        frameCallbacks = CallbackReg.new()
}

function quit()
        main.shouldQuit = true
end

function main:run (...)

        -- execute cmdline arguments on console
        local arg = ""
        for i=2,select('#',...) do
                arg = arg.." "..select(i,...)
        end
        if #arg > 0 then
                console:exec(arg:sub(2))
        end

        local last_focus = true

        local failName = {}

        -- rendering loop
        while not clicked_close() and not main.shouldQuit do

                if last_focus ~= have_focus() then
                    last_focus = have_focus()
                    input_filter_flush()
                end

                local presses = get_keyb_presses()
                local moved,buttons,x,y,rel_x,rel_y = get_mouse_events()

                if moved then
                    input_filter_trickle_mouse_move(vec(rel_x, rel_y), vec(x, y))
                end

                for _,key in ipairs(presses) do
                    if get_keyb_verbose() then print("Lua key event: "..key) end
                    input_filter_trickle_button(key)
                end

                for _,button in ipairs(buttons) do
                    if get_keyb_verbose() then print("Lua mouse event: "..button) end
                    input_filter_trickle_button(button)
                end


                xpcall(function ()
                        failName.name = nil
                        main.frameCallbacks:executeExtended(function (name,cb,...)
                                failName.name = name
                                --t:reset()
                                if cb == nil then
                                        --print(RED.."Callback was nil: "..name)
                                        return true
                                end
                                local result = cb(...)
                                --local us = t.us
                                --if us>5000 and name~="GFX.frameCallback" then
                                --        print("callback \""..name.."\" took "..us/1000 .."ms ")
                                --end
                                return result
                        end)
                        failName.name = nil

                        if not gfx_window_active() then
                                --sleep_seconds(0.2)
                                sleep(200000)
                        end

                end,error_handler)

                if failName.name then
                        print("Removed frameCallback: "..failName.name)
                        main.frameCallbacks:removeByName(failName.name)
                end

        end

        save_user_cfg()

        env:shutdown()
        
end


include `unicode_test_strings.lua` 


include `gfx.lua` 

include `materials.lua` 

include `default_shader.lua` 

include `physics.lua` 
include `physical_materials.lua` 
include `procedural_objects.lua` 
include `procedural_batches.lua` 

include `pid_ctrl.lua` 

include `capturer.lua` 

include `player_ctrl.lua` 

include `configuration.lua` 

include `env.lua` 

include `audio.lua` 

include `net.lua` 

include `/common/init.lua` 

include `/vehicles/init.lua` 

safe_include `/user_script.lua` 

include `welcome_msg.lua`
