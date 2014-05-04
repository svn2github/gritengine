local mu = 1.2
local rad = 0.20 -- wheels
--local cy=-1.37
--local cz=-0.565
local cy=0.5
local cz=0.15

class "." (Plane) {
    gfxMesh=`chassis.mesh`,
    colMesh=`chassis.gcol`,
    placementZOffset=0.4,

    --CM Arm relative to origin. In meters. (Will be multiplied by weight to derrive torque.)
    --cmArm = vec(0, -2.0, -0.5),
    cmArm = vec(0,0,0),

    --One plot for each engine. Units: [m/s] = N (Bonanza: prop wash ~ 44m/s.)
    thrustPlots = {
        --{[0] = 5000; [30] = 2500; [100] = 0; },
        {[0] = 7000; [30] = 5000; [100] = 0; },
    },

    --Aerodynamic Surfaces. For each surface: Center of pressure, "Up" direction, glide ratio, lift curve (in N/(m/s)^2). Sin(AoA) used instead of AoA.
    surfaceInfo = { },

    --Rotors
    rotorInfo = {
        --Main Rotor.
        [1] = {
            --Positive for counter-clockwise.
            rpm = 2000;
            diameter = 9.8;
            cpr = vec(0,0,1);
            act = vec(0,0,1);
            glide = 7;
            --Lift at %Collective. Hover = 0.5
            lift = {[0] = 10000; [0.5] = 14550; [1.0] = 20000;};
            cyclicx = vec(-0.1,0.0,0.0);
            cyclicy = vec(0.0,-0.1,0.0);
            ctype = "rotor";
        };
        --Anti-torque. (Tail rotor.)
        [2] = {
            --Doesn't actually matter for anti-torque.
            rpm = 2000;
            diameter = 2;
            cpr = vec(0,7,0);
            act = vec(-1,0,0);
            glide = 7;
            --"Lift" of the rotor. Needs to counter torque produced by 2/3R of main rotor at given glide.
            lift = {[0] = 0; [0.5] = 970; [1.0] = 1940;};
            cyclicx = vec(0.0,0.0,0.0);
            cyclicy = vec(0.0,0.0,0.0);
            ctype = "torque";
        };
    },

    lightInfo = {},

    --Drag
    dragInfo = { },

}

material "Material__2"    { diffuseColour = {0.000000, 0.000000, 0.000000, 1.000000}; }
material "Material__3"    { diffuseMap = "105.JPG"; }
material "Material__4"    { diffuseColour = {0.059608, 0.062745, 0.047059, 1.000000}; }
material "Material__6"    { diffuseColour = {0.100392, 0.116078, 0.125490, 1.000000}; }
material "Material__7"    { diffuseColour = {0.116078, 0.116078, 0.116078, 1.000000}; }
material "Glass"    { diffuseColour = {0.097255, 0.112941, 0.116078, 0.210000}; }
material "DullCamo"    { diffuseColour = {0.232157, 0.250980, 0.219608, 1.000000}; }
material "GlossBlack"    { diffuseColour = {0.000000, 0.000000, 0.000000, 1.000000}; }
