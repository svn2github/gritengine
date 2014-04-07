-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

procedural_batch "GrassMesh" {
    mesh = "/common/veg/GrassMesh.mesh",
    density = .2,
    minSlope = 0, maxSlope = 50,
    rotate = true,
    alignSlope = true,
    noZ = true,
    renderingDistance = 30,
    castShadows = false,
    triangles = 15000,
}

procedural_batch "TropPlant1" {
    mesh = "/common/veg/TropPlant1.mesh",
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

procedural_batch "Stone" {
    mesh = "/common/props/nature/rock.mesh",
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

physical_material "Floor" {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 1.5,
    --proceduralBatches = { "GrassMesh" }
    --proceduralBatches = { "TropPlant1", "Stone" }
}

material "RoadMarkings" { }

material "Floor" { diffuseMap="/common/tex/Test.dds", textureScale={.25,.25} }
--material "Floor" { }

--material "RoadSurface" { diffuseMap="RoadSurface_d.dds", normalMap="RoadSurface_n.dds", specularMap="RoadSurface_s.dds" }
--material "RoadSurface" { diffuseMap="BreezeBlocks_d.dds", normalMap="BreezeBlocks_n.dds" }
material "RoadSurface" { diffuseMap="RedBrickVert_d.dds", normalMap="RedBrickVert_n.dds" }
material "RoofTiles" { diffuseMap="FeltTiles_d.png", specularFromDiffuse={-1,1}, diffuseColour=srgb(248, 253, 255), textureScale={.25,.25} }
--material "RoadSurface" { diffuseMap="RedBrick_d.dds", normalMap="RedBrick_n.dds" }
--material "RoadMarkings" { diffuseMap="RoadMarkings_d.dds", normalMap="RoadMarkings_n.dds", specularMap="RoadMarkings_s.dds" }
material "RoadMarkings" { overlayOffset=true, alphaReject=0.5, premultipliedAlpha=true, diffuseMap="RoadMarkings_d.dds", normalMap="RoadMarkings_n.dds", specularMap="RoadMarkings_s.dds" }
class "TestFloor"   (ColClass) {receiveShadows=true,renderingDistance=1200,castShadows=true}
class "Floor"       (ColClass) {receiveShadows=true,renderingDistance=1200,castShadows=true}
class "FloorMarkings" (BaseClass) {gfxMesh=r"Floor.mesh", receiveShadows=true,renderingDistance=1200, materialMap={RoadSurface=r"RoofTiles"}}
class "ThunderDome" (ColClass) {receiveShadows=true,renderingDistance=400,castShadows=true}


object "Floor"       (0,0,0)   {rot=quat(1,0,0,0), name="Floor", materialMap={RoadSurface=r"RoofTiles"}}
--object "FloorMarkings"       (0,0,0)   {rot=quat(1,0,0,0), name="Markings"}
object "TestFloor"   (100,0,1)   {rot=quat(1,0,0,0), name="TestFloor"}

object "/common/props/street/Lamp" (0,0,3) { name="lamp" }
object "/vehicles/Evo" (0.5,-4,0.4) { name="evo" }
object "/common/props/furniture/WorkBench" (-1.761258,-0.358200,0.650000) {name="Unnamed:/common/props/furniture/WorkBench:0", rot=quat(-0.9866859, 0, 0, -0.1626372)}

env.clockTicking = false
env.secondsSinceMidnight = 10*60*60
--player_ctrl:warp(vector3(-1.580179, -3.82132, 1.49557),quat(0.9471574, -0.3077501, 0.0279533, -0.0860314))

