--
-- This is the Scarman lua. just so that jostvice knows it is the scarman lua, because he has 900 .luas opened and he finds it slow to identify which lua it is. hello
--
--

local mu = 1.2

-- Wheel, Suspension
local len = 0.1 --amount wheel can go up an down
local rad = 0.354 -- wheel radius
local wheelX, wheelY, wheelY2, wheelZ = 0.731, 1.063, -1.611, -0.217 --wheel Y and wheel Y 2 are the two axle's Y. the rest explains itself

--Lights
local hlightX, hlightY, hlightZ = -0.575, 1.702, 0.149 -- Headlight Pos
local hlight2X, hlight2Y, hlight2Z = -0.695, 1.571, 0.174 -- Headlight 2 Pos

local blightX, blightY, blightZ = -0.592, -2.554, 0.373 -- Brakelight Pos
local blight2X, blight2Y, blight2Z = -0.691, -2.554, 0.373 -- Brakelight 2 Pos

local rlightX, rlightY, rlightZ = -0.593, -2.534, 0.215 -- Reverselight Pos

--Smoke
local exhaustX, exhaustY, exhaustZ = -0.462, -2.592, -0.21 -- Exhaust smoke Pos
local engineX, engineY, engineZ = 0.0, 1.767, 0.093 -- Engine Smoke Pos


local slack = 0.0 -- dunno

class `.` (Vehicle) {
    camAttachPos = vec(0, 0, 0.2),
    gfxMesh = `Body.mesh`,
    colMesh = `Body.gcol`,
    placementZOffset=0.62,
    engineInfo = {
        sound={
            [1] = `engine1.wav`,
            [2] = `engine2.wav`,
            [3] = `engine3.wav`
        },
        wheelRadius=rad,
        transEff=0.8,
        torqueCurve = {
            [1000] = 100,
            [2000] = 150,
            [3000] = 167,
            [4000] = 167,
            [5000] = 130,
            [6000] = 80,
        },
        gearRatios = {
            [-1] = -3.54, -- reverse
            [0] = 0, -- neutral
            [1] = 3.82,
            [2] = 2.16,
            [3] = 1.47,
            [4] = 1.07,
            [5] = 0.87,
            [6] = 0.74,
        },
        finalDrive=3.94,
        shiftDownRpm=2800,
        shiftUpRpm=5400,
    },
    meshWheelInfo = {
        front_left = {
            steer=1; drive=1; castRadius=0.05; rad=rad; mu=mu; massShare = 1.2;
            left=true; attachPos=vec(-wheelX,wheelY,wheelZ); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
        },

        front_right = {
            steer=1; drive=1; castRadius=0.05; rad=rad; mu=mu; massShare = 1.2;
            left=false; attachPos=vec(wheelX,wheelY,wheelZ); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
        },

        rear_left = {
            rad=rad; castRadius=0.05; handbrake=true; mu=mu; massShare = 0.8;
            left=true; attachPos=vec(-wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
        },

        rear_right = {
            rad=rad; castRadius=0.05; handbrake=true; mu=mu; sport = 1.1; massShare = 0.8;
            left=false; attachPos=vec(wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
        },
    },
    steerMax = 45;
    steerMaxFast = 25;
    steerRate = 200;
    steerRateFast = 30;
    unsteerRate = 400;
    unsteerRateFast = 400;

    driverExitPos = vector3(-1.45, -0.24, 0.49);

    -- Lights - Headlight
    lightHeadLeft = {
        pos=vec(hlightX, hlightY, hlightZ),
        pos=vec(hlight2X, hlight2Y, hlight2Z),
    };
    lightHeadRight = {
        pos=vec(-hlightX, hlightY, hlightZ),
        pos=vec(-hlight2X, hlight2Y, hlight2Z),
    };

    --Brake lights
    lightBrakeLeft = {
        pos=vec(blightX, blightY, blightZ), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        pos=vec(blight2X, blight2Y, blight2Z), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
    };
    lightBrakeRight = {
        pos=vec(-blightX, blightY, blightZ), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        pos=vec(-blight2X, blight2Y, blight2Z), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
    };

    lightReverseLeft = {
        pos=vec(rlightX, rlightY, rlightZ), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
    };
    lightReverseRight = {
        pos=vec(-rlightX, rlightY, rlightZ), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
    };
    -- Colors
    colourSpec = {
        { probability=1, { "ice_silver"  } },
        { probability=1, { "velvet_red"  } },
        { probability=1, { "carbon_gray"  } },
        { probability=1, { "midnight_black"  } },
        { probability=1, { "cream_white"  } },
        { probability=1, { "crystal_blue"  } },
    },
    engineSmokeVents = {
        vec(engineX, engineY, engineZ);
    };
    exhaustSmokeVents = {
        vec(exhaustX, exhaustY, exhaustZ);
        vec(-exhaustX, exhaustY, exhaustZ);
    };
}


class `Wheel` (ColClass) { placementZOffset = 0.3; castShadows = true }


-- most materials are temporal and will probably joined
local g, s = 0.6, 0.04
-- when using paint, set spec and gloss to 1, they will be masked by the paint colour
material `Carpaint` {
    shader = `/common/Paint`,
    microFlakesMap = `/common/MicroFlakes.dds`,
    paintSelectionMask = vec(1, 0, 0, 0),
    specularMask = 1,
    glossMask = 1,
    shadowBias = 0.05,
}
material `LightPlastic` {
    diffuseMask = vec(0.2, 0.2, 0.2),
    specularMask = 0.04,
    glossMask = 0.5,
}
material `Chrome` {
    diffuseMask = 0.09 * vec(1, 1, 1),
    specularMask = 0.15,
    glossMask = 1,
}
material `Pattern` {
    diffuseMask = vec(0.1, 0.1, 0.1),
    specularMask = 0.04,
    glossMask = 0.25,
}
material `Interior` {
    diffuseMask = vec(0.1, 0.1, 0.1),
    specularMask = 0.04,
    glossMask = 0.2,
}
material `Rubber` {
    diffuseMask = vec(0.05, 0.05, 0.05),
    specularMask = 0.04,
}
material `Headlight` {
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Brakelight` {
    diffuseMask = vec(1,0,0),
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Turnlight` {
    diffuseMask = vec(1.0,0.597,0),
    glossMask = g,
    specularMask = s,
    alphaMask = 0.7,
    sceneBlend = "ALPHA",
}
material `Windows` {
    diffuseMask = vec(0.035, 0.035, 0.035),
    glossMask = 1,
    specularMask = 0.045,
    alphaMask = 0.8,
    sceneBlend = "ALPHA",
}
