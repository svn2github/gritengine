------------------------------------------------------------------------------
--  History, Undo/Redo
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- NOT FULLY TESTED

history = {}

function history.new()
	local self =
	{
		actions = {};
		current_position = 0;
		max = 256;
	}
	make_instance(self, history)
	return self
end;

function history:register(redo, undo, name)
	if #self.actions ~= self.current_position then
		for i = self.current_position+1, #self.actions do
			self.actions[i] = nil
		end
	end
	
	if #self.actions >= self.max then
		table.remove(self.actions, 1)
	else
		self.current_position = self.current_position + 1
	end
	
	self.actions[#self.actions+1] = {}
	self.actions[#self.actions].name = name
	self.actions[#self.actions].redo = redo
	self.actions[#self.actions].undo = undo
end

function history:undo()
	if self.current_position >= 1 then
		self.actions[self.current_position].undo()
		self.current_position = self.current_position - 1
	end
end

function history:redo()
	if not (self.current_position+1 > #self.actions) then
		self.current_position = self.current_position + 1
		self.actions[self.current_position].redo()
	end
end