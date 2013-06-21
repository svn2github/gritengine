local t

function mats()
        t = time(function() include "materials.lua" end)
        --read_matbin("gtasa/san_andreas.matbin",matbin_reader)
        echo("materials.lua: "..t.." seconds")
end

mats()

include "phys_mats.lua"

t = time(function() include "classes.lua" end)
echo("classes.lua: "..t.." seconds")

include "carcols.lua"

include "vehicles.lua"

include "all_streetlamps.lua"

ui:bind("b",function()fire("/gtasa/"..all_vehicles[math.random(#all_vehicles)])end)

function go_la()
        player_ctrl:warp(vector3(2312.48, -1621.77, 35.7562), quat(0.870673,0.00683816,0.00386254,0.4918))
end

function go_vegas()
        player_ctrl:warp(vector3(1856.87, 1360.64, 60.1808), quat(0.981828,-0.0473323,-0.00884934,0.183564))
end

function go_vegas2()
        player_ctrl:warp(vector3(1770.23, 2959.79, 41.6458), quat(0.00732922,-0.000130489,-0.0178007,0.999815))
end

function go_vegas3()
        player_ctrl:warp(vector3(2104.36, 1969.44, 12.7467),quat(0.989455,-0.0669341,-0.00866934,0.128155))
end

function go_sf()
        player_ctrl:warp(vector3(-2016.56, 884.951, 68.9321), quat(0.868686,-0.051001,0.0288787,-0.491883))
end

function go_nowhere()
        player_ctrl:warp(vector3(0,0,-10000))
end

function all_cast_shadows()
        foreach(object_all(), function(o)
                o.castShadows = true
                if o.instance then
                        o.instance.gfx.castShadows = true
                end
        end)
end

function load_all_cols()
        foreach(class_all(), function(c)
                if c.colMesh ~= nil then
                        if c.colMesh:sub(1,8) == "gta3.img" then
                                disk_resource_load("gtasa/"..c.colMesh)
                        end
                end
        end)

end

function car_grid()
        local tab = {}
        for y=0,10 do
                for x=0,19 do
                        local id = y*20+x
                        local v = all_vehicles[id]
                        if v~=nil then
                                local class = "/gtasa/"..v
                                if class_has(class) then
                                        tab[id] = object (class) (x*10, y*20, 0) { }
                                end
                        end
                end
        end
        return tab
end

function streetlamp_grid()
        local tab = {}
        for y=0,3 do
                for x=0,3 do
                        local id = y*4+x
                        local v = all_streetlamps[id]
                        if v~=nil then
                                local class = "/gtasa/"..v
                                if class_has(class) then
                                        tab[id] = object (class) (x*10, y*10, 0) { }
                                end
                        end
                end
        end
        return tab
end

function kill_class(c)
    echo("Killing all of class \""..c.."\"")
    foreach(object_all_of_class(c), function(o) o:destroy() end)
end

function kill_ide(ide)
    kill_class("/gtasa/"..ide)
end

function kill_pick() kill_class(pick_obj().className) end
