-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local gl_profile_frag = "gp4fp"
local gl_profile_vert = "gpu_vp"

local gbuffer_count = 3

local function prog(name, lang, type)
        local p = get_gpuprog(name) or make_gpuprog(name, lang, type)
        if p.language ~= lang then
                p:destroy()
                p = make_gpuprog(name, lang, type)
        end
        --p.ignoreMissingParams = true
        return p
end

local function sampler(params, tunit, name, num)
        num = num and tostring(num) or ""
        params = params .. "uniform sampler2D "..name..num.." : register(s"..tunit.."),"
        tunit = tunit+1
        return params, tunit
end
local function sampler3d(params, tunit, name, num)
        num = num and tostring(num) or ""
        params = params .. "uniform sampler3D "..name..num.." : register(s"..tunit.."),"
        tunit = tunit+1
        return params, tunit
end
local function samplerCube(params, tunit, name, num)
        num = num and tostring(num) or ""
        params = params .. "uniform samplerCUBE "..name..num.." : register(s"..tunit.."),"
        tunit = tunit+1
        return params, tunit
end

local function configuration_defines ()
        local defines = " -DUSE_FOG="..(debug_cfg.fog and "1" or "0")
                      .." -DNO_TEXTURE_LOOKUPS="..(debug_cfg.textureFetches and "0" or "1")
                      .." -DUSE_HEIGHTMAP_BLENDING="..(debug_cfg.heightmapBlending and "1" or "0")
                      .." -DSHADOW_PADDING="..gfx_option("SHADOW_PADDING")
                      .." -DSHADOW_DIST1="..gfx_option("SHADOW_END0")
                      .." -DSHADOW_DIST2="..gfx_option("SHADOW_END1")
                      .." -DSHADOW_DIST3="..gfx_option("SHADOW_END2")
                      .." -DSHADOW_FADE_START="..gfx_option("SHADOW_FADE_START")
                      .." -DSHADOW_FADE_END="..gfx_option("SHADOW_END2")
                      .." -DSHADOW_RES="..gfx_option("SHADOW_RES")
                      .." -DEMULATE_PCF="..(gfx_option("SHADOW_EMULATE_PCF") and "1" or "0")
                      .." -DSHADOW_FILTER_TAPS="..gfx_option("SHADOW_FILTER_TAPS")
                      .." -DSHADOW_FILTER_DITHER="..(gfx_option("SHADOW_FILTER_DITHER") and "1" or "0")
                      .." -DSHADOW_FILTER_NOISE="..(gfx_option("SHADOW_FILTER_DITHER_TEXTURE") and "1" or "0")
                      .." -DSPREAD1="..(gfx_option("SHADOW_SPREAD_FACTOR0")*gfx_option("SHADOW_FILTER_SIZE"))
                      .." -DSPREAD2="..(gfx_option("SHADOW_SPREAD_FACTOR1")*gfx_option("SHADOW_FILTER_SIZE"))
                      .." -DSPREAD3="..(gfx_option("SHADOW_SPREAD_FACTOR2")*gfx_option("SHADOW_FILTER_SIZE"))
        if debug_cfg.falseColour then
                defines = defines .. " -DRENDER_"..debug_cfg.falseColour.."=1"
        end
        return defines
end



-- {{{ EMISSIVE SHADERS


local function shader_emissive_names (...)
        local function shader_emissive_names_aux (prefix, em, overlay, blended_bones, world)
                return string.format("%s:%s_%s_%01d_%s",
                        prefix,
                        em and "M" or "m",
                        overlay and "O" or "o",
                        blended_bones,
                        world and "W" or "w"
                )
        end
        return shader_emissive_names_aux("emissive_f", ...), shader_emissive_names_aux("emissive_v", ...)
end

local function make_program_emissive_cg (emissive_map, overlay, blended_bones, world)
        local fname, vname
        -- material does emissive additive overlay
        fname, vname = shader_emissive_names(emissive_map, overlay, blended_bones, world)

        print ("Compiling shader: ", vname, fname)
        local defines = "-O3 -DUSE_EMISSIVE_MAP="..(emissive_map and "1" or "0")
                      .." -DUSE_OVERLAY_OFFSET="..(overlay and "1" or "0")
                      .." -DBLENDED_BONES="..blended_bones
                      .." -DWORLD_GEOMETRY="..(world and "1" or "0")
        defines = defines .. configuration_defines()

        defines = defines .. " -DEMISSIVE_PART=1 -DEMISSIVE_FADE=1"

        local vp = prog(vname,"cg","VERTEX")
        vp.profiles = {"vs_3_0", gl_profile_vert}
        vp.sourceFile = "system/uber_recv.cg"
        vp.compileArguments = defines
        vp.entryPoint = "vp_main"
        vp:reload()
        if blended_bones > 0 then
                vp:setAutoConstantInt("bone_matrixes","WORLD_MATRIX_ARRAY_3x4")
                vp.skeletalAnimationIncluded = true
        else
                vp:setAutoConstantInt("world","WORLD_MATRIX")
        end
        vp:setAutoConstantInt("view","VIEW_MATRIX")
        vp:setAutoConstantInt("proj","PROJECTION_MATRIX")
        if overlay then
                vp:setAutoConstantInt("camera_pos_ws","CAMERA_POSITION")
        end

        local fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/uber_recv.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()
        if debug_cfg.fog then
                fp:setAutoConstantInt("the_fog_params", "FOG_PARAMS")
        end

        if not world then
                fp:setAutoConstantInt("custom_param", "CUSTOM", 0)
        end
        fp:setAutoConstantInt("surf_emissive", "SURFACE_EMISSIVE_COLOUR")
        if emissive_map then
                fp:setAutoConstantFloat("time","TIME_0_X", 2310)
                fp:setConstantFloat("uv_animation0", 0, 0, 0, 0)
                fp:setConstantFloat("uv_scale0", 1, 1, 0, 0)
        end

        return vp, fp
end

function shader_emissive_names_ensure_created(...)
        local shf, shv = shader_emissive_names(...)
        if get_gpuprog(shf) == nil then
                make_program_emissive_cg (...)
        end
        return shf, shv
end

function do_reset_emissive_shaders ()
        for _,em in ipairs{false,true} do
        for _,overlay in ipairs{false,true} do
        for _,bones in ipairs{0,1,2,3,4} do
        for _,world in ipairs{false, true} do
                local fname = shader_emissive_names(em, overlay, bones, world)
                if get_gpuprog(fname) ~= nil then
                        make_program_emissive_cg(em, overlay, bones, world)
                end
        end --world
        end --bones
        end --overlay
        end --em
end

-- }}}

-- {{{ WIREFRAME SHADERS

local function shader_wireframe_names (...)
        local function shader_wireframe_names_aux (prefix, overlay, blended_bones, world)
                return string.format("%s:%s_%01d_%s",
                        prefix,
                        overlay and "O" or "o",
                        blended_bones,
                        world and "W" or "w"
                )
        end
        return shader_wireframe_names_aux("wireframe_f", ...), shader_wireframe_names_aux("wireframe_v", ...)
end

local function make_program_wireframe_cg (overlay, blended_bones, world)
        local fname, vname
        -- material does a wireframe in emissive white
        fname, vname = shader_wireframe_names(overlay, blended_bones, world)

        print ("Compiling shader: ", vname, fname)
        local defines = "-O3"
                      .." -DUSE_OVERLAY_OFFSET="..(overlay and "1" or "0")
                      .." -DBLENDED_BONES="..blended_bones
                      .." -DWORLD_GEOMETRY="..(world and "1" or "0")
        defines = defines .. configuration_defines()

        defines = defines .. " -DEMISSIVE_PART=1 -DEMISSIVE_FADE=0"

        local vp = prog(vname,"cg","VERTEX")
        vp.profiles = {"vs_3_0", gl_profile_vert}
        vp.sourceFile = "system/uber_recv.cg"
        vp.compileArguments = defines
        vp.entryPoint = "vp_main"
        vp:reload()
        if blended_bones > 0 then
                vp:setAutoConstantInt("bone_matrixes","WORLD_MATRIX_ARRAY_3x4")
                vp.skeletalAnimationIncluded = true
        else
                vp:setAutoConstantInt("world","WORLD_MATRIX")
        end
        vp:setAutoConstantInt("view","VIEW_MATRIX")
        vp:setAutoConstantInt("proj","PROJECTION_MATRIX")
        if overlay then
                vp:setAutoConstantInt("camera_pos_ws","CAMERA_POSITION")
        end

        local fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/uber_recv.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

        fp:setAutoConstantInt("surf_emissive", "SURFACE_EMISSIVE_COLOUR")

        return vp, fp
end

function shader_wireframe_names_ensure_created(...)
        local shf, shv = shader_wireframe_names(...)
        if get_gpuprog(shf) == nil then
                make_program_wireframe_cg (...)
        end
        return shf, shv
end

function do_reset_wireframe_shaders ()
        for _,overlay in ipairs{false,true} do
        for _,bones in ipairs{0,1,2,3,4} do
        for _,world in ipairs{false, true} do
                local fname = shader_wireframe_names(overlay, bones, world)
                if get_gpuprog(fname) ~= nil then
                        make_program_wireframe_cg(overlay, bones, world)
                end
        end --world
        end --bones
        end --overlay
end

-- }}}

-- {{{ CASTER SHADERS

-- also used to name default caster materials
function shader_caster_names_aux (prefix, dm, overlay, blended_bones, vcols, world)
        return string.format("%s:%s_%s_%01d_%01d_%s",
                prefix,
                dm and "D" or "d",
                overlay and "O" or "o",
                blended_bones,
                vcols,
                world and "W" or "w"
        )
end

function shader_caster_names (...)
        return shader_caster_names_aux("cast_f", ...), shader_caster_names_aux("cast_v", ...)
end

function make_program_caster_cg (diffuse_map, overlay, blended_bones, vcols, world)
        local fname, vname = shader_caster_names(diffuse_map, overlay, blended_bones, vcols, world)
        
        print ("Compiling shader: ", fname, vname)
        local defines = "-O3 -DUSE_DIFFUSE_MAP="..(diffuse_map and "1" or "0")
                      .." -DUSE_OVERLAY_OFFSET="..(overlay and "1" or "0")
                      .." -DUSE_STIPPLE_TEXTURE=1"
                      .." -DBLENDED_BONES="..blended_bones
                      .." -DWORLD_GEOMETRY="..(world and "1" or "0")
                      .." -DSPREAD="..gfx_option("SHADOW_FILTER_SIZE")
        defines = defines .. configuration_defines()
        local tunit = 0
        local params = ""
        if true then
                params, tunit = sampler(params, tunit, "stipple_map")
        end
        if diffuse_map then
                params, tunit = sampler(params, tunit, "diffuse_map")
        end
        defines = defines .. " -DCASTER_PARAMS=\""..params.."\""

        local vp = prog(vname,"cg","VERTEX")
        vp.profiles = {"vs_3_0", gl_profile_vert}
        vp.sourceFile = "system/uber_cast.cg"
        vp.entryPoint = "caster_vp_main"
        vp.compileArguments = defines
        vp:reload()
        vp:setAutoConstantInt("view_proj","VIEWPROJ_MATRIX")
        vp:setAutoConstantInt("light_pos_ws","LIGHT_POSITION")
        if blended_bones > 0 then
                vp:setAutoConstantInt("bone_matrixes","WORLD_MATRIX_ARRAY_3x4")
                vp.skeletalAnimationIncluded = true
        else
                vp:setAutoConstantInt("world","WORLD_MATRIX")
        end
        if overlay then
                vp:setAutoConstantInt("camera_pos_ws","CAMERA_POSITION")
        end

        local fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/uber_cast.cg"
        fp.entryPoint = "caster_fp_main"
        fp.compileArguments = defines
        fp:reload()
        if not world then
                fp:setAutoConstantInt("visibility", "CUSTOM", 0)
        end
        fp:setConstantFloat("alpha_rej", 0)
        fp:setConstantFloat("bias_offset", 0)

        return vp, fp
end

--[[ I think that I don't need this
function shader_caster_names_ensure_created(...)
        local shf, shv = shader_caster_names(...)
        if get_gpuprog(shf) == nil then
                make_program_caster_cg (...)
        end
        return shf, shv
end
-- ]]


function do_reset_caster_shaders ()
        local total_caster_shaders = 0
        local used_caster_shaders = 0
        for _,diff in ipairs{false,true} do
                for _,overlay in ipairs{false,true} do
                        for _,bones in ipairs{0,1,2,3,4} do
                                for _,world in ipairs{false,true} do
                                        total_caster_shaders = total_caster_shaders + 1
                                        used_caster_shaders = used_caster_shaders + 1
                                        make_program_caster_cg(diff, overlay, bones, 0, world)
                                end
                        end
                end
        end
end

-- }}}

-- {{{ RECEIVER SHADERS

local function program_code (dm, pma, em, nm, tm, spec_mode, paint_mode, blend, overlay, stipple, blended_bones, vcols, grass_lighting, world, rshadow, microflakes, forward_only)
        local c = 0
        c = c * 2 ; c = c + (dm and 1 or 0)
        c = c * 2 ; c = c + (pma and 1 or 0)
        c = c * 2 ; c = c + (nm and 1 or 0)
        c = c * 2 ; c = c + (tm and 1 or 0)
        c = c * 3 ; c = c + spec_mode
        c = c * 11 ; c = c + (paint_mode==false and 0 or (paint_mode+1))
        c = c * 4 ; c = c + (blend-1)
        c = c * 2 ; c = c + (overlay and 1 or 0)
        c = c * 2 ; c = c + (stipple and 1 or 0)
        c = c * 5 ; c = c + blended_bones
        c = c * 3 ; c = c + (vcols==0 and 0 or vcols==3 and 1 or vcols==4 and 2)
        c = c * 2 ; c = c + (grass_lighting and 1 or 0)
        c = c * 2 ; c = c + (world and 1 or 0)
        c = c * 2 ; c = c + (rshadow and 1 or 0)
        c = c * 2 ; c = c + (microflakes and 1 or 0)
        c = c * 2 ; c = c + (forward_only and 1 or 0)
        return c
end

local function shader_names (...)
        local function shader_names_aux (prefix, dm, pma, em, nm, tm, spec_mode, paint_mode, blend, overlay, stipple, blended_bones, vcols, grass_lighting, world, rshadow, microflakes, forward_only)
                assert(em==false)
                return string.format("%s:%s_%s_%s_%s_%s_%s_%01d_%s_%s_%01d_%01d_%s_%s_%s_%s_%s",
                        prefix,
                        dm and "D" or "d",
                        pma and "P" or "p",
                        nm and "N" or "n",
                        spec_mode==2 and "S" or spec_mode==1 and "G" or "g",
                        tm and "T" or "t",
                        paint_mode==false and "c" or tostring(paint_mode),
                        blend,
                        overlay and "O" or "o",
                        stipple and "T" or "t",
                        blended_bones,
                        vcols,
                        grass_lighting and "G" or "g",
                        world and "W" or "w",
                        rshadow and "R" or "r",
                        microflakes and "M" or "m",
                        forward_only and "F" or "f"
                )
        end
        return shader_names_aux("recv_f", ...), shader_names_aux("recv_v", ...)
end

local function make_program_cg_ (category, diffuse_map, pma, emissive_map, normal_map, tran_map, spec_mode, paint_mode, blend, overlay, stipple, blended_bones, vcols, grass, world, rshadow, microflakes, forward_only)
        assert(blend>0)
        assert(emissive_map == false)
        local forward, forward_amb_sun, deferred_amb_sun, deferred_lights = false, false, false
        local fname, vname
        if category == 0 then
                -- material does lighting parameter calculation 
                -- if forward_only == false then also does ambient/sun lighting
                forward = true
                forward_amb_sun = not forward_only
                fname, vname = shader_names(diffuse_map, pma, emissive_map, normal_map, tran_map, spec_mode, paint_mode, blend, overlay, stipple, blended_bones, vcols, grass, world, rshadow, microflakes, forward_only)
        elseif category == 1 then
                -- material does ambient/sun lighting using gbuffer
                deferred_amb_sun = true
                fname, vname = "deferred_ambient_sun_f", "deferred_ambient_sun_v"
        elseif category == 2 then
                -- material does point/cone lighting using gbuffer
                deferred_lights = true
                fname, vname = "deferred_lights_f", "deferred_lights_v"
        end
        print ("Compiling shader: ", vname, fname, category)
        local smodel = 0
        if debug_cfg.shadingModel == "SHARP" then smodel = 0 end
        if debug_cfg.shadingModel == "HALF_LAMBERT" then smodel = 1 end
        if debug_cfg.shadingModel == "WASHED_OUT" then smodel = 2 end
        local has_gloss_map = spec_mode==1 or spec_mode==2
        local paint_map, paint_colour, paint_mask, paint_alpha = false, 0, false, false
        if paint_mode ~= false then
                if paint_mode >= 5 then
                        paint_mode = paint_mode - 5
                        paint_alpha = true
                else
                        paint_mask = true
                end
                if paint_mode == 0 then
                        paint_map = true
                else
                        paint_colour = paint_mode
                end
        end
        local defines = "-O3 -DUSE_VERTEX_COLOURS="..(debug_cfg.vertexDiffuse and tostring(vcols) or "0")
                      .." -DUSE_DIFFUSE_MAP="..(diffuse_map and "1" or "0")
                      .." -DPREMULTIPLIED_ALPHA="..(pma and "1" or "0")
                      .." -DUSE_NORMAL_MAP="..(normal_map and "1" or "0")
                      .." -DUSE_GLOSS_MAP="..(has_gloss_map and "1" or "0")
                      .." -DUSE_SPECULAR_FROM_GLOSS="..(spec_mode==2 and "1" or "0")
                      .." -DUSE_TRANSLUCENCY_MAP="..(tran_map and "1" or "0")
                      .." -DUSE_PAINT_MAP="..(paint_map and "1" or "0")
                      .." -DUSE_PAINT_COLOUR="..tostring(paint_colour)
                      .." -DUSE_PAINT_MASK="..(paint_mask and "1" or "0")
                      .." -DUSE_PAINT_ALPHA="..(paint_alpha and "1" or "0")
                      .." -DUSE_MICROFLAKES="..(microflakes and "1" or "0")
                      .." -DUSE_STIPPLE_TEXTURE="..(stipple and "1" or "0")
                      .." -DUSE_OVERLAY_OFFSET="..(overlay and "1" or "0")
                      .." -DBLEND="..tostring(blend)
                      .." -DBLENDED_BONES="..blended_bones
                      .." -DFLIP_BACKFACE_NORMALS="..(grass and "0" or "1")
                      .." -DWORLD_GEOMETRY="..(world and "1" or "0")
                      .." -DSHADING_MODEL="..tostring(smodel)
                      .." -DRECEIVE_SHADOWS="..(rshadow and "1" or "0")
        defines = defines .. configuration_defines()

        local tunit = 0
        if deferred_amb_sun or deferred_lights then tunit = gbuffer_count end -- account for the fat framebuffers
        local shadow_maps = ""
        local env_maps = ""
        local extra_maps = ""
        local extra_maps_again = ""
        local extra_map_args = ""
        if rshadow and not forward_only then
                for i=1,3 do
                        shadow_maps, tunit = sampler(shadow_maps, tunit, "shadow_map",i)
                end
                if gfx_option("SHADOW_FILTER_DITHER_TEXTURE") then
                        shadow_maps, tunit = sampler(shadow_maps, tunit, "shadow_filter_noise")
                end
        end
        if not forward_only then
                env_maps, tunit = samplerCube(env_maps, tunit, "env_cube0")
                env_maps, tunit = samplerCube(env_maps, tunit, "env_cube1")
        end
        if stipple then
                extra_maps, tunit = sampler(extra_maps, tunit, "stipple_map")
                extra_maps_again = extra_maps_again .. "sampler2D stipple_map, "
                extra_map_args = extra_map_args .. "stipple_map, "
        end
        if microflakes then
                extra_maps, tunit = sampler(extra_maps, tunit, "microflakes_map")
                extra_maps_again = extra_maps_again .. "sampler2D microflakes_map, "
                extra_map_args = extra_map_args .. "microflakes_map, "
        end
        local user_tunit = tunit
        local list_diffuse_maps = ""
        local list_normal_maps = ""
        local list_gloss_maps = ""
        local list_tran_maps = ""
        local list_uvs = ""
        local list_uv_values = ""
        local list_uv_scales = ""
        local list_uv_animations = ""
        local function append_comma_always (str, v)
                return str .. v .. ", "
        end
        local uniforms = ""
        local uniform_args = ""
        if forward then
                for i=0,blend-1 do
                        if diffuse_map then
                                extra_maps, tunit = sampler(extra_maps, tunit, "diffuse_map", i)
                                list_diffuse_maps = append_comma_always(list_diffuse_maps, "diffuse_map"..i)
                                extra_maps_again = extra_maps_again .. "sampler2D diffuse_map"..i..", "
                                extra_map_args = extra_map_args .. "diffuse_map"..i..", "
                        end
                        if normal_map then
                                extra_maps, tunit = sampler(extra_maps, tunit, "normal_map", i)
                                list_normal_maps = append_comma_always(list_normal_maps, "normal_map"..i)
                                extra_maps_again = extra_maps_again .. "sampler2D normal_map"..i..", "
                                extra_map_args = extra_map_args .. "normal_map"..i..", "
                        end
                        if has_gloss_map then 
                                extra_maps, tunit = sampler(extra_maps, tunit, "gloss_map", i)
                                list_gloss_maps = append_comma_always(list_gloss_maps, "gloss_map"..i)
                                extra_maps_again = extra_maps_again .. "sampler2D gloss_map"..i..", "
                                extra_map_args = extra_map_args .. "gloss_map"..i..", "
                        end
                        if tran_map then
                                extra_maps, tunit = sampler(extra_maps, tunit, "tran_map", i)
                                list_tran_maps = append_comma_always(list_tran_maps, "tran_map"..i)
                                extra_maps_again = extra_maps_again .. "sampler2D tran_map"..i..", "
                                extra_map_args = extra_map_args .. "tran_map"..i..", "
                        end
                        uniforms = uniforms .. "uniform float2 uv_animation"..i..","
                        uniform_args = append_comma_always(uniform_args, "uv_animation"..i)
                        list_uv_animations = append_comma_always(list_uv_animations, "uv_animation"..i)

                        uniforms = uniforms .. "uniform float2 uv_scale"..i..","
                        uniform_args = append_comma_always(uniform_args, "uv_scale"..i)
                        list_uv_scales = append_comma_always(list_uv_scales, "uv_scale"..i)

                        uniforms = uniforms .. "uniform float2 uv"..i..","
                        list_uvs = append_comma_always(list_uvs, "uv"..i)
                        uniform_args = append_comma_always(uniform_args, "uv0_")
                end
                if paint_map then
                        extra_maps, tunit = sampler(extra_maps, tunit, "paint_map")
                        extra_maps_again = extra_maps_again .. "sampler2D paint_map, "
                        extra_map_args = extra_map_args .. "paint_map, "
                end
                defines = defines .. " -DEXTRA_MAPS=\""..extra_maps.."\""
                defines = defines .. " -DEXTRA_MAPS_AGAIN=\""..extra_maps_again.."\""
                defines = defines .. " -DEXTRA_MAP_ARGS=\""..extra_map_args.."\""
                defines = defines .. " -DBLEND_UNIFORMS=\""..uniforms.."\""
                defines = defines .. " -DDIFFUSE_MAPS=\""..list_diffuse_maps.."\""
                defines = defines .. " -DNORMAL_MAPS=\""..list_normal_maps.."\""
                defines = defines .. " -DSPEC_MAPS=\""..list_gloss_maps.."\""
                defines = defines .. " -DTRAN_MAPS=\""..list_tran_maps.."\""
                defines = defines .. " -DBLEND_UNIFORM_ARGS=\""..uniform_args.."\""
                defines = defines .. " -DUVS=\""..list_uvs.."\""
                defines = defines .. " -DUV_SCALES=\""..list_uv_scales.."\""
                defines = defines .. " -DUV_ANIMATIONS=\""..list_uv_animations.."\""
        end
        local can_receive_shadows = not deferred_lights and not forward_only
        --if can_receive_shadows then
                defines = defines .. " -DSHADOW_MAPS=\""..shadow_maps.."\""
        --end
        defines = defines .. " -DENV_MAPS=\""..env_maps.."\""
        defines = defines .. " -DFORWARD_PART="..(forward and "1" or "0")
        defines = defines .. " -DDEFERRED_AMBIENT_SUN_PART="..((deferred_amb_sun or forward_amb_sun) and "1" or "0")
        defines = defines .. " -DDEFERRED_LIGHTS_PART="..(deferred_lights and "1" or "0")
        --print(defines)

        local vp = prog(vname,"cg","VERTEX")
        vp.profiles = {"vs_3_0", gl_profile_vert}
        vp.sourceFile = "system/uber_recv.cg"
        vp.compileArguments = defines
        vp.entryPoint = "vp_main"
        vp:reload()
        if forward then
                if blended_bones > 0 then
                        vp:setAutoConstantInt("bone_matrixes","WORLD_MATRIX_ARRAY_3x4")
                        vp.skeletalAnimationIncluded = true
                else
                        vp:setAutoConstantInt("world","WORLD_MATRIX")
                end
                vp:setAutoConstantInt("view","VIEW_MATRIX")
                vp:setAutoConstantInt("proj","PROJECTION_MATRIX")
        end
        if forward_amb_sun then
                if rshadow then
                        for i=1,3 do
                                vp:setAutoConstantInt("shadow_view_proj"..i,"TEXTURE_VIEWPROJ_MATRIX",i-1)
                        end
                end
                vp:setAutoConstantInt("sun_pos_ws","LIGHT_POSITION")
        end
        if forward_amb_sun or overlay then
                vp:setAutoConstantInt("camera_pos_ws","CAMERA_POSITION")
        end
        if deferred_amb_sun then
                --vp:setAutoConstantInt("quad_proj","PROJECTION_MATRIX")
                vp:setConstantFloat("top_left_ray", 0, 0, 0)
                vp:setConstantFloat("top_right_ray", 0, 0, 0)
                vp:setConstantFloat("bottom_left_ray", 0, 0, 0)
                vp:setConstantFloat("bottom_right_ray", 0, 0, 0)
        end
        if deferred_lights then
                vp:setAutoConstantInt("render_target_flipping","RENDER_TARGET_FLIPPING")
        end

        local fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/uber_recv.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()
        if forward_amb_sun then
                if debug_cfg.fog then
                end
        end
        if forward_amb_sun or deferred_amb_sun then
                if debug_cfg.fog then
                        fp:setAutoConstantInt("the_fog_params", "FOG_PARAMS")
                        fp:setAutoConstantInt("the_fog_colour", "FOG_COLOUR")
                end
        end
        if forward_amb_sun then
                fp:setAutoConstantInt("sun_diffuse", "LIGHT_DIFFUSE_COLOUR", 0)
                fp:setAutoConstantInt("sun_specular", "LIGHT_SPECULAR_COLOUR", 0)
        end
        if forward and rshadow then
                --fp:setConstantFloat("shadow_oblique_cutoff", 0.0)
        end
        if not world then
                if forward then
                        fp:setAutoConstantInt("custom_param", "CUSTOM", 0)
                end
        end
        if forward then
                fp:setConstantFloat("alpha_rej", 0)
                if diffuse_map or normal_map or tran_map or has_gloss_map then
                        fp:setAutoConstantFloat("time","TIME_0_X", 2310)
                        for i=0,blend-1 do
                                fp:setConstantFloat("uv_animation"..i, 0, 0, 0, 0)
                                fp:setConstantFloat("uv_scale"..i, 1, 1, 0, 0)
                        end
                        if debug_cfg.falseColour == "UV_STRETCH_BANDS" or
                           debug_cfg.falseColour == "UV_STRETCH" then
                                fp:setAutoConstantInt("texture_size", "PACKED_TEXTURE_SIZE", user_tunit)
                        end
                end
                if paint_map or paint_colour==1 then
                        fp:setAutoConstantInt("col1", "CUSTOM", 1)
                        fp:setAutoConstantInt("col_spec1", "CUSTOM", 2)
                end
                if paint_map or paint_colour==2 then
                        fp:setAutoConstantInt("col2", "CUSTOM", 3)
                        fp:setAutoConstantInt("col_spec2", "CUSTOM", 4)
                end
                if paint_map or paint_colour==3 then
                        fp:setAutoConstantInt("col3", "CUSTOM", 5)
                        fp:setAutoConstantInt("col_spec3", "CUSTOM", 6)
                end
                if paint_map or paint_colour==4 then
                        fp:setAutoConstantInt("col4", "CUSTOM", 8)
                        fp:setAutoConstantInt("col_spec4", "CUSTOM", 8)
                end
                fp:setAutoConstantInt("surf_diffuse", "SURFACE_DIFFUSE_COLOUR")
                fp:setAutoConstantInt("surf_specular", "SURFACE_SPECULAR_COLOUR")
                fp:setAutoConstantInt("surf_gloss", "SURFACE_SHININESS")
                if not grass then
                        fp:setAutoConstantInt("render_target_flipping","RENDER_TARGET_FLIPPING")
                end
                if microflakes then
                        fp:setConstantFloat("microflakes_mask",0)
                end
        end
        if deferred_amb_sun then
                if rshadow then
                        for i=1,3 do
                                fp:setAutoConstantInt("shadow_view_proj"..i,"TEXTURE_VIEWPROJ_MATRIX",i-1)
                        end
                end
        end
        if deferred_lights then
                if gfx_d3d9() then
                        fp:setAutoConstantInt("viewport_size","VIEWPORT_SIZE")
                end
        end
        if forward_only then
                fp:setAutoConstantInt("far_clip_distance","FAR_CLIP_DISTANCE")
        end
        --fp:setConstantFloat("always_120583", 120583)


        return vp, fp
end

local function make_program_cg (...)
        return make_program_cg_(0, ...)
end

if shader_table == nil then
        shader_table = {}
end

function shader_names_ensure_created(...)
        local code = program_code(...)
        if shader_table[code] == nil then
                shader_table[code] = {...}
                make_program_cg (...)
        end
        return shader_names(...)
end

function do_reset_receiver_shaders ()
        local used_shaders = 0

        local start_time = micros()
        for code,tab in pairs(shader_table) do
                used_shaders = used_shaders + 1
                make_program_cg(unpack(tab))
        end
        local end_time = micros()

        print("Rebuilt "..used_shaders.." shaders in "..tostring((end_time-start_time)/1E6).." seconds.")
end

-- }}}

-- {{{ SCREENSPACE SHADERS (e.g. deferred)

local function make_program_deferred_lights_cg ()
        return make_program_cg_(2, false, false, false, false, false, false, 0, 1, false, false, 0, 0, false, false, false, false, false)
end

local function make_program_compositor_v_cg ()
        local vname = "compositor_v"

        print ("Compiling shader: ", vname)
        local defines = "-O3"
        defines = defines .. configuration_defines()

        local vp = prog(vname,"cg","VERTEX")
        vp.profiles = {"vs_3_0", gl_profile_vert}
        vp.sourceFile = "system/compositor_vp.cg"
        vp.compileArguments = defines
        vp.entryPoint = "vp_main"
        vp:reload()

        return vp
end

local function make_program_tonemap_cg ()
        local fname = "tonemap"

        print ("Compiling shader: ", fname)
        local defines = "-O3"
        defines = defines .. configuration_defines()

        local fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/tonemap.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

        return fp
end

local function make_program_bloom_cg ()
        local fname, fp, defines

        fname = "bloom_filter_then_horz_blur"
           print ("Compiling shader: ", fname)
        defines = "-O3"
        defines = defines .. configuration_defines()
        defines = defines .. " -DBLOOM_HORZ=1"
        defines = defines .. " -DBLOOM_FILTER=1"
        fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/bloom.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

        fname = "bloom_vert_blur"
        print ("Compiling shader: ", fname)
        defines = "-O3"
        defines = defines .. configuration_defines()
        defines = defines .. " -DBLOOM_HORZ=0"
        fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/bloom.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

        fname = "bloom_horz_blur"
        print ("Compiling shader: ", fname)
        defines = "-O3"
        defines = defines .. configuration_defines()
        defines = defines .. " -DBLOOM_HORZ=1"
        defines = defines .. " -DBLOOM_FILTER=0"
        fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/bloom.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

        fname = "bloom_vert_blur_combine_and_tonemap"
        print ("Compiling shader: ", fname)
        defines = "-O3"
        defines = defines .. configuration_defines()
        defines = defines .. " -DBLOOM_HORZ=0"
        defines = defines .. " -DBLOOM_COMBINE_TONEMAP=1"
        fp = prog(fname,"cg","FRAGMENT")
        fp.profiles = {"ps_3_0", gl_profile_frag}
        fp.sourceFile = "system/bloom.cg"
        fp.compileArguments = defines
        fp.entryPoint = "fp_main"
        fp:reload()

end

function do_reset_deferred_shaders()

        make_program_deferred_lights_cg()
        make_program_compositor_v_cg()
        make_program_tonemap_cg()
        make_program_bloom_cg(true)
        make_program_bloom_cg(false)

end

-- }}}






function do_reset_shaders ()

        do_reset_deferred_shaders()
        do_reset_emissive_shaders()
        do_reset_wireframe_shaders()
        do_reset_caster_shaders()
        do_reset_receiver_shaders()
end

