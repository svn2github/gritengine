-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local plastic_spec = 0.04
material `Red` { diffuseColour=vector3(.5,0,0), specular=plastic_spec, gloss=.5 }
material `Blue` { diffuseColour=vector3(0,0,.5), specular=plastic_spec, gloss=.5 }
material `Green` { diffuseColour=vector3(0,.5,0), specular=plastic_spec, gloss=.5 }
material `Yellow` { diffuseColour=vector3(.5,.5,0), specular=plastic_spec, gloss=.5 }
material `Cyan` { diffuseColour=vector3(0,.5,.5), specular=plastic_spec, gloss=.5 }
material `Magenta` { diffuseColour=vector3(.5,0,.5), specular=plastic_spec, gloss=.55 }
material `Black` { diffuseColour=vector3(.1,.1,.1), specular=plastic_spec, gloss=.75 }
material `White` { diffuseColour=vector3(.7,.7,.7), specular=plastic_spec, gloss=.25 }
material `Grey` { diffuseColour=vector3(.5,.5,.5), specular=plastic_spec, gloss=.0 }

material `Emissive` { diffuseColour=vector3(.7,.7,.7), specular=plastic_spec, gloss=.25, emissiveMask=vec(3,3,3), additionalLighting=true }

material `Chrome` { diffuseColour=V_ZERO, specular=1, gloss=1 }

material `Test` { diffuseMap=`../tex/Test.dds` }
material `TestNorm` { diffuseMap=`../tex/Test.dds`, normalMap=`../tex/Test_n.dds` }

material `Burnt` { diffuseMap=`burnt.png`, diffuseColour=vec(1, 1, 1), specular=0.03, gloss=0.01 }

material `Grass` { diffuseMap = `../tex/davec/Grass_d.dds`, specular=0.03, gloss = 0.01 }
material `PackedGravel` { diffuseMap = `../tex/davec/PackedGravel_d.dds`, normalMap = `../tex/davec/PackedGravel_n.dds`, specular=0.03; specularMap = `../tex/davec/PackedGravel_d.dds`, }
material `RoadSurface` { diffuseMap = `../tex/davec/RoadSurface_d.dds`, normalMap = `../tex/davec/RoadSurface_n.dds`, specular=0.03, specularMap = `../tex/davec/RoadSurface_s.dds` }
material `RedBrick` { diffuseMap = `../tex/davec/RedBrick_d.dds`, normalMap = `../tex/davec/RedBrick_n.dds`, vertexDiffuse=true }
material `RoofTiles` { diffuseMap=`../tex/davec/RoofTiles_d.dds`, specularFromDiffuse={-1,1}, diffuseColour=srgb(248, 253, 255) , specular=0.03, vertexDiffuse=true }

