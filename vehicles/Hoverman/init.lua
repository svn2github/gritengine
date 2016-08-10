-- hijack of JostVice's Scarman
local mass = 1400
local front_pid = {
    p = 15000;
    i = 20;
    d = 2500;
    min= -2;
    max= 2;
}

class `.` (Hover) {
        gfxMesh = `Body.mesh`;
        colMesh = `Body.gcol`;
        placementZOffset=1.4;
        
        jetsHover = {
            {pos = vec(-0.9, 1.08, -0.19), pid = front_pid}; --hovering front left
            {pos = vec(0.9, 1.08, -0.19), pid = front_pid}; --hovering font right
            {pos = vec(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vec(-0.9, -1.6, -0.19)}; --hovering rear left
        };
        jetsInfo = {
            {pos = vec(0, -2.7, 0)}; -- push/pull jet
            {pos = vec(0, -2.19, 0.057)}; -- steer jet
            {pos = vec(-0.9, 1.08, -0.19)}; --hovering front left
            {pos = vec(0.9, 1.08, -0.19)}; --hovering font right
            {pos = vec(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vec(-0.9, -1.6, -0.19)}; --hovering rear left
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
                vec(0.0, 1.881, 0.093);
        };
}

-- most materials are temporal and will probably joined
material `Carpaint` { shader = `/common/Paint`, paintSelectionMap = vec(1, 0, 0, 1), specularMask = 1, glossMask = 1, microFlakesMap = `/common/MicroFlakes.dds`, }
material `LightPlastic` { diffuseMask = vec(0.2, 0.2, 0.2), specularMask = 0.04, glossMask = .5, }
material `Chrome` { diffuseMask = V_ZERO, specularMask = 1, glossMask = 1, }
material `Pattern` { diffuseMask = vec(0.05, 0.05, 0.05), specularMask = 0.04, glossMask = .5, }
material `Blacky` { diffuseMask = V_ZERO, specularMask = 0.5, glossMask = 1, }
material `Headlight` { glossMask = .75, specularMask = 0.04, alphaMask =0.7, sceneBlend = "ALPHA" }
material `Brakelight` { diffuseMask = vec(1,0,0), glossMask = .75, specularMask = 0.04, alphaMask = 0.7, sceneBlend = "ALPHA", }
material `Turnlight` { diffuseMask = vec(1.0,0.597,0), glossMask = .75, specularMask = 0.04, alphaMask = 0.7, sceneBlend = "ALPHA" }
