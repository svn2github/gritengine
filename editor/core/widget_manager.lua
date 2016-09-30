------------------------------------------------------------------------------
--  This is the widget manager class, creates and manages the widget object
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO:
-- Select objects without collision
-- Select sounds, particles

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

local dummy_bounds = vec(2, 2, 0.2)
local arrow_bounds = vec(1, 8, 1)

widget_manager = {
	mode = "translate";
	selectedObjs = nil;
	offsets = {};
	rotationOffsets = {};
	initialPosition = vec(0, 0, 0);
	lastobj = nil;
	widget = nil;
	strdrag = nil;
	space_mode = "local"; -- "world", "local"
	pivot_center = "active object"; -- "individual origins", "active object" or "center point"
	step_size = 0.5;
	highlight_widget = true;
};

-- reference: math_geom.c from Blender
function isect_line_plane(line_a, line_b, plane_pos, plane_normal)
	local u = line_b - line_a
	local dot_p = dot(plane_normal, u)

	if math.abs(dot_p) > 1e-6 then
		local w = line_a - plane_pos
		local fac = -dot(plane_normal, w) / dot_p
		u = u * fac
		return line_a + u
	else -- parallel to plane
		return
	end
end

function widget_manager:enablewidget(pos, mrot)
	if self.widget ~= nil then safe_destroy(self.widget) main.frameCallbacks:removeByName("widget_manager") end
	if self.space_mode == "world" then
		mrot = Q_ID
	end
	
	self.widget = object (`/editor/assets/widget`) (pos) { name = "widget_obj", mode = self.mode, rot = mrot, rotating = self.mode == "rotate" }
	self.widget:activate()
	self.initialPosition = pos
	main.frameCallbacks:insert("widget_manager", wm_callback)
end

function widget_manager:setSpaceMode(mode)
	self.space_mode = mode
	if self.widget and self.widget.instance and valid_object(self.selectedObjs[1]) then
		if mode == "world" then
			self.widget:setOrientation(Q_ID)
		else
			self.widget:setOrientation(self.selectedObjs[1].instance.body.worldOrientation)
		end
	end
end

function widget_manager:set_mode(mode)
	self.mode = mode

	if valid_object(self.widget) and self.widget.instance.dragged ~= nil and self.widget.instance.dragged[1].instance ~= nil then
		self.widget.rotating = self.mode == "rotate"
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
	physics_update()
	main.frameCallbacks:insert("widget_manager", wm_callback)
end

function widget_manager:stopDragging()
	input_filter_set_cursor_hidden(false)
    self:select(false)
	-- self.initialPosition = self.widget.instance.pivot.localPosition
	-- self.selectedObjs[1].initialPosition = self.selectedObjs[1].instance.body.worldPosition
	-- self.selectedObjs[1].initialOrientation = self.selectedObjs[1].instance.body.worldOrientation
end

function widget_manager:startDragging(widget_component)
	if not valid_object(self.widget) then return end
	self.strdrag = widget_component
	if self.mode == "translate" then
		local gh = gfx_world_to_screen(main.camPos, main.camQuat, self.widget.instance.pivot.localPosition)
		
		self.initialobjposdelta = self.widget.instance.pivot.localPosition - isect_line_plane(main.camPos,
			main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs),
			self.widget.instance.pivot.localPosition,
			self.widget.instance[self.strdrag].instance.gfx.localOrientation*V_UP
		)
		
		self.msinitpos = mouse_pos_abs - vec(gh.x, gh.y)
	elseif self.mode == "rotate" then
		self.msinitpos = mouse_pos_abs
		self.widget:setInitialOrientations()
	end
	self.objinitpos = self.widget.instance.pivot.localPosition
	-- input_filter_set_cursor_hidden(true)	
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
	local mid_point = V_ZERO

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

function widget_manager:selectSingleObject()
	self:unselectAll()

	-- self.offsets[1] = vec(0, 0, 0)

	local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local _, b = physics_cast(main.camPos, ray, true, 0)
	-- local b2 = self:selectNonPhysicalObjects()
	
	-- if b2 then
		-- if b and b.owner then
			-- if b.owner.instance and b.owner.instance then
				-- if #(main.camPos - b.owner.instance.body.worldPosition) > #(main.camPos - b2.pos) then
				
				-- end
			-- end
		-- end
	-- end
	
	if b ~= nil then
		local selected = b.owner
		selected.initialPosition = selected.instance.body.worldPosition
		selected.initialOrientation = selected.instance.body.worldOrientation

		self:setEditorToolbar("Selected: "..selected.name)
		
		selected.instance.gfx.wireframe = true
		
		self:enablewidget(selected.instance.body.worldPosition, selected.instance.body.worldOrientation)
		
		if self.selectedObjs == nil then self.selectedObjs = {} end
		self.selectedObjs[1] = selected
		
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
			self.selectedObjs[#self.selectedObjs].initialPosition = self.selectedObjs[#self.selectedObjs].instance.body.worldPosition
			self.selectedObjs[#self.selectedObjs].initialOrientation = self.selectedObjs[#self.selectedObjs].instance.body.worldOrientation
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
				self.selectedObjs[#self.selectedObjs].initialPosition = self.selectedObjs[#self.selectedObjs].instance.body.worldPosition
				self.selectedObjs[#self.selectedObjs].initialOrientation = self.selectedObjs[#self.selectedObjs].instance.body.worldOrientation
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

-- a bounding box ray tracer
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

function widget_manager:selectNonPhysicalObjects()
	local obj = nil

	for k, v in ipairs(object_all()) do
		if v and v.instance and not v.destroyed()  then
			if v.instance.body == nil then
				local found = nil
				if v.instance.gfx then
					-- found = self:bbMouseSelect(v.pos, v.instance.gfx.localOrientation, v.instance.gfx.bb)
				elseif v.instance.audio then
					found = self:bbMouseSelect(v.pos, Q_ID, vec(1, 1, 1))
				end
				
				if found then
					if obj == nil then
						obj = v
					elseif (#(main.camPos - v.pos) < #(main.camPos - obj.pos)) then
						obj = v
					end
				end
			end
		end
	end
	return obj
end

function widget_manager:rayCastToWidget()
	local obj = nil
	local lastdistance = nil
	if self.widget == nil then return end
	if self.widget.instance == nil then return end
	local scale = self.widget.instance.scale
	
	for i = 1, 3 do
		local pos, orient
		local offset
			
		local wi = self.widget.instance
		local axm = { "x", "y", "z" }
		local dxm = { "xy", "xz", "yz" }
		
		-- arrows
		if valid_object(wi[axm[i]]) then
			pos, orient  = wi[axm[i]].instance.gfx.localPosition, wi[axm[i]].instance.gfx.localOrientation
			offset = orient * (4 * scale * V_FORWARDS)
			
			local kq, kna = self:bbMouseSelect(pos + offset, orient, arrow_bounds * scale)

			if kq and (lastdistance == nil or kna < lastdistance)  then
				obj = i == 1 and "x" or i == 2 and "y" or i == 3 and "z"
				lastdistance = kna
			end
		end
		
		-- dummies
		if valid_object(wi[dxm[i]]) then
			pos, orient  = wi[dxm[i]].instance.gfx.localPosition, wi[dxm[i]].instance.gfx.localOrientation

			offset =  ((orient * V_RIGHT) + (orient * V_FORWARDS)) * scale
			
			local _, knd = self:bbMouseSelect(pos + offset, orient, dummy_bounds * scale)
			
			if knd and (lastdistance == nil or knd < lastdistance) then
				obj = i == 1 and "xy" or i == 2 and "xz" or i == 3 and "yz"
				lastdistance = knd
			end
		end
	end
	
	return obj
end

function widget_manager:select(mode, multi)
    if mode == false then
		self.strdrag = nil
	else
		if self.selectedObjs == nil then
			self:selectSingleObject()
		else
			local widget_component = nil
			if valid_object(self.widget) then
				widget_component = self:rayCastToWidget()
			end
			
			if widget_component then
				self:startDragging(widget_component)
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

function wm_callback()
	if widget_manager.widget and not widget_manager.widget.destroyed then
	
		if widget_manager.highlight_widget and widget_manager.strdrag == nil then
			local widget_component = widget_manager.rayCastToWidget(widget_manager)
			
			if widget_component then
				widget_manager.widget:highlight(widget_component)
			else
				widget_manager.widget:highlight()
			end
		end
		
		-- widget dragging
		if widget_manager.msinitpos ~= nil and valid_object(widget_manager.widget) then
			local mouse_delta = (mouse_pos_abs - widget_manager.msinitpos)
			local pivot_pos = widget_manager.widget.instance.pivot.localPosition

			if widget_manager.strdrag ~= nil then
				if widget_manager.mode == "translate" then
					local posx, posy, posz = pivot_pos.x,  pivot_pos.y, pivot_pos.z

					local initpos = widget_manager.objinitpos
					
					local p = isect_line_plane(
						main.camPos,
						main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs),
						initpos,
						widget_manager.widget.instance[widget_manager.strdrag].instance.gfx.localOrientation * V_UP
					) + widget_manager.initialobjposdelta

					if widget_manager.space_mode == "local" then
						local pos = V_ZERO
						local dir = widget_manager.widget.instance[widget_manager.strdrag].instance.gfx.localOrientation * V_NORTH
						local offset = (inv(widget_manager.widget.instance.pivot.localOrientation)*(p-initpos))
						
						if widget_manager.strdrag == "x" then
							pos = dir * offset.x + initpos
						elseif widget_manager.strdrag == "y" then
							pos = dir * offset.y + initpos
						elseif widget_manager.strdrag == "z" then
							pos = dir * offset.z + initpos
						elseif widget_manager.strdrag == "xy" then
							pos = p
						elseif widget_manager.strdrag == "xz" then
							pos = p
						elseif widget_manager.strdrag == "yz" then
							pos = p
						end
						
						posx, posy, posz = pos.x, pos.y, pos.z
					else -- world
						if widget_manager.strdrag == "x" then
							posx = p.x
						elseif widget_manager.strdrag == "y" then
							posy = p.y
						elseif widget_manager.strdrag == "z" then
							posz = p.z
						elseif widget_manager.strdrag == "xy" then
							posx = p.x
							posy = p.y
						elseif widget_manager.strdrag == "xz" then
							posx = p.x
							posz = p.z
						elseif widget_manager.strdrag == "yz" then
							posy = p.y
							posz = p.z
						end					
					end
					widget_manager.widget.instance.pivot.localPosition = vec(posx, posy, posz)
				elseif widget_manager.mode == "rotate" then
					local function rotate(x,y,z)
						if widget_manager.widget ~= nil and widget_manager.widget.instance ~= nil then
							widget_manager.widget:rotate(quat(mouse_delta.x + mouse_delta.y, vec(x,y,z)))
						end
					end

					-- TODO: 1 or -1 depends on camera angle
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
	else
		main.frameCallbacks:removeByName("widget_manager")
	end
end

-- main.frameCallbacks:insert("widget_manager", wm_callback)
