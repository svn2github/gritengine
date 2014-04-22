local front_mu = 3.2
local mu = 3.5
local len = 0.096 --suspension
local rad = 0.35 -- wheel radius
local wx, wf, wb, wz = 0.90, 1.40, -1.45, 0.36 -- wheel position data, see below \ side separation, side deplacement, axe separation, height
local slack = 0.263

class `.` (Vehicle) {
        gfxMesh = `Body.mesh`,
        colMesh = `Body.gcol`,
        placementZOffset=0.4,
        powerPlots = {
                [-1] = { [0] = -6000; [10] = -6000; [25] = -4000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 7000; [100] = 7000; },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=front_mu; sport=1.1;
                  left=true; attachPos=vec(-wx,wf,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=front_mu; sport=1.1;
                  left=false; attachPos=vec(wx,wf,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu; sport = 1.3;
                  left=true; attachPos=vec(-wx,wb,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu; sport = 1.3;
                  left=false; attachPos=vec(wx,wb,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },
        },
        colourSpec = {
                { probability=1, { "arancio_orange",  },
                },
				{ probability=1, { "bianco_grey",  },
                },
				{ probability=1, { "giallo_yellow",  },
                },
				{ probability=1, { "rosso_red",  },
                },
				{ probability=1, { "ithaca_green",  },
                },
				{ probability=1, { "caelum_blue",  },
                },
				{ probability=1, { "fontus_blue",  },
                },
				{ probability=1, { "marrone_grey",  },
                },
				{ probability=1, { "metallic_black",  },
                },
				{ probability=1, { "white",  },
                },
        },
        lightHeadLeft = {
                pos=vec(-0.75, 2.2, 0.25),
        },
        lightHeadRight = {
                pos=vec( 0.75, 2.2, 0.25),
        },
        lightBrakeLeft = {
                pos=vec(-0.6, -2.1, 0.6), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightBrakeRight = {
                pos=vec( 0.6, -2.1, 0.6), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightReverseLeft = {
                pos=vec(-0.7, -2.1, 0.6), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        lightReverseRight = {
                pos=vec( 0.7, -2.1, 0.6), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        engineSmokeVents = {
                vec(0, 2.05, 0.35);
        };
        exhaustSmokeVents = {
                vec(0.62,-2.15, 0.1);
                vec(-0.62,-2.15, 0.1);
        };
}



-- most materials are temporal and will probably joined
local g, s = 1, 1
material `Body` { paintColour = 1; microFlakes=true; gloss=g ; specular = s }
material `Wheel` { diffuseMap = `glass.png`; gloss=1 }
material `backlight` { diffuseMap = `backlight.png`; }
material `Grey` { diffuseMap = `grey.png`;  }
material `BrakeCaliper` { diffuseColour ={20,0,0}; }
material `Black` { diffuseMap = `black.png`;  }
material `LightBlack` { diffuseMap = `lightblack.png`; gloss=1 ; }
material `Tyre` { diffuseMap = `tyre.png` }
material `Silver` { diffuseColour ={0.221,0.221,0.221};  }
material `Grill` { diffuseMap = `grill_grey.jpg`;  }
material `Glass` { diffuseMap = `glass.png`; alpha = true; gloss=1 ; specular = s }

