local mu_front = 2.5
local mu_back = 2.0
local rad = 0.348 -- wheels

class `.` (Vehicle) {
        gfxMesh=`Body.mesh`,
        colMesh=`Body.gcol`,
        placementZOffset=0.4,
        engineInfo = {
            sound={`engine1.wav`, `engine2.wav`, `engine3.wav`}, 
            --sound=`EngineLoop1.wav`,
            wheelRadius=rad,
            transEff=0.7,
            torqueCurve = { 
                [1000] = 225,
                [2250] = 437,
                [4500] = 437,
                [6000] = 350,
                [7000] = 275,
            },
            gearRatios = {
                [-1] = -4.84, -- reverse
                [0] = 0, -- neutral
                [1] = 3.46,
                [2] = 2.08,
                [3] = 1.40,
                [4] = 1.05,
                [5] = 0.605,
            },
            finalDrive=5,
            shiftDownRpm=2000,
            shiftUpRpm=5000,
        },
        drag = 0.31 * vec(6,2,8);
        bonedWheelInfo = {
                { steer=1; drive=1; rad=rad; castRadius=0.1; mu = mu_front;
                  steerBone="steer_f_l", axleBone="axle_f_l", wheelBone="wheel_f_l",
                },

                { steer=1; drive=1; rad=rad; castRadius=0.1; mu = mu_front;
                  steerBone="steer_f_r", axleBone="axle_f_r", wheelBone="wheel_f_r",
                },

                { rad=rad; castRadius=0.1; mu = mu_back; handbrake=true;
                  aimBone="steer_r_l", axleBone="axle_r_l", wheelBone="wheel_r_l",
                },

                { rad=rad; castRadius=0.1; mu = mu_back; handbrake=true;
                  aimBone="steer_r_r", axleBone="axle_r_r", wheelBone="wheel_r_r",
                },
        },
        lightHeadLeft = {
                pos=vec(-0.75, 1.6, 0.25), 
        },
        lightHeadRight = {
                pos=vec( 0.75, 1.6, 0.25), 
        },
        lightBrakeLeft = {
                pos=vec(-0.65, -2.0, 0.9), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightBrakeRight = {
                pos=vec( 0.65, -2.0, 0.9), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightReverseRight = {
                pos=vec( 0.7, -2.5, -0.1), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        engineSmokeVents = {
                vec(-0.55, 1.2, 0.45);
                vec( 0.55, 1.2, 0.45);
        };
        exhaustSmokeVents = {
                vec(0.60, -2.56, -0.15);
        };
}

material `Body` { blendedBones=1, diffuseMap = `Body.jpg`; glossMask=0.65;specularMask=0.1 }

