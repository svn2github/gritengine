-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading sky.lua")

sky_material `Moon` {
    emissiveMap = uniform_texture { name = `starfield.dds` };
    emissiveMask = uniform_float(0.3, 0.3, 0.3);
    alphaRejectThreshold = uniform_float(0.5);
}


sky_shader `SkyBackground` {
    starfieldMask = uniform_float(1, 1, 1);
    starfieldMap = uniform_texture {
        defaultColour = vector3(0,0,0);
        defaultAlpha = 1;
    };
    vertexCode = import_str `SkyBackground.vert.gsl`;
    fragmentCode = import_str `SkyBackground.frag.gsl`;
}

sky_material `Sky` {
    starfieldMap = uniform_texture {
        --addrMode = "CLAMP"; minFilter = "LINEAR"; magFilter = "LINEAR"; mipFilter = "ANISOTROPIC"; anisotropy = 16;
        name = `starfield.dds`;
    };
    starfieldMask = uniform_float(0.2,0.2,0.2);
    shader = `SkyBackground`;
}


sky_shader `Clouds` {
    perlin = uniform_texture {
        defaultColour = vector3(0,0,0);
    };
    perlinN = uniform_texture {
        defaultColour = vector3(0.5,0.5,1);
    };
    vertexCode = import_str `SkyClouds.vert.gsl`;
    fragmentCode = import_str `SkyClouds.frag.gsl`;
}

sky_material `Clouds` {
    perlin = uniform_texture { name = `PerlinNoise.png` };
    perlinN = uniform_texture { name = `PerlinNoiseN.png` };
    sceneBlend = "ALPHA";
    shader = `Clouds`;
}
