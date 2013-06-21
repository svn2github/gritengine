
pid_ctrl = {}

function pid_ctrl.new(initial, p, i, d, min, max)
	local self = {
		lastPos = initial;
		pGain = p;
		iGain = i;
		dGain = d;
		iMin = min;
		iMax = max;
	}
	
	make_instance(self, pid_ctrl)
	
	return self
end

-- Compute a value indicating how to influence an object to correct its position to the reference value
function pid_ctrl:control(ref, pos)
	--echo "PID controlling"
	-- compute error (how far we are from target value)
	local err = ref - pos
	--echo("err "..err)
	
	-- compute accumulated error over time
	if self.iState == nil then
	    self.iState = err
	else
	    self.iState = self.iState + err
	end
	
	if self.iMin and self.iMax then -- clamp iState only if needed
        if #self.iState < self.iMin then
            self.iState = self.iMin * norm(self.iState)
        elseif #self.iState > self.iMax then
            self.iState = self.iMax * norm(self.iState)
        end
	    --self.iState = clamp_v(self.iState, self.iMin, self.iMax)
	end
	
	--echo("iState "..self.iState)
	-- compute rate of change of error
	self.dState = pos - self.lastPos
	--echo("dState "..self.dState)
	self.lastPos = pos
	--echo("lastPos "..self.lastPos)
		
	--echo("pGain "..self.pGain)
	--echo("iGain "..self.iGain)
	--echo("dGain "..self.dGain)
	
	-- compute response
	--local response = self.pGain*err + self.iGain*self.iState + self.dGain*self.dState;
	--echo("response "..response)
	return self.pGain*err + self.iGain*self.iState + self.dGain*self.dState;
end
