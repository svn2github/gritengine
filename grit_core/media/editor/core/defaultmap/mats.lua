material `default_material` {
	diffuseMap=`../assets/default_texture.png`;
	normalMap=`../assets/default_texture_nm.png`;
	glossMap=`../assets/default_texture_gm.png`;
	gloss=1;
	specular=1;
	emissiveColour=vec(0, 0, 0.00001);
	shadowBias=0.05;
}
material `Terrain` {
	-- blend = {
		-- {
			-- diffuseMap=`../../../playground/img/textures/beachsand.dds`;
			-- normalMap=`../../../playground/img/textures/beachsand_N.dds`;
			-- glossMap=`../../../playground/img/textures/beachsand_S.tga`;
			-- textureScale={0.015, 0.015},
			-- shadowBias=0.05;
		-- },
		-- {
			diffuseMap=`../../../playground/img/textures/grass.dds`;
			normalMap=`../../../playground/img/textures/grass_N.dds`;
			glossMap=`../../../playground/img/textures/grass_S.tga`;
			textureScale={0.015, 0.015},
			shadowBias=0.05;
		-- },	
	-- },	
}