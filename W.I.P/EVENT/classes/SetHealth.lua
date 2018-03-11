local SetHealth = {
	name = "SetHealth";
	inputs = {"In"};
	outputs = {"Success", "Fail"};
	-- name, type
	variables = {{"target", "player"}, {"value", "float"}};
	-- input is the input value
	-- variables is in order of declaration
	-- the function returns the value of the output
	script = function(input, target, value)
		if target ~= nil then
			target.health = value
			return 1
		end
		return 2
	end;
}

event_editor:reg_node_script(SetHealth)