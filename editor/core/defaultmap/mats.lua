material `default_material` {
	shadowBias = 0.05,

	diffuseMap = `../assets/default_texture.png`,
	diffuseMask = V_ID * 1.7,
	normalMap = `../assets/default_texture_nm.png`,
	glossMap = `../assets/default_texture_gm.png`,
	specularMask = 1,
	glossMask = 1.0,
}

material `Terrain` {
    shadowBias=0.05,

    glossMask = 1,
	-- blend = {
		-- {
			-- diffuseMap=`../../../playground/img/textures/beachsand.dds`,
			-- normalMap=`../../../playground/img/textures/beachsand_N.dds`,
			-- glossMap=`../../../playground/img/textures/beachsand_S.tga`,
			-- textureScale={0.015, 0.015},
		-- },
		-- {
			diffuseMap = `../../../playground/img/textures/grass.dds`,
			normalMap = `../../../playground/img/textures/grass_N.dds`,
			glossMap = `../../../playground/img/textures/grass_S.tga`,
			textureScale = vec(0.015, 0.015),
		-- },	
	-- },	
}
