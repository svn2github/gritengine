------------------------------------------------------------------------------
--  This is the widget manager class, creates and manages the widget object
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- return an object list from a physics_cast
local function get_pc_ol(...)
	local t = {...}
	if t == nil then return nil end
	local it = 2
	local mobjs = {}
	for i=1, #t/4 do
		mobjs[#mobjs+1] = t[it].owner
		it = it + 4
	end
	if(next(mobjs)) then
		return mobjs
	else
		return nil
	end
end

widget_manager = {
	mode = 1;
	selectedObjs = nil;
	offsets = {};
	rotationOffsets = {};
	lastobj = nil;
	widget = nil;
	strdrag = nil;
	translate_mode = "global";
	pivot_center = "active object"; -- "individual origins", "active object" or "center point"
	grid_size = 0.1;
};

function wm_callback()
	local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local _, b = physics_cast(main.camPos, ray, true, 0)

	-- mouse over
	if b ~= nil then
		if b.owner.wc ~= nil then
			-- widget_manager.lastobj.instance.gfx:setMaterial(`../arrows/line`, widget_manager.lastobj.instance.defmat)
		end

		widget_manager.lastobj = b.owner
		if b.owner.wc ~= nil then
			-- b.owner.instance.gfx:setMaterial(`../arrows/line`, `../arrows/line_dragging`)
		end
	else
		widget_manager.lastobj = nil
	end

	-- widget dragging
	if widget_manager.msinitpos ~= nil and widget_manager.widget.instance ~= nil then
		local diff = (mouse_pos_abs - widget_manager.msinitpos)

		local objtocameradist = #(main.camPos - widget_manager.widget.instance.pivot.localPosition)
		local mk = main.camPos + objtocameradist * gfx_screen_to_world(main.camPos, main.camQuat, diff)
		
		if widget_manager.widget.instance ~= nil and widget_manager.strdrag ~= nil then
			if widget_manager.mode == 1 then
				local pos = widget_manager.widget.instance.pivot.localPosition
				local posx = pos.x
				local posy = pos.y
				local posz = pos.z
				
				if widget_manager.strdrag == "x" then
					posx = mk.x
				elseif widget_manager.strdrag == "y" then
					posy = mk.y
				elseif widget_manager.strdrag == "z" then
					posz = mk.z
				end
				
				if widget_manager.strdrag == "xy" then
					posx = mk.x
					posy = mk.y
				elseif widget_manager.strdrag == "xz" then
					posx = mk.x
					posz = mk.z
				elseif widget_manager.strdrag == "yz" then
					posy = mk.y
					posz = mk.z
				end
				widget_manager.widget.instance.pivot.localPosition = vec(posx, posy, posz)
			elseif widget_manager.mode == 2 then
				local function rotate(x,y,z)
					if widget_manager.widget ~= nil and widget_manager.widget.instance ~= nil then
						widget_manager.widget.instance.pivot.localOrientation = widget_manager.objInitialOrientation * quat(diff.x + diff.y, vector3(x,y,z))
					end
				end

				if widget_manager.strdrag == "y" then
					rotate(0,-1,0)
				elseif widget_manager.strdrag == "y" then
					rotate(0,1,0)
				elseif widget_manager.strdrag == "z" then
					rotate(0,0,1)
				elseif widget_manager.strdrag == "z" then
					rotate(0,0,-1)
				elseif widget_manager.strdrag == "x" then
					rotate(1,0,0)
				elseif widget_manager.strdrag == "x" then
					rotate(-1,0,0)
				end				
			end
		end	
	end
end

function widget_manager:enablewidget(pos, mrot)
	if self.widget ~= nil then safe_destroy(self.widget) end
	if self.translate_mode == "global" and self.mode ~= 2 then mrot = quat(1, 0, 0, 0) end
	
	self.widget = object (`widget`) (pos) { name = "widget_obj", mode = self.mode, rot = mrot, rotating = self.mode == 2 }
	self.widget:activate()
end

function widget_manager:set_mode(mode)
	self.mode = mode

	if self.widget ~= nil and self.widget.instance ~= nil and self.widget.instance.dragged ~= nil and self.widget.instance.dragged[1].instance ~= nil then
		local lc, rt = self.widget.instance.dragged[1].instance.body.worldPosition, self.widget.instance.dragged[1].instance.body.worldOrientation
		self.dragged = self.widget.instance.dragged
		safe_destroy(self.widget)
		if mode ~= 0 then
			self:enablewidget(lc, rt)
		end
		self.dragged = nil
	end
end

function widget_manager:setEditorToolbar(str)
	if editor_interface.map_editor_page.statusbar ~= nil then
		editor_interface.map_editor_page.statusbar:setText(tostring(str))
	end
end

function widget_manager:unselectAll()
	if self.selectedObjs ~= nil then
		for i = 0, #self.selectedObjs do
			if self.selectedObjs[i] ~= nil and self.selectedObjs[i].instance ~= nil then
				self.selectedObjs[i].instance.gfx.wireframe = false
			end
		end
		self.selectedObjs = nil
	end
	self.setEditorToolbar("Selected: none")
	safe_destroy(self.widget)
end


function widget_manager:startDragging(widget_component)
	self.strdrag = widget_component
	if self.mode == 1 then
		local gh = gfx_world_to_screen(main.camPos, main.camQuat, self.widget.instance.pivot.localPosition)
		
		self.msinitpos = mouse_pos_abs - vec2(gh.x, gh.y)
	elseif self.mode == 2 then
		self.msinitpos = mouse_pos_abs
		self.objInitialOrientation = self.widget.instance.pivot.localOrientation
	end
	self.objinitpos = self.widget.instance.pivot.localPosition
	input_filter_set_cursor_hidden(true)	
end


function widget_manager:calcOffsets()
	self.offsets = {}
	for i = 1, #self.selectedObjs do
		if self.selectedObjs[i] ~= nil and not self.selectedObjs[i].destroyed then
			self.offsets[i] = self.selectedObjs[i].instance.body.worldPosition-self.widget.instance.pivot.localPosition
		end
	end
end

function widget_manager:calcCentreOffsets()
	-- calc the middle point
	local mid_point = vec(0, 0, 0)

	for i = 1, #self.selectedObjs do
		if self.selectedObjs[i] ~= nil and not self.selectedObjs[i].destroyed then
			mid_point = mid_point + self.selectedObjs[i].instance.body.worldPosition
		end
	end

	mid_point = mid_point / #self.selectedObjs

	-- set offsets
	self.offsets = {}
	for i = 1, #self.selectedObjs do
		if self.selectedObjs[i] ~= nil and not self.selectedObjs[i].destroyed then
			self.offsets[i] = self.selectedObjs[i].instance.body.worldPosition-mid_point
		end
	end
	return mid_point
end

function widget_manager:selectSingleObject()
	self:unselectAll()

	self.offsets[1] = vec(0, 0, 0)

	local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local _, b = physics_cast(main.camPos, ray, true, 0)
	if b ~= nil then
		if self.selectedObjs == nil then self.selectedObjs = {} end
		self.selectedObjs[1] = b.owner
		
		self:setEditorToolbar("Selected: "..self.selectedObjs[1].name)
		
		self.selectedObjs[1].instance.gfx.wireframe = true
		
		self:enablewidget(self.selectedObjs[1].instance.body.worldPosition, self.selectedObjs[1].instance.body.worldOrientation)
		
		if self.widget ~= nil and self.widget.instance ~= nil then
			self.widget.instance.dragged = self.selectedObjs
		end
	end	
end

function widget_manager:addObject()
	local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local _, b = physics_cast(main.camPos, ray, true, 0)
	if b ~= nil then
		if self.selectedObjs == nil then self.selectedObjs = {} end
		local isonthelist = false
		for i = 1, #self.selectedObjs do
			if self.selectedObjs[i] ~= nil and not self.selectedObjs[i].destroyed then
				if self.selectedObjs[i] == b.owner then
					isonthelist = true
				end
			end
		end
		if not isonthelist then
			self.selectedObjs[#self.selectedObjs+1] = b.owner
		end
		self:setEditorToolbar("Selected: Multiple")
		b.owner.instance.gfx.wireframe = true

		self:enablewidget(b.owner.instance.body.worldPosition, b.owner.instance.body.worldOrientation)
		if self.pivot_center == "active object" then
			self:calcOffsets()
		else
			self.widget.instance.pivot.localPosition = self:calcCentreOffsets()
		end
		
		if self.widget ~= nil and self.widget.instance ~= nil then
			self.widget.instance.dragged = self.selectedObjs
		end
	end	
end

function widget_manager:select(mode, multi)
    if mode == false then
		self.strdrag = nil
		self.objInitialOrientation = nil
	else
		if self.selectedObjs == nil then -- simple selection
			self:selectSingleObject()
		else
			local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
			local objlst = get_pc_ol(physics_cast(main.camPos, ray, false, 0))

			if objlst ~= nil then
				local wcc = nil
				
				-- check if any of the traced objects is a widget component
				for i = 1, #objlst do
					if objlst[i].wc ~= nil then
						wcc = objlst[i].wc
						break
					end
				end
				
				if wcc ~= nil then -- if is a widget component, start dragging
					self:startDragging(wcc)
				elseif not multi then
					self:selectSingleObject()
				elseif multi then
					self:addObject()
				end
			else
				self:unselectAll()
			end
		end	
	end
end

main.frameCallbacks:insert("widget_manager", wm_callback)
