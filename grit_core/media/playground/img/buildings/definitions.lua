material "DEFAULT" { diffuseColour={.25,.25,.25}, specularColour={.25,.25,.25}, gloss=.15, shadowObliqueCutOff=soc, vertexDiffuse = true }
--material "concrW" { diffuseMap = "textures/concrW.dds", normalMap = "textures/concrW_N.dds", specularMap="textures/concRW_S.dds"  }
--material "METALcorr" { diffuseMap = "textures/metalcorr.dds", normalMap = "textures/metalcorr_N.dds", specularMap="textures/metalcorr_S.dds" }
--material "metbeam" { diffuseMap = "textures/metbeam.dds", normalMap = "textures/metbeam_N.dds", specularMap="textures/metbeam_s.dds" }
material "concrW" {
    vertexDiffuse=true,
    blend = {
        { diffuseMap="textures/concrW.dds", normalMap="textures/concrW_N.dds", specularFromDiffuse={-2,0} },
        { diffuseMap="textures/DAM_concrW.dds", normalMap="textures/DAM_concrW_N.dds", specularFromDiffuse={-2,0} },
    },
}
material "METALcorr" {
    vertexDiffuse=true,
    blend = {
        { diffuseMap="textures/metalcorr.dds", normalMap="textures/metalcorr_N.dds", specularFromDiffuse={0,5} },
        { diffuseMap="textures/DAM_metalcorr.dds", normalMap="textures/DAM_metalcorr_N.dds", specularFromDiffuse={-2,0} },
    },
}
material "metbeam" {
    vertexDiffuse=true,
    blend = {
        { diffuseMap="textures/metbeam.dds", normalMap="textures/metbeam_N.dds", specularFromDiffuse={0,0} },
        { diffuseMap="textures/DAM_metbeam.dds", normalMap="textures/DAM_metbeam_N.dds", specularFromDiffuse={0,0} },
    },
}

--Classes
class "hangar" (ColClass) {
    castShadows=true,
    renderingDistance=500,
	lights = {
	{ pos=vector3(17.6306, 0.0, 7.80465), diff=vector3(0.87451,0.717647,0.243137), spec=vector3(0.87451,0.717647,0.243137), range=15.2, iangle=81.5, oangle=105.0, aim=quat(0.707107,-0.707107,0.00061703,0.00061703) },
		}
}
