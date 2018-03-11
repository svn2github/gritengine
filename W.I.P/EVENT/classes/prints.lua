local prints = {
	name = "prints";
	inputs = {"Increase", "Decrease"};
	outputs = {"Success", "Fail"};
	-- name, type
	variables = {{"target", "player"}, {"amount", "float"}};
	-- input is the input value
	-- variables is in order of declaration
	-- the function returns the value of the output
	script = function(input, target, amount)
		if target ~= nil then
			if input == 1 then
				target.health = target.health + amount
			else
				target.health = target.health - amount
			end
			return 1
		end
		return 2
	end;
}

event_editor:reg_node_script(prints)