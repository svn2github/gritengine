-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `sky.lua`

env_saturation_mask = 1

env_cube_dawn_time = 6*60*60
env_cube_noon_time = 12*60*60
env_cube_dusk_time = 18*60*60
env_cube_dark_time = 24*60*60
    
--TODO: this cubemap info should be also taken from map env overrides, maybe?
env_cube_dawn = `env_cube_dawn.envcube.tiff`
env_cube_noon = `env_cube_noon.envcube.tiff`
env_cube_dusk = `env_cube_dusk.envcube.tiff`
env_cube_dark = `env_cube_dark.envcube.tiff`

gfx_env_cube(0, env_cube_noon)
gfx_env_cube(1, env_cube_noon)
gfx_global_exposure(1)
gfx_option("BLOOM_ITERATIONS",1)
gfx_colour_grade(`standard.lut.png`)

function env_recompute()

    local secs = env.secondsSinceMidnight
    
    if secs < env_cube_dawn_time then
        gfx_env_cube(0, env_cube_dark)
        gfx_env_cube(1, env_cube_dawn)
        gfx_env_cube_cross_fade(invlerp(0, env_cube_dawn_time, secs))
    elseif secs < env_cube_noon_time then
        gfx_env_cube(0, env_cube_dawn)
        gfx_env_cube(1, env_cube_noon)
        gfx_env_cube_cross_fade(invlerp(env_cube_dawn_time, env_cube_noon_time, secs))
    elseif secs < env_cube_dusk_time then
        gfx_env_cube(0, env_cube_noon)
        gfx_env_cube(1, env_cube_dusk)
        gfx_env_cube_cross_fade(invlerp(env_cube_noon_time, env_cube_dusk_time, secs))
    elseif secs < env_cube_dark_time then
        gfx_env_cube(0, env_cube_dusk)
        gfx_env_cube(1, env_cube_dark)
        gfx_env_cube_cross_fade(invlerp(env_cube_dusk_time, env_cube_dark_time, secs))
    end
    
    -- account for the fact that the sun is on the other side of the planet in summer
    -- in degrees
    local sun_adjusted_time = math.mod(secs / 60 / 60 / 24 * 360 + env.season, 360)
    local space_orientation = quat(env.latitude,V_EAST)*
                              quat(sun_adjusted_time,V_SOUTH)*
                              quat(env.earthTilt,V_WEST)
    local sun_direction =   (space_orientation * quat(env.season,V_NORTH)) * V_UP
    local moon_direction =  (space_orientation * quat(env.moonPhase,V_NORTH) * quat(env.season,V_NORTH)) * V_UP

    -- procedural from time
    if sky_ent ~= nil then
        sky_ent.orientation = space_orientation
    end
    if moon_ent ~= nil then 
        moon_ent.orientation = space_orientation * quat(env.moonPhase,V_NORTH)
    end
    
    local next_env, current_env, slider
    do 
        local found = false
        for _,some_env in ipairs(env_cycle) do
            current_env = next_env
            next_env = some_env
            if some_env.time*60*60 > secs then
                found = true
                break
            end
        end
        if not found then
            -- wrap-around case
            current_env = env_cycle[#env_cycle]
            next_env = env_cycle[1]
            slider = (secs/60/60 - current_env.time) / (next_env.time+24 - current_env.time)
        else
            slider = (secs/60/60 - current_env.time) / (next_env.time - current_env.time)
        end
    end

    -- sunlight_direction is the parameter to the lighting equation that is used to light the scene
    local sunlight_direction
    if current_env.lightSource == "MOON" then
        gfx_sunlight_direction(norm(moon_direction))
    elseif current_env.lightSource == "SUN" then
        gfx_sunlight_direction(norm(sun_direction))
    end

    -- interpolated from env_cycle
    local function lerp3(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider)
    end
    local function lerp4(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider),
               lerp(a[na+3], b[nb+3], slider)
    end
    local fog_colour = lerp(current_env.fogColour, next_env.fogColour, slider)

    -- sky
    gfx_sun_direction(sun_direction)
    gfx_hell_colour(fog_colour)
    gfx_sun_size(lerp(current_env.sunSize, next_env.sunSize, slider))
    gfx_sun_falloff_distance(lerp(current_env.sunFalloff, next_env.sunFalloff, slider))

    local mixed_sun_colour = lerp(current_env.sunColour, next_env.sunColour, slider)
    gfx_sun_colour(mixed_sun_colour.xyz)
    gfx_sun_alpha(mixed_sun_colour.w)

    gfx_sky_cloud_colour(lerp(current_env.cloudColour, next_env.cloudColour, slider))
    gfx_sky_cloud_coverage(lerp(current_env.cloudCoverage, next_env.cloudCoverage, slider))

    gfx_sky_divider(0, 5)
    gfx_sky_divider(1, 10)
    gfx_sky_divider(2, 15)
    gfx_sky_divider(3, 25)

    gfx_sky_glare_sun_distance(lerp(current_env.sunGlare, next_env.sunGlare, slider))
    gfx_sky_glare_horizon_elevation(lerp(current_env.horizonGlare, next_env.horizonGlare, slider))
    for i=1,6 do
        local mixed_gradient = lerp(current_env["grad"..i], next_env["grad"..i], slider)
        gfx_sky_colour(i-1, mixed_gradient.xyz)
        gfx_sky_alpha(i-1, mixed_gradient.w)
    end
    for i=1,5 do
        local mixed_gradient = lerp(current_env["sunGrad"..i], next_env["sunGrad"..i], slider)
        gfx_sky_sun_colour(i-1, mixed_gradient.xyz)
        gfx_sky_sun_alpha(i-1, mixed_gradient.w)
    end

    -- environment properties
    gfx_particle_ambient(vector3(lerp(current_env.particleLight, next_env.particleLight, slider)))
    gfx_global_saturation(env_saturation_mask * lerp(current_env.saturation, next_env.saturation, slider))
    gfx_fog_colour(fog_colour)
    gfx_fog_density(lerp(current_env.fogDensity, next_env.fogDensity, slider))
    gfx_sunlight_diffuse(lerp(current_env.diffuseLight, next_env.diffuseLight, slider))
    gfx_sunlight_specular(lerp(current_env.specularLight, next_env.specularLight, slider))

end

local function maybe_commit (self)
    if not self.c.autoUpdate then return end

    local reset_sun_pos = false

    for k,v in pairs(self.p) do
        if self.c[k] ~= v then
            self.c[k] = v
            reset_sun_pos = true
        end
    end

    if reset_sun_pos then
        env_recompute()
    end
end

local function change (self, k, v)
    if k == "autoUpdate" then
        ensure_one_of(v,{false,true})
        self.c[k] = v
    elseif k == "secondsSinceMidnight" then
        ensure_number(v)
        self.p[k] = v
    elseif k == "latitude" then
        ensure_range(v,-90,90)
        self.p[k] = v
    elseif k == "season" then
        ensure_range(v,0,360)
        self.p[k] = v
    elseif k == "earthTilt" then
        ensure_range(v,-90,90)
        self.p[k] = v
    elseif k == "clockRate" then
        ensure_range(v,-50000,50000)
        self.p[k] = v
    elseif k == "clockTicking" then
        ensure_one_of(v,{false,true})
        self.p[k] = v
    elseif k == "moonPhase" then
        ensure_range(v,0,360)
        self.p[k] = v
    else
        error("Unrecognised env setting: "..tostring(k))
    end

    maybe_commit(self)
end


include `env_cycle.lua`

--[[
function save_env_cycle(filename)
    filename = filename or "saved_env_cycle.lua"
    local f = io.open(filename,"w")
    if f==nil then error("Could not open file",1) end
    f:write("env_cycle = ")
    f:write(dump(env_cycle,false))
    f:close()
    print("Wrote env cycle to \""..filename.."\"")
end
]]

if not env then

    env = {
        -- current values
        c = {
            autoUpdate = false;
        };

        -- proposed values
        p = {
            latitude = 41; 
            secondsSinceMidnight = 12*60*60; --midday
            season = 180; -- summer, stored as angle in degrees
            earthTilt = 23.44;
            clockRate = 30;
            clockTicking = true;
            moonPhase = 160; -- between sun and earth when moonPhase + season == 180 (mod 360)
        };
        
        tickCallbacks = CallbackReg.new();
    }

else

    setmetatable(env,nil)
    main.frameCallbacks:removeByName("Environment")

    sky_ent = safe_destroy(sky_ent)
    moon_ent = safe_destroy(moon_ent)
    clouds_ent = safe_destroy(clouds_ent)

end

sky_ent = gfx_sky_body_make(`SkyCube.mesh`, 180)
moon_ent = gfx_sky_body_make(`SkyMoon.mesh`, 120)
clouds_ent = gfx_sky_body_make(`SkyClouds.mesh`, 60)

function env:shutdown()
    safe_destroy(sky_ent)
    safe_destroy(moon_ent)
    safe_destroy(clouds_ent)
end

local last_time = seconds()

local function frameCallback()
    local clock_rate = env.clockRate

    local curr_time = seconds()
    local elapsed = curr_time - last_time
    last_time = curr_time
    
    if env.clockTicking then

        env.secondsSinceMidnight = math.mod(env.secondsSinceMidnight + elapsed * env.clockRate, 24*60*60)

        env.tickCallbacks:execute(env.secondsSinceMidnight)

    end
end

main.frameCallbacks:insert("Environment", frameCallback)

setmetatable(env, {
    __index = function (self, k)
        local v = self.c[k] ;
        if v == nil then
            error("No such setting: \""..k.."\"",2)
        end
        return v
    end,
    __newindex = function (self, k, v) change(self,k,v) end
})

env.autoUpdate = true

env_recompute()
