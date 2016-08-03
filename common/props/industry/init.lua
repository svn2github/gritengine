-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material `BoringBarrel` { diffuseMap=`BoringBarrel.dds`, diffuseColour=V_ID*2.5, paintColour=1, gloss = 0.5, specular=0.05, paintByDiffuseAlpha=true, specularMap=`BoringBarrel_s.dds`, normalMap=`BoringBarrel_n.png`, shadowBias=0.1 }

class `BoringBarrel` (ColClass) {
    renderingDistance=60;
    castShadows=true;
    placementZOffset=0.4255;
    placementRandomRotation=true;

    colourSpec = {
        { {
                { {.38,.37,0}, 0, {.38,.37,.0} },
                { {2/255,4/255,13/255}, 0, {2/255,4/255,13/255} },
                { {18/255,2/255,1/255}, 0, {18/255,2/255,1/255} },
                { {0.01,0.01,0.01}, 0, 1 }
        } }
    }
}

material `RedBarrel` { diffuseMap=`OilBarrel.dds`, diffuseColour=V_ID*2.5, gloss = 0.5, specular=0.05, specularMap=`OilBarrel_s.dds`, normalMap=`OilBarrel_n.png`, shadowBias=0.1 }

class `OilBarrel` (ColClass) {
    renderingDistance=60;
    castShadows=true;
    placementZOffset=0.4255;
    placementRandomRotation=true;

    health = 1000;
    impulseDamageThreshold = 200;
    explodeInfo = { radius=10; deactivate=true; }

}

