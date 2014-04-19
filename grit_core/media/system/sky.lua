-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading sky.lua")

sky_shader `SkyDefault` {

    alphaMask = uniform_float(1);
    alphaRejectThreshold = uniform_float(-1);
    emissiveMask = uniform_float(1, 1, 1);

    emissiveMap = uniform_texture {
        defaultColour = vector3(1,1,1);
        defaultAlpha = 1;
    };

    fragmentCode = [[
        out_COLOR = sample2D(mu_emissiveMap, in_TEXCOORD0.xy);
        out_COLOR.rgb /= out_COLOR.a;

        out_COLOR.a *= mu_alphaMask;
        if (out_COLOR.a <= mu_alphaRejectThreshold) discard;

        out_COLOR.rgb = gamma_decode(out_COLOR.rgb);
        out_COLOR.rgb *= mu_emissiveMask;
    ]];
}

sky_material `Moon` {
    emissiveMap = uniform_texture { name = `starfield.dds` };
    emissiveMask = uniform_float(0.3, 0.3, 0.3);
    alphaRejectThreshold = uniform_float(0.5);
}



sky_shader `SkyBackground` { -- {{{

    starfieldMask = uniform_float(1, 1, 1);

    starfieldMap = uniform_texture {
        defaultColour = vector3(0,0,0);
        defaultAlpha = 1;
    };

    vertexCode = [[
        float aspect = su_viewportSize.x / su_viewportSize.y;
        float fov_x = aspect * su_fovY;

        // The world matrix encodes only sky orientation data (i.e. due to the rotation of the earth).
        out_POSITION = mul(su_worldViewProj, float4(in_POSITION.xyz,0));

        // hack our way to maximum depth
        out_POSITION.z = out_POSITION.w;
        out_POSITION.z *= (1-1.0/65536); // avoid 'black lightning' artifacts


        float4 sunlight_dir_ss_ = mul(su_viewProj, float4(-su_sunDirection,1));

        // for interpolators
        float2 uv = in_TEXCOORD0.xy;
        float3 pos_ws = mul(su_world, float4(in_POSITION.xyz,0)).xyz;
        float3 sunlight_dir_ss = sunlight_dir_ss_.xyz/sunlight_dir_ss_.w;
        float2 fov = float2(fov_x, su_fovY);
        float2 sun_pos_ss_polar;
        sun_pos_ss_polar.x = mod(atan2(-su_sunDirection.x, -su_sunDirection.y)/PI/2 + 1, 1) * 360;
        sun_pos_ss_polar.y = atan(-su_sunDirection.z / sqrt(dot(su_sunDirection.xy, su_sunDirection.xy))) / PI * 180;

        out_TEXCOORD0[0] = uv.x;
        out_TEXCOORD0[1] = uv.y;
        out_TEXCOORD0[2] = pos_ws.x;
        out_TEXCOORD0[3] = pos_ws.y;
        out_TEXCOORD1[0] = pos_ws.z;
        out_TEXCOORD1[1] = sunlight_dir_ss.x;
        out_TEXCOORD1[2] = sunlight_dir_ss.y;
        out_TEXCOORD1[3] = sunlight_dir_ss.z;
        out_TEXCOORD2[0] = fov.x;
        out_TEXCOORD2[1] = fov.y;
        out_TEXCOORD2[2] = sun_pos_ss_polar.x;
        out_TEXCOORD2[3] = sun_pos_ss_polar.y;
    ]];

    fragmentCode = [[
        // decode interpolator
        float2 uv;
        float3 pos_ws;
        float3 sunlight_dir_ss;
        float2 fov;
        float2 sun_pos_ss_polar;
        uv.x               = in_TEXCOORD0[0];
        uv.y               = in_TEXCOORD0[1];
        pos_ws.x           = in_TEXCOORD0[2];
        pos_ws.y           = in_TEXCOORD0[3];
        pos_ws.z           = in_TEXCOORD1[0];
        sunlight_dir_ss.x  = in_TEXCOORD1[1];
        sunlight_dir_ss.y  = in_TEXCOORD1[2];
        sunlight_dir_ss.z  = in_TEXCOORD1[3];
        fov.x              = in_TEXCOORD2[0];
        fov.y              = in_TEXCOORD2[1];
        sun_pos_ss_polar.x = in_TEXCOORD2[2];
        sun_pos_ss_polar.y = in_TEXCOORD2[3];

        float2 polar_rad;
        polar_rad.x = mod(atan2(pos_ws.x, pos_ws.y) + 2*PI, 2*PI);
        polar_rad.y = atan(pos_ws.z / sqrt(dot(pos_ws.xy, pos_ws.xy)));
        float az = polar_rad.x / PI * 180;
        float el = polar_rad.y / PI * 180;
        float2 polar_ = float2(az,el);

        if (el <= 0.0) {
            out_COLOR.rgb = su_hellColour;
            return;
        }




        // need to do these in fragment shader, to stop the sun vanishing at the corners of the screen
        float2 pos_ss_ = in_WPOS.xy/su_viewportSize.xy*2-1;
        pos_ss_.y *= -d3d9();

        // SUN GLARE
        float2 rel_polar = sun_pos_ss_polar.xy - polar_.xy;

        // ensure range is within -180 and 180
        if (rel_polar.x > 180) rel_polar.x -= 360;
        if (rel_polar.x < -180) rel_polar.x += 360;

        // debug crosshairs for polar coords
        //if (abs(rel_polar.x) < 3) out_COLOR.rgb = float3(1,1,0);
        //if (abs(rel_polar.y) < 3) out_COLOR.rgb = float3(1,0,0);

        // debug for drawing sun location
        //if (dot(rel_polar, rel_polar) < 10*10) out_COLOR.rgb *= float3(1,1,0);

        // sunnyness is the amount this sky pixel is affected by the sun
        float sunnyness = 0.0;
        {
            // needs max to avoid a big reflection on far side of the skysphere
            float qty = max(0, - (rel_polar.x-90)/90 * (rel_polar.x+90)/90 - el / su_skyGlareHorizonElevation);
            sunnyness = min(qty*qty, 1);
        }

        {
            float r = pow(dot(rel_polar/su_skyGlareSunDistance, rel_polar/su_skyGlareSunDistance),.1);
            r = min(r,2);
            sunnyness = clamp(sunnyness + (cos(r*PI/2)+1)/2, 0, 1);
        }

        // STARFIELD
        float2 tex_coord_ddx = ddx(uv);
        float2 tex_coord_ddy = ddy(uv);
        out_COLOR.rgb = mu_starfieldMask * gamma_decode(sample2D(mu_starfieldMap, uv, tex_coord_ddx, tex_coord_ddy).rgb);

        // SKY GRADIENT
        float3 sky;
        float3 ssky;
        if (el < su_skyDivider1) {
            sky  = lerp(su_skyColour0,  su_skyColour1,  (el- 0)/(su_skyDivider1-0));
            ssky = lerp(su_skySunColour0, su_skySunColour1, (el- 0)/(su_skyDivider1-0));
        } else if (el < su_skyDivider2) {
            sky  = lerp(su_skyColour1,  su_skyColour2,  (el-su_skyDivider1)/(su_skyDivider2-su_skyDivider1));
            ssky = lerp(su_skySunColour1, su_skySunColour2, (el-su_skyDivider1)/(su_skyDivider2-su_skyDivider1));
        } else if (el < su_skyDivider3) {
            sky  = lerp(su_skyColour2,  su_skyColour3,  (el-su_skyDivider2)/(su_skyDivider3-su_skyDivider2));
            ssky = lerp(su_skySunColour2, su_skySunColour3, (el-su_skyDivider2)/(su_skyDivider3-su_skyDivider2));
        } else if (el < su_skyDivider4) {
            sky  = lerp(su_skyColour3,  su_skyColour4,  (el-su_skyDivider3)/(su_skyDivider4-su_skyDivider3));
            ssky = lerp(su_skySunColour3, su_skySunColour4, (el-su_skyDivider3)/(su_skyDivider4-su_skyDivider3));
        } else if (el <= 90) {
            sky  = lerp(su_skyColour4,  su_skyColour5,  (el-su_skyDivider4)/(90-su_skyDivider4));
            ssky  = lerp(su_skySunColour4, su_skyColour5, (el-su_skyDivider4)/(90-su_skyDivider4));
        } else {
            sky = float3(1,1,1);
            ssky = float3(1,1,1);
        }
        out_COLOR.rgb += lerp(sky, ssky, sunnyness);




        // SUN
        if (sunlight_dir_ss.z < 1) {
            float2 sun_uv = float2(pos_ss_ - sunlight_dir_ss.xy)/su_sunSize*fov;
            if (el < 0.3 && sun_uv.y < 0 && sun_uv.y > -1) {
                //sun_uv.x *= (el+100)/101;
                sun_uv.y += (0.3-el)/5;
            }

            float sun_qty = 1;
            float dist_to_sun = dot(sun_uv,sun_uv);
            if (dist_to_sun>=1) {
                dist_to_sun /= su_sunFalloffDistance;
                dist_to_sun += 0.8; // magic number, allows big sun + small fade to look different to small sun + big fade
                sun_qty = clamp(1/dist_to_sun/dist_to_sun, 0.0, 1.0);
            }
            out_COLOR.rgb = lerp(out_COLOR.rgb, su_sunColour, su_sunAlpha * sun_qty);
        }
    ]];
}

-- }}}


sky_material `Sky` {
    starfieldMap = uniform_texture {
        --addrMode = "CLAMP"; minFilter = "LINEAR"; magFilter = "LINEAR"; mipFilter = "ANISOTROPIC"; anisotropy = 16;
        name = `starfield.dds`;
    };
    perlin = uniform_texture { name = `PerlinNoise.png` };
    perlinN = uniform_texture { name = `PerlinNoiseN.png` };
    starfieldMask = uniform_float(0.2,0.2,0.2);
    shader = `SkyBackground`;
}




sky_shader `SkyClouds` { -- {{{

    perlin = uniform_texture {
        defaultColour = vector3(0,0,0);
    };

    perlinN = uniform_texture {
        defaultColour = vector3(0.5,0.5,1);
    };

    vertexCode = [[
        float aspect = su_viewportSize.x / su_viewportSize.y;
        float fov_x = aspect * su_fovY;

        // The world matrix encodes only sky orientation data (i.e. due to the rotation of the earth).
        out_POSITION = mul(su_worldViewProj, float4(in_POSITION.xyz,0));

        // hack our way to maximum depth
        out_POSITION.z = out_POSITION.w;
        out_POSITION.z *= (1-1.0/65536); // avoid 'black lightning' artifacts


        float4 sunlight_dir_ss_ = mul(su_viewProj, float4(-su_sunDirection,1));

        // for interpolators
        float2 uv = in_TEXCOORD0.xy;
        float3 sunlight_dir_ss = sunlight_dir_ss_.xyz/sunlight_dir_ss_.w;
        float2 fov = float2(fov_x, su_fovY);
        float2 sun_pos_ss_polar;
        sun_pos_ss_polar.x = mod(atan2(-su_sunDirection.x, -su_sunDirection.y)/PI/2 + 1, 1) * 360;
        sun_pos_ss_polar.y = atan(-su_sunDirection.z / sqrt(dot(su_sunDirection.xy, su_sunDirection.xy))) / PI * 180;

        out_TEXCOORD0[0] = uv.x;
        out_TEXCOORD0[1] = uv.y;
        out_TEXCOORD0[2] = sunlight_dir_ss.x;
        out_TEXCOORD0[3] = sunlight_dir_ss.y;
        out_TEXCOORD1[0] = sunlight_dir_ss.z;
        out_TEXCOORD1[1] = fov.x;
        out_TEXCOORD1[2] = fov.y;
        out_TEXCOORD1[3] = sun_pos_ss_polar.x;
        out_TEXCOORD2[0] = sun_pos_ss_polar.y;
    ]];

    fragmentCode = [[
        // decode interpolator
        float2 uv;
        float3 sunlight_dir_ss;
        float2 fov;
        float2 sun_pos_ss_polar;
        uv.x               = in_TEXCOORD0[0];
        uv.y               = in_TEXCOORD0[1];
        sunlight_dir_ss.x  = in_TEXCOORD0[2];
        sunlight_dir_ss.y  = in_TEXCOORD0[3];
        sunlight_dir_ss.z  = in_TEXCOORD1[0];
        fov.x              = in_TEXCOORD1[1];
        fov.y              = in_TEXCOORD1[2];
        sun_pos_ss_polar.x = in_TEXCOORD1[3];
        sun_pos_ss_polar.y = in_TEXCOORD2[0];


        // need to do these in fragment shader, to stop the sun vanishing at the corners of the screen
        float2 pos_ss_ = in_WPOS.xy/su_viewportSize.xy*2-1;
        pos_ss_.y *= -d3d9();

        // CLOUDS
        float2 perlin_uv = 5*uv;
        float cloud_dist = sqrt(dot(perlin_uv,perlin_uv));

        float4 cloud_anim = float4(0.01, 0.01, 0.02, 0.02);
        float2 clouduv1 = (su_time * cloud_anim.xy + perlin_uv.xy)/5;
        float2 clouduv2 = (su_time * cloud_anim.zw + perlin_uv.yx)/5;
        float2 clouduv3 = (su_time * cloud_anim.xy + perlin_uv.xy)*5;

        cloud_dist /= 4.5;
        float cloud_atten = clamp(1-cloud_dist*cloud_dist, 0, 1);
        float cloud_tex1 = sample2D(mu_perlin, clouduv1).r;
        float cloud_tex2 = sample2D(mu_perlin, clouduv2).r;
        float cloud_tex3 = sample2D(mu_perlin, clouduv3).r;

        float cloud = clamp(((0.48*cloud_tex1 + 0.48*cloud_tex2 + 0.04*cloud_tex3) - (1-su_skyCloudCoverage)) / su_skyCloudCoverage, 0, 1);
        float murkyness = clamp(cloud*2.0 - 0.2, 0, 1) * 0.6;

        float3 cloud_ntex1 = sample2D(mu_perlinN, clouduv1).rgb*2 - 1;
        float3 cloud_ntex2 = sample2D(mu_perlinN, clouduv2).grb*2 - 1;
        float3 cloud_ntex3 = sample2D(mu_perlinN, clouduv3).rgb*2 - 1;
        float3 cloud_n = normalize(0.48*cloud_ntex1 + 0.48*cloud_ntex2 + 0.04*cloud_ntex3);

        float2 sun_uv = float2(pos_ss_ - sunlight_dir_ss.xy);
        float sun_distance = sqrt(dot(sun_uv,sun_uv)) * (fov.x+fov.y)/2;
        float3 sun_cloud_dome_pos;
        sun_cloud_dome_pos.z = 4.51*sin(sun_pos_ss_polar.y/180*PI);
        sun_cloud_dome_pos.xy = 4.51*cos(sun_pos_ss_polar.y/180*PI) * float2(sin(sun_pos_ss_polar.x/180*PI), cos(sun_pos_ss_polar.x/180*PI));
        if (sun_cloud_dome_pos.z<0) sun_cloud_dome_pos.z *= -1;
        float3 cloud_dome_pos = float3(perlin_uv, 0.3);
        float3 cloud_sun_dir = normalize(sun_cloud_dome_pos - cloud_dome_pos);
        float emboss = lerp(dot(cloud_n, cloud_sun_dir), 1, 0.5);
        out_COLOR.rgb = emboss * su_skyCloudColour * cloud_atten * cloud;
        out_COLOR.a = cloud_atten * cloud;
    ]];
}
-- }}}


sky_material `Clouds` {
    perlin = uniform_texture { name = `PerlinNoise.png` };
    perlinN = uniform_texture { name = `PerlinNoiseN.png` };
    sceneBlend = 'ALPHA';
    shader = `SkyClouds`;
}
