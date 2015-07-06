material `sphere_mat` {
    diffuseColour = vec(0, 0, 0),
    diffuseMask = vec(0, 0, 0),
    gloss = 1.0,
    glossMask = 1.0,
    specular = 1.0,
}

material `sphere_mat2` {
    diffuseColour = vec(0, 0, 0),
    diffuseMask = vec(0, 0, 0),
    gloss = 0.5,
    glossMask = 0.5,
    specular = 1.0,
}

material `sphere_mat3` {
    diffuseColour = vec(0, 0, 0),
    diffuseMask = vec(0, 0, 0),
    gloss = 0.25,
    glossMask = 0.25,
    specular = 1.0,
}

material `sphere_mat_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    diffuseMask = 0.5*vector3(1,1,1),
    gloss = 1.0,
    specular = 0.04,
    specularMask = 0.04,
}

material `sphere_mat2_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    diffuseMask = 0.5*vector3(1,1,1),
    gloss = 0.5,
    glossMask = 0.5,
    specular = 0.04,
    specularMask = 0.04,
}

material `sphere_mat3_d` {
    diffuseColour = 0.5*vector3(1,1,1),
    diffuseMask = 0.5*vector3(1,1,1),
    gloss = 0.25,
    glossMask = 0.25,
    specular = 0.04,
    specularMask = 0.04,
}

material `old_metal` {
	diffuseMap=`textures/old_metal_diff.tga`,
	normalMap=`textures/old_metal_ddn.tga`,
	glossMap=`textures/old_metal_spec.tga`,
    gloss = 1,
    specular = 1,
}

material `old_metal_no_diff` {
    diffuseColour = V_ZERO,
    diffuseMask = V_ZERO,
	normalMap=`textures/old_metal_ddn.tga`,
	glossMap=`textures/old_metal_spec.tga`,
    gloss = 1,
    specular = 1,
}
