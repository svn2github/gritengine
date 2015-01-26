-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading default_shader.lua")

shader `Default` {

    diffuseMap = uniform_texture_2d(1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);

    alphaMask = uniform_float(1);
    alphaRejectThreshold = uniform_float(-1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1);

    glossMap = uniform_texture_2d(1, 1, 1);
    glossMask = uniform_float(1);
    specularMask = uniform_float(1);

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
    ]],

    dangsCode = [[
        var diff_texel = sample(mat.diffuseMap, vert.coord0.xy);
        // TODO(dcunnin): Support enumerations
        //if (mat.premultipliedAlpha) diff_texel = pma_decode(diff_texel);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;
        out.alpha = diff_texel.a * mat.alphaMask;
        if (out.alpha < mat.alphaRejectThreshold) discard;
        var normal_texel = sample(mat.normalMap, vert.coord0.xy).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        // TODO(dcunnin): double sided faces
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        var gloss_texel = sample(mat.glossMap, vert.coord0.xy);
        out.gloss = gloss_texel.b * mat.glossMask;
        out.specular = gamma_decode(gloss_texel.r) * mat.specularMask;
    ]],

    colourCode = [[
        var c = sample(mat.emissiveMap, vert.coord0.xy);
        out.colour = gamma_decode(c.rgb) * mat.emissiveMask;
    ]]
}
