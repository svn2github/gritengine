-- (c) Acisclo Murillo (JostVice), (c) Some texture work from Vincent Mayeur - 2012 - Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
--Materials

local soc=20
soc = 0

material `DEFAULT` { diffuseColour={.5,.5,.5}, specularColour={.5,.5,.5}, gloss=.15, shadowObliqueCutOff=soc, vertexDiffuse = true }

material `terrainLAY1` {
    vertexDiffuse=true,
    blend = {
        { diffuseMap=`textures/grass.dds`, normalMap=`textures/grass_N.dds`, glossMap=`textures/grass_S.tga`, textureScale={2,2} },
        { diffuseMap=`textures/dirt.dds`, normalMap=`textures/dirt_N.dds`,glossMap=`textures/dirt_S.tga` },
        { diffuseMap=`textures/rock.dds`, normalMap=`textures/rock_N.png`,glossMap=`textures/rock_S.tga`, textureScale={3,3} },
        { diffuseMap=`textures/beachsand.dds`, normalMap=`textures/beachsand_N.dds`,glossMap=`textures/beachsand_S.tga`},
    },
    shadowObliqueCutOff = soc,
}

material `terrainGRASS` {
    vertexDiffuse=true,
    diffuseMap=`textures/grass.dds`, 
	normalMap=`textures/grass_N.dds`, 
	glossMap=`textures/grass_S.tga`, 
	textureScale={2,2},
    shadowObliqueCutOff = soc,
}
	
material `terrainLAY2` {
    vertexDiffuse=true,
    blend = {
        { diffuseMap=`textures/grass.dds`, normalMap=`textures/grass_N.dds`, glossMap=`textures/grass_S.tga`, textureScale={2,2} },
        { diffuseMap=`textures/dirt.dds`, normalMap=`textures/dirt_N.dds`,glossMap=`textures/dirt_S.tga` },
        { diffuseMap=`textures/grass_dead.dds`, normalMap=`textures/grass_dead_N.dds`,glossMap=`textures/grass_dead_S.tga` },
        { diffuseMap=`textures/mud.dds`, normalMap=`textures/mud_N.dds`,glossMap=`textures/mud_S.tga` },
    },
    shadowObliqueCutOff = soc,
}
	
material `airport_cement` {
    vertexDiffuse=true,
    blend = {
        { diffuseMap=`textures/cement_tiles.dds`, normalMap=`textures/cement_tiles_N.dds`, glossMap=`textures/cement_tiles_S.tga`, textureScale={2,2} },
        { diffuseMap=`textures/dirt.dds`, normalMap=`textures/dirt_N.dds`, glossMap=`textures/dirt_S.tga` },
    },
}
material `WATERFALL` {
    vertexDiffuse=true,
    textureAnimation={0,-1},
    diffuseMap = `textures/waterfall.dds`, diffuseColour={1,1,1}, alpha=0.75,
    normalMap=`textures/waterfall_NM.dds`,
    specularMap=`textures/waterfall_S.dds`, specularColour={2,2.3,4}, gloss=0.7,
    --translucencyMap="textures/waterfall_S.dds",
    backfaces = true,
}

material `ocean` {
	diffuseColour = V_ZERO,
	--diffuseMap="textures/ocean_D.dds",
	normalMap=`textures/ocean_N.tga`,
	glossMap=`textures/ocean_S.tga`,
    depthWrite=true,
	alpha = 0.9,
	textureAnimation={-0.1,0},
}

material `Road` {vertexDiffuse=true, diffuseMap=`textures/road.dds`, normalMap=`textures/road_N.dds`, glossMap=`textures/road_S.tga`  }
material `TunnelWall` {vertexDiffuse=true, diffuseMap=`textures/TunnelWall.dds`, normalMap=`textures/TunnelWall_N.dds`, glossMap=`textures/TunnelWall_S.tga`  }

--Classes for the jilted generation

class `VCtest` (BaseClass) {castShadows=true,receiveShadows=true,renderingDistance=300}
class `road` (ColClass) {castShadows=true,receiveShadows=true,renderingDistance=1500}
class `Road2` (ColClass) {renderingDistance=1500}
class `terrain` (ColClass) {castShadows=true,receiveShadows=true,renderingDistance=1500}
class `canal` (ColClass) {castShadows=true,receiveShadows=true,renderingDistance=1500}
class `tunnel` (ColClass) {castShadows=true, receiveShadows=true, renderingDistance=500}
class `ocean_plane` (BaseClass) {renderingDistance=10000, castShadows=false, receiveShadows=false}
lights = {

	}
class `Waterfall` (BaseClass) {castShadows=true,receiveShadows=true,renderingDistance=300}
class `WaterfallBase` (ColClass) {castShadows=true,receiveShadows=true,renderingDistance=500}
class `airport_base` (ColClass) {renderingDistance=1500}

class `/common/sounds/waterfall` (SoundEmitterClass) { renderingDistance = 200, rollOff = 3, referenceDistance = 10 }
