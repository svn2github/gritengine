material `lambert2` {
    diffuseColour={.25, .1, .05};
    specular = .02;
    blendedBones = 2;
}

class `TestGirl` {} {

    renderingDistance = 400;

    init = function (persistent)
        persistent:addDiskResource(`test_girl_walk_baked.mesh`)
    end;

    activate = function (persistent,instance)

        persistent.needsStepCallbacks = true

        -- correct weird orientation of model
        instance.pivot = gfx_body_make()
        instance.pivot.localPosition = persistent.spawnPos
        instance.pivot.localOrientation = (persistent.rot or Q_ID) * quat(0,0,0,1) * quat(90,vector3(1,0,0))

        instance.gfx = instance.pivot:makeChild(`test_girl_walk_baked.mesh`)
        instance.gfx:setAnimationMask("walk",1)
        instance.danceLen = instance.gfx:getAnimationLength("walk")
        instance.dancePos = 0

        instance.gfx.castShadows = persistent.castShadows == true
    end;

    deactivate = function (persistent)
    end;

    stepCallback = function (persistent, elapsed)
        local inst = persistent.instance
        inst.dancePos = math.mod(inst.dancePos + elapsed, inst.danceLen)
        inst.gfx.localPosition = inst.gfx.localPosition + elapsed * 1.2 * (inst.gfx.localOrientation * V_UP)
        inst.gfx:setAnimationPos("walk", inst.dancePos)
    end;
}


object "TestGirl" (0, 0, 0) {name="my_girl"}
