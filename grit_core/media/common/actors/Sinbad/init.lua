-- (c) Dave Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

class `../Sinbad2` (BaseClass) {

    renderingDistance = 100;

    castShadows = true;
    
    placementZOffset = 5;
    gfxMesh = `Body.mesh`;

    activate = function (persistent,instance)

        BaseClass.activate(persistent, instance)

        persistent.needsStepCallbacks = true

        for _,v in ipairs({instance.gfx:getAllAnimations()}) do
            instance[v.."Len"] = instance.gfx:getAnimationLength(v)
            instance[v.."Rate"] = 1
            instance[v.."Pos"] = 0
        end
        
        instance.gfx:setAnimationMask("IdleBase",0)
        instance.gfx:setAnimationMask("IdleTop",1)

        instance.gfx.castShadows = persistent.castShadows == true
    end;
    
    deactivate = function (persistent)
        local instance = persistent.instance
        persistent.needsStepCallbacks = false
    end;

    stepCallback = function (persistent, elapsed)
        local inst = persistent.instance
        for _,v in ipairs({inst.gfx:getAllAnimations()}) do
            inst[v.."Pos"] = math.mod(inst[v.."Pos"] + elapsed  * inst[v.."Rate"], inst[v.."Len"])
            inst.gfx:setAnimationPos(v, inst[v.."Pos"]) 
        end
    end;
}   

class `.` {} {

    renderingDistance = 100;

    castShadows = true;
    
    placementZOffset = 5;

    init = function (persistent)
        persistent:addDiskResource(`Body.mesh`)
    end;
            
    activate = function (persistent,instance)

        persistent.needsStepCallbacks = true

        instance.pivot = gfx_body_make()
        instance.pivot.localPosition = persistent.spawnPos
        instance.pivot.localOrientation = quat(1,1,0,0)

        instance.gfx = instance.pivot:makeChild(`Body.mesh`)
        for _,v in ipairs({instance.gfx:getAllAnimations()}) do
            instance[v.."Len"] = instance.gfx:getAnimationLength(v)
            instance[v.."Rate"] = 1
            instance[v.."Pos"] = 0
        end
        
        instance.gfx:setAnimationMask("IdleBase",0)
        instance.gfx:setAnimationMask("IdleTop",1)

        instance.gfx.castShadows = persistent.castShadows == true
    end;
    
    deactivate = function (persistent)
        local instance = persistent.instance
        instance.gfx:destroy()
        instance.pivot:destroy()
        persistent.needsStepCallbacks = false
    end;

    stepCallback = function (persistent, elapsed)
        local inst = persistent.instance
        for _,v in ipairs({inst.gfx:getAllAnimations()}) do
            inst[v.."Pos"] = math.mod(inst[v.."Pos"] + elapsed  * inst[v.."Rate"], inst[v.."Len"])
            inst.gfx:setAnimationPos(v, inst[v.."Pos"]) 
        end
    end;
}   

material `Body` { blendedBones=4, diffuseMap=`Body.tga`, shadowBias=0.15, specularMask=0, glossMask=0 }
material `Gold` { blendedBones=3, diffuseMap=`Clothes.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }
material `Sheaths` { blendedBones=1, diffuseMap=`Sword.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }
material `Clothes` { blendedBones=4, diffuseMap=`Clothes.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }
material `Teeth` { blendedBones=3, diffuseMap=`Body.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }
material `Eyes` { blendedBones=1, diffuseMap=`Body.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }
material `Spikes` { blendedBones=1, diffuseMap=`Clothes.tga`, shadowBias=0.05, specularMask=0, glossMask=0 }

env.clockRate = 1
