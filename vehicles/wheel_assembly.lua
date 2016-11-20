-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php


-- The wheel assembly handles physical simulation and rendering of a wheel + suspension

WheelAssembly = WheelAssembly or { }

function WheelAssembly:constructorUtil (name, obj, load, info)

        -- the running state, maintained as the wheel lives
        self.onGround = false
        self.skidding = 0
        self.locked = false
        self.travel = 0 -- gets converted to rotation
        self.steer = 0
        self.wheelAngularVelocity = 0
        self.wheelAngularVelocityIgnoringSkid = 0
        self.torque = 0
        self.tractionControl = info.tractionControl or 0
        self.temperature = 0
        self.smokeTimer = 0
        self.dustTimer = 0
        self.firstTick = true

        self.rayPosOS = vector3(0,0,0)
        self.rayDirOS = vector3(0,0,0)
        self.axleDirBeforeSteerOS = vector3(0,0,0)
        self.axleDirOS = vector3(0,0,0)

        self.restitutionForce = vector3(0,0,0)
        self.velocityDifference = vector3(0,0,0)
        self.worldContactPos = vector3(0,0,0)
        self.worldContactNormal = vector3(0,0,0)

        -- keep a record of stuff from the wheel description 'info'
        self.obj = obj
        self.load = load
        self.name = name
        self.wheelRadius = info.rad
        if self.wheelRadius <= 0 then error("Inappropriate wheel radius: "..self.wheelRadius) end
        self.wheelMass = info.mass or 20
        self.castRadius = info.castRadius or 0.1
        self.wheelCircumference = 2 * info.rad * math.pi
        self.offRoad = info.offRoad or false
        self.maxRestitution = info.maxRestitution  --perfectly ok for this to be nil

        self.driveMu = info.driveMu or info.mu or 200
        self.sideMu = info.sideMu or info.mu or 200
        self.optimalTurnAngle = info.optimalTurnAngle or 15
        self.sideP = info.sideSport or info.sport or 1.5

        self.sideA = 1/((self.sideP-1)*math.pow(self.optimalTurnAngle,self.sideP))
        self.sideB = self.sideMu/(self.optimalTurnAngle/(1+(1/(self.sideP-1))))

end

-- this one expects suspenionLength to have been populated, but in the case of the boned wheel this requires some processing between
-- constructorUtil and constructorUtil2
function WheelAssembly:constructorUtil2 (name, obj, load, info)

        local hooke = 2 * (9.81*load) / self.suspensionLength * (info.hookeFactor or 1)
        local damping = 2 * math.sqrt(load * hooke) * (info.dampingFactor or 0.5)
        self.suspensionHooke = hooke
        self.suspensionDamping = damping
         -- probably when vehicles are spawned, they are 'parked' so this is a reasonable initial 'previous' value for computing damping
        self.lastExtension = -self.suspensionLength/2

end 

-- aimBone is the direction in which the ray is shot
-- steerBone is the axis around which the wheel is steered (often the same as aim_bone)
-- axleBone is the point around which the wheel rotates due to engine torque, it is moved up and down steer_bone to represent the suspension
-- wheelBone is rotated around its y axis to move the wheels due to engine torque
function WheelAssembly.newBoned (name, obj, load, info)

        local self = { boned=true }
        make_instance(self,WheelAssembly)

        self:constructorUtil(name,obj,load,info)

        -- graphics
        self.parentGfx = obj.instance.gfx
        self.aimBoneName = info.aimBone
        self.steerBoneName = info.steerBone
        self.axleBoneName = info.axleBone
        self.wheelBoneName = info.wheelBone
        self:reload()

        self:updatePos()

        self:constructorUtil2(name,obj,load,info)

        return self
end
 
function WheelAssembly.newMesh (name, obj, load, info)

        local self = { boned=false }
        make_instance(self,WheelAssembly)

        self:constructorUtil(name,obj,load,info)

        self.forwards = vector3(0,0,0)
        self.right = vector3(0,0,0)
        self.slack = info.slack or 0

        self.suspensionLength = info.len
        self.down = norm(info.down or V_DOWN)
        self.forwardsBeforeSteer = norm(info.forwards or V_FORWARDS)

        self:constructorUtil2(name,obj,load,info)

        -- metrics for shooting rays and stuff
        self.rayPosOS = info.attachPos
        if info.attachDir then
                self.rayDirOS = info.attachDir
        else
                self.rayDirOS = vector3(0,0,-1) -- down by default
        end
        if info.forwards then
                self.axleDirBeforeSteerOS = info.forwards
        else
                self.axleDirBeforeSteerOS = vector3(1,0,0)
        end

        -- graphics
        local parent = obj.instance.gfx
        self.rootNode = parent:makeChild()
        self.rootNode.localPosition = self.rayPosOS
        self.rootNode.localOrientation = quat(vector3(0,1,0), self.rayDirOS)
        -- axle node does both the 'suspension' offset and 'steer' rotation
        if info.brakeMesh then
                self.axleNode = self.rootNode:makeChild(info.brakeMesh)
        else
                self.axleNode = self.rootNode:makeChild()
        end
        -- wheel node is for spinning due to the engine
        self.wheelNode = self.axleNode:makeChild()
        -- so that the wheels on the left hand side of the car are inverted
        self.wheelGfx = self.wheelNode:makeChild(info.mesh)
        if info.left then
                self.wheelGfx.localOrientation = quat(180,V_UP)
        end

        self:setSteer(self.steer)

        self:updateGFX()

        return self
end

function WheelAssembly:reload()
        if self.boned then
                self.aimBone = self.parentGfx:getBoneId(self.aimBoneName or self.steerBoneName)
                if self.steerBoneName then
                        self.steerBone = self.parentGfx:getBoneId(self.steerBoneName)
                end
                self.axleBone = self.parentGfx:getBoneId(self.axleBoneName)
                self.wheelBone = self.parentGfx:getBoneId(self.wheelBoneName)
        end
end

function WheelAssembly:destroy ()
        if self.boned then
                -- shrink it down
                self.parentGfx:setBoneLocalOrientation(self.wheelBone, quat(0, 0, 0, 0))
        else
                self.rootNode = safe_destroy(self.rootNode)
                self.axleNode = safe_destroy(self.axleNode)
                self.wheelNode = safe_destroy(self.wheelNode)
                self.wheelGfx = safe_destroy(self.wheelGfx)
        end
end

function WheelAssembly:setBurnt(v)
        if v then
                if self.wheelGfx then
                        self.wheelGfx:setAllMaterials("/common/mat/Burnt")
                end
                if self.axleNode then
                        self.axleNode:setAllMaterials("/common/mat/Burnt")
                end
        end
end

-- update based on changes to the wheel attachment to the parent vehicle, e.g. retracting gear on planes
-- use the unmodified bone transforms to figure out some of the needed metrics
function WheelAssembly:updatePos()
        if self.boned then
                local p = self.parentGfx:getBoneWorldPosition(self.aimBone)
                local q = self.parentGfx:getBoneWorldOrientation(self.aimBone)
                self.rayPosOS = p
                self.rayDirOS = q * vector3(0,1,0) -- ray is +y in bone space
                local wq = self.parentGfx:getBoneInitialOrientation(self.wheelBone)
                self.axleDirBeforeSteerOS = q * wq * vector3(0,1,0)
                
                local ap = self.parentGfx:getBoneInitialPosition(self.axleBone)
                local wp = self.parentGfx:getBoneInitialPosition(self.wheelBone)
                self.slack = ap.y
                self.suspensionLength = wp.y

                self:setSteer(self.steer)
        else
        end
end

function WheelAssembly:setSteer(amount)
        self.steer = amount
        self.axleDirOS = quat(self.steer, self.rayDirOS) * self.axleDirBeforeSteerOS

end

function WheelAssembly:setTorque(torque)
        self.torque = torque
end

-- called from update callback, NOT step callback
function WheelAssembly:updateGFX()
        local angle = 360 * self.travel / self.wheelCircumference
        if self.boned then
                local e = self.parentGfx
                e:setBoneLocalPositionOffset(self.axleBone, vector3(0,self.lastExtension,0))
                if self.steerBone then
                        e:setBoneLocalOrientationOffset(self.steerBone, quat(self.steer, vector3(0,1,0)))
                end
                e:setBoneLocalOrientationOffset(self.wheelBone, quat(angle, vector3(0,-1,0)))
        else
                self.axleNode.localPosition = vector3(0, self.suspensionLength+self.slack + self.lastExtension, 0)
                self.axleNode.localOrientation = quat(self.steer, V_FORWARDS)
                self.wheelNode.localOrientation = quat(angle, V_LEFT)
        end
end

function WheelAssembly:setFade(fade)
        if self.boned then
        else
                self.axleNode.fade = fade
                self.wheelGfx.fade = fade
        end
end

function WheelAssembly:extensionChange(extension)
        local extension_delta = extension - self.lastExtension
        self.lastExtension = extension
        return extension_delta
end

function WheelAssembly:rotateWheel (interval)
        if self.locked then return end
        local distance = self.wheelAngularVelocity * self.wheelRadius * interval
        self.travel = (self.travel + distance) % self.wheelCircumference
end

function WheelAssembly:process (interval)

        local vehicle = self.obj
        local body = vehicle.instance.body
        local torque = self.torque

        -- set angular velocity, will overwrite if we are in contact with the ground
        local inertia = self.wheelRadius * self.wheelRadius * self.wheelMass / 2
        if torque == 0 then
                self.wheelAngularVelocity = self.wheelAngularVelocity * math.pow(0.5,interval)
        else
                self.wheelAngularVelocity = self.wheelAngularVelocity + (torque * interval / inertia )
        end
        self.wheelAngularVelocity = clamp(self.wheelAngularVelocity, -1000, 1000) -- about 10k rpm
        if sign(torque) < 0 and sign(self.wheelAngularVelocity) > 0 then
                self.wheelAngularVelocity = 0
        end
        if sign(torque) > 0 and sign(self.wheelAngularVelocity) < 0 then
                self.wheelAngularVelocity = 0
        end
        if self.locked then
                self.wheelAngularVelocity = 0
        end
        self.wheelAngularVelocityIgnoringSkid = self.wheelAngularVelocity


        -- _ws means world space

        local ray_start = body:localToWorld(self.rayPosOS)
        local ray_length = self.suspensionLength + self.wheelRadius + self.slack - self.castRadius
        local ray_dir = body.worldOrientation * self.rayDirOS
        local ray_reach, ground, n, mat = physics_sweep_sphere(self.castRadius, ray_start, ray_length * ray_dir, true, 0, body)

        if ray_reach == nil then
                self.onGround = false
                ray_reach = 1
                ray_reach = self.suspensionLength + self.wheelRadius + self.slack
        else
                self.onGround = true
                ray_reach = ray_reach * ray_length + self.castRadius
        end

        -- contact point (world space)
        local cp = ray_reach * self.rayDirOS + self.rayPosOS
        local cp = body:localToWorld(cp)

        local extension = ray_reach - self.wheelRadius - self.suspensionLength - self.slack

        extension = clamp(extension, -self.suspensionLength, 0)


        local extension_rate = self:extensionChange(extension) / interval

        self.skidding = 0
        self.temperature = self.temperature - .3
        self.temperature = clamp(self.temperature, 0, 100)

        if not self.onGround then
                self.temperature = self.temperature - 3
                self:rotateWheel(interval)
                self.firstTick = true
                return
        end


        local spring_force_mag   = - extension * self.suspensionHooke

        local damping_force_mag  = - extension_rate * self.suspensionDamping


        -- this is the important one
        local surface_force_mag = spring_force_mag + damping_force_mag
        local surface_force_mag_clamped = surface_force_mag

        if self.maxRestitution and surface_force_mag > self.maxRestitution then
                surface_force_mag_clamped = self.maxRestitution
        end


        local r = surface_force_mag_clamped * n

        --if player_ctrl.vehicle ~= nil and player_ctrl.vehicle.instance == self.obj then
        --        print("RF: ",extension)
        --end
        body:force(r, cp)

        -- subtract ground velocity from body velocity
        local vd = body:getLocalVelocity(cp, true) - ground:getLocalVelocity(cp, true)

        -- compute them maximum frictional force the surface can provide
        local surface_friction_factor = (self.offRoad and physics:getMaterial(mat).offRoadTyreFriction or physics:getMaterial(mat).roadTyreFriction)
        local smoke_arg = physics:getMaterial(mat).tyreSmoke
        local dust_arg = physics:getMaterial(mat).tyreDust

        -- forward (object space)
        local fo = cross(n, self.axleDirOS)

        -- right (object space)
        local ro = cross(n, fo)

        -- transform to world space
        local fw = body.worldOrientation * fo
        local rw = body.worldOrientation * ro

        -- divide into ahead and sideways component
        local forward_speed = dot(vd, fw)
        local right_speed = dot(vd, rw)

        local lateral_force  -- calculated differently depending on wheel state, see below
        local longitudinal_force -- calculated differently depending on wheel state, see below

        local load = self.load
        local max_longitudinal_force = self.driveMu*surface_friction_factor*surface_force_mag
        if self.locked then

                -- first compute limiting friction
                -- this is the force required to keep the object stationary
                -- no matter how fast it is going
                lateral_force = -right_speed * load / interval  / 2-- constant force required to stop motion by next interval
                longitudinal_force = -forward_speed * load / interval  / 2-- speed/interval*load is the momentum

                -- use a circle
                local max_force = 0.5 * (self.driveMu + self.sideMu) * surface_friction_factor * surface_force_mag

        else
                self.wheelAngularVelocityIgnoringSkid = forward_speed / self.wheelRadius

                lateral_force  = friction_model_lateral(self.sideP, self.sideA, self.sideB*surface_friction_factor,
                                                        forward_speed, right_speed, surface_force_mag)
                longitudinal_force = torque / self.wheelRadius

                local spilt_force = math.abs(longitudinal_force) - max_longitudinal_force
                if spilt_force > self.tractionControl then
                        longitudinal_force = sign(longitudinal_force) * (max_longitudinal_force + spilt_force - self.tractionControl)
                elseif spilt_force > 0 then
                        longitudinal_force = sign(longitudinal_force) * max_longitudinal_force
                        self.wheelAngularVelocity = self.wheelAngularVelocityIgnoringSkid
                else
                        self.wheelAngularVelocity = self.wheelAngularVelocityIgnoringSkid
                end

                --print(string.format("%10s % 5.0f % 5.0f % 5.0f % 5.0f", self.name, math.max(0,spilt_force), attempted_longitudinal_force, longitudinal_force, surface_force_mag))

        end


        local stuck = false
        -- old contact point
        if not self.firstTick then
                stuck = true
                local dcp = cp - self.worldContactPos
                local disp_lat = dot(dcp, rw)
                if disp_lat<0.1 and disp_lat>-0.1 then
                        --print("stuck at", disp_lat)
                        lateral_force = lateral_force + load * (- 50 * disp_lat)
                else
                        stuck = false
                end
                if self.locked then
                        local disp_long = dot(dcp, fw)
                        if disp_long<0.1 and disp_long>-0.1 then
                                --print("stuck at", disp_lat)
                                longitudinal_force = longitudinal_force + load * (- 200 * disp_long)
                        else
                                stuck = false
                        end
                end
        end

        lateral_force, longitudinal_force, self.skidding = friction_ellipse(lateral_force, self.sideMu*surface_friction_factor*surface_force_mag,
                                                                            longitudinal_force, max_longitudinal_force)

        if not self.locked then self.skidding = 0 end


        self.temperature = self.temperature + self.skidding
        if self.skidding == 0 then
                self.temperature = self.temperature - 0.7
        end

        self:rotateWheel(interval)

        local tr = longitudinal_force * fw -- traction force
        body:force(tr, cp)


        local fr = lateral_force * rw -- friction force
        body:force(fr, cp)

        local gr = r + fr + tr -- force on the ground

        -- hack to avoid applying extremely large forces to whatever we happen to be driving over
        local magnitude = math.min(#gr, ground.mass * 10)
        gr = -magnitude * norm(gr)
        ground:force(gr, cp)

        self.firstTick = false
        if not stuck then
                self.worldContactPos = cp
        end
        self.worldContactNormal = n
        self.velocityDifference = vd
        self.restitutionForce = r

        local wheel_speed = self.wheelAngularVelocity * self.wheelRadius

        if #body.linearVelocity > 0.1 then
                if dust_arg then
                        self.dustTimer = dust_arg.behaviour(self.dustTimer, interval, cp, self.temperature/100, fw, forward_speed)
                end

                if smoke_arg then
                        self.smokeTimer = smoke_arg.behaviour(self.smokeTimer, interval, cp, self.temperature/100, fw, forward_speed)
                end
        end
        --if smoke_arg then
        --        self.smokeTimer = self.smokeTimer + interval
        --        if self.smokeTimer >= smoke_arg.period then
        --                self.smokeTimer = self.smokeTimer - smoke_arg.period
        --                local qty = self.temperature / 100
        --                qty = qty / math.max(1,forward_speed/10)
        --                smoke_arg.behaviour(cp, qty, fw, wheel_speed)
        --        end
        --end

end

