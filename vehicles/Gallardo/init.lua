local mu = 3.5
local len = 0.096 --suspension
local rad = 0.35 -- wheel radius
local wx, wf, wb, wz = 0.90, 1.40, -1.45, 0.36 -- wheel position data, see below \ side separation, side deplacement, axe separation, height
local slack = 0.263

class `.` (Vehicle) {
        gfxMesh = `Body.mesh`,
        colMesh = `Body.gcol`,
        placementZOffset=0.30,
        engineInfo = {
            sound= {
                [1] = `engine1.wav`,
                [2] = `engine2.wav`,
                [3] = `engine3.wav`
            },
            wheelRadius=rad,
            transEff=0.8,
            torqueCurve = {
                [1000] = 205,
                [2000] = 358,
                [4000] = 409,
                [5000] = 460,
                [7000] = 358,
                [8000] = 207,
            },
            gearRatios = {
                [-1] = -4.84, -- reverse
                [0] = 0, -- neutral
                [1] = 2.56,
                [2] = 1.85,
                [3] = 1.42,
                [4] = 1.114,
                [5] = 0.94,
                [6] = 0.81,
            },
            finalDrive=3.42,
            idleRpm=1000,
            shiftDownRpm=4800,
            shiftUpRpm=7100,
            maxRpm=8500,
            drag=1e-06,
            wheelDrag=2e-06,
        },
        drag = 0.4 * vec(3, 1, 8),
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu;
                  left=true; attachPos=vec(-wx,wf,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu;
                  left=false; attachPos=vec(wx,wf,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu;
                  left=true; attachPos=vec(-wx,wb,wz); len=len; slack=slack; mesh=`Wheel.mesh`; brakeMesh=`BrakePad.mesh`
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu;
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
material `Body` { shader = `/common/Paint`, microFlakesMap = `/common/MicroFlakes.dds`, paintSelectionMap = vec(1, 0, 0, 1), glossMask = 1, specularMask = 1 }
material `Wheel` { diffuseMap = `glass.png`, glossMask = 1 }
material `backlight` { diffuseMap = `backlight.png`, }
material `Grey` { diffuseMap = `grey.png`, }
material `BrakeCaliper` { diffuseMask = srgb(20,0,0), }
material `Black` { diffuseMap = `black.png`,  }
material `LightBlack` { diffuseMap = `lightblack.png`, glossMask = 1, }
material `Tyre` { diffuseMap = `tyre.png` }
material `Silver` { diffuseMask = vec(0.221,0.221,0.221),  }
material `Grill` { diffuseMap = `grill_grey.jpg`,  }
material `Glass` { diffuseMap = `glass.png`, sceneBlend = "ALPHA", glossMask = 1, specularMask = 1 }

