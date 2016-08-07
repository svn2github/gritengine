-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons License BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/3.0/
---------------------------
---- MATERIALS LIBRARY ----
---------------------------

local function point_tex(name, overrides)
    overrides = overrides or {}
    local T = {
        image = name,
        filterMax = "POINT",
        filterMip = "LINEAR",
    }
    -- Vince had a problem on ATI where filterMip had to be NONE or the filterMax would not take
    -- effect.
    for k, v in pairs(overrides) do
        T[k] = v
    end
    return T
end

-- GREYBOX MATS --

material `greybox` {
    diffuseMask = vec(.4, .4, .4),
    diffuseVertex = 1,
}
material `greybox_red` {
    diffuseMask = vec(.33, 0.0, 0.0),
    diffuseVertex = 1,
}
material `greybox_blue` {
    diffuseMask = vec(0.0, .1, .33),
}
material `greybox_white` {
    diffuseMask = vec(0.8, .8, .8),
    diffuseVertex = 1,
}
material `greybox_black` {
    diffuseMask = vec(0.1, .1, .1),
    diffuseVertex = 1,
}

-- Buildings Materials -- 

material `ambient_strips` {
    diffuseMap = point_tex(`textures/ambient_strips.dds`),
    alphaMask = 0.99,
    sceneBlend = "ALPHA",
}
material `panels_a` {
    diffuseMap = point_tex(`textures/panels_a.dds`),
    glossMap = point_tex(`textures/panels_a_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `panels_b` {
    diffuseMap = point_tex(`textures/panels_b.dds`),
    glossMap = point_tex(`textures/panels_b_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `panels_c` {
    diffuseMap = point_tex(`textures/panels_c.dds`),
    glossMap = point_tex(`textures/panels_c_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `panels_d` {
    diffuseMap = point_tex(`textures/panels_d.dds`),
    glossMap = point_tex(`textures/panels_d_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `windows_a` {
    diffuseMap = point_tex(`textures/windows_a.dds`),
    glossMap = point_tex(`textures/windows_a_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `girders` {
    diffuseMap = point_tex(`textures/girders.dds`),
    glossMap = point_tex(`textures/girders_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `glassdoor` {
    diffuseMap = point_tex(`textures/glassdoor_a.dds`),
    glossMap = point_tex(`textures/glassdoor_a_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `leaks` {
    diffuseMap = point_tex(`textures/dirt_leaks.dds`),
    alphaMask = 0.4,
    sceneBlend = "ALPHA",
    diffuseVertex = 1,
}

-- Platforms Materials -- 

material `platforms` {
    additionalLighting = true,

    diffuseMap = point_tex(`textures/platforms.dds`),
    glossMap = point_tex(`textures/platforms_spec.dds`),
    glossMask = 1,
    emissiveMap = point_tex(`textures/platforms_em.dds`) ,
    emissiveMask = vec(5, 5, 5),
    diffuseVertex = 1,
}
material `platform_tiles_a` {
    diffuseMap = point_tex(`textures/platform_tiles_a.dds`),
    glossMap = point_tex(`textures/platform_tiles_a_spec.dds`) ,
    glossMask = 1,
    diffuseVertex = 1,
}
material `plaform_panels_a` {
    diffuseMap = point_tex(`textures/platform_panels_a.dds`),
    glossMap = point_tex(`textures/platform_panels_a_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}
material `platform_stairs_a` {
    diffuseMap = point_tex(`textures/platform_stairs_a.dds`),
    diffuseVertex = 1,
    glossMap = point_tex(`textures/platform_stairs_a_spec.dds`) ,
    glossMask = 1,
}
material `wood_bench` {
    diffuseMap = point_tex(`textures/wood_bench.dds`),
    diffuseVertex = 1,
}
material `energy_field` {
    backfaces = true,
    additionalLighting = true,

    emissiveMap = point_tex(`textures/energy_field.dds`),
    emissiveMask = vec(0, .5, 2),
    textureAnimation = vec(0, -.5),
    alphaRejectThreshold = 1,
    diffuseVertex = 1,
} 
material `sustainment_unit` {
    additionalLighting = true,

    diffuseMap = point_tex(`textures/sustainment_unit.dds`),
    glossMap = point_tex(`textures/sustainment_unit_spec.dds`),
    glossMask = 1,
    emissiveMap = point_tex(`textures/sustainment_unit_em.dds`),
    emissiveMask = vec(5, 5, 5),
    diffuseVertex = 1,
}
material `door_maintenance` {
    diffuseMap = point_tex(`textures/door_maintenance.dds`),
    glossMap = point_tex(`textures/door_maintenance_spec.dds`),
    glossMask = 1,
    diffuseVertex = 1,
}

-- Props Materials --

material `cardboard_a` {
    diffuseMap = point_tex(`textures/cardboard_a.dds`),
    glossMap = point_tex(`textures/cardboard_a_spec.dds`),
    glossMask = 1,
}
material `foliage_tree_a` {
    backfaces = true,
    diffuseMap = point_tex(`textures/foliage_tree_a.dds`, { modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP" }),
    glossMap = point_tex(`textures/foliage_tree_a_spec.dds`, { modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP" }),
    glossMask = 1,
    alphaRejectThreshold = 0.33,
    diffuseVertex = 1,
}
material `trunk_a` {
    diffuseMap = point_tex(`textures/trunk_a.dds`),
    diffuseVertex = 1,
}
material `dumpster` {
    diffuseMap = point_tex(`textures/dumpster.dds`),
    diffuseVertex = 1,
    glossMap = point_tex(`textures/dumpster_spec.dds`),
    glossMask = 1,
}
material `tube_station` {
    additionalLighting = true,

    diffuseMap = point_tex(`textures/tube_station.tga`),
    glossMap = point_tex(`textures/tube_station_spec.tga`),
    glossMask = 1,
    emissiveMap = point_tex(`textures/tube_station_em.tga`),
    emissiveMask = vec(5, 5, 5),
    diffuseVertex = 1,
}
material `tube` {
    diffuseMap = point_tex(`textures/tube.tga`),
    diffuseVertex = 1,
    glossMap = point_tex(`textures/tube_spec.tga`),
    glossMask = 1,
    alphaMask = 0.8,
    sceneBlend = "ALPHA",
}
