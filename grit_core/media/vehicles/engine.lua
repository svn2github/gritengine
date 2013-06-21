-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading engine.lua")

Engine = Engine or { }

function Engine.new (power_plots, drag)
        local self = make_instance({}, Engine)
        self.powerCurve = {}
        for k,v in pairs(power_plots) do
                self:setPowerCurve(k, v)
        end
        self:setDrag(drag or 30)
        self:setGear(0)
        return self
end

function Engine:setPowerCurve(gear, power_plot)
        self.powerCurve[gear] = Plot(power_plot) -- turns it into a spline representation
end

function Engine:setDrag(drag)
        self.drag = drag
end

function Engine:setGear(gear)
        if self.powerCurve[gear] == nil then
                error("Invalid gear: "..tostring(gear))
        end
        self.gear = gear
end

function Engine:getGear()
        return self.gear
end

function Engine:getTorque(mph)
        -- mph is negative when car is reversing
        if self.gear ~= 0 then return self.powerCurve[self.gear][math.abs(mph)] end
        return 0
        --return -self.drag * mph
end

