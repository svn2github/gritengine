material "TropGroup1" {
    backfaces=true,
    diffuseMap = "textures/TropGroup1.dds",
    clamp = true,
    alphaReject = 0.5,
    shadowAlphaReject = true,
    normalMap = "textures/TropGroup1_N.dds",
    specularFromDiffuse = {-0.3, 0.2}, gloss=7,
    translucencyMap = "textures/TropGroup1_SSS.dds",
    shadowBias=.03,
    gloss = 0,
    specular = 0,
}

class "TropPlant1" (BaseClass) { castShadows=true, renderingDistance=70, placementRandomRotation=true }
class "TinyPalmT" (BaseClass) { castShadows=true, renderingDistance=70, placementRandomRotation=true }
class "YellowFlowers" (BaseClass) { castShadows=true, renderingDistance=35, placementRandomRotation=true }
class "PinkFlowers" (BaseClass) { castShadows=true, renderingDistance=35, placementRandomRotation=true }

material "Tree_aelmTrunk" {
	vertexDiffuse = true,
    diffuseMap = "textures/tree_aelm.dds",
    normalMap = "textures/tree_aelm_N.dds",
    gloss = 0,
    specular = 0,
}

material "Tree_aelmLev" {
	vertexDiffuse = false,
    diffuseMap = "textures/tree_aelm.dds",
    clamp = true,
    alphaReject = 0.5,
    normalMap = "textures/tree_aelm_N.dds",
    gloss = 0,
    specular = 0,
}


class "Tree_aelm_LOD" (ColClass) { castShadows=true, renderingDistance=350, colMesh=`Tree_aelm.gcol` }
class "Tree_aelm" (ColClass) { castShadows=true, renderingDistance=100, lod=`Tree_aelm_LOD` }


--paroxum's tree, hes mad

material "generic_bark" {
	vertexDiffuse = true,
    diffuseMap = "textures/generic_bark.tga",
    normalMap = "textures/generic_bark_nrm.tga",
    gloss = 0,
    specular = 0,
}

material "flowerbed_dif" {
	backfaces=true,
	vertexDiffuse = false,
    diffuseMap = "textures/flowerbed_dif.tga",
    normalMap = "textures/flowerbed_nrm.tga",
	shadowAlphaReject = true,
    shadowReceive = false,
	clamp = true,
    alphaReject = 0.5,
    diffuseColour = { 1.3, 1.3, 1.3 },
    ambientColour = 5,
    gloss = 0,
    specular = 0,
}

class "prxtree" (ColClass) { castShadows=true, renderingDistance=250 }

--end paroxum tree

material "GrassTuft1" {
    backfaces=true,
    diffuseMap = "textures/GrassTuft1_D.dds",
    clamp = true,
    alphaReject = 0.9,
    grassLighting = true,
    gloss = 0,
    specular = 0,
}

material "grasstuft2" {
    backfaces=true,
    diffuseMap = "textures/GrassTuft2_D.dds",
	normalMap = "textures/GrassTuft2_N.dds",
    clamp = true,
    alphaReject = 0.33,
    grassLighting = true,
    gloss = 0,
    specular = 0,
}


material "GrassMap1" {
    backfaces=true,
    diffuseMap = "textures/GrassMap1.dds",
    clamp = true,
    alphaReject = 0.5,
    grassLighting = true,
    gloss = 0,
    specular = 0,
}

class "GrassTuft1" (BaseClass) { renderingDistance=30, placementRandomRotation=true }
class "GrassMesh" (BaseClass) { renderingDistance=30, placementRandomRotation=true }
