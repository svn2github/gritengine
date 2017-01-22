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

local col = vec(.2, .4, .4)

material `ChevronLight` {
    diffuseMask = col,
    emissiveMask = 3 * col,
    additionalLighting = true,
}

local light = function(x, y, z)
    return {
        emissiveMaterials = `ChevronLight`,
        pos = vec(x, y, z),
        aim = quat(90, V_RIGHT),
        range = 50,
        diff = col,
        spec = col,
        coronaColour = col,
        coronaSize = 4,
        iangle = 40,
        oangle = 75,
        ciangle = 50,
        coangle = 90,
    }
end

class `ChevronLight` (ColClass) {
    renderingDistance = 200,
    placementZOffset = 0,
    lights = { light(0, 2, 0), light(0, -0.5, 0), light(0, -3, 0) },
}
