--material "rock01" {
--vertexAmbient=true,
--diffuseMap = {"grass01.png", "rock01.png"},
--}
--material "road01" { diffuseMap="road01.png" } 

material `road01` {
    diffuseMap = `road.png`,
}

material `02 - Default` {
    backfaces = true,
    diffuseMap = {
        image = `branch7.png`,
        modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP",
        filterMin = "LINEAR", filterMax = "LINEAR", filterMip = "ANISOTROPIC",
        anisotropy = 16,
    };
    alphaRejectThreshold = 0.5,
}

material `20 - Default` {
    backfaces=true,
    diffuseMap = {
        image = `branch3.dds`,
        modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP",
        filterMin = "LINEAR", filterMax = "LINEAR", filterMip = "ANISOTROPIC",
        anisotropy = 16,
    };
    alphaRejectThreshold = 0.5,
}

material `03 - Default` {
    diffuseMap=`bark.png`,
}
