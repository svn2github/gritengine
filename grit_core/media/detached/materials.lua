-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons License BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/3.0/
---------------------------
---- MATERIALS LIBRARY ----
---------------------------

local filter_mip = "LINEAR"
local filter_mag = "POINT"

if vince_ati_bug == true then
    filter_mip = "NONE"
end

-- GREYBOX MATS --

material "greybox" { diffuseColour= {.4,.4,.4} ,vertexDiffuse=true}
material "greybox_red" { diffuseColour= {.33,0.0,0.0} ,vertexDiffuse=true}
material "greybox_blue" { diffuseColour= {0.0,.1,.33}}
material "greybox_white" { diffuseColour= {0.8,.8,.8} , vertexDiffuse=true}
material "greybox_black" { diffuseColour= {0.1,.1,.1} , vertexDiffuse=true}

-- Buildings Materials -- 

material "ambient_strips" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/ambient_strips.dds", alpha = 0.99 }
material "panels_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/panels_a.dds" ,glossMap="textures/panels_a_spec.dds" ,vertexDiffuse=true}
material "panels_b" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/panels_b.dds" ,glossMap="textures/panels_b_spec.dds" ,vertexDiffuse=true}
material "panels_c" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/panels_c.dds" ,glossMap="textures/panels_c_spec.dds" ,vertexDiffuse=true}
material "panels_d" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/panels_d.dds" ,glossMap="textures/panels_d_spec.dds" ,vertexDiffuse=true}
material "windows_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/windows_a.dds" ,glossMap="textures/windows_a_spec.dds" ,vertexDiffuse=true}
material "girders" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/girders.dds", glossMap="textures/girders_spec.dds" ,vertexDiffuse=true}
material "glassdoor" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/glassdoor_a.dds" ,glossMap="textures/glassdoor_a_spec.dds" ,vertexDiffuse=true}
material "leaks" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/dirt_leaks.dds" , alpha = 0.4 ,vertexDiffuse=true}

-- Platforms Materials -- 

material "platforms" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/platforms.dds", glossMap="textures/platforms_spec.dds", emissiveMap="textures/platforms_em.dds" , emissiveColour = {5,5,5},vertexDiffuse=true}
material "platform_tiles_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/platform_tiles_a.dds",glossMap="textures/platform_tiles_a_spec.dds" ,vertexDiffuse=true}
material "plaform_panels_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/platform_panels_a.dds",glossMap="textures/platform_panels_a_spec.dds" ,vertexDiffuse=true}
material "platform_stairs_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/platform_stairs_a.dds",vertexDiffuse=true, glossMap="textures/platform_stairs_a_spec.dds" }
material "wood_bench" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/wood_bench.dds",vertexDiffuse=true}
material "energy_field" { filterMip=filter_mip, filterMag=filter_mag, emissiveMap= "textures/energy_field.dds", emissiveColour = {0,.5,2},  textureAnimation={0,-.5}, alpha=0, backfaces=true,vertexDiffuse=true} 
material "sustainment_unit" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/sustainment_unit.dds", glossMap="textures/sustainment_unit_spec.dds", emissiveMap="textures/sustainment_unit_em.dds" , emissiveColour = {5,5,5},vertexDiffuse=true}
material "door_maintenance" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/door_maintenance.dds", glossMap="textures/door_maintenance_spec.dds" ,vertexDiffuse=true}

-- Props Materials --

material "cardboard_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/cardboard_a.dds", glossMap="textures/cardboard_a_spec.dds"}
material "foliage_tree_a" { filterMip=filter_mip, filterMag=filter_mag, grassLighting = true, diffuseMap="textures/foliage_tree_a.dds", glossMap="textures/foliage_tree_a_spec.dds", backfaces=true, clamp = true, alphaReject = 0.33, vertexDiffuse=true}
material "trunk_a" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/trunk_a.dds",vertexDiffuse=true}
material "dumpster" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/dumpster.dds",vertexDiffuse=true, glossMap="textures/dumpster_spec.dds"}
material "tube_station" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/tube_station.tga", glossMap="textures/tube_station_spec.tga", emissiveMap="textures/tube_station_em.tga", emissiveColour = {5,5,5}, vertexDiffuse=true}
material "tube" { filterMip=filter_mip, filterMag=filter_mag, diffuseMap="textures/tube.tga",vertexDiffuse=true, glossMap="textures/tube_spec.tga", alpha = 0.8}
