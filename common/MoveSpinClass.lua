-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

MoveSpinClass = extends (ColClass) {
    spinSpeed = 45; -- in degrees
    spinAxis = V_UP;

    moveSpeed = 1; -- in meters per second, I guess...
    moveAxis = V_UP;
    moveBothWays = false; -- if true the object will move back and forth at specified vector, usefull for moving platforms
    moveBothWaysLength = 5; -- the length object should travel before changing to opposite moving velocity
}

function MoveSpinClass.activate(persistent, instance)
    ColClass.activate(persistent, instance)
    
    instance.body.angularVelocity = math.rad(persistent.spinSpeed) * persistent.spinAxis
    
    instance.body.linearVelocity = persistent.moveSpeed * persistent.moveAxis
    if persistent.moveBothWays and persistent.moveBothWaysLength ~= 0 then
        persistent.needsStepCallbacks = true
        instance.startPos = instance.body.worldPosition
        instance.moveAxis = persistent.moveAxis
    end

    if instance.body.mass ~= 0 then -- converting to static object if not already
        instance.body.mass = 0
    end
end

function MoveSpinClass.deactivate(persistent)
    persistent.needsStepCallbacks = false
    ColClass.deactivate(persistent)
end

function MoveSpinClass.stepCallback(persistent, elapsed)
    local instance = persistent.instance
    local body = instance.body
    if #(instance.startPos - body.worldPosition) > persistent.moveBothWaysLength then
        instance.startPos = instance.body.worldPosition
        instance.moveAxis = -instance.moveAxis
        body.linearVelocity = persistent.moveSpeed * instance.moveAxis
    end
end
