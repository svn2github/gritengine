class `test_sphere` (BaseClass) { castShadows = true }

material `sphere_mat` {
    diffuseColour = V_ZERO,
    gloss = 1.0,
    specular = 1.0,
}

material `sphere_mat2` {
    diffuseColour = V_ZERO,
    gloss = 0.5,
    specular = 1.0,
}

material `sphere_mat3` {
    diffuseColour = V_ZERO,
    gloss = 0.25,
    specular = 1.0,
}

material `sphere_mat_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    gloss = 1.0,
    specular = 0.04,
}

material `sphere_mat2_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    gloss = 0.5,
    specular = 0.04,
}

material `sphere_mat3_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    gloss = 0.25,
    specular = 0.04,
}

material `old_metal` {
	diffuseMap=`textures/old_metal_diff.tga`,
	normalMap=`textures/old_metal_ddn.tga`,
	glossMap=`textures/old_metal_spec.tga`,
}

material `old_metal_no_diff` {
    diffuseColour = V_ZERO,
	normalMap=`textures/old_metal_ddn.tga`,
	glossMap=`textures/old_metal_spec.tga`,
}
