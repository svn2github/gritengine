for i=1,20 do
    class (`barrier`..string.format("%02d",i)) (ColClass) { renderingDistance = 500 }
end

for i=1,20 do
    class (`wipeo`..string.format("_%02d",i)) (ColClass) { castShadows=true, renderingDistance = 500 }
end

class `speedpad` (BaseClass) {castShadows=true,renderingDistance=500}
class `weaponpad` (BaseClass) {castShadows=true,renderingDistance=500}

local SpinningClass = extends (ColClass) {
    activate = function (self,instance,class)
        ColClass.activate(self,instance,class)
        instance.spinSpeed = self.spinSpeed or 10
        instance.spinAxis = self.spinAxis or V_UP
        instance.body.angularVelocity = math.rad(instance.spinSpeed)*instance.spinAxis
    end
}

class `wo_tunnel` (SpinningClass) {castShadows=true,renderingDistance=500}
