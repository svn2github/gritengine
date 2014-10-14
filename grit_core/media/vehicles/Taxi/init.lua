-- http://www.edmunds.com/ford/crown-victoria/2011/features-specs.html

-- length: 5.38
-- width: 1.96
-- height: 1.44
-- wheel base: 2.91
-- track: 1.67
-- weight distribution is allegedly 55:45 or there about...

local mu = 1.2

-- Wheel, Suspension
local len = 0.14 --amount wheel can go up an down
local rad = 0.3654 -- wheel radius
local wheelX, wheelY, wheelY2, wheelZ = 0.776, 1.38, -1.56, -0.156 --wheel Y and wheel Y 2 are the two axle's Y. the rest explains itself

--Lights
local hlightX, hlightY, hlightZ = 0.629, 2.005, 0.142 -- Headlight
local blightX, blightY, blightZ = 0.782, -2.70, 0.322 -- Brakelight
local rlightX, rlightY, rlightZ = 0.782, -2.70, 0.214 -- Reverse light

class `.` (Vehicle) {
        gfxMesh = `Body.mesh`,
        colMesh = `Body.gcol`,
        placementZOffset=1.4,
        engineInfo = {
            sound={
                [1] = `engine1.wav`,
                [2] = `engine2.wav`,
                [3] = `engine3.wav`
            },
            wheelRadius=rad,
            transEff=0.8,
            torqueCurve = {
                [1000] = 250,
                [2000] = 300,
                [3000] = 350,
                [4000] = 380,
                [5000] = 350,
                [6000] = 200,
            },
            gearRatios = {
                [-1] = -2.32, -- reverse
                [0] = 0, -- neutral
                [1] = 2.84,
                [2] = 1.55,
                [3] = 1,
                [4] = 0.7,
            },
            finalDrive=2.73,
            shiftDownRPM=2800,
            shiftUpRPM=5400,
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu; massShare = 1.1;
                  left=true; attachPos=vec(-wheelX,wheelY,wheelZ); len=len; mesh=`Wheel.mesh`;
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu; massShare = 1.1;
                  left=false; attachPos=vec(wheelX,wheelY,wheelZ); len=len; mesh=`Wheel.mesh`;
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu; massShare = 0.9;
                  left=true; attachPos=vec(-wheelX,wheelY2,wheelZ); len=len; mesh=`Wheel.mesh`;
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; mu=mu; massShare = 0.9;
                  left=false; attachPos=vec(wheelX,wheelY2,wheelZ); len=len; mesh=`Wheel.mesh`;
                },
        },
        -- Lights - Headlight
        lightHeadLeft = {
                pos=vec(-hlightX, hlightY, hlightZ), coronaPos=vec(0, 0.2, 0),
                materials = {
                        { mesh=`LightHeadLeft`, on=`LightOn`, off=`Atlas` };
                };

        };
        lightHeadRight = {
                pos=vec(hlightX, hlightY, hlightZ), coronaPos=vec(0, 0.2, 0),
                materials = {
                        { mesh=`LightHeadRight`, on=`LightOn`, off=`Atlas` };
                };
        };
        
        --Brake lights
        lightBrakeLeft = {
                pos=vec(blightX, blightY, blightZ), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=`LightBrakeLeft`, on=`LightBrakeOn`, dim=`LightBrakeDim`, off=`Atlas` };
                };
        };
        lightBrakeRight = {
                pos=vec(-blightX, blightY, blightZ), coronaColour=vec(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=`LightBrakeRight`, on=`LightBrakeOn`, dim=`LightBrakeDim`, off=`Atlas` };
                };
        };
        
        lightReverseLeft = {
                pos=vec(rlightX, rlightY, rlightZ), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
        lightReverseRight = {
                pos=vec(-rlightX, rlightY, rlightZ), coronaColour=vec(0.03, 0.03, 0.03), coronaSize = 0.7,
        };

        engineSmokeVents = {
                vec(0, 2.247, 0.2);
        };
        exhaustSmokeVents = {
                vec(0.689, -2.801, -0.274);
        };
}

include `classes.lua`


-- most materials are temporal and will probably joined
material `Atlas` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; shadowBias=0.05 }
material `GlowingParts` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; emissiveMap=`Diffuse.png`; emissiveColour=vec(0.4,0.4,0.4), shadowBias=0.05 }
material `LightOn` { emissiveMap=`Diffuse.png`, emissiveColour=vec(4,4,4); }
material `LightBrakeOn` { emissiveMap=`Diffuse.png`, emissiveColour=vec(6,0,0); diffuseColour=vec(0,0,0); specular=0; gloss=0; }
material `LightBrakeDim` { emissiveMap=`Diffuse.png`, emissiveColour=vec(2,0,0); diffuseColour=vec(0,0,0); specular=0; gloss=0; }

material `LightHeadLeft` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; shadowBias=0.05 }
material `LightHeadRight` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; shadowBias=0.05 }
material `LightBrakeLeft` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; shadowBias=0.05 }
material `LightBrakeRight` { glossMap=`Gloss.png`; diffuseMap=`Diffuse.png`; shadowBias=0.05 }

