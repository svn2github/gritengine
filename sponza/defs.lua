print("Loading Crytek sponza classes & materials")

for i=0,382 do
    class (`sponza` .. string.format("_%02d",i)) (ColClass) { castShadows=true, renderingDistance = 400 }
end

if true then
class `sponza_03` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_74` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_08` (ColClass) { castShadows = false; renderingDistance = 400 }
class `sponza_19` (ColClass) { castShadows = false; renderingDistance = 400 }
class `sponza_376` (ColClass) { castShadows = false; renderingDistance = 400 }
class `sponza_117` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_378` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_370` (ColClass) { castShadows = true; renderingDistance = 50 }
class `sponza_368` (ColClass) { castShadows = true; renderingDistance = 50 }
class `sponza_282` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_288` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_289` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_71` (ColClass) { castShadows = false; renderingDistance = 100 }
class `sponza_257` (ColClass) { castShadows = false; renderingDistance = 100 }
end

material `leaf` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_thorn.dds`;
	normalMap = `textures/sponza_thorn_n.tga`;
	specularMap = `textures/sponza_thorn_s.tga`;
    alpha=true;
    backfaces = true;
    premultipliedAlpha=true;
}

material `vase_round` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/vase_round.dds`;
	normalMap = `textures/vase_round_n.tga`;
	specularMap = `textures/vase_round_s.tga`;
}

material `Material__57` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/vase_plant.dds`;
	specularMap = `textures/vase_plant_s.tga`;
    alpha=true;
    backfaces = true;
    premultipliedAlpha=true;
}

material `Material__298` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/background.dds`;
	normalMap = `textures/background_n.tga`;
}

material `16___Default` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
}

material `bricks` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/spnza_bricks_a.dds`;
	normalMap = `textures/spnza_bricks_a_n.tga`;
	specularFromDiffuseAlpha = true;
}

material `arch` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_arch.dds`;
    specularFromDiffuseAlpha=true;
}

material `ceiling` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_ceiling_a.dds`;
    specularFromDiffuseAlpha=true;
}

material `column_a` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_column_a.dds`;
	normalMap = `textures/sponza_column_a_n.tga`;
    specularFromDiffuseAlpha=true;
}

material `floor` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_floor_a.dds`;
    specularFromDiffuseAlpha=true;
}

material `column_c` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_column_c.dds`;
	normalMap = `textures/sponza_column_c_n.tga`;
    specularFromDiffuseAlpha=true;
}

material `details` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_details.dds`;
    specularFromDiffuseAlpha=true;
}

material `column_b` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_column_b.dds`;
	normalMap = `textures/sponza_column_b_n.tga`;
    specularFromDiffuseAlpha=true;
}

material `Material__47` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
}

material `flagpole` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_flagpole.dds`;
    specularFromDiffuseAlpha=true;
}

material `fabric_e` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_fabric_green.dds`;
    specularMap = `textures/sponza_fabric_s.tga`;
}

material `fabric_d` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_fabric_blue.dds`;
    specularMap = `textures/sponza_fabric_s.tga`;
}

material `fabric_a` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_fabric.dds`;
    specularMap = `textures/sponza_fabric_s.tga`;
}

material `fabric_g` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_curtain_blue.dds`;
}

material `fabric_c` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_curtain.dds`;
}

material `fabric_f` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_curtain_green.dds`;
}

material `chain` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/chain_texture.dds`;
	normalMap = `textures/chain_texture_n.tga`;
    alpha=true;
    backfaces = true;
    premultipliedAlpha=true;
}

material `vase_hanging` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/vase_hanging.dds`;
}

material `vase` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/vase.dds`;
}

material `Material__25` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/lion.dds`;
	normalMap = `textures/lion_n.tga`;
}

material `roof` {
	ambientColour = 0.5880;
	diffuseColour = {0.5880,0.5880,0.5880};
	diffuseMap = `textures/sponza_roof.dds`;
}
