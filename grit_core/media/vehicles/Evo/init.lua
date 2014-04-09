local drive_mu = 2.30
local side_mu = 2.31

local rad = 0.348 -- wheels
local max_restitution = 30000

local drive_front = 1
local drive_rear = 2

drive_front, drive_rear = drive_front/(0.5*drive_front+0.5*drive_rear), drive_rear/(0.5*drive_front+0.5*drive_rear)

class "." (Vehicle) {
        gfxMesh=`Body.mesh`,
        colMesh=`Body.gcol`,
        placementZOffset=0.4,
        powerPlots = {
                [-1] = { [0] = -4000; [10] = -4000; [50] = 0; [50.0001] = 0; };
                [0] = {}, --neutral
              --[1] = { [0] = 1500; [10] = 1500; [20] = 3000; [40] = 4500; [80] = 6000; [100] = 9000 ; [120] = 10500; [150] = 0; [150.001] = 0; },
                [1] = { [0] = 4000; [100] = 5000 }
        },       
        brakePlot = { [-10] = 400; [0] = 400; [10] = 5000; [20] = 5000; [40] = 5000; };
        bonedWheelInfo = {
                front_left = { drive=drive_front; steer=1; rad=rad; castRadius=0.1; --maxRestitution=max_restitution;
                  driveMu = drive_mu;  sideMu = drive_mu; optimalTurnAngle = 10; sport = 1.2;-- tractionControl = 4000;
                  steerBone="steer_f_l", axleBone="axle_f_l", wheelBone="wheel_f_l",
                },
                front_right = { drive=drive_front; steer=1; rad=rad; castRadius=0.1; --maxRestitution=max_restitution;
                  driveMu = drive_mu;  sideMu = drive_mu; optimalTurnAngle = 10; sport = 1.2;-- tractionControl = 4000;
                  steerBone="steer_f_r", axleBone="axle_f_r", wheelBone="wheel_f_r",
                },
                rear_left = { drive=drive_rear; handbrake=true; rad=rad; castRadius=0.1; --maxRestitution=max_restitution;
                  driveMu = drive_mu; sideMu = side_mu; optimalTurnAngle = 10; sport = 1.2;-- tractionControl = 4000;
                  aimBone="steer_r_l", axleBone="axle_r_l", wheelBone="wheel_r_l",
                },
                rear_right = { drive=drive_rear; handbrake=true; rad=rad; castRadius=0.1; --maxRestitution=max_restitution;
                  driveMu = drive_mu;  sideMu = side_mu; optimalTurnAngle = 10; sport = 1.2;-- tractionControl = 4000;
                  aimBone="steer_r_r", axleBone="axle_r_r", wheelBone="wheel_r_r",
                },
        },
        colourSpec = {
                { probability=1, { "*DARKEST_METALLICS", "*DARK_METALLICS", "*MIDRANGE_METALLICS" },
                                 { "white", },
                                 { "white", "dark_grey", "gold" },
                },
                { probability=1, { "*BRIGHTEST_METALLICS", "*BRIGHT_METALLICS", "*MIDRANGE_METALLICS" },
                                 { "black", },
                                 { "white", "dark_grey", "gold" },
                },
                { probability=1, { "metallic_black", "metallic_silver" },
                                 { "*BRIGHTEST_METALLICS", "*BRIGHT_METALLICS" },
                                 { "white", "dark_grey", "gold" }
                },
        },
        lightHeadLeft = {
                pos=vector3(-0.7, 2.2, 0.25), coronaPos=vector3(-0.7, 2.2, 0.25),
                materials = {
                        { mesh=`LightHeadLeft`, on=`LightOn`, off=`LightOff` };
                        { mesh=`LightHeadLeftGlass`, on=`LightOnGlass`, off=`LightOffGlass` };
                }
        };
        lightHeadRight = {
                pos=vector3( 0.7, 2.2, 0.25), coronaPos=vector3( 0.7, 2.2, 0.25),
                materials = {
                        { mesh=`LightHeadRight`, on=`LightOn`, off=`LightOff` };
                        { mesh=`LightHeadRightGlass`, on=`LightOnGlass`, off=`LightOffGlass` };
                }
        };
        lightBrakeLeft = {
                pos=vector3(-0.6, -2.0, 0.25), coronaPos=vector3(-0.6, -2.0, 0.25), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=`LightBrakeLeft`, on=`LightBrakeOn`, dim=`LightBrakeDim`, off=`LightOff` };
                }
        };
        lightBrakeRight = {
                pos=vector3( 0.6, -2.0, 0.25), coronaPos=vector3( 0.6, -2.0, 0.25), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=`LightBrakeRight`, on=`LightBrakeOn`, dim=`LightBrakeDim`, off=`LightOff` };
                }
        };
        lightReverseLeft = {
                pos=vector3(-0.7, -2.0, 0.25), coronaPos=vector3(-0.7, -2.0, 0.25), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
                materials = {
                        { mesh=`LightReverse`, on=`LightOn`, off=`LightOff` };
                }
        };
        lightReverseRight = {
                pos=vector3( 0.7, -2.0, 0.25), coronaPos=vector3( 0.7, -2.0, 0.25), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
                materials = {
                        { mesh=`LightReverse`, on=`LightOn`, off=`LightOff` };
                }
        };
        engineSmokeVents = {
                vector3(-0.25, 1.95, 0.4);
                vector3( 0.25, 1.95, 0.4);
        };
        exhaustSmokeVents = {
                vector3(0.56, -2.05, -0.22);
        };
}

material "Body" { blendedBones=1, diffuseMap = "Body.dds"; paintByDiffuseAlpha = true; paintColour = "Body_c.dds"; microFlakes=true }
material "LightBrakeOn" { blendedBones=1, emissiveMap = "Body.dds"; emissiveColour={20,0,0}; diffuseMap = "Body.dds"  }
material "LightBrakeDim" { blendedBones=1, emissiveMap = "Body.dds"; emissiveColour={3,0,0}; diffuseMap = "Body.dds"  }
material "LightOn" { blendedBones=1, emissiveMap = "Body.dds"; emissiveColour={8,8,8}; diffuseMap = "Body.dds"  }
material "LightOff" { blendedBones=1, diffuseMap = "Body.dds"  }
material "LightOnGlass" { blendedBones=1, emissiveColour={0.3,0.3,0.3}; diffuseMap = "Body.dds"; alpha = 0;  }
material "LightOffGlass" { blendedBones=1, diffuseMap = "Body.dds"; alpha = true;  }

--[[

http://www.ehow.com/list_7411770_specifications-lancer-evo-9.html

Wheelbase:             2.650
Length:                4.495
Width:                 1.810
Height:                1.480
Track, Front:          1.545
Track, Rear:           1.545
Min. Ground Clearance: 1.40

http://www.mitsubishicars.com/MMNA/jsp/evo/11/specs.do?loc=en-us#engineering

The Lancer Evo IX's 3,262 lb.-curb weight sits on a 103.3-inch wheelbase with a 59.6-inch track. This performance sedan's body is 178.5 inches long, 69.7 inches wide and 57.1 inches in height. The vehicle's undercarriage affords it 5.5 inches of ground clearance and a 38.7-foot turning diameter. The cabin of the Lancer Evo IX offers 95.1-cubic feet of passenger volume, while it's trunk provides 10.2-cubic feet of cargo volume.

in metres:

wheelbase: 2.624
track: 1.514
length: 4.534
width: 1.770
height: 1.450
ground clearance: 0.140
turning diameter: 11.8

]]

