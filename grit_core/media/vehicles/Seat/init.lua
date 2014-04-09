local mu_front = 2.8
local mu_rear_side = 3.1
local mu_rear_drive = 3.1
local rad = 0.348 -- wheels

class "." (Vehicle) {
        gfxMesh=`Body.mesh`,
        colMesh=`Body.gcol`,
        placementZOffset=0.4,
        powerPlots = {
                [-1] = { [0] = -5000; [10] = -5000; [30] = -5000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0]=5000; [20]=5000; },
        },       
        bonedWheelInfo = {
                { steer=1; rad=rad; castRadius=0.1, mu = mu_front; sport = 1.1; optimalTurnAngle = 10;
                  steerBone="steer_f_l", axleBone="axle_f_l", wheelBone="wheel_f_l",
                },

                { steer=1; rad=rad; castRadius=0.1, mu = mu_front; sport = 1.1; optimalTurnAngle = 10;
                  steerBone="steer_f_r", axleBone="axle_f_r", wheelBone="wheel_f_r",
                },

                { drive=1; rad=rad; castRadius=0.1, handbrake=true;  driveMu = mu_rear_drive; sideMu = mu_rear_side; sport=1.1; optimalTurnAngle = 10;
                  aimBone="steer_r_l", axleBone="axle_r_l", wheelBone="wheel_r_l",
                },
                
                { drive=1; rad=rad; castRadius=0.1, handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport=1.1; optimalTurnAngle = 10;
                  aimBone="steer_r_r", axleBone="axle_r_r", wheelBone="wheel_r_r",
                },
        },
        colourSpec = {
                { probability=.5,
                  { "*COLOURLESS", },
                  { "*METALLICS" },
                  { "*COLOURLESS", },
                },
                { probability=.5,
                  { "*COLOURLESS", },
                  { "*COLOURLESS", },
                  { "*METALLICS" },
                },
                { probability=.5,
                  { "*DARKEST_METALLICS", "*DARK_METALLICS" },
                  { "*COLOURLESS", },
                  { "*COLOURLESS", },
                },
                { probability=1,
                  { "dark_metallic_red", "darkest_metallic_red", "dark_metallic_orange", "darkest_metallic_orange", "metallic_black", },
                  { "*RED_METALLICS", "*ORANGE_METALLICS", "*COLOURLESS", },
                  { "*RED_METALLICS", "*ORANGE_METALLICS", "*COLOURLESS", },
                },
                { probability=1,
                  { "dark_metallic_blue", "darkest_metallic_blue", "dark_metallic_cyan", "darkest_metallic_cyan", "metallic_black", },
                  { "*BLUE_METALLICS", "*CYAN_METALLICS", "*COLOURLESS", },
                  { "*BLUE_METALLICS", "*CYAN_METALLICS", "*COLOURLESS", },
                },
                { probability=1,
                  { "*GREEN_METALLICS", "*YELLOW_METALLICS", "*COLOURLESS", },
                  { "*GREEN_METALLICS", "*YELLOW_METALLICS", "*COLOURLESS", },
                  { "*GREEN_METALLICS", "*YELLOW_METALLICS", "*COLOURLESS", },
                },
        },
        lightHeadLeft = {
                pos=vector3(-0.65, 1.8, 0.2), coronaPos=vector3(-0.65, 1.8, 0.2),
        },
        lightHeadRight = {
                pos=vector3( 0.65, 1.8, 0.2), coronaPos=vector3( 0.65, 1.8, 0.2),
        },
        lightBrakeLeft = {
                pos=vector3(-0.63, -2.3, 0.45), coronaPos=vector3(-0.63, -2.25, 0.45), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        },
        lightBrakeRight = {
                pos=vector3( 0.63, -2.3, 0.45), coronaPos=vector3( 0.63, -2.25, 0.45), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        },
        lightReverseLeft = {
                pos=vector3(-0.53, -2.1, 0.53), coronaPos=vector3(-0.53, -2.1, 0.53), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        lightReverseRight = {
                pos=vector3( 0.53, -2.1, 0.53), coronaPos=vector3( 0.53, -2.1, 0.53), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        },
        engineSmokeVents = {
                vector3(-0.25, 1.95, 0.2);
                vector3( 0.25, 1.95, 0.2);
        };
        exhaustSmokeVents = {
                vector3(-0.45, -2.3, -0.14);
        };
}

material "Body" { blendedBones=1, diffuseMap = "Body.dds", paintByDiffuseAlpha = true, paintColour="Body_c.dds", microFlakes = true }

