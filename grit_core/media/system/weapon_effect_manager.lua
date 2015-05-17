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
        if w == nil then return (next(self.weapons, nil)) end
        return w
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
        src = src or main.camPos
        quat = quat or main.camQuat
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
        src = src or main.camPos
        quat = quat or main.camQuat
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


-- Pick things up and move them
WeaponGrab = {
    object = nil;
    grabDist = 0;
    localGrabPos = vec(0, 0, 0);
    lastDeviation = 0;
    accDeviation = 0;
    accDeviationMax = 10;
    pidParam1 = -100;
    pidParam2 = -20;
    pidParam3 = -1;

    -- For controlling rotation
    lastOrientationDeviation = Q_ID;
    pidOrientationParam1 = -1;
    pidOrientationParam2 = -3;

    primaryEngage = function (self, src, quat)
        local len = 8000
        local dir = quat * V_FORWARDS
        local ray = len * dir
        local dist, body = physics_cast(src, ray, true, 0)
        if dist ~= nil then
            self.grabDist = dist * len
            self.object = body.owner
            self.localGrabPos = body:worldToLocal(src + dist * ray)
            self.lastDeviation = 0
            self.lastOrientationDeviatoin = Q_ID
        end
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        if not obj.activated then return end
        local body = obj.instance.body
        if body == nil then return end

        -- Use a PID loop to control position of grabbed object
        local measured_pos = body:localToWorld(self.localGrabPos)
        local target_pos = main.camPos + self.grabDist * (main.camQuat * V_FORWARDS)

        local deviation = measured_pos - target_pos
        local deviation_rate = (deviation - self.lastDeviation) / elapsed_secs
        self.lastDeviation = deviation
        local acc_deviation = self.accDeviation + deviation
        if #acc_deviation > self.accDeviationMax then
            acc_deviation =  norm(acc_deviation) * self.accDeviationMax
        end
        self.accDeviation = acc_deviation

        local acc = deviation * self.pidParam1 + deviation_rate * self.pidParam2 + acc_deviation * self.pidParam3

        body:force(acc * body.mass, measured_pos)
    end;
    primaryDisengage = function (self)
        self.object = nil
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        if not obj.activated then return end
        local body = obj.instance.body
        if body == nil then return end

        -- use PD loop to control orientation of grabbed object
        local target_orientation = main.camQuat
        local measured_orientation = body.worldOrientation

        local deviation = norm(measured_orientation * inv(target_orientation))
        local deviation_tensor = tensor(deviation)

        local deviation_change = (deviation * inv(self.lastOrientationDeviation))
        local deviation_rate_tensor = tensor(deviation_change) / elapsed_secs
        self.lastOrientationDeviation = deviation

        local acc = deviation_tensor * self.pidOrientationParam1 + deviation_rate_tensor * self.pidOrientationParam2

        body:torque(acc * body.inertia)
        --body.angularVelocity = V_ZERO
        --body.worldOrientation = slerp(body.worldOrientation, main.camQuat, 0.01)
    end;
    secondaryDisengage = function (self)
    end;
}

WeaponEffectManager:set("Grab", WeaponGrab)

WeaponEffectManager:select("Grab")


