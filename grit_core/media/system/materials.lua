include `/system/shaders.lua`

local use_hw_gamma = false


local function process_tex_name (mname, tname)
        return tname:sub(2)
end

local function get_colour (v)
        local r,g,b,a = 1,1,1,1
        if type(v)=="number" then
                r = v % 256
                v = (v - r)/256
                g = v % 256
                v = (v - g)/256
                b = v % 256
                v = (v - b)/256
                a = v % 256
                return r/255, g/255, b/255, a/255
        elseif type(v)=="vector3" then
                return v.x, v.y, v.z, 1
        else
                return v[1] or r, v[2] or g, v[3] or b, v[4] or a
        end
end

local function set_texture_filtering (mat, index, clamp, minification, magnification, mipmaps)
        mat:setTextureFiltering(0, 0, index, minification, magnification, mipmaps)
        mat:setTextureAnisotropy(0, 0, index, 16)
        if clamp then
                mat:setTextureAddressingMode(0,0,index,"CLAMP","CLAMP","CLAMP")
        end
end

local function set_texture_filtering_tab (mat, index, tab)
        set_texture_filtering(mat, index, tab.clamp, tab.filterMin, tab.filterMag, tab.filterMip)
end


local function opt_tab_idx (tab, idx)
        return tab[idx]
end

local function material_caster (name, original, world, tab)

        local needs_texture = tab.shadowAlphaReject and tab.blend[1].diffuseMap

        --local shf, shv = shader_caster_names_ensure_created(tab.diffuseMap, tab.overlayOffset, tab.blendedBones, 0, world)
        local shf, shv = shader_caster_names(needs_texture, tab.overlayOffset, tab.blendedBones, 0, world)
        --print("Setting material \""..name.."\" with shader: ", shf, shv)

        local mat = get_material(name)
        if mat==nil then
                mat = Material(name)
        else
                -- removing the technique here causes a crash because
                -- the best supported technique no-longer exists.
                mat:removeAllPasses(0)
                mat:createPass(0)
        end

        mat:setFragmentProgram(0,0,shf)
        mat:setVertexProgram(0,0,shv)

        local ar = -1
        if tab.alphaReject then ar = tab.alphaReject end
        mat:setFragmentConstantFloat(0,0,"alpha_rej", ar)
        mat:setFragmentConstantFloat(0,0,"bias_offset", tab.shadowBias)

        if tab.backfaces then
                -- cull nothing
                mat:setCull(0,0,"CULL_NONE")
                mat:setManualCull(0,0,false)
        end     

        local tex_index = 0

        -- stipple texture
        if true then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index, (`stipple.png`):sub(2))
                mat:setTextureFiltering(0,0,tex_index,"POINT","POINT","NONE")
                tex_index = tex_index + 1
        end

        -- diffuse map
        if needs_texture then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index, process_tex_name(original,tab.blend[1].diffuseMap))
                set_texture_filtering_tab(mat, tex_index, tab)
                tex_index = tex_index + 1
        end

        return mat

end

local function paint_mode_from_tab(tab)
        if not tab.paintColour then return false end
        local paint_mode = false
        if tab.paintColour == 1 then
                paint_mode = 1
        elseif tab.paintColour == 2 then
                paint_mode = 2
        elseif tab.paintColour == 3 then
                paint_mode = 3
        elseif tab.paintColour == 4 then
                paint_mode = 4
        else
                paint_mode = 0
        end
        if tab.paintByDiffuseAlpha then paint_mode = paint_mode + 5 end
        return paint_mode
end

local function material_bloom (name, horz)
        local mat = get_material(name)
        if mat==nil then
                mat = Material(name)
        else
                mat:removeAllTechniques()
                mat:createTechnique()
                mat:createPass(0)
        end

        local namepart = horz and "horz" or "vert_recombine"
        local fname, vname = "bloom_"..namepart.."_f", "bloom_"..namepart.."_v"

        mat:setVertexProgram(0,0,vname)
        mat:setFragmentProgram(0,0,fname)

        if horz then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,0, "")
                mat:setTextureFiltering(0,0,0,"LINEAR","LINEAR","NONE")
        else
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,0, "")
                mat:setTextureFiltering(0,0,0,"LINEAR","LINEAR","NONE")
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,1, "")
                mat:setTextureFiltering(0,0,1,"LINEAR","LINEAR","NONE")
        end

        mat:setLightingEnabled(0,0,false)
        mat:setDepthFunction(0,0,"TRUE")

        return mat
end



local function material_wireframe (name, original, world, tab)

        local shf, shv = shader_wireframe_names_ensure_created(tab.overlayOffset, tab.blendedBones, world)

        local mat = get_material(name)
        if mat==nil then
                mat = Material(name)
        else
                mat:removeAllTechniques()
                mat:createTechnique()
                mat:createPass(0)
        end

        mat:setFragmentProgram(0,0,shf)
        mat:setVertexProgram(0,0,shv)

        mat:setCull(0,0,"CULL_NONE")
        mat:setManualCull(0,0,false)


        local tex_index = 0

        mat:setEmissive(0,0, 1,1,1)
        mat:setPolygonMode(0,0,"WIREFRAME")
        mat:setDepthBias(0,0,1,1)

        mat:setDepthWriteEnabled(0,0,false)

        return mat
end


local function material_emissive (name, original, world, tab)

        local vcols = 0
        if tab.vertexDiffuse then vcols = vcols + 3 end
        if tab.vertexAlpha then vcols = vcols + 1 end
        local shf, shv = shader_emissive_names_ensure_created(tab.emissiveMap, tab.overlayOffset, tab.blendedBones, world)
        --print("Setting material \""..name.."\" with shader: ", shf, shv, vcols)

        local mat = get_material(name)
        if mat==nil then
                mat = Material(name)
        else
                mat:removeAllTechniques()
                mat:createTechnique()
                mat:createPass(0)
        end

        mat:setFragmentProgram(0,0,shf)
        mat:setVertexProgram(0,0,shv)

        local uvs_needed = tab.emissiveMap

        for i, t in ipairs(tab.blend) do
                if uvs_needed and t.textureScale then
                        local u,v = unpack(t.textureScale)
                        mat:setFragmentConstantFloat(0,0,"uv_scale"..(i-1), 1/u, 1/v, 0, 0)
                end
                if uvs_needed and t.textureAnimation then
                        local u,v = unpack(t.textureAnimation)
                        -- The key requirement here is that 'time * uv_animation' in the shader appears continuous (modulo 1).
                        -- time varies from 0 to 2310, so this means uv_animation must be a fraction whose denominator is a multiple of 2310
                        u = u==0 and 0 or 2310/math.floor(2310/u)
                        v = v==0 and 0 or 2310/math.floor(2310/v)
                        mat:setFragmentConstantFloat(0,0,"uv_animation"..(i-1), u, v, 0, 0)
                end
        end

        if tab.backfaces then
                mat:setCull(0,0,"CULL_NONE")
                mat:setManualCull(0,0,false)
        end     


        local tex_index = 0

        -- emissive map
        if tab.emissiveMap then
                mat:createTextureUnitState(0,0)
                mat:setTextureHWGamma(0,0,tex_index, use_hw_gamma)
                mat:setTextureName(0,0,tex_index, process_tex_name(original,tab.emissiveMap))
                set_texture_filtering_tab(mat, tex_index, tab)
                tex_index = tex_index + 1
        end

        local r,g,b = get_colour(tab.emissiveColour)
        mat:setEmissive(0,0, r,g,b)
        mat:setDepthBias(0,0,1,1)

        mat:setSceneBlending(0,0,"ONE","ONE")

        mat:setDepthWriteEnabled(0,0,false)

        return mat
end


local function material_internal (name, original, shadow_mat, fade, world, tab)

        local forward_only = tab.alpha == false
        local spec_mode = 0
        if tab.hasGlossMap and tab.noSpecularChannel then spec_mode = 1 end
        if tab.hasGlossMap and not tab.noSpecularChannel then spec_mode = 2 end
        local vcols = 0
        if tab.vertexDiffuse then vcols = vcols + 3 end
        if tab.vertexAlpha then vcols = vcols + 1 end
        local paint_mode = paint_mode_from_tab(tab)
        local shf, shv = shader_names_ensure_created(tab.hasDiffuseMap, tab.premultipliedAlpha, false, tab.hasNormalMap, tab.translucencyMap, spec_mode, paint_mode, #tab.blend, tab.overlayOffset, tab.stipple, tab.blendedBones, vcols, tab.grassLighting, world, tab.shadowReceive, tab.microFlakes, forward_only)
        --print("Setting material \""..name.."\" with shader: ", shf, shv, vcols)

        local mat = get_material(name)
        if mat==nil then
                mat = Material(name)
        else
                mat:removeAllTechniques()
                mat:createTechnique()
                mat:createPass(0)
        end

        --mat:setAmbientVertex(0,0,true)
        --mat:setDiffuseVertex(0,0,true)
        --mat:setSpecularVertex(0,0,true)
        --mat:setEmissiveVertex(0,0,true)


        mat:setShadowCasterMaterial(0,shadow_mat)

        mat:setFragmentProgram(0,0,shf)
        mat:setVertexProgram(0,0,shv)

        local uvs_needed = tab.hasDiffuseMap or tab.emissiveMap or tab.hasNormalMap or tab.hasSpecularMap or tab.translucencyMap or type(tab.paintColour) == "string" 

        mat:setFragmentConstantFloat(0,0,"alpha_rej", tab.alphaReject or -1)
        mat:setAlphaToCoverage(0,0, tab.alphaToCoverage)
        --mat:setFragmentConstantFloat(0,0,"shadow_oblique_cutoff", math.sin(tab.shadowObliqueCutOff*math.pi/180))
        for i=0,#tab.blend-1 do
                local t = tab.blend[i+1]
                if uvs_needed and t.textureScale then
                        local u,v = unpack(t.textureScale)
                        mat:setFragmentConstantFloat(0,0,"uv_scale"..i, 1/u, 1/v, 0, 0)
                end
                if uvs_needed and t.textureAnimation then
                        local u,v = unpack(t.textureAnimation)
                        u = u==0 and 0 or 2310/math.floor(2310/u)
                        v = v==0 and 0 or 2310/math.floor(2310/v)
                        mat:setFragmentConstantFloat(0,0,"uv_animation"..i, u, v, 0, 0)
                end
        end
        if tab.microFlakes then
                mat:setFragmentConstantFloat(0,0,"microflakes_mask", tab.microFlakes)
        end

        if tab.backfaces then
                mat:setCull(0,0,"CULL_NONE")
                mat:setManualCull(0,0,false)
        end     


        local tex_index = 0

        -- shadow maps
        if tab.shadowReceive and not forward_only then
                for i=1,3 do
                        mat:createTextureUnitState(0,0)
                        mat:setContentType(0,0,tex_index,"SHADOW")
                        mat:setTextureFiltering(0,0,tex_index,"POINT","POINT","NONE")
                        tex_index = tex_index + 1
                end
                if gfx_option("SHADOW_FILTER_DITHER_TEXTURE") then
                        mat:createTextureUnitState(0,0)
                        mat:setTextureName(0,0,tex_index,gfx_shadow_pcf_noise_map():sub(2))
                        mat:setTextureFiltering(0,0,tex_index,"POINT","POINT","NONE")
                        tex_index = tex_index + 1
                end
        end
        if not forward_only then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index,gfx_env_cube(0):sub(2))
                mat:setTextureAddressingMode(0,0,tex_index,"WRAP","WRAP","WRAP")
                mat:setTextureFiltering(0,0,tex_index,"ANISOTROPIC","ANISOTROPIC","LINEAR")
                tex_index = tex_index + 1
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index,gfx_env_cube(1):sub(2))
                mat:setTextureAddressingMode(0,0,tex_index,"WRAP","WRAP","WRAP")
                mat:setTextureFiltering(0,0,tex_index,"ANISOTROPIC","ANISOTROPIC","LINEAR")
                tex_index = tex_index + 1
        end

        -- stipple texture
        if tab.stipple then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index, gfx_fade_dither_map():sub(2))
                mat:setTextureFiltering(0,0,tex_index,"POINT","POINT","NONE")
                tex_index = tex_index + 1
        end

        -- stipple texture
        if tab.microFlakes then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index, "system/MicroFlakes.dds")
                mat:setTextureFiltering(0,0,tex_index,"POINT","POINT","NONE")
                tex_index = tex_index + 1
        end

        for _,t in ipairs(tab.blend) do

                -- diffuse map
                if t.diffuseMap then
                        mat:createTextureUnitState(0,0)
                        mat:setTextureHWGamma(0,0,tex_index, use_hw_gamma)
                        mat:setTextureName(0,0,tex_index, process_tex_name(original,t.diffuseMap))
                        set_texture_filtering_tab(mat, tex_index, tab)
                        tex_index = tex_index + 1
                end

                -- normal map
                if t.normalMap then
                        mat:createTextureUnitState(0,0)
                        mat:setTextureName(0,0,tex_index, process_tex_name(original,t.normalMap))
                        set_texture_filtering_tab(mat, tex_index, tab)
                        tex_index = tex_index + 1
                end

                -- gloss map
                if t.glossMap then
                        mat:createTextureUnitState(0,0)
                        mat:setTextureName(0,0,tex_index, process_tex_name(original,t.glossMap))
                        set_texture_filtering_tab(mat, tex_index, tab)
                        tex_index = tex_index + 1
                end

                -- translucency map
                if t.translucencyMap then
                        mat:createTextureUnitState(0,0)
                        mat:setTextureName(0,0,tex_index, process_tex_name(original,t.translucencyMap))
                        set_texture_filtering_tab(mat, tex_index, tab)
                        tex_index = tex_index + 1
                end

        end

        -- paint map
        if type(tab.paintColour) == "string" then
                mat:createTextureUnitState(0,0)
                mat:setTextureName(0,0,tex_index, process_tex_name(original,tab.paintColour))
                set_texture_filtering_tab(mat, tex_index, tab)
                tex_index = tex_index + 1
        end

        -- diffuse colour
        local r,g,b = get_colour(tab.diffuseColour)
        mat:setDiffuse(0,0, r,g,b, (tab.alpha or 1))

        mat:setSpecular(0,0, tab.specular,0,0,1,tab.gloss)

        -- alpha stuff
        if tab.alpha or fade then
                mat:setSceneBlending(0,0,"SRC_ALPHA","ONE_MINUS_SRC_ALPHA")
        end

        mat:setDepthWriteEnabled(0,0,tab.depthWrite)
        mat:setTransparentSortingForced(0,0,tab.depthSort or fade)

        mat.transparencyCastsShadows = true

        return mat
end


local pair_one = {1, 1} -- statically allocated to avoid GC overhead


--vince suggested these for 'plastic' material:
local default_spec = math.pow(60/255, 2.2)
local default_gloss = math.pow(90/255, 2.2)

local function set_material_defaults(tab)

        if not tab.blend then 
                tab.blend = { {
                        diffuseMap = tab.diffuseMap;
                        normalMap = tab.normalMap;
                        glossMap = tab.glossMap;
                        textureAnimation = tab.textureAnimation;
                        textureScale = tab.textureScale;
                } }
        end

        tab.diffuseMap = nil
        tab.normalMap = nil
        tab.glossMap = nil
        tab.textureAnimation = nil
        tab.textureScale = nil

        for _,v in ipairs(tab.blend) do
                if v.diffuseMap then tab.hasDiffuseMap = true end
                if v.normalMap then tab.hasNormalMap = true end
                if v.glossMap then tab.hasGlossMap = true end
        end

        if #tab.blend > 1 then
                tab.alpha = false
                tab.alphaReject = false
        end
                
        local function default (k, v)
                if tab[k] == nil then tab[k] = v end
        end

        default("vertexAlpha", false)
        default("vertexDiffuse", false)
        default("diffuseColour", 0xFFFFFFFF)
        default("emissiveColour", tab.emissiveMap and 0xffffff or 0x000000)
        if tab.hasGlossMap and not tab.noSpecularChannel then
            default("specular", 1)
        else
            default("specular", default_spec)
        end
        if tab.hasGlossMap then
            default("gloss", 1)
        else
            default("gloss", default_gloss)
        end
        default("alpha", false)
        if tab.alpha == true then tab.alpha = 1 end
        if tab.microFlakes == true then tab.microFlakes = 1 end
        default("blendedBones", 0)
        default("alphaReject", false)
        default("shadowAlphaReject", not not (tab.alphaReject and tab.hasDiffuseMap)) -- if we have alpha reject then we probably want to have this
        default("shadowBias", 0)
        default("castShadows", true)
        default("shadowReceive", true)
        default("shadowObliqueCutOff", 0)
        default("stipple", not tab.alpha)
        default("depthSort", not not tab.alpha) -- use double not to cast number to boolean
        default("depthWrite", not tab.alpha)
        default("alphaToCoverage", false)
        default("backfaces", false)
        default("grassLighting", false)
        default("overlayOffset", false)
        default("uvScale", pair_one)
        default("polygonMode", "SOLID")
        default("premultipliedAlpha", false)
        default("filterMip", "LINEAR")
        default("filterMin", "ANISOTROPIC")
        default("filterMag", "ANISOTROPIC")

        return tab
end

function get_default_caster_material_name(backfaces, bones, world)
        local pref = backfaces and "default_caster_backfaces" or "default_caster_nobackfaces"
        local name = shader_caster_names_aux(pref, false, false, bones, 0, world);
        return name.."!"..(world and "&" or "")
end


-- curry to avoid parentheses
function do_create_material(name, tab)

        local emissive_needed = false
        if tab.emissiveMap then emissive_needed = true end
        if tab.emissiveColour then 
                local r,g,b = get_colour(tab.emissiveColour)
                if r > 0 or g > 0 or b > 0 then emissive_needed = true end
                tab.emissiveColour = vector3(r,g,b)
        end

        if tab.diffuseColour then
                local r,g,b,a = get_colour(tab.diffuseColour)
                if a < 1 then
                        if not tab.alpha then tab.alpha = 1 end
                        if tab.alpha == true then tab.alpha = 1 end -- haven't run through defaults yet
                        tab.alpha = tab.alpha * a
                end
                tab.diffuseColour = vector3(r,g,b)
        end

        set_material_defaults(tab)

        if debug_cfg.translucencyMaps == false then tab.translucencyMap = nil end
        if debug_cfg.colourMaps == false then tab.colourMap = nil end
        if debug_cfg.polygonMode ~= "SOLID" then tab.polygonMode = debug_cfg.polygonMode end
        if gfx_option("SHADOW_RECEIVE") == false then tab.shadowReceive = false end
        if gfx_option("SHADOW_CAST") == false then tab.castShadows = false end
        if debug_cfg.textureScale == false then tab.textureScale = false end
        if debug_cfg.textureAnimation == false then tab.textureAnimation = false end

        local function clear_blend (field) for _,v in ipairs(tab.blend) do v[field] = nil end end

        -- let global settings override material settings
        if debug_cfg.diffuseMaps == false then clear_blend("diffuseMap") ; tab.hasDiffuseMap = false end
        if debug_cfg.normalMaps == false then clear_blend("normalMap") ; tab.hasNormalMap = false end
        if debug_cfg.glossMaps == false then clear_blend("glossMap") ; tab.hasGlossMap = false end

        local def_caster = get_default_caster_material_name(tab.backfaces,tab.blendedBones, false)
        local def_wcaster = get_default_caster_material_name(tab.backfaces,tab.blendedBones, true)

        local custom_caster_needed = tab.shadowAlphaReject or (tab.shadowBias ~= 0)

        -- need a custom caster if the diffuse texture needs to be bound
        local caster  = custom_caster_needed and material_caster(name.."!", name, false, tab) or get_material(def_caster)
        local wcaster = custom_caster_needed and material_caster(name.."!&", name, true,  tab) or get_material(def_wcaster)

        if not tab.stipple then
                material_internal(name.."'", name, caster, true, false, tab)
        end
        if emissive_needed then
                material_emissive(name.."^", name, false, tab)
                material_emissive(name.."^&", name, true, tab)
        end
        material_internal(name,      name,  caster, false, false, tab)
        material_internal(name.."&", name, wcaster, false, true,  tab)
        material_wireframe(name.."|", name, false, tab)
        material_wireframe(name.."|&", name, true, tab)

        -- no prefix: ordinary material, stipple
        -- & base (world)
        -- ' fade with alpha blend
        -- ! caster
        -- !& caster (world)
        -- ^ emissive
        -- ^& emissive (world)
end

-- use global to pass name to curried function because an upvalue implies an allocation


-- make sure global variable exists, to avoid error later one


function do_reset_materials()

        local tab = set_material_defaults {}
        -- always rebuild default casters
        for _,backfaces in ipairs{true,false} do
                tab.backfaces = backfaces
                for _,bones in ipairs{0,1,2,3,4} do
                        for _,world in ipairs{false,true} do
                                tab.blendedBones = bones
                                local cname = get_default_caster_material_name(backfaces, bones, world)
                                material_caster(cname, nil, world, tab)
                        end
                end
        end

        --BaseWhite is the only material without a leading / so we do it directly
        --do_create_material("BaseWhite",{})
        --register_material("BaseWhite",{})

        material "/system/FallbackMaterial" { }

        reprocess_all_registered_materials(do_create_material)
end


function do_reset_deferred()
        do_reset_deferred_shaders()
end

