local mu = 1.2
local rad = 0.20 -- wheels
--local cy=-1.37
--local cz=-0.565
local cy=-0.46
local cz=0.10

class `.` (Plane) {
    gfxMesh=`Body.mesh`,
    colMesh=`chassis.gcol`,
    placementZOffset=0.68,

    driverExitPos = vector3(-1, 1, 0);

    --CM Arm relative to origin. In meters. (Will be multiplied by weight to derrive torque.)
    --cmArm = vec(0, -2.0, -0.5),
    cmArm = vec(0,0,0),

    --One plot for each engine. Units: [m/s] = N (Bonanza: prop wash ~ 44m/s.)
    thrustPlots = {
        {[0] = 12000; [30] = 8000; [50] = 6750; [100] = 6000; },
        --{[0] = 7000; [30] = 5000; [100] = 0; },
    },
    thrustPos = {
        vec(-0.01643252, 1.697112, 0.6376899)
    },

    --Aerodynamic Surfaces. For each surface: Center of pressure, "Up" direction, glide ratio, lift curve (in N/(m/s)^2). Sin(AoA) used instead of AoA.
    surfaceInfo = {
        --Left Wing.
        [1] = {
            cpr = vec( -4, -0.3, 0.3);
            act = vec(0.2,  0.0, .98);
            glide = 7;
            --lift = {[-.3] = 0; [-.2] = -3.0; [0.3] = 6.5; [0.4] = 0;};
            lift = {[-2]=0; [-1]=0; [-.3] = 0; [-.2] = -7; [0.3] = 20; [0.4] = 0; [1]=0; [2]=0;};
            drag = {[-1] = 3.0; [0.0] = 7.0; [0.3] = 20; [1.0] = 200; [2]=200;};
            limitAoA = {-.3; .4;};
            ctype = "lwing";
        };
        --Right Wing.
        [2] = {
            cpr = vec(4, -0.3, 0.3);
            act = vec(-0.2,  0.0, .98);
            glide = 7;
            --lift = {[-.3] = 0; [-.2] = -3.0; [0.3] = 6.5; [0.4] = 0;};
            lift = {[-2]=0; [-1]=0; [-.3] = 0; [-.2] = -7; [0.3] = 20; [0.4] = 0; [1]=0; [2]=0;};
            drag = {[-1] = 3.0; [0.0] = 7.0; [0.3] = 20; [1.0] = 200; [2]=200;};
            limitAoA = {-.3; .4;};
            ctype = "rwing";
        };
        --Tail Wing.
        [3] = {
            cpr = vec( 0,  -6.0, 0.5);
            act = vec( 0,  0.0, 1.0);
            glide = 7;
            --lift = {[-.4] = 0; [-.3] = -1.0; [0.2] = 0.4; [0.3] = 0;};
            lift = {[-2]=0; [-1]=0; [-.4] = 0; [-.3] = -7.0; [0.2] = 3; [0.3] = 0; [1]=0; [2]=0;};
            drag = {[-1] = 0.1; [0.0] = 0.2; [0.3] = 3.0; [1.0] = 20; [2] = 20;};
            limitAoA = {-.4; .3;};
            ctype = "elevator";
        };
        --Tail Stabilizer.
        [4] = {
            cpr = vec( 0.0, -6.0, 0.5);
            act = vec( -1.0, 0.0, 0.0);
            glide =7;
            lift = {[-2]=0; [-1]=0; [-.35]=0; [-.25] = - 3.0; [0.25] = 3.0; [0.35] = 0; [1]=0; [2]=0;};
            drag = {[-1] = 1.0; [0.0] = 1.0; [0.25] = 3.0; [1.0] = 15.0; [2] = 15;};
            limitAoA = {-.35; .35;};
            ctype = "rudder";
        }
    },

    --Lights
    lightInfo = {
        [1] = {
            pos = vec(-4.7,-0.2,0.4);
            rad = 1.0;
            color = vec(1,0,0);
        };
        [2] = {
            pos = vec( 4.7,-0.2,0.4);
            rad = 1.0;
            color = vec(0,1,0);
        };
        [3] = {
            pos = vec( 0,-5.35,2);
            rad = 1.0;
            color = vec(1,1,1);
        };
    };

    --Rotors.
    rotorInfo = { },

    --Drag
    dragInfo = { },

    --Exactly the same structure as in vehicle class.
    bonedWheelInfo = {
                front = {
                 steer=1; rad=rad; castRadius=0.03; massShare = 0.8;
                 mu = mu;
                 aimBone="gear_strut_f", steerBone="gear_steer_f", axleBone="gear_axle_f", wheelBone="gear_wheel_f",
                },

                wing_starboard = {
                 handbrake=true; rad=rad; castRadius=0.05; mu = mu; massShare = 1.8;
                 aimBone="gear_strut_s", axleBone="gear_axle_s", wheelBone="gear_wheel_s",
                },

                wing_port = {
                 handbrake=true; rad=rad; castRadius=0.05; mu = mu; massShare = 1.8;
                 aimBone="gear_strut_p", axleBone="gear_axle_p", wheelBone="gear_wheel_p",
                },
        },

    gearDoors = { gear_door_p   = Plot{[0]=0; [1]=100},
                  gear_door_s   = Plot{[0]=0; [1]=100},
                  gear_door_f_p = Plot{[0]=0; [0.35]=120; [0.350001]=120, [1]=120},
                  gear_door_f_s = Plot{[0]=0; [0.35]=120; [0.350001]=120, [1]=120},
    },

    gearStruts = { gear_strut_p = Plot{[0]=0; [0.2]=0; [0.200001]=0; [1]=-80},
                   gear_strut_s = Plot{[0]=0; [0.2]=0; [0.200001]=0; [1]=-80},
                   gear_strut_f = Plot{[0]=0; [0.2]=0; [0.250001]=0; [1]=-110},
    },

    gearStrutsCol = { gear_strut_p = {8, vec(0,-1,0), vec(0.17, 0.0, 0.00) },
                      gear_strut_s = {9, vec(0,1,0), vec(-0.17, 0.0, 0.00) },
                      gear_strut_f = {7, vec(-1,0,0), vec(0, -0.23, 0.0) },
     },

    gearCycle = 4,

    propellors = { "prop" },
}

material `white` {
    blendedBones = 2,
    diffuseMask = vec(0,1,0),
   
}
material `anthracite` {
    blendedBones = 2,
    diffuseMask = vec(0.0980392, 0.0980392, 0.0980392),
}
material `red` {
    blendedBones = 2,
    diffuseMask = vec(.3, .0, .0)
}
material `grey` {
    blendedBones = 2,
    diffuseMask = vec(0.1, 0.1, 0.1),
}
material `tyre` {
    blendedBones = 2,
    diffuseMask = vec(0.1, 0.1, 0.1),
}
material `trans` {
    blendedBones = 2,
    backfaces = true,
    sceneBlend = "ALPHA",

    diffuseMask = vec(0.0980392, 0.0980392, 0.0980392),
    specularMask = 0.3,
    alphaMask = 0.5,
    glossMask = 0.7,
}
material `fin` {
    blendedBones = 2,
    diffuseMap = `fin.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
material `nose` {
    blendedBones = 2,
    diffuseMap = `nose.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
material `fus` {
    blendedBones = 2,
    diffuseMap = `fus.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
material `panel` {
    blendedBones = 2,
    diffuseMap = `panel.png`,
    diffuseMask = vec(.3, .3, .3),
}
material `tail` {
    blendedBones = 2,
    diffuseMap = `tail.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
material `lwin` {
    blendedBones = 2,
    diffuseMap = `lwin.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
material `rwin` {
    blendedBones = 2,
    diffuseMap = `rwin.png`,
    diffuseMask = vec(.3, .3, .3),
    glossMask = 0.7,
}
