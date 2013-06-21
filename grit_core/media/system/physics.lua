-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading physics.lua")

if physics == nil then
        physics = {
            frameTime = seconds();
            leftOver = 0;
            speed = 1;
            oneToOne = false;
            enabled = true;
            maxSteps = 50;
            allocs = 0;
            debugWorld = false;
            prodding = false;
            stepCallbacks = CallbackReg.new();
        }
else
        physics.stepCallbacks:removeByName("Core")
        physics.stepCallbacks:removeByName("Prod")
        main.frameCallbacks:removeByName("physics")
end

-- also called by F11
function physics_step (elapsed)
    local _, initial_allocs = get_alloc_stats()

    physics.stepCallbacks:execute(elapsed)

    local _, final_allocs = get_alloc_stats()
    physics.allocs = final_allocs - initial_allocs
end

-- also called by F11
function physics_frame_step (step_size, elapsed_time)
	local elapsed = physics.leftOver + elapsed_time * physics.speed
	local iterations = 0
	while elapsed>=step_size do
		if iterations >= physics.maxSteps then
			-- no more processing, throw away remaining time
			physics.leftOver = 0
			return
		end
		elapsed = elapsed - step_size
		physics_step(step_size)
		iterations = iterations + 1
	end
	
	physics.leftOver = elapsed
end

local function core (step_size)
    object_do_step_callbacks(step_size)
    gfx_particle_pump(step_size)
    do_events(step_size)
    physics_update()

end
physics.stepCallbacks:insert("Core", core)


local function frameCallback()
    audio_update(player_ctrl.camPos, V_ZERO, player_ctrl.camDir)
    
    local curr_time = seconds()
    local elapsed_time = curr_time - physics.frameTime
    physics.frameTime = curr_time
    
    if physics.enabled == false then return true end

    local step_size = physics_option("STEP_SIZE")
    
    if physics.oneToOne then
        physics.leftOver = 0
        physics_step(step_size)
    else
		physics_frame_step(step_size, elapsed_time)
    end
    
    return true
end
main.frameCallbacks:insert("physics", frameCallback)

local function prod (time)
        if physics.prodding then
                local dist, body, nx, ny, nz, _ = cam_ray()
                if dist~= nil then
                        local dir = player_ctrl.camDir*V_FORWARDS
                        local pos = player_ctrl.camPos + dist * dir
                        body:impulse(time * (player_ctrl.fast and 100 or 10)*body.mass * dir, pos)
                end
        end
end
physics.stepCallbacks:insert("Prod", prod)


