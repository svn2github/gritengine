map_ghost_spawn(vector3(0, -40, 15))

material "basicgrass" { diffuseMap="textures/grass_d.dds", normalMap="textures/grass_n.png" }
material "grass_lod" { diffuseMap="textures/lod_grass.dds" }
material "intermap" { diffuseMap="textures/intermap_d.dds", normalMap="textures/intermap_n.dds", specularMap="textures/intermap_s.dds", clamp=true}
material "roadmap" { diffuseMap="textures/roadmap_d.dds", normalMap="textures/roadmap_n.dds", specularMap="textures/roadmap_s.dds", clamp=false  }
material "roadmap_2lane" { diffuseMap="textures/roadmap_2lane_d.dds", normalMap="textures/roadmap_2lane_n.dds", specularMap="textures/roadmap_2lane_s.dds", clamp=true  }
material "rollroofing" { diffuseMap="textures/rollroofing_d.dds", normalMap="textures/rollroofing_n.png", specularMap="textures/rollroofing_s.dds" }
material "buildingatlas01" { diffuseMap="textures/buildingatlas_d.dds", normalMap="textures/buildingatlas_n.png", specularMap="textures/buildingatlas_s.dds" }
material "devstone" { diffuseMap="textures/devstone.dds" }

class "GenericDoor001" (ColClass) {castShadows=false,renderingDistance=50}

class "hugeroads" (ColClass) {castShadows=false,renderingDistance=600}
class "HugeAssRoads01" (ColClass) {castShadows=false,renderingDistance=600}
class "HugeAssRoads02" (ColClass) {castShadows=false,renderingDistance=600}
class "HugeAssRoads03" (ColClass) {castShadows=false,renderingDistance=600}
class "HugeAssRoads04" (ColClass) {castShadows=false,renderingDistance=600}
class "HugeAssRoads05" (ColClass) {castShadows=false,renderingDistance=600}

class "lot1" (ColClass) {castShadows=true,renderingDistance=150, lod=true}
class "lot2" (ColClass) {castShadows=true,renderingDistance=150, lod=true}
class "lot3" (ColClass) {castShadows=true,renderingDistance=150, lod=true}
class "lot4" (ColClass) {castShadows=true,renderingDistance=150, lod=true}
class "lot5" (ColClass) {castShadows=true,renderingDistance=150, lod=true}
class "lot6" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lot7" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lod_lot1" (BaseClass) {castShadows=true,renderingDistance=3000}
class "lod_lot2" (BaseClass) {castShadows=true,renderingDistance=3000}
class "lod_lot3" (BaseClass) {castShadows=true,renderingDistance=3000}
class "lod_lot4" (BaseClass) {castShadows=true,renderingDistance=3000}
class "lod_lot5" (BaseClass) {castShadows=true,renderingDistance=3000}
class "lod_lot6" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_lot7" (BaseClass) {castShadows=false,renderingDistance=3000}

class "NorthLot01a" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot01b" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot01c" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot02" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot03" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot04" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "NorthLot05" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lod_NorthLot01a" (BaseClass) {castShadows=false, renderingDistance=3000 }
class "lod_NorthLot01b" (BaseClass) {castShadows=false, renderingDistance=3000 }
class "lod_NorthLot01c" (BaseClass) {castShadows=false, renderingDistance=3000 }
class "lod_NorthLot02" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_NorthLot03" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_NorthLot04" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_NorthLot05" (BaseClass) {castShadows=false,renderingDistance=3000}

class "EastLot1" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "EastLot2" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "EastLot3" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lod_EastLot1" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_EastLot2" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_EastLot3" (BaseClass) {castShadows=false,renderingDistance=3000}

class "lotsEast01" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lod_lotsEast01" (BaseClass) {castShadows=false,renderingDistance=3000}



class "MedianBit01" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "MedianBit02" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "MedianBit03" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "MedianBit04" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "MedianBit05" (ColClass) {castShadows=false,renderingDistance=150, lod=true}
class "lod_MedianBit01" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_MedianBit02" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_MedianBit03" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_MedianBit04" (BaseClass) {castShadows=false,renderingDistance=3000}
class "lod_MedianBit05" (BaseClass) {castShadows=false,renderingDistance=3000}

object "GenericDoor001" (-11.5473, 18.0, 1.307) {}
--huge roads to be broken down into roads under lots placeholders
object "hugeroads" (45.0792, -45.0, -2.42941) {}
object "HugeAssRoads01" (-94.9629, -72.4213, 5.5432) {}
object "HugeAssRoads02" (17.2309, 246.308, 12.7157) {}
object "HugeAssRoads03" (85.0313, 376.671, 33.0182) {}
object "HugeAssRoads04" (252.047, 171.691, -2.30143) {}
object "HugeAssRoads05" (245.134, -79.8116, -4.25297) {}
--basic lots placeholders
object "lot1" (-45.0, 45.0, 0.0569678) {}
object "lot2" (45.0, 45.0, 0.0569678) {}
object "lot3" (-45.0, -45.0, 0.0569678) {}
object "lot4" (45.0, -45.0, 0.0569678) {}
object "lot5" (137.582, 3.8147e-006, -2.35353) {}
object "lot6" (-2.49999, -135.315, -2.62241) {}
object "lot7" (135.588, -135.0, -1.90553) {}

object "NorthLot01a" (25.2054, 305.055, 16.8454) {}
object "NorthLot01b" (-74.2959, 246.248, 14.298) {}
object "NorthLot01c" (5.4146, 229.327, 4.22121) {}
object "NorthLot02" (-125.044, 138.787, 8.40292) {}
object "NorthLot03" (-44.947, 126.817, 1.2345) {}
object "NorthLot04" (45.6201, 127.524, 2.27736) {}
object "NorthLot05" (137.741, 181.528, 3.63864) {}

object "EastLot1" (-149.956, 51.432, 5.34461) {}
object "EastLot2" (-158.2, -36.0234, 2.06152) {}
object "EastLot3" (-162.874, -124.499, -2.07035) {}

object "lotsEast01" (235.134, -79.8013, -4.17814) {}

object "MedianBit01" (-248.686, -249.264, -6.02392) {}
object "MedianBit02" (-234.54, -69.3399, -0.551648) {}
object "MedianBit03" (-199.338, 105.517, 10.4306) {}
object "MedianBit04" (-76.6388, 299.383, 23.33) {}
object "MedianBit05" (83.0657, 433.228, 31.2418) {}
