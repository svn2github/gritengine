--
-- This is the Julietta lua. just so that jostvice knows it is the Julietta lua, because he has 900 .luas opened and he finds it slow to identify which lua it is. hello

local mu_front = 1.5
local mu_rear_side = 1.5
local mu_rear_drive = 1.5

-- Wheel, Suspension
local len = 0.1 --amount wheel can go up an down
local rad = 0.319 -- wheel radius
local wheelX, wheelY, wheelY2, wheelZ = 0.626, 0.769, -1.576, -0.15 --wheel Y and wheel Y 2 are the two axle's Y. the rest explains itself

class `.` (Vehicle) {
        gfxMesh = `Body.mesh`,
        colMesh = `Body.gcol`,
        placementZOffset=1.4,
        powerPlots = {
                [-1] = { [0] = -6000; [10] = -6000; [25] = -4000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 8000; [100] = 8000; },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.0;
                  left=true; attachPos=vec(-wheelX,wheelY,wheelZ); len=len; mesh=`Wheel.mesh`
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.0;
                  left=false; attachPos=vec(wheelX,wheelY,wheelZ); len=len; mesh=`Wheel.mesh`
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 1.0;
                  left=true; attachPos=vec(-wheelX,wheelY2,wheelZ); len=len; mesh=`Wheel.mesh`
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 1.0;
                  left=false; attachPos=vec(wheelX,wheelY2,wheelZ); len=len; mesh=`Wheel.mesh`
                },
        },

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
}


class `Wheel` (ColClass) { placementZOffset = 0.3; castShadows = true }


-- most materials are temporal and will probably joined
local g, s = 0.6, 0.04
-- when using paint, set spec and gloss to 1, they will be masked by the paint colour
material `Paint` { paintColour = 1; specular=1; gloss = 1; microFlakes=true; shadowBias=0.05 }
material `LightPlastic` { diffuseColour=vec(0.2, 0.2, 0.2); specular=0.04; gloss=0.5; }
material `Chrome` { diffuseColour=0.09*vec(1,1,1); specular=0.15; gloss = 1; }
material `Pattern` { diffuseColour=vec(0.2, 0.2, 0.2), specular=0.04, gloss=0.25 }
material `Grey` { diffuseColour=vec(0.2, 0.2, 0.2), specular=0.04, gloss=0.2 }
material `Dark Grey` { diffuseColour=vec(0.2, 0.2, 0.2), specualar=0.04, gloss=0  }
material `Headlight` { gloss = g; specular=s}
material `ReverseLight` { gloss = g; specular=s}
material `Brakelight` { diffuseColour=vec(1,0,0), gloss = g; specular=s}
material `Turnlight` { diffuseColour=vec(1.0,0.597,0), gloss=g; specular=s}
material `Window` { diffuseColour=vec(0.035, 0.035, 0.035), gloss=1; specular=0.045}

