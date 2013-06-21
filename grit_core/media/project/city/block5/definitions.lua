--Block 5 definition file (30/5/2011)

---------------Materials---------------
material "DEFAULT" { diffuseColour={1,1,1}, specularColour={1,1,1}, gloss=15 }
material "/project/city/block5/meshes/block1" { diffuseMap="/project/city/block5/textures/block1.png"}

-- Lot 21
material "/project/DEFAULT" { diffuseColour={1,1,1}, specularColour={1,1,1}, gloss=15 }
material "/project/Hotel" { diffuseMap="/project/city/block5/textures/hotel_d.png", normalMap="/project/city/block5/textures/hotel_n.png", specularFromDiffuse = {-0.25, 0.1}, specularity=20,  }
material "/project/Hotel_roof" { diffuseMap="/project/city/block5/textures/hotel_roof_d.png", specularFromDiffuse = {0.25, 0.1}, specularity=20,  }
-- end lot 21

---------------Classes---------------
class "meshes/lot19" (ColClass) {renderingDistance=1200}
class "meshes/lot20" (ColClass) {renderingDistance=1200}
class "meshes/lot21" (ColClass) {renderingDistance=1200, castShadows=true,
lights = {
		{ pos=vector3(8.82019, 4.43657, -0.653585), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=3.5 },
		{ pos=vector3(8.82019, 0.556346, -0.653585), diff=vector3(0.705882,1.0,1.0), spec=vector3(0.705882,1.0,1.0), range=3.5 },
		{ pos=vector3(8.82019, -3.74536, -0.653585), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=3.5 },
		{ pos=vector3(6.21773, -6.94567, -0.653585), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=3.5 },
		{ pos=vector3(2.08429, -6.94567, -0.653585), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=3.5 },
		{ pos=vector3(6.32083, 12.4554, -0.221225), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=6.0, iangle=36.5, oangle=68.3, aim=quat(0.707107,-0.707107,0.0,0.0) },
		{ pos=vector3(6.32083, 8.65815, -0.221225), diff=vector3(1.0,1.0,0.811765), spec=vector3(1.0,1.0,0.811765), range=6.0, iangle=36.5, oangle=68.3, aim=quat(0.707107,-0.707107,0.0,0.0) },
	}
}
class "meshes/lot21_building" (ColClass) {renderingDistance=1200, castShadows=true}
class "meshes/Cylinder01" (ColClass) {renderingDistance=1200, castShadows=true}
