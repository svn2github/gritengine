-- (c) David Cunningham 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php


WeaponEffectManager = {

    weapons = { };
    selectedName = nil;

    primaryEngaged = false;
    secondaryEngaged = false;

    set = function (self, name, weapon)
        self.weapons[name] = weapon
    end;

    get = function (self, name)
        return self.weapons[name]
    end;

    getSelected = function (self)
        return self.weapons[self.selectedName]
    end;

    getNext = function (self)
        local w = next(self.weapons, self.selectedName)
        if w == nil then return next(self.weapons, nil) end
    end;

    getPrev = function (self)
        local last = nil
        for k, v in pairs(self.weapons) do
            if k == self.selectedName then
                if last ~= nil then
                    return last
                end
            end
            last = k
        end
        return last
    end;

    select = function (self, name)
        local w = self:get(name)
        if w == nil then error("No such weapon: " .. name) end
        self:primaryDisengage()
        self:secondaryDisengage()
        self.selectedName = name
    end;

    stepCallback = function (self, elapsed_secs, src, quat)
        local w = self:getSelected()
        if w == nil then return end
        if self.primaryEngaged then
            w:primaryStepCallback(elapsed_secs, src, quat)
        end
        if self.secondaryEngaged then
            w:secondaryStepCallback(elapsed_secs, src, quat)
        end
    end;

    primaryEngage = function (self, src, quat)
        local w = self:getSelected()
        if w == nil then return end
        w:primaryEngage(src, quat)
        self.primaryEngaged = true
    end;
   
    primaryDisengage = function (self)
        local w = self:getSelected()
        if w == nil then return end
        if not self.primaryEngaged then return end
        w:primaryDisengage()
        self.primaryEngaged = false
    end;
   

    secondaryEngage = function (self, src, quat)
        local w = self:getSelected()
        if w == nil then return end
        w:secondaryEngage(src)
        self.secondaryEngaged = true
    end;
   
    secondaryDisengage = function (self)
        local w = self:getSelected()
        if w == nil then return end
        if not self.secondaryEngaged then return end
        w:secondaryDisengage()
        self.secondaryEngaged = false
    end;
   
}

-- Push things around
WeaponEffectManager:set("Prod", {
    accelFast = 30;
    accelSlow = 3;

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
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        self:stepCallbackAux(elapsed_secs, src, quat, self.accelFast)
    end;
    secondaryDisengage = function (self)
    end;
})

-- Delete fired / placed objects
WeaponEffectManager:set("Delete", {
    primaryEngage = function (self, src, quat)
        local dir = quat * V_FORWARDS
        local ray = 8000 * dir
        local dist, body = physics_cast(src, ray, true, 0)
        if dist == nil then return end
        local o = body.owner
        if o.temporary or o.placed then
            o:destroy()
        end
    end;
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
})


WeaponEffectManager:select("Prod")

--[[
function ghost:grab()
    local function grab_callback(elapsed)
        
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

-- Pick things up and move them
WeaponEffectManager:set("Grab", {
    object = nil;
    grabDist = 0;

    primaryEngage = function (self, src, quat)
        local len = 8000
        local dir = quat * V_FORWARDS
        local ray = len * dir
        local dist, body = physics_cast(src, ray, true, 0)
        if dist ~= nil then
            self.grabDist = dist * len
            self.object = body.owner
        end
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        local body = obj.instance.body

        local target = main.camPos + self.grabDist * (main.camQuat * V_FORWARDS)
        local delta = target - body.worldPosition

        if #delta < 5 then
            body.linearVelocity = V_ZERO
        else
            body:force(-physics_get_gravity() * body.mass, body.worldPosition)
        end

        if #delta > 0.1 then
                body:force(delta * 1000 * body.mass, body.worldPosition)
        end

    end;
    primaryDisengage = function (self)
        self.object = nil
    end;

    -- TODO: maybe RMB can apply a force so that we can "throw" stuff
    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        local body = obj.instance.body

        if input_filter_pressed("left") then
            body.angularVelocity = V_ZERO
            body.worldOrientation = slerp(body.worldOrientation, main.camQuat, 0.01)
        end
    end;
    secondaryDisengage = function (self)
    end;
})


