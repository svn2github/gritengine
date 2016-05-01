material `mat_chromeClean` {
    specular = 0.3,
    gloss = 0.5,
    diffuseColour = vec(0.2, 0.2, 0.2),
    shadowBias=0.2,
}

material `mat_basicGlass` {
    specular = 0.4,
    gloss = 1,
    alpha = 0.5,
    diffuseColour = vec(0.1, 0.1, 0.1),
}

material `mat_batteryCoreEffect` {
    specular = 0,
    gloss = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveColour = vec(0, 3, 0),
    diffuseColour = vec(0, 1, 0),
    textureAnimation = { 0.5, 0.15 },
}

material `mat_batteryCoreEffect_space` {
    specular = 0,
    gloss = 0,
    diffuseMap = `batteryCoreEffect.dds`,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveColour = vec(3, 3, 3),
    textureAnimation = { 0.5, 0.15 },
}

material `mat_batteryCoreEffect_red` {
    specular = 0,
    gloss = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveColour = vec(3, 0, 0),
    diffuseColour = vec(1, 1, 0),
    textureAnimation = { 0.5, 0.15 },
}

material `mat_batteryCoreEffect_yellow` {
    specular = 0,
    gloss = 0,
    emissiveMap = `batteryCoreEffect.dds`,
    emissiveColour = vec(3, 3, 0),
    diffuseColour = vec(1, 1, 0),
    textureAnimation = { 0.5, 0.15 },
}

material `mat_basicPlastic` {
    specular = 0.1,
    gloss = 0.3,
    diffuseColour = vec(0.02, 0.02, 0.02),
    shadowBias=0.2,
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
