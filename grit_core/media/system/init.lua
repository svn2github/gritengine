-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print ("Initialising script...")
io.stdout:setvbuf("no") -- no output buffering
collectgarbage("setpause",110) -- begin a gc cycle after blah% increase in ram use
collectgarbage("setstepmul",150) -- collect at blah% the rate of new object creation

set_texture_verbose(false)
set_mesh_verbose(false)
--set_keyb_verbose(true)

initialise_all_resource_groups()

include("strict.lua")

include("abbrev.lua")

include("util.lua")

include("hud_materials.lua")
include("hud.lua")

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

                
                if last_focus and not have_focus() then
                        keyb_flush() -- get rid of any sticky keys
                        last_focus = false
                        ui:updateGrabbed()
                end

                if not last_focus and have_focus() then
                        last_focus = true
                        ui:updateGrabbed()
                end


                xpcall(function ()
                        failName.name = nil
                        main.frameCallbacks:executeExtended(function (name,cb,path,...)
                                failName.name = name
                                --t:reset()
                                if cb == nil then
                                        --echo(RED.."Callback was nil: "..name)
                                        return true
                                end
                                path_stack_push_dir(path)
                                local result = cb(...)
                                path_stack_pop()
                                --local us = t.us
                                --if us>5000 and name~="GFX.frameCallback" then
                                --        print("callback \""..name.."\" took "..us/1000 .."ms ")
                                --end
                                return result
                        end)
                        failName.name = nil

                        if get_main_win().isActive == false then
                                --sleep_seconds(0.2)
                                sleep(200000)
                        end

                end,error_handler)

                if failName.name then
                        path_stack_pop()
                        echo("Removed frameCallback: "..failName.name)
                        main.frameCallbacks:removeByName(failName.name)
                end

        end

        save_user_cfg()

        env:shutdown()
        
end



sm = get_sm()



include("ui.lua")

include("gfx.lua")

include("materials.lua")

include("physics.lua")
include("physical_materials.lua")
include("procedural_objects.lua")
include("procedural_batches.lua")

include("console_prompt.lua")
include("console.lua")

include("pid_ctrl.lua")

include("player_ctrl.lua")

include("capturer.lua")

include("configuration.lua")

include("env.lua")

include("audio.lua")

include("placement_editor.lua")

include("net.lua")

include("simplemenu.lua") --hacky menu :D

include("/common/init.lua")

include("/vehicles/init.lua")

safe_include("/user_script.lua")

