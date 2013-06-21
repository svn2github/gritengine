--DECAL TEST
class "decaltest2" (BaseClass) {renderingDistance=300}
class "decaltest1" (ColClass) {renderingDistance=300}
--3D Gutters
class "guttertest1" (ColClass) {renderingDistance=300}
-- Define Object Classes.
class "stupidland" (ColClass) {castShadows=false, renderingDistance=300 }
class "highway_test" (ColClass) {castShadows=true, renderingDistance=300 }
class "saucer" (ColClass) {castShadows=true, renderingDistance=300 }
class "RoadBarrel" (ColClass) {castShadows=true, renderingDistance=150, placementZOffset=0.38, placementRandomRotation=true }
class "GrassNE" (ColClass) {castShadows=false,renderingDistance=600 }
class "GrassNW" (ColClass) {castShadows=false,renderingDistance=600 }
class "GrassNW2" (ColClass) {castShadows=false,renderingDistance=600 }
class "GrassNE2" (ColClass) {castShadows=false,renderingDistance=600 }
class "GrassNE4" (ColClass) {castShadows=false,renderingDistance=600 }
class "cafesomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "rowhomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "apartsomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "hotelsomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "churchsomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "littleshopshit" (ColClass) {castShadows=true, renderingDistance=600}
class "groundzeroads" (ColClass) {castShadows=false, renderingDistance=1000 }
class "road1" (ColClass) {renderingDistance=150, lod=true}
class "road2" (ColClass) {renderingDistance=150, lod=true}
class "road3" (ColClass) {renderingDistance=150, lod=true}
class "road4" (ColClass) {renderingDistance=150, lod=true}
class "lod_road1" (BaseClass) {castShadows=false, renderingDistance=1000}
class "lod_road2" (BaseClass) {castShadows=false, renderingDistance=1000}
class "lod_road3" (BaseClass) {castShadows=false, renderingDistance=1000}
class "lod_road4" (BaseClass) {castShadows=false, renderingDistance=1000}
--class "SchoolRoad" (ColClass) {castShadows=false,renderingDistance=600 }
--class "lod_groundzeroads" (BaseClass) {castShadows=false,renderingDistance=3000}
class "bigpropane" (ColClass) {castShadows=false, renderingDistance=200, placementZOffset=1, lod=true}
class "lod_bigpropane" (BaseClass) {castShadows=true, renderingDistance=1000, placementZOffset=1}
--wip
class "storesomeshit" (ColClass) {castShadows=true, renderingDistance=600 }
class "CnrStrSign" (ColClass) {castShadows=false, renderingDistance=100}

class "RedBarrel" (ColClass) {castShadows=true, renderingDistance=300}

class "streetlamp" (ColClass) {
    castShadows=true, renderingDistance=300,
    lights = {
        { pos=vector3(0,-1.7,7.85), diff=5*vector3(1,0.7,0), spec=5*vector3(1,0.7,0), range=14, iangle=20, oangle=60, aim=quat(-90,V_RIGHT) }
    }
}
