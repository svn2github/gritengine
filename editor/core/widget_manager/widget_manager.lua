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
	highlight_widget = false;
};

function wm_callback()
	if widget_manager.highlight_widget then
		-- local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
		-- local _, b = physics_cast(main.camPos, ray, true, 0)

		-- if b ~= nil and b.owner ~= nil then
			-- if b.owner.wc ~= nil then
				-- widget_manager.lastobj.instance.gfx:setMaterial(`../arrows/line`, widget_manager.lastobj.instance.defmat)
			-- end

			-- widget_manager.lastobj = b.owner
			-- if b.owner.wc ~= nil then
				-- b.owner.instance.gfx:setMaterial(`../arrows/line`, `../arrows/line_dragging`)
			-- end
		-- else
			-- widget_manager.lastobj = nil
		-- end
	end
	
	-- widget dragging
	if widget_manager.msinitpos ~= nil and valid_object(widget_manager.widget) then
		local mouse_delta = (mouse_pos_abs - widget_manager.msinitpos)

		local pivot_pos = widget_manager.widget.instance.pivot.localPosition
		
		local objtocameradist = #(main.camPos - pivot_pos)
		local mk = main.camPos + objtocameradist * gfx_screen_to_world(main.camPos, main.camQuat, mouse_delta)
		
		if widget_manager.strdrag ~= nil then
			if widget_manager.mode == 1 then
				local pos = pivot_pos
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
						-- widget_manager.widget.instance.pivot.localOrientation = widget_manager.objInitialOrientation * quat(mouse_delta.x + mouse_delta.y, vector3(x,y,z))
						widget_manager.widget:rotate(quat(mouse_delta.x + mouse_delta.y, vec(x,y,z)))
					end
				end

				-- TODO: 1 or -1 depends of camera angle
				if widget_manager.strdrag == "y" then
					rotate(0,1,0)
				elseif widget_manager.strdrag == "z" then
					rotate(0,0,1)
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

	if valid_object(self.widget) and self.widget.instance.dragged ~= nil and self.widget.instance.dragged[1].instance ~= nil then
		self.widget.rotating = self.mode == 2
		local lc, rt = self.widget.instance.dragged[1].instance.body.worldPosition, self.widget.instance.dragged[1].instance.body.worldOrientation
		self.dragged = self.widget.instance.dragged

		self.widget:updateArrows()
		
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
			if self.selectedObjs[i] ~= nil and self.selectedObjs[i].instance ~= nil and self.selectedObjs[i].instance.gfx ~= nil and not self.selectedObjs[i].destroyed then
				self.selectedObjs[i].instance.gfx.wireframe = false
			end
		end
		self.selectedObjs = nil
	end
	
	self.setEditorToolbar("Selected: none")
	safe_destroy(self.widget)
end

function widget_manager:startDragging(widget_component)
	if not valid_object(self.widget) then return end
	self.strdrag = widget_component
	if self.mode == 1 then
		local gh = gfx_world_to_screen(main.camPos, main.camQuat, self.widget.instance.pivot.localPosition)
		
		self.msinitpos = mouse_pos_abs - vec(gh.x, gh.y)
	elseif self.mode == 2 then
		self.msinitpos = mouse_pos_abs
		---------------self.objInitialOrientation = self.widget.instance.pivot.localOrientation
		self.widget:setInitialOrientations()
	end
	self.objinitpos = self.widget.instance.pivot.localPosition
	input_filter_set_cursor_hidden(true)	
end

function widget_manager:calcOffsets()
	self.offsets = {}
	for i = 1, #self.selectedObjs do
		if valid_object(self.selectedObjs[i]) then
			self.offsets[i] = self.selectedObjs[i].instance.body.worldPosition-self.widget.instance.pivot.localPosition
		end
	end
end

function widget_manager:calcCentreOffsets()
	-- calc the middle point
	local mid_point = vec(0, 0, 0)

	for i = 1, #self.selectedObjs do
		if valid_object(self.selectedObjs[i]) then
			mid_point = mid_point + self.selectedObjs[i].instance.body.worldPosition
		end
	end

	mid_point = mid_point / #self.selectedObjs

	-- set offsets
	self.offsets = {}
	for i = 1, #self.selectedObjs do
		if valid_object(self.selectedObjs[i]) then
			self.offsets[i] = self.selectedObjs[i].instance.body.worldPosition-mid_point
		end
	end
	return mid_point
end

-- TODO: select objects without collision
-- local objs = object_all()
-- for k, v in ipairs(objs) do
-- end

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
		
		if valid_object(self.widget) then
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
			if valid_object(self.selectedObjs[i]) then
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

		-- self:enablewidget(b.owner.instance.body.worldPosition, b.owner.instance.body.worldOrientation)
		
		if valid_object(self.widget) then
			self.widget.instance.pivot.localPosition = b.owner.instance.body.worldPosition
			self.widget.instance.pivot.localOrientation = b.owner.instance.body.worldOrientation
			
			if self.pivot_center == "active object" then
				self:calcOffsets()
			else
				self.widget.instance.pivot.localPosition = self:calcCentreOffsets()
			end
			
			if valid_object(self.widget) then
				self.widget.instance.dragged = self.selectedObjs
			end
		end
	end	
end

function widget_manager:selectAll()
	local objs = object_all()
	
	for i = 1, #objs do
		local b = objs[i]
		if valid_object(b) then
			if self.selectedObjs == nil then self.selectedObjs = {} end
			local isonthelist = false
			for i = 1, #self.selectedObjs do
				if valid_object(self.selectedObjs[i]) then
					if self.selectedObjs[i] == b then
						isonthelist = true
					end
				end
			end
			if not isonthelist then
				self.selectedObjs[#self.selectedObjs+1] = b
			end

			b.instance.gfx.wireframe = true
			if valid_object(self.widget) then
				self.widget.instance.pivot.localPosition = b.instance.body.worldPosition
				self.widget.instance.pivot.localOrientation = b.instance.body.worldOrientation
				
				if self.pivot_center == "active object" then
					self:calcOffsets()
				else
					self.widget.instance.pivot.localPosition = self:calcCentreOffsets()
				end
				
				self.widget.instance.dragged = self.selectedObjs
			end
		end	
	end
end

-- Reference: http://gamedev.stackexchange.com/questions/18436/most-efficient-aabb-vs-ray-collision-algorithms by Jeroen Baert
function intersectRayAABoxV(origin, direction, p1, p2)
    local t1, t2 = {}, {}
    local t_near, t_far = -1000, 1000

	-- we test slabs in every direction
	local axis = { "x", "y", "z" }
	local i = axis[1]
	
    for j = 1, 3 do
		i = axis[j]
		-- ray parallel to planes in this direction
        if (direction[i] == 0) then
            if ((origin[i] < p1[i]) or (origin[i] > p2[i])) then
                return false -- parallel and outside box: no intersection possible
            end
		else
			-- ray not parallel to planes in this direction
            t1[i] = (p1[i] - origin[i]) / direction[i]
            t2[i] = (p2[i] - origin[i]) / direction[i]

			-- we want t1 to hold values for intersection with near plane
            if(t1[i] > t2[i]) then
                local tmpv = t1
				t1 = t2
				t2 = tmpv
            end
            if (t1[i] > t_near) then
                t_near = t1[i]
            end
            if (t2[i] < t_far) then
                t_far = t2[i]
            end
            if( (t_near > t_far) or (t_far < 0) ) then
                return false
            end
        end
    end

    return true, t_near, t_far
end

function widget_manager:bbMouseSelect(pos, rot, scale)
	local iq = inv(rot)
	-- move our stuff to origin to calculate it properly
	local deltapos = main.camPos - pos
	-- rotates the camera position around using the widget orientation
	local ppos =  (iq*deltapos)+pos
	-- new camera orientation rotated by the widget orientation
	local rrot =  iq * main.camQuat

	local dir = 1000 * gfx_screen_to_world(ppos, rrot, mouse_pos_abs)
	local bmin, bmax = pos -scale/2, pos+scale/2
	return intersectRayAABoxV(ppos, dir, bmin, bmax)
end

function widget_manager:select(mode, multi)
    if mode == false then
		self.strdrag = nil
		self.objInitialOrientation = nil
	else
		if self.selectedObjs == nil then -- simple selection
			self:selectSingleObject()
		else
			local wfound = nil
			if valid_object(self.widget) then
				-- Check if mouse is pointing at the widget
				local wi = self.widget.instance
				local axm = { "x_a", "y_a", "z_a" }
				local dxm = { "dummy_xy", "dummy_xz", "dummy_yz" }
				local lastdistance = nil
				
				local scale = self.widget.instance.scale
				for i = 1, 3 do
					local posit, orient
					local offset, offset2
					if valid_object(wi[axm[i]]) then
						posit, orient  = wi[axm[i]].instance.gfx.localPosition, wi[axm[i]].instance.gfx.localOrientation
						offset, offset2 = orient * (4*scale * V_FORWARDS), orient * (7*scale * V_FORWARDS) -- arrow base, arrow
						
						local kq, kna = self:bbMouseSelect(posit+offset, orient, vec(0.25, 8, 0.25)*scale)
						if not kq then
							kq, kna = self:bbMouseSelect(posit+offset2, orient, vec(0.8, 2, 0.8)*scale)
						end
						
						if kq and (lastdistance == nil or kna < lastdistance)  then
							wfound = i == 1 and "x" or i == 2 and "y" or i == 3 and "z"
							lastdistance = kna
						end
					end
					
					if valid_object(wi[dxm[i]]) then
						posit, orient  = wi[dxm[i]].instance.gfx.localPosition, wi[dxm[i]].instance.gfx.localOrientation
						offset = (orient * V_FORWARDS*scale) + (i == 1 and (V_RIGHT*scale) or i == 2 and (V_UP*scale) or i == 3 and (V_FORWARDS*scale))

						local _, knd = self:bbMouseSelect(posit+offset, orient, vec(2, 2, 0.1)*scale)

						if knd and (lastdistance == nil or knd < lastdistance) then
							wfound = i == 1 and "xy" or i == 2 and "xz" or i == 3 and "yz"
							lastdistance = knd
						end
					end
				end
			end
			if wfound then
				self:startDragging(wfound)
			-- otherwise select other object
			else
				if not multi then
					self:selectSingleObject()
				elseif multi then
					self:addObject()
				end
			end
		end	
	end
end

main.frameCallbacks:insert("widget_manager", wm_callback)