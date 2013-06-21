--materials
--development/in developtment textures
material "decaltest" { diffuseMap="materials/decaltest.dds", alpha=true}
material "CnrStrSign" { diffuseMap="materials/cornermap.dds", normalMap="materials/cornermap_n.png" }
material "devtex5m" { diffuseMap="materials/devtex5m.png" }
material "lot_test" { diffuseMap="materials/lot_test.dds", normalMap="materials/lot_test_n.png", specularMap="materials/lot_test_s.dds" }
material "highway" { diffuseMap="materials/highwaymap.dds", normalMap="materials/highwaymap_n.png" }
-- Define Materials For Object Classes.
material "saucer" { diffuseMap="materials/saucer.dds", normalMap="materials/saucer_n.png", specularMap="materials/saucer_s.dds" }
material "basicgrass" { diffuseMap="materials/grass.dds", normalMap="materials/grass_n.png" }
material "intermap" { diffuseMap="materials/intermap.dds", normalMap="materials/intermap_n.png", specularMap="materials/intermap_s.dds", clamp=true}
material "roadmap" { diffuseMap="materials/roadmap.dds", normalMap="materials/roadmap_n.png", specularMap="materials/roadmap_s.dds" }
material "roadmap_var1" { diffuseMap="materials/roadmap_var1.png", normalMap="materials/roadmap_var1_n.png", specularMap="materials/roadmap_var1_s.png"  }
material "lod_roads1" { diffuseMap="materials/lod_roads1.png" }
material "SchoolStreet" { diffuseMap="materials/SchoolStreet.dds", normalMap="materials/SchoolStreet_n.png", specularMap="materials/SchoolStreet_s.dds" }
material "lod_roads" { diffuseMap="materials/lod_roads.png"}
material "RoadBarrel" { diffuseMap="materials/RoadBarrel.png", specularMap="materials/RoadBarrel_s.dds", specularColour=vector3(2,2,2), glossFromSpecularAlpha=true; specularity=30 }
material "bigpropane" { diffuseMap="materials/bigpropane.dds", normalMap="materials/bigpropane_n.png", specularMap="materials/bigpropane_s.dds", shadowBias=.1 }
material "indus_lod1" { diffuseMap="materials/indus_lod1.png" }
material "streetlamp" { diffuseMap="materials/streetlamp.png", specularMap="materials/streetlamp_s.png" }
material "RedBarrel" { diffuseMap="materials/RedBarrel.png", normalMap="materials/RedBarrel_n.png", specularMap="materials/RedBarrel_s.png" }
-- Physical Materials Placeholder
physical_material "PropTank" { interactionGroup = SmoothSoftGroup, roadTyreFriction = 1.1, offRoadTyreFriction = 0.9 }
