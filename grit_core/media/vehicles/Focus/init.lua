local mu_front = 2.5
local mu_back = 2.0
local rad = 0.348 -- wheels

class `.` (Vehicle) {
        gfxMesh=`Body.mesh`,
        colMesh=`Body.gcol`,
        placementZOffset=0.4,
        powerPlots = {
                [-1] = { [0] = -7000; [15] = -7000; [30] = -5000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 8000; [70] = 8000; },
        },       
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

material `Body` { blendedBones=1, diffuseMap = `Body.jpg`; }

