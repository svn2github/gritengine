-- (c) Acisclo Murillo (JostVice), (c) Some texture work from Vincent Mayeur - 2012 - Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
--Materials

material `DEFAULT` {
    diffuseMask = vec(0.5, 0.5, 0.5),
    specularMask = .5,
    glossMask = .15,
    diffuseVertex = 1,
}

material `terrainLAY1` {
    shader = `/common/HeightmapBlend4`,
    diffuseVertex = 1,
    
    diffuseMap0 = `textures/grass.dds`,
    normalMap0 = `textures/grass_N.dds`,
    pbrMap0 = `textures/grass_S.tga`,
    uvScale0 = 1/vec(2, 2),

    diffuseMap1 = `textures/dirt.dds`,
    normalMap1 = `textures/dirt_N.dds`,
    pbrMap1 = `textures/dirt_S.tga`,

    diffuseMap2 = `textures/rock.dds`,
    normalMap2 = `textures/rock_N.png`,
    pbrMap2 = `textures/rock_S.tga`,
    uvScale2 = 1/vec(3, 3),

    diffuseMap3 = `textures/beachsand.dds`,
    normalMap3 = `textures/beachsand_N.dds`,
    pbrMap3 = `textures/beachsand_S.tga`,
}

material `terrainGRASS` {
    diffuseVertex = 1,
    diffuseMap = `textures/grass.dds`, 
	normalMap = `textures/grass_N.dds`, 
	glossMap = `textures/grass_S.tga`, 
    glossMask = 1,
	textureScale = 1 / vec(2, 2),
}
	
material `terrainLAY2` {
    shader = `/common/HeightmapBlend4`,

    diffuseVertex = 1,
    diffuseMap0 = `textures/grass.dds`,
    normalMap0 = `textures/grass_N.dds`,
    pbrMap0 = `textures/grass_S.tga`,
    uvScale0 = 1 / vec(2, 2),

    diffuseMap1 = `textures/dirt.dds`,
    normalMap1 = `textures/dirt_N.dds`,
    pbrMap1 = `textures/dirt_S.tga`,

    diffuseMap2 = `textures/grass_dead.dds`,
    normalMap2 = `textures/grass_dead_N.dds`,
    pbrMap2 = `textures/grass_dead_S.tga`,

    diffuseMap3 = `textures/mud.dds`,
    normalMap3 = `textures/mud_N.dds`,
    pbrMap3 = `textures/mud_S.tga`,
}
	
material `airport_cement` {
    shader = `/common/HeightmapBlend2`,

    diffuseVertex = 1,

    diffuseMap0 = `textures/cement_tiles.dds`,
    normalMap0 = `textures/cement_tiles_N.dds`,
    pbrMap0 = `textures/cement_tiles_S.tga`,
    uvScale0 = 1 / vec(2, 2),

    diffuseMap1 = `textures/dirt.dds`,
    normalMap1 = `textures/dirt_N.dds`,
    pbrMap1 = `textures/dirt_S.tga`,
}

material `WATERFALL` {
    sceneBlend = "ALPHA",
    backfaces = true,
    castShadows = false,

    textureAnimation = vec(0, -1),
    diffuseVertex = 1,
    diffuseMap = `textures/waterfall.dds`,
    alphaMask = 0.75,
    normalMap = `textures/waterfall_NM.dds`,
    -- specularMap = `textures/waterfall_S.dds`,
    specularMask = 0.02,
    glossMask = 0.7,
}


shader `Ocean` {

    textureAnimation = uniform_float(0, 0);
    textureScale = uniform_float(1, 1);

    diffuseMap = uniform_texture_2d(1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);
    diffuseVertex = static_float(0);  -- Boolean

    alphaMask = uniform_float(1);
    alphaVertex = static_float(0);  -- Boolean
    alphaRejectThreshold = uniform_float(-1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1);

    glossMap = uniform_texture_2d(1, 1, 1);
    glossMask = uniform_float(0);
    specularMask = uniform_float(0.04);
    premultipliedAlpha = static_float(0);  -- Boolean

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz)+Float3(0, 0, sin(global.time*0.0002 * (vert.position.x+vert.position.y)));
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
    ]],

    dangsCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
		var uv2 = vert.coord0.xy * mat.textureScale*5 + global.time*5 * -mat.textureAnimation.yx;
        var diff_texel = sample(mat.diffuseMap, uv);
        if (mat.premultipliedAlpha > 0) diff_texel = pma_decode(diff_texel);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;
        if (mat.diffuseVertex > 0) out.diffuse = out.diffuse * vert.colour.xyz;
        out.alpha = diff_texel.a * mat.alphaMask;
        if (mat.alphaVertex > 0) out.alpha = out.alpha * vert.colour.w;
        if (out.alpha <= mat.alphaRejectThreshold) discard;
        var normal_texel = ((sample(mat.normalMap, uv) + sample(mat.normalMap, uv2))/2).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        var gloss_texel = sample(mat.glossMap, uv);
        out.gloss = gloss_texel.b * mat.glossMask;
        out.specular = gamma_decode(gloss_texel.r) * mat.specularMask;
    ]],

    colourCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
        var c = sample(mat.emissiveMap, uv);
        out.colour = gamma_decode(c.rgb) * mat.emissiveMask;
    ]],
}

material `ocean` {
	shader = `Ocean`,
    sceneBlend = "ALPHA_DEPTH",

	diffuseMask = vec(0, 0, 0),
	alphaMask = 0.9,
	normalMap = `textures/ocean_N.tga`,
    glossMask = 1,
    specularMask = 0.5,
	textureAnimation = vec(-0.1, 0),
}

material `Road` {
    diffuseVertex = 1,
    diffuseMap = `textures/road.dds`,
    normalMap = `textures/road_N.dds`,
    glossMap = `textures/road_S.tga`,
    glossMask = 1,
}
material `TunnelWall` {
    diffuseVertex = 1,
    diffuseMap = `textures/TunnelWall.dds`,
    normalMap = `textures/TunnelWall_N.dds`,
    glossMap = `textures/TunnelWall_S.tga`,
    glossMask = 1,
}

--Classes for the jilted generation

class `VCtest` (BaseClass) {castShadows = true,renderingDistance = 300}
class `road` (ColClass) {castShadows = true,renderingDistance = 1500}
class `Road2` (ColClass) {renderingDistance = 1500}
class `terrain` (ColClass) {castShadows = true,renderingDistance = 1500}
class `canal` (ColClass) {castShadows = true,renderingDistance = 1500}
class `tunnel` (ColClass) {castShadows = true, renderingDistance = 500}
class `ocean_plane` (BaseClass) {renderingDistance = 10000, castShadows = false}
class `Waterfall` (BaseClass) {castShadows = true,renderingDistance = 300}
class `WaterfallBase` (ColClass) {castShadows = true,renderingDistance = 500}
class `airport_base` (ColClass) {renderingDistance = 1500}

class `/common/sounds/waterfall` (SoundEmitterClass) { renderingDistance = 200, rollOff = 3, referenceDistance = 10 }
