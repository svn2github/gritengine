map_ghost_spawn(vector3(0, 0, 15))


--THE DIFFERENT PARTS OF THE CITY

--OBJECT DEFINITION (CLASSES)
include `city/block1/definitions.lua`
include `city/block2/definitions.lua`
include `city/block3/definitions.lua`
include `city/block4/definitions.lua`
include `city/block5/definitions.lua`
include `city/block6/definitions.lua`
include `city/block7/definitions.lua`

--OBJECT PLACEMENT
include `city/block1/placement.lua`
include `city/block2/placement.lua`
include `city/block3/placement.lua`
include `city/block4/placement.lua`
include `city/block5/placement.lua`
include `city/block6/placement.lua`
include `city/block7/placement.lua`
--class `city` (ColClass) {castShadows=false,renderingDistance=1200}

--MATERIALS (THE SHARED ONES) 

material `basicgrass` { diffuseMap=`textures/grass.dds`, normalMap=`textures/grass_n.png` }
material `intermap` { diffuseMap=`textures/intermap.dds`, normalMap=`textures/intermap_n.dds`, specularMap=`textures/intermap_s.dds`, clamp=true}
material `roadmap` { diffuseMap=`textures/roadmap.dds`, normalMap=`textures/roadmap_n.dds`, specularMap=`textures/roadmap_s.dds` }
material `roadmap_whitelines` { diffuseMap=`textures/road2lane.dds`, normalMap=`textures/road2lane_n.dds`, specularMap=`textures/road2lane_s.dds` }

--TILING

--for y = -3,3 do
--    for x = -3,3 do
--        object `city` ( x*285,  y*275, 0.0) {}
--    end
--end
