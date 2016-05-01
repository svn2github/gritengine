map_ghost_spawn(vector3(0, 0, 0))

class `door_low` (BaseClass) {castShadows=true,receiveShadows=true,renderingDistance=300}
class `smallmap` (BaseClass) {castShadows=true,receiveShadows=true,renderingDistance=300}

--Material definition:
material `scifi_door` { diffuseMap=`heavydoor_1024_DIF.dds`, normalMap=`heavydoor_1024_NRM.dds`, specularMap=`heavydoor_1024_SPEC.dds`,
						specularColour={2,2,2}}
material `wall_low` { diffuseMap=`heavywall_1024_DIF.dds`, normalMap=`heavywall_1024_NRM.dds`, specularMap=`heavywall_1024_SPEC.dds`,
						specularColour={2,2,2}}
--Object placement
--object "door_low" (0,0,0) {}
object `smallmap` (0,0,0) { name="smallmap" }
