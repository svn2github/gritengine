-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading sky.lua")

sky_material `Moon` {
    emissiveMap = `starfield.dds`,
    emissiveMask = vec(0.3, 0.3, 0.3),
    alphaRejectThreshold = 0.5,
}


shader `SkyBackground` {
    starfieldMask = uniform_float(1, 1, 1),
    starfieldMap = uniform_texture {
        defaultColour = vec(0, 0, 0),
        defaultAlpha = 1,
    };
    vertexCode = import_str `SkyBackground.vert.gsl`,
    colourCode = import_str `SkyBackground.colour.gsl`,
}

sky_material `Sky` {
    starfieldMap = {
        image = `starfield.dds`;
        modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP",
        filterMin = "LINEAR", filterMax = "LINEAR", filterMip = "ANISOTROPIC",
        anisotropy = 16,
    };
    starfieldMask = vec(0.2, 0.2, 0.2);
    shader = `SkyBackground`;
}


shader `Clouds` {
    perlin = uniform_texture {
        defaultColour = vector3(0, 0, 0);
    };
    perlinN = uniform_texture {
        defaultColour = vector3(0.5, 0.5, 1);
    };
    vertexCode = import_str `SkyClouds.vert.gsl`;
    colourCode = import_str `SkyClouds.colour.gsl`;
}

sky_material `Clouds` {
    shader = `Clouds`,
    sceneBlend = "ALPHA",

    perlin = `PerlinNoise.png`,
    perlinN = `PerlinNoiseN.png`,
}
