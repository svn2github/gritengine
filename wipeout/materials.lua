material `TunnelInner` {
    diffuseMap = `TunnelInner.dds`,
}

material `TunnelOuter` {
    diffuseMap = `TunnelOuter.dds`,
}

material `TunnelCap` {
    diffuseMap = `TunnelCap.dds`,
}

material `TunnelSide` {
    diffuseMap = `TunnelSide.dds`,
}

material `FinishLine` {
    diffuseMap = `FinishLine.dds`,
}

material `TrackApexArrow` {
    diffuseMap = `TrackApexArrow.dds`,
}

material `UnderSide` {
    diffuseMap = `UnderSide.dds`,
}

material `PadBase` {
    diffuseMap = `PadBase.dds`,
    castShadows = false,
}


-- there appear to be latent problems with emissive and alpha channels here.

material `Barrier` {
    sceneBlend = "ALPHA",

    diffuseMap = `Barrier.dds`,
    emissiveMap = `Barrier.dds`,
    emissiveMask = vec(0.3, 0.3, 0.3),
    alphaRejectThreshold = 0.3,
    additionalLighting = true,
}

material `NeonRed` {
    sceneBlend = "ALPHA",
    backfaces = true,
    castShadows = false,
    additionalLighting = true,

    diffuseMap = `NeonRed.dds`,
    diffuseVertex = 1,
    alphaVertex = 1,
    alphaMask = 1,

    emissiveMap = `NeonRed.dds`,
    emissiveMask = 10 * vec(1, 1, 1),
    emissiveVertex = 1,
    emissiveAlphaVertex = 1,
}

material `NeonGreen` {
    sceneBlend = "ALPHA",
    backfaces = true,
    castShadows = false,
    additionalLighting = true,

    diffuseMap = `NeonGreen.dds`,
    diffuseVertex = 1,
    alphaVertex = 1,
    alphaMask = 1,

    emissiveMap = `NeonGreen.dds`,
    emissiveMask = 10 * vec(1, 1, 1),
    emissiveVertex = 1,
    emissiveAlphaVertex = 1,
}

material `Glass` {
    --diffuseMask = vec(10, 10, 10) * 100,
    specularMask = 0,
    sceneBlend = "ALPHA",
    diffuseMap = `Glass.dds`,
    castShadows = false,
}

sky_material `Sky` {
    emissiveMap = { image = `FunkyStarField.dds`, modeU = 'CLAMP', modeV = 'CLAMP', moveW = 'CLAMP' },
    emissiveMask = vec(4, 0.6, 1) * 2,
}

physical_material `Barrier` {
    interactionGroup = SmoothSoftGroup,
    roadTyreFriction = 0.8,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.25,
}

physical_material `Track` {
    interactionGroup = SmoothSoftGroup,
    roadTyreFriction = 0.8,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.25,
}
