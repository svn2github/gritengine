------------------------------------------------------------------------------
--  A W.I.P. (not working, just a concept) character animation system/ai manager
-- Animation events: call a function when reaches a animation timing
-- State machine: easy way to manage character animations and other stuff
-- Animation manager: manage animations and animation blending
-- AI character
-- TODO: 2d animation blending space: see https://goo.gl/I6zYt9
--
--  (c) 2015-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------


function lookAt(source, target)
	local dir = norm(target-source)
	return quat(yaw(dir.x, dir.y), V_DOWN) * quat(pitch(dir.z), V_EAST)
end;

StateClass =  extends (BaseClass)
{
    activate = function(self, instance)
        BaseClass.activate(self, instance)

        self.needsStepCallbacks = true
		instance.currentStateName = ""
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false

        BaseClass.deactivate(self)
    end;
	
    destroy = function (self)

    end;	
	
    stepCallback = function (self, elapsed)
		self:currentState(elapsed)
    end;

	gotoState = function(self, state_name)
		local ins = self.instance
		ins.currentStateName = state_name
		self.currentState = self[state_name.."_state"]
	end;	
	
    currentState = function (self, elapsed)
		
    end;
}

StateMachine =
{
	currentStateName = "";
	prevStateName = "";
	var = {}; -- store temporary variables, on current state context only
	prevVar = {}; -- store previous state variables, just for "init" context
	reference = {}; -- where states are stored
	
    update = function (self, elapsed)
		if self.currentState.update ~= nil then
			-- NOTE: this swap self and the object pointer, we have two 'self', one of the object and other is the real self (state)
			self.currentState.update(self.reference, elapsed, self)
		end
    end;

	goto = function(self, state_name)
		if state_name ~= nil and self[state_name.."_state"] ~= nil then
			local curstname = self.currentStateName
			local prevStateName = self.currentStateName
			self.currentStateName = state_name
			
			if self[curstname] ~= nil and self[curstname].exit ~= nil then
				self[curstname].exit(self.reference, self)
			end
			
			self.prevVar = self.var
			
			self.currentState = self.reference[state_name.."_state"]
			
			self.var = {}
			
			if self[self.currentStateName].init ~= nil then
				self[self.currentStateName].init(self.reference, self)
				self.prevVar = {}
			end
		else
			print(RED.."State: "..state_name.." not found!")
		end
	end;	
	
    currentState = {init=do_nothing,exit=do_nothing,update=do_nothing};
}

AnimEvent = 
{
    activate = function(self, instance)
		instance.animEvents = {}
		instance.onFinishAnimEvents = {}
    end;

    stepCallback = function (self, elapsed)
		local inst = self.instance
		for i = 1, #inst.animEvents do
			if inst.animPos[inst.animEvents.animID] == inst.animEvents.timePos then
				inst.animEvents[i].callback(self)
			end
		end

		for i = 1, #inst.onFinishAnimEvents do
			if inst.animPos[inst.animEvents.animID] == inst.animLen[inst.onFinishAnimEvents.animID] then
				inst.onFinishAnimEvents[i].callback()
				table.remove(inst.onFinishAnimEvents, i)
			end
		end		
    end;
	
	addEvent = function(self, id, tp, cb)
		self.instance.animEvents[#inst.animEvents+1] = {
			animID = id;
			timePos = tp;
			callback = cb;
		}
	end;
	
	addOnFinishEvent = function(self, id, cb)
		self.instance.onFinishAnimEvents[#inst.onFinishAnimEvents+1] = {
			animID = id;
			callback = cb;
		}
	end;	
}

AnimMgr =
{
    activate = function(self, instance)
		local ins = instance

		ins.animName = {ins.gfx:getAllAnimations()}
		
		ins.animID = {};

		for i = 1, #ins.animName do
			ins.animID[ins.animName[i]] = i
		end
		
		ins.animLen = {};

		for i = 1, #ins.animName do
			ins.animLen[i] = ins.gfx:getAnimationLength(ins.animName[i]);
		end
		
		ins.animPos = {};
		
		for i = 1, #ins.animName do
			ins.animPos[i] = 0;
		end

		ins.currentAnimID = -1
		ins.animFadeSpeed = 3.5
		ins.resetAnim = false		
		
		ins.fadingAnims = {};
		
		for i = 1, #ins.animName do
			ins.fadingAnims[i] = {}
			ins.fadingAnims[i].inx = false
			ins.fadingAnims[i].out = false
		end
    end;

    stepCallback = function (self, elapsed)
		self:fadeAnimations(elapsed)
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
}

-- table_concat(AnimatedClass, ColClass)

CustomAnimatedClass = double_extends (AnimatedClass, ColClass)
{
	init = function (persistent)
		ColClass.init(persistent)
	end;
	
    activate = function(self, instance)
		AnimatedClass.activate(self, instance)
		
		self:setAnimation(instance.animID.idle, false)
		self:gotoState("idle")
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false

        AnimatedClass.deactivate(self)
    end;
	
    destroy = function (self)

    end;	
	
    stepCallback = function (self, elapsed)
		AnimatedClass.stepCallback(self, elapsed)

    end;
 
	idle_state = function(self, elapsed)
		local ins = self.instance
		local id = ins.animID.idle
		
		ins.animPos[id] = math.mod(ins.animPos[id] + elapsed, ins.animLen[id])
		ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
	end;
}

class `CustomAnimated` (CustomAnimatedClass)
{

	gfxMesh = `/detached/characters/robot_med/robot_med.mesh`;
	colMesh = `/detached/characters/robot_med/robot_med.gcol`;

	mass = 90;	
    radius = 0.3;
	height = 2.2;

    placementZOffset = 1.112;
	health = 1000;
}

function double_extends (p1, p2)
	return function(child)
		for k,v in pairs(p1) do
			if child[k] == nil then
				child[k] = v
			end
		end
		for k,v in pairs(p2) do
			if child[k] == nil then
				child[k] = v
			end
		end				
		
		return child
	end
end

function multi_extends (parents)
	return function(child)
		for i = 1, #parents do
			for k,v in pairs(parents[i]) do
				if child[k] == nil then
					child[k] = v
				end
			end
		end	
		return child
	end
end

function merge_extends (parents)
	local child = {}
	
	for i = 1, #parents do
		for k,v in pairs(parents[i]) do
			if child[k] == nil then
				child[k] = v
			end
		end
	end	
	return child

end

AICharacter =  extends (StateClass)
{
    renderingDistance = 500.0;
    castShadows = true;

    height = 1.8;
    radius = 0.3;

    mass = 80; 
    
	AICharacter = true;

    activate = function(self, instance)
        StateClass.activate(self, instance)

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

		self.maxPerceptionAngle = 85
		self.maxPerceptionDistance = 200

        instance.isActor = true
        instance.runState = false
        local body = instance.body
        body.ghost = true

		-- self:gotoState("idle")
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false
		if self:getAgentID() ~= -1 then
			agent_stop(self:getAgentID())
			agent_destroy(self:getAgentID())
		end
        StateClass.deactivate(self)
    end;
	
    destroy = function (self)
		if self:getAgentID() ~= -1 then
			agent_stop(self:getAgentID())
			agent_destroy(self:getAgentID())
		end
    end;	
	
    stepCallback = function (self, elapsed)
		StateClass.stepCallback(self, elapsed)
		
		if self:getAgentID() ~= -1 then
			self:updatePosition(elapsed)
			local vel = self:getVelocity()
			if vel ~= V_ZERO then
				local dir = norm(vec(vel.x, vel.y, 0))
				body.worldOrientation = quat(V_NORTH, dir)
			end
		end
		
    end;

	empty_state = function(self, elapsed)
		
	end;	
	
	walk_state = function(self, elapsed)
		local ins = self.instance

	end;

	idle_state = function(self, elapsed)
		local ins = self.instance

	end;

	getTargetPosition = function()
		if self.instance.target ~= nil and not self.instance.target.destroyed then
			return self.instance.target.body.worldPosition
		end
	end;
	
	getEyePosition = function()
		return self.instance.body.worldPosition + vec(0, 0, 1)
	end;	

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
