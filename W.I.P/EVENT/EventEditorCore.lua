------------------------------------------------------------------------------
--  This is the Node System used by the Event Editor to run Graphical
--  programming stuff
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

EventEditor = {}

function EventEditor.new()
	local self = {
		connections = {};
		nodes = {};
		variables = {};
		node_scripts = {};
		code = {};
	}
	make_instance(self, EventEditor)
	return self
end

function EventEditor:Destroy()
	for i = 0, #nodes do
		self.nodes[i].Destroy()
	end
end

function EventEditor:reg_node_script(ns)
	if (ns ~= nil) then

		-- if (ns.name ~= nil) then
			-- self.nodes_script[#nodes_script].name = ns.name
		-- else
			-- print(RED.."Node name missing!")
			-- return false
		-- end

		-- if (ns.script ~= nil) then
			-- self.nodes_script[#nodes_script].script = ns.script
		-- else
			-- print(RED.."ns.name: ".."Node script missing!")
			-- return false
		-- end

		-- if (ns.variables ~= nil) then
			-- self.nodes_script[#nodes_script].variables = ns.variables
		-- end

		-- if (ns.in_con ~= nil) then
			-- self.nodes_script[#nodes_script].in_con = ns.inx
		-- else
			-- print(RED.."ns.name: ".."Node input connector(s) missing!")
			-- return false
		-- end

		-- if (ns.out_con ~= nil) then
			-- self.nodes_script[#nodes_script].out_con = ns.out
		-- end
		self.node_scripts[#self.node_scripts+1] = ns
	else
		return false
	end
	
	return true
end

function EventEditor:unreg_node_script(ns_name)
	for i = 0, #self.nodes_script do
		if self.nodes_script[i].name == ns_name then
			self.nodes_script[i] = nil
			return true
		end
	end
	return false
end

function EventEditor:connect(c1, c2)
	self.connections[#connections+1] = gfx_hud_object_add()
	self.connections[#connections].c1 = c1
	self.connections[#connections].c2 = c2
	self.connections[#connections]:updatePoints()
end

function EventEditor:get_node_type(nd_type)
	for i = 0, #self.node_scripts do
		if (self.node_scripts[i].name == nd_type) then
			return self.node_scripts[i]
		end
	end
	return nil
end

function EventEditor:new_node(n_type, pos)
	local nd = self:get_node_type(n_type)
	
	if nd == nil then print(RED.."Node type doesn't registered") return false end
	
	nodes[#nodes+1] = gfx_hud_object_add() { node_type = nd.name, position = pos }
	-- add in connectors
	for i = 0, #nd.in_con do
		nodes[#nodes]:addInCon(nd.in_con[i].name)
	end
	-- add out connectors
	for i = 0, #nd.out_con do
		nodes[#nodes]:addOutCon(nd.out_con[i].name)
	end
	-- add var connectors
	for i = 0, #nd.variables do
		nodes[#nodes]:addVarCon(nd.variables[i].name, nd.variables[i].type)
	end
	
	return true
end

function EventEditor:delete_node(node)
	local nodeid = {}
		
	for i = 0, #self.nodes do
		if (self.nodes[i] == node) then
			nodeid = i
			break
		end
	end
	
	node:breakAllLines()
	node:destroy()
	
	-- set nil just to make sure
	self.nodes[nodeid] = nil
end

-- function EventEditor:get_struct()
	-- local event_struct = {}
	
	-- node_struct.nodes = {}
	-- node_struct.variables = {}
	-- node_struct.connections = {}
	
	-- for i = 0, #self.nodes do
		-- node_struct.nodes[i] = {}
		-- node_struct.nodes[i].type = self.nodes[i].type
		-- node_struct.nodes[i].name = self.nodes[i].name
		-- node_struct.nodes[i].coord = { self.nodes[i].position.x, self.nodes[i].position.y }
	-- end
	
	-- for i = 0, #self.variables do
		-- node_struct.variables[i] = {}
		-- node_struct.variables[i].type = self.variables[i].type
		-- node_struct.variables[i].name = self.variables[i].name
		-- node_struct.variables[i].coord = { self.variables[i].position.x, self.variables[i].position.y }
		-- node_struct.variables[i].value = self.variables[i].value
	-- end
	
	-- for i = 0, #self.connections do
		-- node_struct.connections[i] = {}
		
		-- node_struct.connections[i].p1 = {}
		-- node_struct.connections[i].p1.node = self.connections[i].p1.node.name
		-- node_struct.connections[i].p1.connector = self.connections[i].p1.connector.name
		
		-- node_struct.connections[i].p2 = {}
		-- node_struct.connections[i].p2.node = self.connections[i].p2.node.name
		-- node_struct.connections[i].p2.connector = self.connections[i].p2.connector.name
	-- end
	
	-- return event_struct
-- end

-- function EventEditor:generate_code()
	-- self.code = {}
	-- return self.code
-- end

function EventEditor:hide()
	for i = 0, #self.nodes do
		self.nodes[i].enabled = false
	end
end

function EventEditor:show()
	for i = 0, #self.nodes do
		self.nodes[i].enabled = true
	end
end

event_editor = EventEditor.new()