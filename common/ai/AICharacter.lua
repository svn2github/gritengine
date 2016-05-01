------------------------------------------------------------------------------
--  Simple AI Character
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

local function vector_without_component (v, n)
    return v - dot(v, n) * n
end

local function cast_cylinder_with_deflection(body, radius, height, pos, movement)
	local ret_body, ret_normal, ret_pos

	for i = 0,4 do
		 local walk_fraction, wall, wall_normal = physics_sweep_cylinder(radius - i*0.0005, height - 0.0001, quat(1,0,0,0), pos, movement, true, 0, body)
		if walk_fraction ~= nil then
			if ret_body == nil then
				ret_body = wall
				ret_normal = wall_normal
				ret_pos = pos + walk_fraction*movement
			end
			wall_normal = norm(wall_normal * vector3(1,1,0))
			movement = movement*walk_fraction + vector_without_component(movement*(1-walk_fraction), wall_normal)
		else
			return i, movement, ret_body, ret_normal, ret_pos
		end 
	end 

	return ret_body, ret_normal, ret_pos
end 


-- aichars = {}
-- aichars[#aichars+1] = object (`/navigation/aichar`) (pick_pos()+vec(0, 0, class_get(`/navigation/aichar`).placementZOffset)) {}

function crowd_move(pos)
	for i = 1, #current_map.aicharacters do
		if not current_map.aicharacters[i].destroyed and current_map.aicharacters[i].activated and current_map.aicharacters[i].instance.agentID ~= -1 then
			current_map.aicharacters[i]:updateDestination(pos, false)
		end
	end
end

-- for i = 1, #current_map.aicharacters do
	-- if not current_map.aicharacters[i].destroyed then
		-- current_map.aicharacters[i].needsStepCallbacks = true
	-- end
-- end


AICharacter =  extends (ColClass) {
    renderingDistance = 2000.0;
    castShadows = true;

    height = 1.8;
    radius = 0.3;
    stepHeight = 0.3;
    runSpeed = 12;
    walkSpeed = 6;
    pushForce = 1000;
    runPushForce = 1000;

    mass = 80; 
    
	AICharacter = true;

    activate = function(self, instance)
        ColClass.activate(self, instance)

		local ins = instance
        self.needsStepCallbacks = true
		
		ins.target = nil
		
		-- AI
		ins.destinationRadius = 2
		ins.destinationReached = true

		ins.agentID = -1
		
		if ins.body ~= nil then
			local pos = navigation_nearest_point_on_navmesh(ins.body.worldPosition)
			if pos ~= nil then
				self:setAgentID(agent_make(pos))
			end
		end
		
		if current_map ~= nil then
			if current_map.aicharacters == nil then
				current_map.aicharacters = {}
			end
			current_map.aicharacters[#current_map.aicharacters+1] = self
		end
		
		ins.destination = vec(0, 0, 0)
		ins.stopped = true
		
		-- obstacle when controlled by player
		--ins.tempObstacle
		
		self.maxPerceptionAngle = 85
		self.maxPerceptionDistance = 200

        instance.isActor = true
        instance.runState = false
        local body = instance.body
        body.ghost = true

		-- animations/states
		instance.currentStateName = ""

		instance.animName = 
		{
			"idle";
			"walk";			
		};
		
		-- NEVER RENAME THIS, used for creating tables (kinda enum)
		instance.ANIMLIST = 
		{
			"idle";
			"walk";		
		};
		
		instance.animID = {};

		for i = 1, #instance.ANIMLIST do
			instance.animID[instance.ANIMLIST[i]] = i
		end
		
		instance.animLen = {};

		for i = 1, #instance.ANIMLIST do
			instance.animLen[i] = instance.gfx:getAnimationLength(instance.animName[i]);
		end
		
		instance.animPos = {};
		
		for i = 1, #instance.ANIMLIST do
			instance.animPos[i] = 0;
		end

		instance.currentAnimID = -1
		instance.animFadeSpeed = 3.5
		instance.resetAnim = false		
		
		instance.fadingAnims = {};
		
		for i = 1, #instance.ANIMLIST do
			instance.fadingAnims[i] = {}
			instance.fadingAnims[i].inx = false
			instance.fadingAnims[i].out = false
		end

		instance.ANIMLIST = nil

		self:setAnimation(ins.animID.idle, false)
		self:gotoState("idle")
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false
		if self:getAgentID() ~= -1 then
			agent_stop(self:getAgentID())
			agent_destroy(self:getAgentID())
		end
        ColClass.deactivate(self)
    end;
	
    destroy = function (self)
		if self:getAgentID() ~= -1 then
			agent_stop(self:getAgentID())
			agent_destroy(self:getAgentID())
		end
    end;	
	
    stepCallback = function (self, elapsed)
		if self:getAgentID() ~= -1 then
			local instance = self.instance
			local body = instance.body

			local curr_foot = body.worldPosition - vec(0, 0, self.placementZOffset)
			local height = self.height
			local curr_centre = curr_foot + vector3(0,0,self.height/2)

			local radius = self.radius

			-- push bodies
			if self:isMoving() then
				local speed = (instance.runState and self.runSpeed or self.walkSpeed) * elapsed
				local walk_dir = quat(yaw_angle(body.worldOrientation), V_DOWN)
				local walk_vect = speed * (walk_dir * norm(self:getVelocity()))

				local step_height = self.stepHeight

				local walk_cyl_height = height - step_height
				local walk_cyl_centre = curr_centre + vector3(0,0,step_height/2)
				--if no_step_up then
					walk_cyl_height = height
					walk_cyl_centre = curr_centre
				--end
				local collision_body, collision_normal, collision_pos = cast_cylinder_with_deflection(body, radius, walk_cyl_height, walk_cyl_centre, walk_vect)

				if collision_body and type(collision_body) ~= "number" then
					local push_force = instance.runState and self.runPushForce or self.pushForce
					local magnitude = math.min(self.pushForce, collision_body.mass * 15) * -collision_normal
					collision_body:force(magnitude, collision_pos)
				end
			end

			self:updatePosition(elapsed)
			local vel = self:getVelocity()
			if vel ~= V_ZERO then
				local dir = norm(vec(vel.x, vel.y, 0))
				body.worldOrientation = quat(V_NORTH, dir)
			end
		end
		self:currentState(elapsed)
		self:fadeAnimations(elapsed)
    end;
 
	-- Animations/States
    currentState = function (self, elapsed)
		
    end;

	walk_state = function(self, elapsed)
		local ins = self.instance
		local id = ins.animID.walk
		
		ins.animPos[id] = math.mod(ins.animPos[id] + elapsed*(self:getSpeed()*0.5), ins.animLen[id])
		ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])		
	end;

	idle_state = function(self, elapsed)
		local ins = self.instance
		local id = ins.animID.idle
		
		ins.animPos[id] = math.mod(ins.animPos[id] + elapsed, ins.animLen[id])
		ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
	end;
	
	lookAt = function(source, target)
		local dir = norm(target-source)
		return quat(yaw(dir.x, dir.y), V_DOWN) * quat(pitch(dir.z), V_EAST)
	end;

	getTargetPosition = function()
		if self.instance.target ~= nil and not self.instance.target.destroyed then
			return self.instance.target.body.worldPosition
		end
	end;
	
	getEyePosition = function()
		return self.instance.body.worldPosition + vec(0, 0, 1)
	end;	
	
	empty_state = function(self, elapsed)
		
	end;
	
	gotoState = function(self, state_name)
		local ins = self.instance
		ins.currentStateName = state_name
		self.currentState = self[state_name.."_state"]
	end;

	setAnimation = function(self, id, reset)
		local inst = self.instance
		
		if inst.currentAnimID >= 0 then
			-- if we have an old animation, fade it out
			inst.fadingAnims[inst.currentAnimID].inx = false
			inst.fadingAnims[inst.currentAnimID].out = true
		end
		
		inst.currentAnimID = id
		-- if we have a new animation, enable it and fade it in
		inst.gfx:setAnimationMask(inst.animName[id], 0)
		inst.fadingAnims[id].inx = true
		inst.fadingAnims[id].out = false
		if reset then inst.gfx:setAnimationPos(inst.animName[id], 0) end
	end;

	fadeAnimations = function(self, elapsed)
		local inst = self.instance
		
		for i = 1, #inst.animName do
			if inst.fadingAnims[i].inx then
				local newWeight = inst.gfx:getAnimationMask(inst.animName[i]) + elapsed * inst.animFadeSpeed
				inst.gfx:setAnimationMask(inst.animName[i], math.clamp(newWeight, 0, 1))
				if newWeight >= 1 then
					inst.fadingAnims[i].inx = false
				end
			elseif inst.fadingAnims[i].out then
				local newWeight = inst.gfx:getAnimationMask(inst.animName[i]) - elapsed * inst.animFadeSpeed
				inst.gfx:setAnimationMask(inst.animName[i], math.clamp(newWeight, 0, 1))

				if newWeight <= 0 then
					inst.fadingAnims[i].out = false
				end				
			end
		end
	end;	

	-- AI:
	canSee = function(self, target_pos)
		local ins = self.instance
		local pos = ins.body.worldPosition + vec(0, 0, 1) -- ~eye position

		local distance = #(target_pos - pos)
		
		if distance <= self.maxPerceptionDistance then
			local _, occ = physics_cast(pos, norm(target_pos - pos) * distance, true, 0, ins.body)

			if not occ then
				local p = pos + distance * norm(ins.body.worldOrientation * V_NORTH)

				local angle = quat(p - pos, target_pos - pos).angle
				if angle <= self.maxPerceptionAngle then
					return true
				else
				end
			end
		end
		return false
	end;

	getAgentID = function(self)
		return self.instance.agentID
	end;
	
	setAgentID = function(self, id)
		self.instance.agentID = id
	end;
	
	restartAgent = function(self)
		if navigation_navmesh_loaded() then
			if self.instance ~= nil and self:getAgentID() ~= -1 then
				agent_destroy(self:getAgentID())
			end
			self:setAgentID(agent_make(self.instance.body.worldPosition-vec(0, 0, self.placementZOffset)))
		end
	end;		

	getDestination = function(self)
		return self.instance.destination
	end;	
	
	updateDestination = function(self, position, up_prev_path)
		local ins = self.instance
		if not self.activated then return end
		
		local new_dest, target_ref = navigation_nearest_point_on_navmesh(position)
		if not new_dest or target_ref == 0 then return end
		
		agent_move_target(self:getAgentID(), new_dest, up_prev_path)
		ins.destination = new_dest
		self.stopped = false
		self.velocity = vec(0, 0, 0)

		self:gotoState("walk")
		self:setAnimation(ins.animID.walk, false)
	end;

	destinationReached = function(self)
		local ins = self.instance
		if #(self:getPosition() - (ins.destination or V_ZERO)) <= ins.destinationRadius then return true end
		return agent_distance_to_goal(self:getAgentID(), 0) < 0
	end;	
	
	teleport = function (self, position)
		local ins = self.instance
		local new_dest = navigation_nearest_point_on_navmesh(position)
		if not new_dest then return end
		
		agent_destroy(self:getAgentID())
		self:setAgentID(agent_make(result_pos))
		
		ins.body.worldPosition = result_pos
	end;
	
	isStuck = function(self)
		return false--(self:getSpeed() <= 2 and agent_distance_to_goal(self:getAgentID(), 0) <= 5) -- TODO: get neighbours and its radius to set the value
	end;
	
	getPosition = function(self)
		return self.instance.body.worldPosition
	end;
	
	updatePosition = function(self, elapsed)
		local ins = self.instance
		if not self.activated then return end
		
		if agent_active(self:getAgentID()) then
			ins.body.worldPosition = agent_position(self:getAgentID())+vec(0, 0, self.placementZOffset)
		end
		
		if self:destinationReached() or self:isStuck() then
			if ins.currentStateName ~= "idle" then
				self:gotoState("idle")
				self:setAnimation(ins.animID.idle, false)
				self:stop()		
			end
		end
	end;	
	
	setVelocity = function (self, vel)
		local ins = self.instance
		ins.manualVelocity = vel
		if vel ~= V_ZERO then
			ins.stopped = false
		end
		ins.destination = V_ZERO
		
		if self.activated then
			agent_request_velocity(self:getAgentID(), ins.manualVelocity)
		end
	end;
	
	getVelocity = function (self)
		local ins = self.instance
		if not self.activated then
			return V_ZERO
		end
		return agent_velocity(self:getAgentID())
	end;	
	
	getSpeed = function (self)
		local ins = self.instance
		return #self:getVelocity()
	end;
	
	isMoving = function (self)
		local ins = self.instance
		return self:getSpeed() ~= 0
	end;
	
	stop = function(self)
		local ins = self.instance

		if agent_stop(self:getAgentID()) then
			ins.destination = nil
			ins.manualVelocity = V_ZERO
			ins.stopped = true
		end
	end;	
	
	getAgentHeight = function (self)
		local ins = self.instance
		return agent_height()
	end;		
		
	getAgentRadius = function (self)
		local ins = self.instance
		return agent_radius()
	end;
}
