print("Loading wipeout classes")

for i=1,20 do
    class (string.format("barrier%02d",i)) (ColClass) { renderingDistance = 500 }
end

for i=1,20 do
    class (string.format("wipeo_%02d",i)) (ColClass) { castShadows=true, renderingDistance = 500 }
end

class "speedpad" (BaseClass) {castShadows=true,renderingDistance=500}
class "weaponpad" (BaseClass) {castShadows=true,renderingDistance=500}

local SpinningClass = extends (ColClass) {
    activate = function (persistent,instance,class)
        ColClass.activate(persistent,instance,class)
        instance.spinSpeed = persistent.spinSpeed or 10
        instance.spinAxis = persistent.spinAxis or V_UP
        instance.body.angularVelocity = math.rad(instance.spinSpeed)*instance.spinAxis
    end
}

class "wo_tunnel" (SpinningClass) {castShadows=true,renderingDistance=500}
