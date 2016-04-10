/* Copyright (c) David Cunningham and the Grit Game Engine project 2015;
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <cmath>

#include "gfx_gasoline_backend.h"


void GfxGslBackendUnparser::unparse (const GfxGslAst *ast_, int indent)
{
    std::string space(4 * indent, ' ');
    if (auto ast = dynamic_cast<const GfxGslBlock*>(ast_)) {
        ss << space << "{\n";
        for (auto stmt : ast->stmts) {
            unparse(stmt, indent+1);
        }
        ss << space << "}\n";
    } else if (auto ast = dynamic_cast<const GfxGslShader*>(ast_)) {
        for (auto stmt : ast->stmts) {
            unparse(stmt, indent);
        }
    } else if (auto ast = dynamic_cast<const GfxGslDecl*>(ast_)) {
        ss << space << varPref << ast->id << " = ";
        unparse(ast->init, indent);
        ss << ";\n";
    } else if (auto ast = dynamic_cast<const GfxGslIf*>(ast_)) {
        ss << space << "if (";
        unparse(ast->cond, indent);
        ss << ") {\n";
        unparse(ast->yes, indent+1);
        if (ast->no) {
            ss << space << "} else {\n";
            unparse(ast->no, indent+1);
        }
        ss << space << "}\n";
    } else if (auto ast = dynamic_cast<const GfxGslAssign*>(ast_)) {
        ss << space;
        unparse(ast->target, indent);
        ss << " = ";
        unparse(ast->expr, indent);
        ss << ";\n";
    } else if (dynamic_cast<const GfxGslDiscard*>(ast_)) {
        ss << space << "discard;\n";
    } else if (dynamic_cast<const GfxGslReturn*>(ast_)) {
        ss << space << "return;\n";

    } else if (auto ast = dynamic_cast<const GfxGslCall*>(ast_)) {
        ss << ast->func;
        if (ast->args.size() == 0) {
            ss << "()";
        } else {
            const char *sep = "(";
            for (auto arg : ast->args) {
                ss << sep;
                unparse(arg, indent);
                sep = ", ";
            }
            ss << ")";
        }
    } else if (auto ast = dynamic_cast<const GfxGslField*>(ast_)) {
        if (dynamic_cast<GfxGslGlobalType*>(ast->target->type)) {
            ss << "global_" << ast->id;
        } else if (dynamic_cast<GfxGslMatType*>(ast->target->type)) {
            ss << "mat_" << ast->id;
        } else if (dynamic_cast<GfxGslVertType*>(ast->target->type)) {
            ss << "vert_" << ast->id;
        } else if (dynamic_cast<GfxGslFragType*>(ast->target->type)) {
            ss << "frag_" + ast->id;
        } else if (dynamic_cast<GfxGslOutType*>(ast->target->type)) {
            ss << "out_" + ast->id;
        } else if (dynamic_cast<GfxGslBodyType*>(ast->target->type)) {
            ss << "body_" + ast->id;
        } else if (auto *type = dynamic_cast<GfxGslCoordType*>(ast->target->type)) {
            if (type->dim == 1) {
                ASSERT(ast->id == "x" || ast->id == "r");
                ss << "(";
                unparse(ast->target, indent);
                ss << ")";
            } else {
                ss << "(";
                unparse(ast->target, indent);
                ss << ").";
                ss << ast->id;
            }
        } else {
            ss << "(";
            unparse(ast->target, indent);
            ss << ").";
            ss << ast->id;
        }
    } else if (auto ast = dynamic_cast<const GfxGslLiteralInt*>(ast_)) {
        ss << "Int(" << ast->val << ")";
    } else if (auto ast = dynamic_cast<const GfxGslLiteralFloat*>(ast_)) {
        ss << "Float(" << ast->val << ")";
    } else if (auto ast = dynamic_cast<const GfxGslLiteralBoolean*>(ast_)) {
        ss << (ast->val ? "true" : "false");
    } else if (auto ast = dynamic_cast<const GfxGslVar*>(ast_)) {
        ss << varPref << ast->id;
    } else if (auto ast = dynamic_cast<const GfxGslBinary*>(ast_)) {
        if (ast->op == GFX_GSL_OP_MOD) {
            ss << "mod(";
            unparse(ast->a, indent);
            ss << ", ";
            unparse(ast->b, indent);
            ss << ")";
        } else {
            ss << "(";
            unparse(ast->a, indent);
            ss << " " << to_string(ast->op) << " ";
            unparse(ast->b, indent);
            ss << ")";
        }
    } else if (dynamic_cast<const GfxGslGlobal*>(ast_)) {
        ss << "global";
    } else if (dynamic_cast<const GfxGslMat*>(ast_)) {
        ss << "mat";
    } else if (dynamic_cast<const GfxGslVert*>(ast_)) {
        ss << "vert";
    } else if (dynamic_cast<const GfxGslFrag*>(ast_)) {
        ss << "frag";
    } else if (dynamic_cast<const GfxGslOut*>(ast_)) {
        ss << "out";

    } else {
        EXCEPTEX << "INTERNAL ERROR: Unknown GfxGslAst." << ENDL;
    }
}

std::string gfx_gasoline_generate_preamble_functions (void)
{
    std::stringstream ss;

    ss << "Float3 normalise (Float3 v) { return normalize(v); }\n";
    ss << "Float4 pma_decode (Float4 v) { return Float4(v.xyz/v.w, v.w); }\n";
    ss << "Float  gamma_decode (Float v)  { return pow(v, 2.2); }\n";
    ss << "Float2 gamma_decode (Float2 v) { return pow(v, Float2(2.2, 2.2)); }\n";
    ss << "Float3 gamma_decode (Float3 v) { return pow(v, Float3(2.2, 2.2, 2.2)); }\n";
    ss << "Float4 gamma_decode (Float4 v) { return pow(v, Float4(2.2, 2.2, 2.2, 2.2)); }\n";
    ss << "Float  gamma_encode (Float v)  { return pow(v, 1/2.2); }\n";
    ss << "Float2 gamma_encode (Float2 v) { return pow(v, Float2(1/2.2, 1/2.2)); }\n";
    ss << "Float3 gamma_encode (Float3 v) { return pow(v, Float3(1/2.2, 1/2.2, 1/2.2)); }\n";
    ss << "Float4 gamma_encode (Float4 v) { return pow(v, Float4(1/2.2, 1/2.2, 1/2.2, 1/2.2)); }\n";

    ss << "Float3 desaturate (Float3 c, Float sat)\n";
    ss << "{\n";
    ss << "    Float grey = (c.x + c.y + c.z) / 3;\n";
    ss << "    return lerp(Float3(grey, grey, grey), c, Float3(sat, sat, sat));\n";
    ss << "}\n";

    ss << "Float3 unpack_deferred_diffuse_colour(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    return gamma_decode(texel2.rgb);\n";
    ss << "}\n\n";

    ss << "Float unpack_deferred_specular(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    return gamma_decode(texel2.a);\n";
    ss << "}\n\n";

    ss << "Float unpack_deferred_shadow_cutoff(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    texel0.a *= 255;\n";
    ss << "    if (texel0.a >= 128) {\n";
    ss << "        texel0.a -= 128;\n";
    ss << "    }\n";
    ss << "    return texel1.a;\n";
    ss << "}\n\n";

    ss << "Float unpack_deferred_gloss(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    return texel1.a;\n";
    ss << "}\n\n";

    ss << "Float unpack_deferred_cam_dist(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    return 255.0\n";
    ss << "           * (256.0*256.0*texel0.x + 256.0*texel0.y + texel0.z)\n";
    ss << "           / (256.0*256.0*256.0 - 1);\n";
    ss << "}\n\n";

    ss << "Float3 unpack_deferred_normal(Float4 texel0, Float4 texel1, Float4 texel2)\n";
    ss << "{\n";
    ss << "    Float up = -1;\n";  // 1 or -1
    ss << "    texel0.a *= 255;\n";
    ss << "    if (texel0.a >= 128) {\n";
    ss << "        up = 1;\n";
    ss << "    }\n";
    // This algorithm is described as USE_NORMAL_ENCODING == 2 in the original uber.cgh.
    ss << "    Float2 low2 = texel1.xy * 255;\n";  // range: [0,256)
    ss << "    Float hi_mixed = texel1.z * 255;\n";  // range: [0,256)
    ss << "    Float2 hi2;\n";  // range: [0, 16)
    ss << "    hi2.y = int(hi_mixed/16);\n";
    ss << "    hi2.x = hi_mixed - hi2.y*16;\n";
    ss << "    Float2 tmp = low2 + hi2*256;\n";  // range: [0, 4096)
    ss << "    Float3 normal;\n";  // range: [0, 1]
    ss << "    normal.xy = (tmp/4095) * Float2(2,2) - Float2(1,1);\n";
    ss << "    normal.z = up * (sqrt(1 - min(1.0, normal.x*normal.x + normal.y*normal.y)));\n";
    ss << "    return normal;\n";
    ss << "}\n\n";

    return ss.str();
}

std::string gfx_gasoline_generate_global_fields (const GfxGslContext &ctx, bool reg)
{
    std::stringstream ss;

    unsigned counter = 0;

    for (const auto &pair : ctx.globalFields) {
        ss << "uniform " << pair.second << " global_" << pair.first;
        if (reg && dynamic_cast<const GfxGslTextureType*>(pair.second)) {
            ss << " : register(s" << counter << ")";
            counter++;
        }
        ss << ";\n";
    }
    for (const auto &pair : ctx.matFields) {
        auto it = ctx.ubt.find(pair.first);
        if (auto *tt = dynamic_cast<const GfxGslTextureType*>(pair.second)) {
            if (it != ctx.ubt.end()) {
                ss << "const Float4 mat_" << pair.first << " = " << tt->solid;
            } else {
                ss << "uniform " << pair.second << " mat_" << pair.first;
                if (reg) {
                    ss << " : register(s" << counter << ")";
                    counter++;
                }
            }
        } else {
            ss << "uniform " << pair.second << " mat_" << pair.first;
        }
        ss << ";\n";
    }
    for (const auto &pair : ctx.bodyFields) {
        ss << "uniform " << pair.second << " body_" << pair.first;
        if (reg && dynamic_cast<const GfxGslTextureType*>(pair.second)) {
            EXCEPTEX << "Not allowed" << ENDL;
            ss << " : register(s" << counter << ")";
            counter++;
        }
        ss << ";\n";
    }

    return ss.str();
}

std::string gfx_gasoline_generate_var_decls (const GfxGslTypeMap &vars) 
{
    std::stringstream ss;

    if (vars.size() == 0) return "";

    ss << "// Variable declarations\n";

    for (const auto &pair : vars)
        ss << pair.second << " " << pair.first << ";\n";

    ss << "\n";

    return ss.str();
}

std::string gfx_gasoline_generate_trans_encode (const std::vector<GfxGslTrans> &trans,
                                                const std::string &var_pref)
{
    std::stringstream ss;

    if (trans.size() == 0) return "";

    ss << "    // Encode interpolated vars\n";

    for (unsigned i=0 ; i<trans.size() ; i+=4) {
        unsigned sz = trans.size()-i > 4 ? 4 : trans.size()-i;
        static const char *fields = "xyzw";
        for (unsigned j=0 ; j<sz ; ++j) {
            const auto &tran = trans[i+j];
            std::stringstream expr;
            switch (tran.kind) {
                case GfxGslTrans::VERT:
                expr << "vert_" << tran.path[0];
                break;
                case GfxGslTrans::USER:
                expr << var_pref << tran.path[0];
                break;
                case GfxGslTrans::INTERNAL:
                expr << "internal_" << tran.path[0];
                break;
            }
            for (unsigned k=1 ; k<tran.path.size() ; ++k)
                expr << "." << tran.path[k];
            ss << "    trans" << i/4;
            if (sz > 1) ss << "." << fields[j];
            ss << " = " << expr.str() << ";\n";

        }
    }
    ss << "\n";

    return ss.str();
}


std::string gfx_gasoline_generate_trans_decode(const std::vector<GfxGslTrans> &trans,
                                               const std::string &pref,
                                               GfxGslTrans::Kind only)
{
    std::stringstream ss;

    if (trans.size() == 0) return "";

    ss << "// Decode interpolated vars\n";

    for (unsigned i=0 ; i<trans.size() ; i+=4) {
        unsigned sz = trans.size()-i > 4 ? 4 : trans.size()-i;
        static const char *fields = "xyzw";
        for (unsigned j=0 ; j<sz ; ++j) {
            const auto &tran = trans[i+j];
            std::stringstream expr;
            std::string prefix = pref;
            for (unsigned k=0 ; k<tran.path.size() ; ++k) {
                expr << prefix << tran.path[k];
                prefix = ".";
            }
            if (tran.kind == only) {
                ss << "    " << expr.str() << " = ";
                ss << "trans" << i/4;
                if (sz > 1) ss << "." << fields[j];
                ss << ";\n";
            }
        }
    }

    ss << "\n";

    return ss.str();
}

std::string gfx_gasoline_preamble_lighting (const GfxGslEnvironment &env) 
{
    std::stringstream ss;

    ss << "// Lighting functions\n";

    // Punctual lighting simulates the lighting of a fragment by rays all eminating from
    // the same point.  Arguments light_diffuse and light_specular are usually the same value.
    //     surf_to_light: surface to light vector
    //     surf_to_cam: surface to camera vector (typically computed in vertex shader)
    //     sd: surface diffuse colour
    //     sn: surface normal vector
    //     sg: surface gloss (0 to 1)
    //     ss: surface spec (0 to 1)
    //     light_diffuse: light intensity 0 to 1 or greater for hdr (number of photons, basically)
    //     light_specular: light intensity 0 to 1 or greater for hdr (number of photons, basically)
    ss << "Float3 punctual_lighting(Float3 surf_to_light, Float3 surf_to_cam,\n"
       << "                         Float3 sd, Float3 sn, Float sg, Float ss,\n";
    ss << "                         Float3 light_diffuse, Float3 light_specular)\n";
    ss << "{\n";

    ss << "    Float3 diff_component = light_diffuse * sd;\n";

    // specular component
    ss << "    Float3 surf_to_half = normalize(0.5*(surf_to_cam + surf_to_light));\n";
    ss << "    Float fresnel = ss + (1-ss)\n";
    ss << "                   * strength(1.0 - dot(surf_to_light, surf_to_half), 5);\n";
    ss << "    Float gloss = pow(4096.0, sg);\n";
    ss << "    Float highlight = 1.0/8 * (gloss+2) * strength(dot(sn, surf_to_half), gloss);\n";
    ss << "    Float3 spec_component = light_specular * fresnel * highlight;\n";

    ss << "    return (spec_component + diff_component) * max(0.0, dot(sn, surf_to_light));\n";
    ss << "}\n";

    // Test a single shadow map at a single position (world space).
    ss << "Float test_shadow(Float3 pos_ws,\n";
    ss << "                  Float4x4 shadow_view_proj,\n";
    ss << "                  FloatTexture2 tex,\n";
    ss << "                  Float spread)\n";
    ss << "{\n";
    ss << "    Float sun_dist = dot(pos_ws, global_sunlightDirection)\n";
    ss << "                     / " << env.shadowFactor << ";\n";
    ss << "    Float3 pos_ls = mul(shadow_view_proj, Float4(pos_ws, 1)).xyw;\n";
    ss << "    pos_ls.xy /= pos_ls.z;\n";
    auto filter_taps_side = unsigned(::sqrt(env.shadowFilterTaps) + 0.5);
    float half_filter_taps_side = filter_taps_side / 2.0;
    ss << "    Int filter_taps_side = " << filter_taps_side << ";\n";
    ss << "    Float half_filter_taps_side = " << half_filter_taps_side << ";\n";
    switch (env.shadowDitherMode) {
        case GfxGslEnvironment::SHADOW_DITHER_NONE:
        ss << "    Float2 fragment_uv_offset = Float2(0,0);\n";
        break;
        case GfxGslEnvironment::SHADOW_DITHER_NOISE:
        ss << "    Float2 noise_uv = frag_screen.xy / 64;\n";
        ss << "    Float2 noise_texel = sampleLod(global_shadowPcfNoiseMap, noise_uv, 0).rg;\n";
        ss << "    Float2 noise_offset = (2 * noise_texel - 1);  // length(offset) <= 1\n";
        ss << "    Float2 fragment_uv_offset = 0.8 * noise_offset;\n";
        break;
        case GfxGslEnvironment::SHADOW_DITHER_PLAIN:
        ss << "    Float2 dithered_offset;\n";
        ss << "    if ((Int(frag_screen.x) % 2) == 1) {\n";
        ss << "        if ((Int(frag_screen.y)%2)==1) {\n";
        ss << "            dithered_offset = Float2( 1,  0);\n";
        ss << "        } else {\n";
        ss << "            dithered_offset = Float2(-1,  0);\n";
        ss << "        }\n";
        ss << "    } else {\n";
        ss << "        if ((Int(frag_screen.y) % 2) == 1) {\n";
        ss << "            dithered_offset = Float2( 0,  1);\n";
        ss << "        } else {\n";
        ss << "            dithered_offset = Float2( 0, -1);\n";
        ss << "        }\n";
        ss << "    }\n";
        ss << "    Float2 fragment_uv_offset = 0.6 * dithered_offset;\n";
        break;
    }
    ss << "    fragment_uv_offset *= spread / filter_taps_side / " << env.shadowRes << ";\n";
    ss << "    Float total = 0;\n";
    ss << "    for (Int y=0 ; y < filter_taps_side ; y++) {\n";
    ss << "        for (Int x=0 ; x < filter_taps_side ; x++) {\n";
    ss << "            Float2 tap_uv = Float2(x - half_filter_taps_side + 0.5,\n";
    ss << "                                   y - half_filter_taps_side + 0.5);\n";
    ss << "            tap_uv *= spread / " << env.shadowRes << " / half_filter_taps_side;\n";
    ss << "            tap_uv += pos_ls.xy + fragment_uv_offset;\n";
    ss << "            total += sun_dist > sampleLod(tex, tap_uv, 0).r ? 1.0 : 0.0;\n";
    ss << "        }\n";
    ss << "    }\n";
    ss << "    return total / " << env.shadowFilterTaps << ";\n";
    ss << "}\n";

    ss << "Float unshadowyness(Float3 pos_ws, Float cam_dist)\n";
    ss << "{\n";
    ss << "    Float shadowyness = 0.0;\n";
    ss << "    if (cam_dist < " << env.shadowDist[0] << ") {\n";
    ss << "        shadowyness = test_shadow(pos_ws, global_shadowViewProj0,\n";
    ss << "                                  global_shadowMap0, " << env.shadowSpread[0] << ");\n";
    ss << "    } else if (cam_dist < " << env.shadowDist[1] << ") {\n";
    ss << "        shadowyness = test_shadow(pos_ws, global_shadowViewProj1,\n";
    ss << "                                  global_shadowMap1, " << env.shadowSpread[1] << ");\n";
    ss << "    } else if (cam_dist < " << env.shadowDist[2] << ") {\n";
    ss << "        shadowyness = test_shadow(pos_ws, global_shadowViewProj2,\n";
    ss << "                                  global_shadowMap2, " << env.shadowSpread[2] << ");\n";
    ss << "    }\n";
    ss << "    Float fade = 1;\n";
    ss << "    Float sf_end = " << env.shadowFadeEnd << ";\n";
    ss << "    Float sf_start = " << env.shadowFadeStart << ";\n";
    ss << "    if (sf_end != sf_start) {\n";
    ss << "        fade = min(1.0, (sf_end - cam_dist) / (sf_end - sf_start));\n";
    ss << "    }\n";
    ss << "    shadowyness *= fade;\n";
    ss << "    return max(0.0, 1 - shadowyness);\n";
    ss << "}\n\n";

    // Env cube lighting simulates global illumination (i.e. light from all directions).
    ss << "Float3 env_lighting(Float3 surf_to_cam,\n"
       << "                    Float3 sd, Float3 sn, Float sg, Float ss,\n";
    ss << "                    FloatTextureCube cube, Float map_mipmaps)\n";
    ss << "{\n";
    ss << "    Float3 reflect_ws = -reflect(surf_to_cam, sn);\n";
    // Use 20 as the max mipmap, as we will never see a texture 2^20 big.
    ss << "    Float3 fresnel_light = \n";
    ss << "        gamma_decode(sampleLod(cube, reflect_ws, map_mipmaps - 1).rgb);\n";
    ss << "    Float3 diff_light = gamma_decode(sampleLod(cube, sn, map_mipmaps - 1).rgb);\n";
    ss << "    Float spec_mm = (1 - sg) * map_mipmaps;\n";  // Spec mip map
    ss << "    Float3 spec_light = gamma_decode(sampleLod(cube, reflect_ws, spec_mm).rgb);\n";
    ss << "    Float3 diff_component = sd * diff_light;\n";
    ss << "    Float3 spec_component = ss * spec_light;\n";
    ss << "    Float fresnel_factor = strength(1.0 - dot(sn, surf_to_cam), 5);\n";
    ss << "    Float3 fresnel_component = sg * fresnel_factor * fresnel_light;\n";
    ss << "    return 16 * (diff_component + spec_component + fresnel_component);\n";
    ss << "}\n\n";

    ss << "Float3 sunlight(Float3 shadow_pos, Float3 s2c, Float3 d, Float3 n, Float g, Float s,\n";
    ss << "                Float cam_dist)\n";
    ss << "{\n";
    ss << "    Float3 sun = punctual_lighting(-global_sunlightDirection, s2c,\n";
    ss << "        d, n, g, s, global_sunlightDiffuse, global_sunlightSpecular);\n";
    ss << "    sun *= unshadowyness(shadow_pos, cam_dist);\n";
    ss << "    return sun;\n";
    ss << "}\n\n";

    ss << "Float3 envlight(Float3 s2c, Float3 d, Float3 n, Float g, Float s)\n";
    ss << "{\n";
    if (env.envBoxes == 1) {
        ss << "    Float3 env = env_lighting(s2c,\n";
        ss << "        d, n, g, s, global_envCube0, global_envCubeMipmaps0);\n";
    } else if (env.envBoxes == 2) {
        ss << "    Float3 env0 = env_lighting(s2c,\n";
        ss << "        d, n, g, s, global_envCube0, global_envCubeMipmaps0);\n";
        ss << "    Float3 env1 = env_lighting(s2c,\n";
        ss << "        d, n, g, s, global_envCube1, global_envCubeMipmaps1);\n";
        ss << "    Float3 env = lerp(env0, env1, global_envCubeCrossFade * Float3(1,1,1));\n";
    } else {
        ss << "    Float3 env = Float3(0.0, 0.0, 0.0);\n";
    }
    ss << "    return env;\n";
    ss << "}\n\n";

    ss << "Float3 tonemap(Float3 colour)\n";
    ss << "{\n";
    ss << "    colour = colour / (1 + colour);\n";
    ss << "    colour = gamma_encode(colour);\n";
    ss << "    Float3 lut_uv = (colour * 31 + 0.5) / 32;\n";  // Hardcode 32x32x32 dimensions.
    ss << "    colour = sample(global_colourGradeLut, lut_uv).rgb;\n";
    ss << "    colour = desaturate(colour, global_saturation);\n";
    ss << "    return colour;\n";
    ss << "}\n\n";

    return ss.str();
}


std::string gfx_gasoline_preamble_fade (const GfxGslEnvironment &env) 
{
    (void) env;
    std::stringstream ss;

    ss << "void fade (void)\n";
    ss << "{\n";
    ss << "    int x = (int(frag_screen.x) % 8);\n";
    ss << "    int y = (int(frag_screen.y) % 8);\n";
    ss << "    Float fade = internal_fade * 16.0;  // 16 possibilities\n";
    ss << "    Float2 uv = Float2(x,y);\n";
    ss << "    // uv points to top left square now\n";
    ss << "    uv.x += 8.0 * (int(fade)%4);\n";
    ss << "    uv.y += 8.0 * int(fade/4);\n";
    ss << "    if (sampleLod(global_fadeDitherMap, uv / 32.0, 0).r < 0.5) discard;\n";
    ss << "}\n";

    ss << "\n";
    return ss.str();
}


std::string gfx_gasoline_preamble_transformation (bool first_person, const GfxGslEnvironment &env)
{
    // TODO(dcunnin): Need to specialise transform_to_world and rotate_to_world for instanced
    // geometry.

    std::stringstream ss;
    ss << "// Standard library (vertex shader specific calls)\n";

    ss << "Float3 transform_to_world (Float3 v)\n";
    ss << "{\n";
    ss << "    Float3 r = Float3(0, 0, 0);\n";
    if (env.boneWeights == 0) {
        ss << "    r = mul(body_world, Float4(v, 1)).xyz;\n";
    } else {
        // The bone weights are supposed to sum to 1, we could remove this overconservative divide
        // if we could assert that property at mesh loading time.
        ss << "    Float total = 0;\n";
        for (unsigned i=0 ; i < env.boneWeights ; ++i) {
            ss << "    r += vert_boneWeights[" << i
               << "] * mul(body_boneWorlds[int(vert_boneAssignments[" << i
               << "])], Float4(v, 1)).xyz;\n";
            ss << "    total += vert_boneWeights[" << i << "];\n";
        }
        ss << "    r /= total;\n";
    }
    // If we're in first person mode, the "world space" coord is actually a space that is centered
    // at the camera with Y pointing into the distance, Z up and X right.  To convert that to true
    // world space we just use the inverse view matrix.  However, since the view matrix converts to
    // a coordinate frame where Z points into the distance, we do a conversion fully into that
    // coordinate frame first.  Then we apply the inverse view matrix which rewinds that and also
    // takes us all the way back to actual world space.
    if (first_person) {
        ss << "    Float3 r2 = Float3(r.x, r.z, -r.y);\n";
        ss << "    r = mul(global_invView, Float4(r2, 1)).xyz;\n";
    }
    ss << "    return r;\n";
    ss << "}\n";
    ss << "Float3 rotate_to_world (Float3 v)\n";
    ss << "{\n";
    ss << "    Float3 r = Float3(0, 0, 0);\n";
    if (env.boneWeights == 0) {
        ss << "    r = mul(body_world, Float4(v, 0)).xyz;\n";
    } else {
        // The bone weights are supposed to sum to 1, we could remove this overconservative divide
        // if we could assert that property at mesh loading time.
        ss << "    Float total = 0;\n";
        for (unsigned i=0 ; i < env.boneWeights ; ++i) {
            ss << "    r += vert_boneWeights[" << i
               << "] * mul(body_boneWorlds[int(vert_boneAssignments[" << i
               << "])], Float4(v, 0)).xyz;\n";
            ss << "    total += vert_boneWeights[" << i << "];\n";
        }
        ss << "    r /= total;\n";
    }
    // See comment about first person mode, above.
    if (first_person) {
        ss << "    Float3 r2 = Float3(r.x, r.z, -r.y);\n";
        ss << "    r = mul(global_invView, Float4(r2, 0)).xyz;\n";
    }
    ss << "    return r;\n";
    ss << "}\n";
    ss << "\n";

    return ss.str();
}
