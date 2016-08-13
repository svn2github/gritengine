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
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_thorn.dds`,
	normalMap = `textures/sponza_thorn_n.tga`,
	glossMap = `textures/sponza_thorn_s.tga`,
    sceneBlend = "ALPHA",
    backfaces = true,
    premultipliedAlpha = 1,
}

material `vase_round` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/vase_round.dds`,
	normalMap = `textures/vase_round_n.tga`,
	glossMap = `textures/vase_round_s.tga`,
}

material `Material__57` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/vase_plant.dds`,
	glossMap = `textures/vase_plant_s.tga`,
    sceneBlend = "ALPHA",
    backfaces = true,
    premultipliedAlpha = 1,
}

material `Material__298` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/background.dds`,
	normalMap = `textures/background_n.tga`,
}

material `16___Default` {
    diffuseMask = vec(0.558, 0.558, 0.558),
}

material `bricks` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/spnza_bricks_a.dds`,
	normalMap = `textures/spnza_bricks_a_n.tga`,
	-- specularFromDiffuseAlpha = true,
}

material `arch` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_arch.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `ceiling` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_ceiling_a.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `column_a` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_column_a.dds`,
	normalMap = `textures/sponza_column_a_n.tga`,
    -- specularFromDiffuseAlpha=true,
}

material `floor` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_floor_a.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `column_c` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_column_c.dds`,
	normalMap = `textures/sponza_column_c_n.tga`,
    -- specularFromDiffuseAlpha=true,
}

material `details` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_details.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `column_b` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_column_b.dds`,
	normalMap = `textures/sponza_column_b_n.tga`,
    -- specularFromDiffuseAlpha=true,
}

material `Material__47` {
    diffuseMask = vec(0.558, 0.558, 0.558),
}

material `flagpole` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_flagpole.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `fabric_e` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_fabric_green.dds`,
    glossMap = `textures/sponza_fabric_s.tga`,
}

material `fabric_d` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_fabric_blue.dds`,
    glossMap = `textures/sponza_fabric_s.tga`,
}

material `fabric_a` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_fabric.dds`,
    glossMap = `textures/sponza_fabric_s.tga`,
}

material `fabric_g` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_curtain_blue.dds`,
}

material `fabric_c` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_curtain.dds`,
}

material `fabric_f` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_curtain_green.dds`,
}

material `chain` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/chain_texture.dds`,
	normalMap = `textures/chain_texture_n.tga`,
    sceneBlend = "ALPHA",
    backfaces = true,
    premultipliedAlpha = 1,
}

material `vase_hanging` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/vase_hanging.dds`,
}

material `vase` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/vase.dds`,
}

material `Material__25` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/lion.dds`,
	normalMap = `textures/lion_n.tga`,
}

material `roof` {
    diffuseMask = vec(0.558, 0.558, 0.558),
	diffuseMap = `textures/sponza_roof.dds`,
}
