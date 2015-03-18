-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

procedural_batch `GrassMesh` {
    mesh = `/common/veg/GrassMesh.mesh`,
    density = .2,
    minSlope = 0, maxSlope = 50,
    rotate = true,
    alignSlope = true,
    noZ = true,
    renderingDistance = 30,
    castShadows = false,
    triangles = 15000,
}

procedural_batch `TropPlant1` {
    mesh = `/common/veg/TropPlant1.mesh`,
    density = .01,
    minSlope = 0, maxSlope = 50,
    rotate = true,
    alignSlope = true,
    noZ = true,
    renderingDistance = 70,
    castShadows = true,
    tangents = true,
    triangles = 10000,
}

procedural_batch `Stone` {
    mesh = `/common/props/nature/rock.mesh`,
    density = .01,
    minSlope = 0, maxSlope = 50,
    rotate = true,
    alignSlope = false,
    noZ = true,
    renderingDistance = 70,
    castShadows = true,
    tangents = true,
    triangles = 10000,
}

physical_material `Floor` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 1.5,
    --proceduralBatches = { `GrassMesh` }
    --proceduralBatches = { `TropPlant1`, `Stone` }
}

material `RoofTiles` { diffuseMap=`/common/tex/davec/RoofTiles_d.dds`, diffuseColour=0.5*srgb(248, 253, 255), textureScale={.25,.25} }

material `Floor` { diffuseMap=`/common/tex/Test.dds`, textureScale={.25,.25} }

material `RoadSurface` { diffuseMap=`/common/tex/davec/RoadSurface_d.dds`, normalMap=`/common/tex/davec/RoadSurface_n.dds`, specularMap=`/common/tex/davec/RoadSurface_s.dds` }
material `BreezeBlocks` { diffuseMap=`/common/tex/davec/BreezeBlocks_d.dds`, normalMap=`/common/tex/davec/BreezeBlocks_n.dds` }
material `RedBrickVert` { diffuseMap=`/common/tex/davec/RedBrickVert_d.dds`, normalMap=`/common/tex/davec/RedBrick_n.dds` }
material `RedBrick` { diffuseMap=`/common/tex/davec/RedBrick_d.dds`, normalMap=`/common/tex/davec/RedBrick_n.dds` }

material `RoadMarkings` {
    overlayOffset=true,
    alphaReject=0.5,
    premultipliedAlpha=true,
    diffuseMap=`/common/tex/davec/RoadMarkings_d.dds`,
    normalMap=`/common/tex/davec/RoadMarkings_n.dds`,
    specularMap=`/common/tex/davec/RoadMarkings_s.dds`
}

class `TestFloor`   (ColClass) {receiveShadows=true,renderingDistance=1200,castShadows=true}
class `Floor`       (ColClass) {receiveShadows=true,renderingDistance=1200,castShadows=true}
class `FloorMarkings` (BaseClass) {gfxMesh=`Floor.mesh`, receiveShadows=true,renderingDistance=1200, materialMap={[`RoadSurface`]=`RoadMarkings`}}

object `Floor` (0,0,0) {rot=quat(1,0,0,0), name=`Floor`, aterialMap={[`RoadSurface`]=`RoadSurface`}}
object `FloorMarkings` (0,0,0) {rot=quat(1,0,0,0), name=`Markings`}
object `TestFloor` (100,0,1) {rot=quat(1,0,0,0), name=`TestFloor`}

object `/common/props/street/Lamp` (0,0,3) { name=`lamp` }
object `/vehicles/Scarman` (0.5,-4,0.4) { name=`car` }
object `/common/props/furniture/WorkBench` (-1.761258,-0.358200,0.650000) {name=`test_workbench`, rot=quat(-0.9866859, 0, 0, -0.1626372)}

env.clockTicking = false
env.secondsSinceMidnight = 10*60*60

