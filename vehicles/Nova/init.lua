local drive_mu = 3.2
local side_mu = 1.5
local rear_mu = 1.5
local rad = 0.25 -- wheel radius
local wx, wf, wb, wz = 0.603, 1.311, -1.108, 0.0 -- wheel position data, see below
local len_f = 0.25
local len_b = 0.3

class `.` (Vehicle) {
        gfxMesh = `Body.mesh`,
        colMesh = `Body.gcol`,
        placementZOffset=0.4,
        powerPlots = {
                [-1] = { [0] = -3000; [10] = -3000; [25] = -3000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 2000; [10] = 2000; [70] = 1000 ; [100] = 3500 },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; drive=1; castRadius=0.05; rad=rad; driveMu=drive_mu; sideMu = side_mu;
                  left=true; attachPos=vec(-wx,wf,wz); len=len_f; mesh=`Wheel.mesh`;
                },

                front_right = {
                  steer=1; drive=1; castRadius=0.05; rad=rad; driveMu=drive_mu; sideMu = side_mu;
                  left=false; attachPos=vec(wx,wf,wz); len=len_f; mesh=`Wheel.mesh`;
                },

                rear_left = {
                  rad=rad; castRadius=0.05; handbrake=true; driveMu=rear_mu; sideMu = side_mu;
                  left=true; attachPos=vec(-wx,wb,wz); len=len_b; mesh=`Wheel.mesh`;
                },

                rear_right = {
                  rad=rad; castRadius=0.05; handbrake=true; driveMu=rear_mu; sideMu = side_mu;
                  left=false; attachPos=vec(wx,wb,wz); len=len_b; mesh=`Wheel.mesh`;
                },
        },
        health = 40000,
        lightHeadLeft = {
                pos=vec(-0.65, 1.8, 0.05),
        },
        lightHeadRight = {
                pos=vec( 0.65, 1.8, 0.05),
        },
        lightBrakeLeft = {
                pos=vec(-0.7, -2.0, 0.15), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightBrakeRight = {
                pos=vec( 0.7, -2.0, 0.15), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
        },
        lightReverseLeft = {
                pos=vec(-0.7, -2.0, -0.05), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        engineSmokeVents = {
                vec(0, 1.350000, 0.300000);
        };
}

material `Body` { diffuseMap = `Body.dds`; }
material `Wheel` { diffuseMap = `Tyre.dds`; }
