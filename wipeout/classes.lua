for i=1,20 do
    class (`barrier`..string.format("%02d",i)) (ColClass) { renderingDistance = 750 }
end

for i=1,20 do
    class (`wipeo`..string.format("_%02d",i)) (ColClass) { castShadows=true, renderingDistance = 1000 }
end

class `speedpad` (BaseClass) {castShadows=true,renderingDistance=500}
class `weaponpad` (BaseClass) {castShadows=true,renderingDistance=500}

local SpinningClass = extends (ColClass) {
    activate = function (self,instance,class)
        ColClass.activate(self, instance, class)
        instance.spinSpeed = self.spinSpeed or 10
        instance.spinAxis = self.spinAxis or V_UP
        instance.body.angularVelocity = instance.body.worldOrientation * (math.rad(instance.spinSpeed)*instance.spinAxis)
    end
}

class `wo_tunnel` (SpinningClass) {castShadows=true,renderingDistance=800}

local col = vec(1, .2, .1)

material `ChevronLight1` {
    diffuseMask = col,
    emissiveMask = 5 * col,
    additionalLighting = true,
}

material `ChevronLight2` {
    diffuseMask = col,
    emissiveMask = 5 * col,
    additionalLighting = true,
}

material `ChevronLight3` {
    diffuseMask = col,
    emissiveMask = 5 * col,
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
    lights = { light(0, -3, 0), light(0, -0.5, 0), light(0, 2, 0) },
    activate = function(self, instance)
        ColClass.activate(self, instance)
        self.needsFrameCallbacks = true
        self:frameCallback(0)
    end,
    deactivate = function(self, instance)
        self.needsFrameCallbacks = false
        ColClass.deactivate(self, instance)
    end,
    setLightEnabled = function(self, num, v)
        self.instance.gfx:setEmissiveEnabled(`ChevronLight` .. num, v)
        self.instance.lights[num].enabled = v
    end,
    frameCallback = function(self, elapsed_secs)
        local s = seconds() % 1
        self:setLightEnabled(1, s <= .3)
        self:setLightEnabled(2, s > .3 and s <= .6)
        self:setLightEnabled(3, s > .6)
    end,
}
