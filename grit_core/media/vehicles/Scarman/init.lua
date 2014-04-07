--
-- This is the Scarman lua. just so that jostvice knows it is the scarman lua, because he has 900 .luas opened and he finds it slow to identify which lua it is. hello
--
--

local mu_front = 1.32
local mu_rear_side = 1.6
local mu_rear_drive = 1.6

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

class "../Scarman" (Vehicle) {
        gfxMesh = r"Body.mesh",
        colMesh = r"Body.gcol",
        placementZOffset=1.4,
        powerPlots = {
                [-1] = { [0] = -6000; [10] = -6000; [25] = -4000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 7000; [100] = 7000; },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.2;
                  left=true; attachPos=vector3(-wheelX,wheelY,wheelZ); len=len; slack=slack; mesh=r"Wheel.mesh"; brakeMesh=r"BrakePad.mesh"
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.2;
                  left=false; attachPos=vector3(wheelX,wheelY,wheelZ); len=len; slack=slack; mesh=r"Wheel.mesh"; brakeMesh=r"BrakePad.mesh"
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.8;
                  left=true; attachPos=vector3(-wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh=r"Wheel.mesh"; brakeMesh=r"BrakePad.mesh"
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.8;
                  left=false; attachPos=vector3(wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh=r"Wheel.mesh"; brakeMesh=r"BrakePad.mesh"
                },
        },
		-- Lights - Headlight
		lightHeadLeft = {
                pos=vector3(hlightX, hlightY, hlightZ), coronaPos=vector3(hlightX, hlightY, hlightZ),
				pos=vector3(hlight2X, hlight2Y, hlight2Z), coronaPos=vector3(hlight2X, hlight2Y, hlight2Z),
        };
        lightHeadRight = {
                pos=vector3(-hlightX, hlightY, hlightZ), coronaPos=vector3(-hlightX, hlightY, hlightZ),
				pos=vector3(-hlight2X, hlight2Y, hlight2Z), coronaPos=vector3(-hlight2X, hlight2Y, hlight2Z)
        };
		--lightHeadLeft = {
        --        pos=vector3(hlight2X, hlight2Y, hlight2Z), coronaPos=vector3(hlight2X, hlight2Y, hlight2Z),
        --};
        --lightHeadRight = {
        --        pos=vector3(-hlight2X, hlight2Y, hlight2Z), coronaPos=vector3(-hlight2X, hlight2Y, hlight2Z),
        --};
		
		--Brake lights
        lightBrakeLeft = {
                pos=vector3(blightX, blightY, blightZ), coronaPos=vector3(blightX, blightY, blightZ), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
				pos=vector3(blight2X, blight2Y, blight2Z), coronaPos=vector3(blight2X, blight2Y, blight2Z), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        };
        lightBrakeRight = {
                pos=vector3(-blightX, blightY, blightZ), coronaPos=vector3(-blightX, blightY, blightZ), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
				pos=vector3(-blight2X, blight2Y, blight2Z), coronaPos=vector3(-blight2X, blight2Y, blight2Z), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        };
		--lightBrakeLeft = {
        --        pos=vector3(blight2X, blight2Y, blight2Z), coronaPos=vector3(blight2X, blight2Y, blight2Z), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        --};
        --lightBrakeRight = {
        --        pos=vector3(-blight2X, blight2Y, blight2Z), coronaPos=vector3(-blight2X, blight2Y, blight2Z), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        --};
		
        lightReverseLeft = {
                pos=vector3(rlightX, rlightY, rlightZ), coronaPos=vector3(rlightX, rlightY, rlightZ), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
        lightReverseRight = {
                pos=vector3(-rlightX, rlightY, rlightZ), coronaPos=vector3(-rlightX, rlightY, rlightZ), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
		-- Colors
		colourSpec = {
				{ probability=1, { "ice_silver",  },
                },
                { probability=1, { "velvet_red",  },
                },
				{ probability=1, { "carbon_gray",  },
                },
				{ probability=1, { "midnight_black",  },
                },
				{ probability=1, { "cream_white",  },
                },
				{ probability=1, { "crystal_blue",  },
                },
        },
        engineSmokeVents = {
                vector3(engineX, engineY, engineZ);
        };
        exhaustSmokeVents = {
                vector3(exhaustX, exhaustY, exhaustZ);
                vector3(-exhaustX, exhaustY, exhaustZ);
        };
}


class "Wheel" (ColClass) { placementZOffset = 0.3; castShadows = true }


-- most materials are temporal and will probably joined
local g, s = 0.6, 0.04
-- when using paint, set spec and gloss to 1, they will be masked by the paint colour
material "Carpaint" { paintColour = 1; specular=1; gloss = 1; microFlakes=true; shadowBias=0.05 }
material "LightPlastic" { diffuseColour=vector3(0.2, 0.2, 0.2); specular=0.04; gloss=0.5; }
material "Chrome" { diffuseColour=0.09*vector3(1,1,1); specular=0.15; gloss = 1; }
material "Pattern" { diffuseColour=vector3(0.2, 0.2, 0.2), specular=0.04, gloss=0.25 }
material "Interior" { diffuseColour=vector3(0.2, 0.2, 0.2), specular=0.04, gloss=0.2 }
material "Rubber" { diffuseColour=vector3(0.2, 0.2, 0.2), specualar=0.04, gloss=0  }
material "Headlight" { gloss = g; specular=s; alpha=0.7 }
material "Brakelight" { diffuseColour=vector3(1,0,0), gloss = g; specular=s; alpha=0.7 }
material "Turnlight" { diffuseColour=vector3(1.0,0.597,0), gloss=g; specular=s; alpha =0.7 }
material "Windows" { diffuseColour=vector3(0.035, 0.035, 0.035), gloss=1; specular=0.045; alpha =0.8 }

