material `default_material` {
	diffuseMap = `/editor/assets/default_texture.png`;
	diffuseColour = V_ID * 1.7;
	normalMap = `/editor/assets/default_texture_nm.png`;
	glossMap = `/editor/assets/default_texture_gm.png`;
	specular = 1;
	gloss = 1.2;
	shadowBias = 0.05;
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
			diffuseMap=`../../playground/img/textures/grass.dds`;
			normalMap=`../../playground/img/textures/grass_N.dds`;
			glossMap=`../../playground/img/textures/grass_S.tga`;
			textureScale={0.015, 0.015},
			shadowBias=0.05;
		-- },	
	-- },	
}