material `mat_chromeClean` {
    shadowBias=0.2,

    specularMask = 0.3,
    glossMask = 0.5,
    diffuseMask = vec(0.2, 0.2, 0.2),
}

material `mat_basicGlass` {
    specularMask = 0.4,
    glossMask = 1,
    alphaMask = 0.5,
    sceneBlend = "ALPHA",
    diffuseMask = vec(0.1, 0.1, 0.1),
}

material `mat_batteryCoreEffect` {
    additionalLighting = true;

    specularMask = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveMask = vec(0, 3, 0),
    diffuseMask = vec(0, 1, 0),
    textureAnimation = vec2(0.5, 0.15),
}

material `mat_batteryCoreEffect_space` {
    additionalLighting = true;

    specularMask = 0,
    diffuseMap = `batteryCoreEffect.dds`,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveMask = vec(3, 3, 3),
    textureAnimation = vec2(0.5, 0.15),
}

material `mat_batteryCoreEffect_red` {
    additionalLighting = true;

    specularMask = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveMask = vec(3, 0, 0),
    diffuseMask = vec(1, 1, 0),
    textureAnimation = vec2(0.5, 0.15),
}

material `mat_batteryCoreEffect_yellow` {
    additionalLighting = true;

    specularMask = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveMask = vec(3, 3, 0),
    diffuseMask = vec(1, 1, 0),
    textureAnimation = vec2(0.5, 0.15),
}

material `mat_basicPlastic` {
    shadowBias = 0.2,

    specularMask = 0.1,
    glossMask = 0.3,
    diffuseMask = vec(0.02, 0.02, 0.02),
}

PickUpClass = {
    radius = 1;
    renderingDistance = 50;

    init = function (self)
        local class_name = self.className
        local gfx_mesh = self.gfxMesh or class_name..".mesh"
        self:addDiskResource(gfx_mesh)
    end;

    destroy = function (self)
    end;

    activate = function (self, instance)
        local class_name = self.className
        local gfx_mesh = self.gfxMesh or class_name..".mesh"

        instance.angle = 0
        instance.gfx = gfx_body_make(gfx_mesh)
        instance.gfx.localPosition = self.spawnPos
        instance.gfx.enabled = not self.pickedUp
        self.needsStepCallbacks = not self.pickedUp
        self:stepCallback(0)
    end;

    deactivate = function (self)
        local instance = self.instance
        self.needsStepCallbacks = false
        instance.gfx = safe_destroy(instance.gfx)

    end;

    stepCallback = function (self, elapsed_secs)
        local instance = self.instance
        -- rotate
        instance.angle = (instance.angle + (elapsed_secs * 180)) % 360  -- 1 rev per second
        instance.gfx.localOrientation = quat(instance.angle, V_UP)

        -- test for controllable
        physics_test(self.radius, self.spawnPos, true, function(body)
            if self.pickedUp then return end
            self.pickedUp = true
            self.instance.gfx.enabled = false
            self.needsStepCallbacks = false
            local found_obj = body.owner
            if found_obj == nil then return end
            local playground = game_manager.currentMode
            if found_obj == playground.vehicle or found_obj == playground.protagonist then
                playground:coinPickUp()
            end
        end)
    end;
}

class `pickup_energyReplenish` (PickUpClass) {
    placementZOffset = 1.5
}
class `pickup_fiveRockets` (PickUpClass) {
    placementZOffset = 1.5
}
class `pickup_gearUpgradeTree1` (PickUpClass) {
    placementZOffset = 1.5
}
class `pickup_lesserGearBundle` (PickUpClass) {
    placementZOffset = 1.5
}
class `pickup_tool_ioWire` (PickUpClass) {
    placementZOffset = 1.1
}
class `strike_bomberShell` (PickUpClass) {
    placementZOffset = 1.5
}
