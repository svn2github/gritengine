-- (c) David Cunningham 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php


WeaponManager = {
    weapons = { };

    setWeapon = function (self, name, weapon)
        self.gameModes[name] = weapon
    end;

    getWeapon = function (self, name)
        return self.gameModes[name]
    end;

    -- Sets (map name to true)
    primaryEngagedWeapons = { };
    secondaryEngagedWeapons = { };

    stepUpdate = function (self, elapsed_secs, src, quat)
        for k, _ in pairs(self.primaryEngagedWeapons) do
            weapons[k]:primaryStepUpdate(elapsed_secs, src, quat)
        end
        for k, _ in pairs(self.secondaryEngagedWeapons) do
            weapons[k]v:secondaryStepUpdate(elapsed_secs, src, quat)
        end
    end;

    engagePrimary = function (self, weapon_name, src, quat, alt)
        weapons[weapon_name]:engagePrimary(weapon_name, src, quat, alt)
        primaryEngagedWeapons[weapon_name] = true
    end;
   
    disengagePrimary = function (self, weapon_name, src, quat, alt)
        weapons[weapon_name]:disengagePrimary(weapon_name, src, quat, alt)
        primaryEngagedWeapons[weapon_name] = nil
    end;
   

    engageSecondary = function (self, weapon_name, src, quat, alt)
        weapons[weapon_name]:engageSecondary(weapon_name, src, quat, alt)
        secondaryEngagedWeapons[weapon_name] = true
    end;
   
    disengageSecondary = function (self, weapon_name, src, quat, alt)
        weapons[weapon_name]:disengageSecondary(weapon_name, src, quat, alt)
        secondaryEngagedWeapons[weapon_name] = nil
    end;
   
}

-- Push things around
WeaponManager:setWeapon("Prod", {
    accelFast = 100;
    accelSlow = 10;

    stepCallbackAux = function (self, elapsed_secs, src, quat, accel)
        local dir = quat * V_FORWARDS
        local ray = 8000 * dir
        local dist, body = physics_cast(src, ray, true, 0)
        if dist~= nil then
            local pos = src + dist * ray
            body:impulse(elapsed_secs * accel * body.mass * dir, pos)
        end
    end;

    primaryEngage = function (self, src, quat)
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        self:stepCallbackAux(elapsed_secs, src, quat, self.accelSlow)
    end;
    primaryDisengage = function (self, src, quat)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        self:stepCallbackAux(elapsed_secs, src, quat, self.accelFast)
    end;
    secondaryDisengage = function (self, src, quat)
    end;
})

-- Delete fired / placed objects
WeaponManager:setWeapon("Delete", {
    primaryEngage = function (self, src, quat)
        local dir = quat * V_FORWARDS
        local ray = 8000 * dir
        local dist, body = physics_cast(src, ray, true, 0)
        if dist-= nil then return end
        local o = body.owner
        if o.temporary or o.placed then
            o:destroy()
        end
    end;
    primaryDisengage = function (self, src, quat)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryDisengage = function (self, src, quat)
    end;
})



--[[
function ghost:grab()
    local function grab_callback(elapsed)
        local obj = self.grabbedObj
        if obj == nil then
            print "dropping object"
            physics.stepCallbacks:removeByName("grabbedObj")
            return true
        end
            
        local target = (player_ctrl.camPos + 3*norm(player_ctrl.camDir*V_FORWARDS))
        local delta = target - obj.worldPosition
                    
        if #delta < 5 then
            obj.linearVelocity = V_ZERO
        else
            obj:force(-physics_get_gravity() * obj.mass, obj.worldPosition)
        end
        
        if #delta > 0.1 then
                obj:force(delta * 1000 * obj.mass, obj.worldPosition)
        end
        
        if input_filter_pressed("left") then
            obj.angularVelocity = V_ZERO
            obj.worldOrientation = slerp(obj.worldOrientation, player_ctrl.camDir, 0.01)
        end
        
        return true
    end

    if self.grabbedObj ~= nil then
        self.grabbedObj = nil
        physics.stepCallbacks:removeByName("grabbedObj")
        return
    end
    
    local obj = pick_obj_safe()
    obj = obj and obj.instance.body or nil
    if obj and obj.mass ~= 0 and obj.mass < self.grabThreshold then
            self.grabbedObj = obj
            physics.stepCallbacks:insert("grabbedObj", grab_callback)
    end
end
]]

