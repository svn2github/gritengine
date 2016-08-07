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

material `ocean` {
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
