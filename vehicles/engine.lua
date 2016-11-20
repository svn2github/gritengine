
Engine = { }

function Engine.new(info)
    local self = {}
    make_instance(self, Engine)
    
    -- Initial configuration
    self.torqueCurve = Plot(info.torqueCurve)
    self.gearRatios = info.gearRatios 
    self.finalDrive = info.finalDrive or 4
    self.wheelRadius = info.wheelRadius or 0.5
    self.transEff = info.transEff or 0.7
    self.shiftDownRpm = info.shiftDownRpm or 2000
    self.shiftUpRpm = info.shiftUpRpm or 4500
    self.idleRpm = info.idleRpm or 1000
    self.maxRpm = info.maxRpm or 7000
    self.drag = info.drag or 3e-06
    self.wheelDrag = info.wheelDrag or 5e-06

    -- State variables
    self.gear = 0
    self.rpm = 0
    self.coast = false
    self.on = false
    
    
    self.previousGear = 0
    
    if info.sound ~= nil then
        -- audio
        if type(info.sound) == "table" then -- 3 engine sounds
            self.sound = {}
            
            -- TODO: make it more user-friendly
            if #info.sound > 3 then
                error("You can't create more than 3 sounds for engine!")
            elseif #info.sound == 2 then
                error("You can't create 2 sounds for engine. Possible options: 1 or 3 sounds.")
            elseif #info.sound == 0 then
                error("I can't find any engine sound!")
            end
                
            for k, v in ipairs(info.sound) do
                self.sound[k] = {}
                self.sound[k] = audio_body_make(v)
                self.sound[k].position = vec(0, 0, 0)
                self.sound[k].pitch = 1
                self.sound[k].volume = 0.0
                self.sound[k].looping = true
                self.sound[k]:play()
            end
        else -- only 1 sound for engine
            self.sound = audio_body_make(info.sound)
            self.sound.position = vec(0, 0, 0)
            self.sound.pitch = 1
            self.sound.volume = 0.0
            self.sound.looping = true
            self.sound:play()
        end

    end
    return self
end
    
function Engine:updateSimpleAutomaticGearbox(push, forward_speed, rpm)

    if push == -1 then
        if forward_speed < 5 then
            self.gear = -1
        else
            -- Don't engage reverse gear at high speeds, although the torque will not be applied
            -- due to the brakes coming on and overriding the torque, the rpm will go heavily
            -- negative and the sound will be like an idling engine, even if you're braking at
            -- 70mph.
        end
    elseif push == 1 and self.gear == -1 then
        if forward_speed > -5 then
            self.gear = 1
        else
            -- See comment above.
        end
    end

    -- Don't shift when reversing
    if self.gear == -1 then return end

    if rpm > self.shiftUpRpm then
        -- upshift
        self.gear = self.gear + 1
        if self.gear > #self.gearRatios then self.gear = #self.gearRatios end
    elseif rpm < self.shiftDownRpm then
        -- downshift
        self.gear = self.gear - 1
        if self.gear < 1 then self.gear = 1 end
    else
        -- rpm is ok
    end
    
end

function Engine:update(pos, push, forward_speed, wheel_rpm, elapsed)
    
    dbg_val = ("%d %d %d"):format(push, forward_speed, wheel_rpm or -1)

    if self.on then

        local torque = 0

        local gear_ratio = self.gearRatios[self.gear] * self.finalDrive

        -- rpm calculation
        if wheel_rpm == nil then
            -- Model inertia of engine itself, according to 'push'
            if push == 1 then
                self.rpm = self.rpm + 10000 * elapsed
            elseif self.rpm > self.idleRpm then
                self.rpm = self.rpm - self.drag * (self.rpm * self.rpm)
            end
            -- Do not bother switching gears, just max out
        else
            -- Engine Rpm is set by wheel Rpm, except when going very slowly.
            self.rpm = wheel_rpm * gear_ratio
        end

        local engaged = true
        if self.rpm < self.idleRpm then
             engaged = false
            -- This also covers the negative case, i.e. motion is opposite to chosen gear
            self.rpm = self.idleRpm
        end
        if self.rpm > self.maxRpm then
            self.rpm = self.maxRpm
        end

        if wheel_rpm ~= nil then
            -- set gear for next iteration
            self:updateSimpleAutomaticGearbox(push, forward_speed, self.rpm)
            
            if push ~= 0 then
                -- If we are braking instead, this torque value is not used, so always assume we are
                -- driving in that direction
                torque = self.torqueCurve[self.rpm] * gear_ratio * self.transEff
                if self.rpm >= self.maxRpm then torque = 0 end
            else
                -- Engine braking
                if engaged then 
                    torque = torque - self.drag * (self.rpm * self.rpm) * gear_ratio * self.transEff
                else
                    torque = torque - sign(wheel_rpm) * self.wheelDrag * (wheel_rpm * wheel_rpm) 
                end
            end

        end

        -- update audio
        if self.sound ~= nil then
            if type(self.sound) == "table" then
                local svol1 = 0.85 - 2^(self.rpm/1000 - 2)
                local svol2 = 0.6 - 2^(-self.rpm/1000 + 1)
                local svol3 = 1 - 2^(-self.rpm/4000 - 0.25)

                self.sound[1].volume = svol1
                self.sound[1].position = pos
                self.sound[1].pitch = 0.2 + svol1
                self.sound[2].volume = svol2
                self.sound[2].position = pos
                self.sound[2].pitch = 0.2 + svol2
                self.sound[3].volume = svol3
                self.sound[3].position = pos
                self.sound[3].pitch = 0.2 + svol3
            else
                self.sound.pitch = self.rpm / 2500
                self.sound.position = pos
                self.sound.volume = 0.8
            end
        end

        return torque

    else

        if self.sound ~= nil then
            if type(self.sound) == "table" then
                self.sound[1].volume = 0
                self.sound[2].volume = 0
                self.sound[3].volume = 0
            else
                self.sound.volume = 0
            end
        end

        return 0

    end

end

function Engine:getRpm()
    return self.rpm
end

function Engine:getGear()
    return self.gear
end

function Engine:reversing()
    return self.gear == -1
end

function Engine:destroy()
    if type(self.sound) == "table" then
        for k, v in ipairs(self.sound) do
            safe_destroy(v)
        end
    else
        safe_destroy(self.sound)
    end
end

