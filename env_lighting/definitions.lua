material `sphere_mat` {
    diffuseMask = vec(0, 0, 0),
    glossMask = 1.0,
    specularMask = 1.0,
}

material `sphere_mat2` {
    diffuseMask = vec(0, 0, 0),
    glossMask = 0.5,
    specularMask = 1.0,
}

material `sphere_mat3` {
    diffuseMask = vec(0, 0, 0),
    glossMask = 0.25,
    specularMask = 1.0,
}

material `sphere_mat_d` {
    diffuseMask = 0.5 * vec(1, 1, 1),
    glossMask = 1.0,
    specularMask = 0.04,
}

material `sphere_mat2_d` {
    diffuseMask = 0.5 * vec(1, 1, 1),
    glossMask = 0.5,
    specularMask = 0.04,
}

material `sphere_mat3_d` {
    diffuseMask = 0.5 * vec(1, 1, 1),
    glossMask = 0.25,
    specularMask = 0.04,
}

material `old_metal` {
	diffuseMap = `textures/old_metal_diff.tga`,
	normalMap = `textures/old_metal_ddn.tga`,
	glossMap = `textures/old_metal_spec.tga`,
    glossMask = 1,
    specularMask = 1,
}

material `old_metal_no_diff` {
    diffuseMask = vec(0, 0, 0),
	normalMap = `textures/old_metal_ddn.tga`,
	glossMap = `textures/old_metal_spec.tga`,
    glossMask = 1,
    specularMask = 1,
}
