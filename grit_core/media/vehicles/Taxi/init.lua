
-- http://www.edmunds.com/ford/crown-victoria/2011/features-specs.html

-- length: 5.38
-- width: 1.96
-- height: 1.44
-- wheel base: 2.91
-- track: 1.67
-- weight distribution is allegedly 55:45 or there about...

local mu_front = 1.6
local mu_rear_side = 1.4
local mu_rear_drive = 1.6

-- Wheel, Suspension
local len = 0.14 --amount wheel can go up an down
local rad = 0.3654 -- wheel radius
local wheelX, wheelY, wheelY2, wheelZ = 0.776, 1.38, -1.56, -0.156 --wheel Y and wheel Y 2 are the two axle's Y. the rest explains itself

--Lights
local hlightX, hlightY, hlightZ = 0.629, 2.005, 0.142 -- Headlight
local blightX, blightY, blightZ = 0.782, -2.70, 0.322 -- Brakelight
local rlightX, rlightY, rlightZ = 0.782, -2.70, 0.214 -- Reverse light

class "../Taxi" (Vehicle) {
        gfxMesh = r"Body.mesh",
        colMesh = r"Body.gcol",
        placementZOffset=1.4,
        powerPlots = {
                [-1] = { [0] = -6000; [10] = -6000; [25] = -4000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 7000; [100] = 7000; },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.1;
                  left=true; attachPos=vector3(-wheelX,wheelY,wheelZ); len=len; mesh=r"Wheel.mesh";
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.1;
                  left=false; attachPos=vector3(wheelX,wheelY,wheelZ); len=len; mesh=r"Wheel.mesh";
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.9;
                  left=true; attachPos=vector3(-wheelX,wheelY2,wheelZ); len=len; mesh=r"Wheel.mesh";
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.9;
                  left=false; attachPos=vector3(wheelX,wheelY2,wheelZ); len=len; mesh=r"Wheel.mesh";
                },
        },
		-- Lights - Headlight
		lightHeadLeft = {
                pos=vector3(-hlightX, hlightY, hlightZ), coronaPos=vector3(-hlightX, hlightY+0.2, hlightZ),
                materials = {
                        { mesh=r"LightHeadLeft", on=r"LightOn", off=r"Atlas" };
                };

        };
        lightHeadRight = {
                pos=vector3(hlightX, hlightY, hlightZ), coronaPos=vector3(hlightX, hlightY+0.2, hlightZ),
                materials = {
                        { mesh=r"LightHeadRight", on=r"LightOn", off=r"Atlas" };
                };
        };
		
		--Brake lights
        lightBrakeLeft = {
                pos=vector3(blightX, blightY, blightZ), coronaPos=vector3(blightX, blightY, blightZ), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=r"LightBrakeLeft", on=r"LightBrakeOn", dim=r"LightBrakeDim", off=r"Atlas" };
                };
        };
        lightBrakeRight = {
                pos=vector3(-blightX, blightY, blightZ), coronaPos=vector3(-blightX, blightY, blightZ), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
                materials = {
                        { mesh=r"LightBrakeRight", on=r"LightBrakeOn", dim=r"LightBrakeDim", off=r"Atlas" };
                };
        };
		
        lightReverseLeft = {
                pos=vector3(rlightX, rlightY, rlightZ), coronaPos=vector3(rlightX, rlightY, rlightZ), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
        lightReverseRight = {
                pos=vector3(-rlightX, rlightY, rlightZ), coronaPos=vector3(-rlightX, rlightY, rlightZ), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };

        engineSmokeVents = {
                vector3(0, 2.247, 0.2);
        };
        exhaustSmokeVents = {
                vector3(0.689, -2.801, -0.274);
        };
}

include "classes.lua"


-- most materials are temporal and will probably joined
material "Atlas" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; shadowBias=0.05 }
material "GlowingParts" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; emissiveMap="Diffuse.png"; emissiveColour=vector3(0.4,0.4,0.4), shadowBias=0.05 }
material "LightOn" { emissiveMap="Diffuse.png", emissiveColour=vector3(4,4,4); }
material "LightBrakeOn" { emissiveMap="Diffuse.png", emissiveColour=vector3(6,0,0); diffuseColour=vector3(0,0,0); specular=0; gloss=0; }
material "LightBrakeDim" { emissiveMap="Diffuse.png", emissiveColour=vector3(2,0,0); diffuseColour=vector3(0,0,0); specular=0; gloss=0; }

material "LightHeadLeft" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; shadowBias=0.05 }
material "LightHeadRight" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; shadowBias=0.05 }
material "LightBrakeLeft" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; shadowBias=0.05 }
material "LightBrakeRight" { glossMap="Gloss.png"; diffuseMap="Diffuse.png"; shadowBias=0.05 }

