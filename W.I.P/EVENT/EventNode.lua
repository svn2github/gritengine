------------------------------------------------------------------------------
--  This is the Node System used by the Event Editor to run Graphical
--  programming stuff
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

local Node = {};

function Node.new(cb, vars)
	local self = {
		callback = {};
		inputs = {};
		outputs = {};
		-- hold variables names ex. "current_level.obj_01", from the
		-- LevelEditor variable nodes
		variables = {};
	};
	self.callback = cb;
	self.variables = vars;
	
	make_instance(self, Node)
	return self
end;

------------------------------------------------------------------------------
-- Add a input connector to the node
--
-- @param name          the connector name, used to create the variable name
-- @return              the input connector
-- 
------------------------------------------------------------------------------
function Node:add_input(name)
	self.inputs[#self.inputs+1] = {}
	self.inputs[#self.inputs].name = name

	return self.inputs[#self.inputs]
end;

function Node:add_output(name)
	self.outputs[#self.output+1] = {}
	self.outputs[#self.output].name = name
	self.outputs[#self.output].connections = {}
	
	return self.output[#self.output]
end;

------------------------------------------------------------------------------
-- Add a input connector to the node
--
-- @param name          the username to query.
-- 
------------------------------------------------------------------------------
function Node:set_var(name, value)
		self.variables[name].value = value
end;

function Node.start(self, connector)
	local cbarg = "return self:callback("..connector..", "
	
	for i = 1, #self.variables do
		if self.variables[i].type == "string" then
			cbarg = cbarg.."'"..self.variables[i].name.."'"
		else
			cbarg = cbarg..self.variables[i].name
		end
		
		if i ~= #self.variables then
			cbarg = cbarg..", "
		end
	end
	
	cbarg = cbarg..")"
	
	cbarg = loadstring(cbarg)
	
	local res = cbarg()
	
	-- if boolean transform to number
	if type(res) == "boolean" then
		if res == true then
			res = 1
		else
			res = 0
		end
	end
	
	-- if is a number, then have just one output
	if type(res) == "number" then
		for i = 1, #self.outputs[res].childs do
			self.outputs[res].connections[i].node:start(self.outputs[res].connections[i].id)
		end
	-- if is a table, can have multiple outputs (also a output can have many
	-- different connections)
	elseif type(res) == "table" then
		for j = 1, #res do
			for i = 1, #self.outputs[res[j]].childs do
				self.outputs[res[j]].connections[i].node:start(self.outputs[res[j]].connections[i].id)
			end
		end
	end
	
end;

------------------------------------------------------------------------------
-- Create a new node
--
-- @param name          the connector name, used to create the variable name
-- @return              the new node
-- 
------------------------------------------------------------------------------
function create_node(type)
	--local nt = EventEditor:getNodeTypeByName(type)
	
	-- TEST
	local nt = {}
	nt.variables = type
	local mvars = {}
	
	
	for i = 1, #nt.variables do
		mvars[nt.variables[i][1]] = {}
		mvars[nt.variables[i][1]].type = nt.variables[i][2]
		mvars[nt.variables[i][1]].value = ""
	end	

	return Node.new(nt.script, mvars)
end;

function connect_node(parent, parent_output, child, child_input)
	parent.outputs[parent_output].connections[#parent.outputs[parent_output].connections+1].node = child.inputs[child_input]
	parent.outputs[parent_output].connections[#parent.outputs[parent_output].connections+1].id = child_input
end;

ev = {}
ev.variables = {}




-- usage:
-- LevelStart->call(LevelStart.outputs_connections)->outputs_connections->call(outputs_connections.outputs_connections)...


-- TEST:
-- mvariables = {{"target", "player"}, {"amount", "float"}};
-- tr = create_node(mvariables)
-- tr:set_var("target", 'current_level.car_001')
-- tr:set_var("amount", 5)