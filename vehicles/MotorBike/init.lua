local rad = 0.3 -- wheels
local len = 0.12
local wf, wb, wz = 0.49, -0.839, -0.14 

class `.` (Bike) {
        gfxMesh=`Body.mesh`,
        colMesh=`Body.gcol`,
        placementZOffset=0.4,
        --steerMax = 25,
        --steerRate = 0.4; unsteerRate = 0.7;
        --steerFastSpeed = 60;
        --steerRateFast = 0.02; unsteerRateFast = 0.8;

        maxLean = 25;
        fallTorque = 6000;

        powerPlots = {
                [-1] = { [0] = -400; [10] = -400; [30] = -300; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0]=400; [20]=400; [40]=470, [80]=520; [100]=570 ; [110]=620; [150]=600; }
        },       
        
        bonedWheelInfo = {
                front = { steer=1; rad=rad; castRadius=0.05; mu = 1.5; mass = 1.3; dampingFactor = 0.35;
                  steerBone="steer_f", axleBone="axle_f", wheelBone="wheel_f",
                },


                rear = { drive=1; handbrake=true; rad=rad; castRadius=0.05; mu = 2.86; mass = 1.0; dampingFactor = 0.3;
                  steerBone="steer_r", axleBone="axle_r", wheelBone="wheel_r",
                },
        },
        lightHeadCenter = {
                pos=vec(0, 0.7, 0.2),
        },
        lightBrakeCenter = {
                pos=vec(0, -1.1, 0.4), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightReverseCenter = {
                pos=vec(0, -1.1, 0.35), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        engineSmokeVents = {
                vec(0.0, 0.65, 0.0);
        };
}


material `Body` { blendedBones=1, diffuseColour = {1, .8, 0} }
material `FrontWheel` { blendedBones=1, diffuseColour = 0xFF3F3F3F }
material `RearWheel` { blendedBones=1, diffuseColour = 0xFF3F3F3F }
