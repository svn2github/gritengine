
material `rocket` {
	diffuseMap=`rocket.png`,
	normalMap=`rocket_nm.png`,
	gloss = 0.6,
	specular = 0.02,
	shadowBias=0.15
}

class `Rocket` (BaseClass) {
    renderingDistance = 100.0;
	placementZOffset = 0.1;

    speed = 40;

    castShadows = true;
    lifePattern = {1, 2, 1, 4, 1, 2, 1, 8};


    activate = function(self, instance)
        BaseClass.activate(self, instance)
        self.needsStepCallbacks = true
        instance.orientation = self.rot or Q_ID
        instance.stepsTravelled = 0
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false;
        BaseClass.deactivate(self)

        return true  -- Do not respawn.
    end;

    stepCallback = function (self, elapsed)

        local instance = self.instance
        local gfx = instance.gfx

        local p = self.pos

        local movement = (instance.orientation * V_FORWARDS) * elapsed * self.speed

        local fraction, hit_obj, wall_normal = physics_sweep_cylinder(0.1, 0.5, instance.orientation * quat(90, vec(1, 0, 0)), p, movement, true, 0)

        if fraction then
            -- hit something

            local hit_pos = p + fraction * movement

            explosion(hit_pos)
    
            self:destroy()
        else
            -- Put particle at current position, then move to next position (particle always behind)
            --local vel = random_vector3_box(vec(-0.2, -0.2, 6), vec(0.2, 0.2, 8))
            -- 1 2 1 4 1 2 1 8
            local r1 = 0.05
            local r2 = r1 * 50

            gfx_particle_emit(`/common/particles/TexturedSmoke`, p, {
                angle = 360*math.random();
                velocity = V_ZERO;
                initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
                maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
                life = self.lifePattern[instance.stepsTravelled % 8];
                diffuse = 0.4 * vec(1, 1, 1);
                age = 0;
            })

            p = p + movement 
            self.pos = p
            gfx.localPosition = p
        end

        instance.stepsTravelled = instance.stepsTravelled + 1
        
    end;

}   


WeaponEffectManager:set("Rocket", {

    lastFire = 0;
    reloadSec = 0.5;
    
    fire = function (self, p, q)
        self.lastFire = seconds()
        object `Rocket` (p) { rot=q }
    end;
    
    checkFire = function (self, p, q)
        if seconds() > self.lastFire + self.reloadSec then
            self:fire(p, q)
        end
    end;
            
    stepCallbackAux = function (self, elapsed_secs, src, quat, accel)
    end;
    
    primaryEngage = function (self, src, quat)
        self:checkFire(src, quat)
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        self:checkFire(src, quat)
    end;
    primaryDisengage = function (self)
    end;
    
    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
})  

