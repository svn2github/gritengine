-- hijack of JostVice's Scarman
local mass = 1400
local front_pid = {
    p = 15000;
    i = 20;
    d = 2500;
    min= -2;
    max= 2;
}

class "." (Hover) {
        gfxMesh = `Body.mesh`;
        colMesh = `Body.gcol`;
        placementZOffset=1.4;
        
        jetsHover = {
            {pos = vector3(-0.9, 1.08, -0.19), pid = front_pid}; --hovering front left
            {pos = vector3(0.9, 1.08, -0.19), pid = front_pid}; --hovering font right
            {pos = vector3(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vector3(-0.9, -1.6, -0.19)}; --hovering rear left
        };
        jetsInfo = {
            {pos = vector3(0, -2.7, 0)}; -- push/pull jet
            {pos = vector3(0, -2.19, 0.057)}; -- steer jet
            {pos = vector3(-0.9, 1.08, -0.19)}; --hovering front left
            {pos = vector3(0.9, 1.08, -0.19)}; --hovering font right
            {pos = vector3(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vector3(-0.9, -1.6, -0.19)}; --hovering rear left
        };
        jetsControl = {
            forwards = { V_FORWARDS*mass*10 };
            backwards = { V_BACKWARDS*mass*10 };
            steerLeft = { V_ZERO, V_RIGHT*mass*5 };
            steerRight = { V_ZERO, V_LEFT*mass*5 };
        };
        
		colourSpec = {
                { probability=1, { "velvet_red",},},
				{ probability=1, { "ice_silver",},},
				{ probability=1, { "carbon_gray",},},
				{ probability=1, { "midnight_black",},},
				{ probability=1, { "cream_white",},},
				{ probability=1, { "crystal_blue",},},
        };
        
        engineSmokeVents = {
                vector3(0.0, 1.881, 0.093);
        };
}

-- most materials are temporal and will probably joined
material "Carpaint" { paintColour = 1; specular=.04; gloss = .75; microFlakes=true; }
material "LightPlastic" { diffuseColour=vector3(0.2, 0.2, 0.2); specular=0.04; gloss = .5; }
material "Chrome" { diffuseColour =V_ZERO; specular=1; gloss = 1; }
material "Pattern" { diffuseColour=vector3(0.05, 0.05, 0.05); specular=0.04; gloss = .5; }
material "Blacky" { diffuseColour =V_ZERO; specular=0.5; gloss = 1; }
material "Headlight" { gloss = .75; specular=0.04; alpha =0.7 }
material "Brakelight" { diffuseColour=vector3(1,0,0), gloss = .75; specular=0.04; alpha =0.7 }
material "Turnlight" { diffuseColour=vector3(1.0,0.597,0), gloss = .75; specular=0.04; alpha =0.7 }
