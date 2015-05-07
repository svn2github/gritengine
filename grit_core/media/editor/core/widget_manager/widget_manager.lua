------------------------------------------------------------------------------
--  This is the widget manager class, creates and manages the widget object
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- returns all objects from a physics_cast
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
	selectedObj = nil;
	lastobj = nil;
	widget = nil;
	strdrag = nil;
	translate_mode = "global";
};

function wm_callback()
	local cray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local _, b = physics_cast(main.camPos, cray, true, 0)

	-- mouse over
	if b ~= nil then
		if b.owner.wc ~= nil then
			-- widget_manager.lastobj.instance.gfx:setMaterial(`../arrows/line`, widget_manager.lastobj.instance.defmat)
		end

		widget_manager.lastobj = b.owner
		if b.owner.wc ~= nil then
			-- b.owner.instance.gfx:setMaterial(`../arrows/line`, `../arrows/line_dragging`)
		end
	elseif widget_manager.lastobj ~= nil then
		widget_manager.lastobj = nil
	else
		widget_manager.lastobj = nil
	end

	-----------------------------------------------------------------------
	-- widget dragging
	if widget_manager.msinitpos ~= nil and widget_manager.widget.instance ~= nil then
		local diff = (mouse_pos_abs - widget_manager.msinitpos)

		local objtocameradist = #(main.camPos - widget_manager.widget.instance.pivot.localPosition)
		local mk = main.camPos + objtocameradist * gfx_screen_to_world(main.camPos, main.camQuat, diff)
		
		if widget_manager.widget.instance ~= nil and widget_manager.strdrag ~= nil then
			if widget_manager.mode == 1 then
				if widget_manager.strdrag == "x" then
					widget_manager.widget.instance.pivot.localPosition = vec(mk.x, widget_manager.widget.instance.pivot.localPosition.y, widget_manager.widget.instance.pivot.localPosition.z)
				elseif widget_manager.strdrag == "y" then
					widget_manager.widget.instance.pivot.localPosition = vec(widget_manager.widget.instance.pivot.localPosition.x, mk.y, widget_manager.widget.instance.pivot.localPosition.z)
				elseif widget_manager.strdrag == "z" then
					widget_manager.widget.instance.pivot.localPosition = vec(widget_manager.widget.instance.pivot.localPosition.x, widget_manager.widget.instance.pivot.localPosition.y, mk.z)
				end
				
				if widget_manager.strdrag == "xy" then
					widget_manager.widget.instance.pivot.localPosition = vec(mk.x, mk.y, widget_manager.widget.instance.pivot.localPosition.z)
				elseif widget_manager.strdrag == "xz" then
					widget_manager.widget.instance.pivot.localPosition = vec(mk.x, widget_manager.widget.instance.pivot.localPosition.y, mk.z)
				elseif widget_manager.strdrag == "yz" then
					widget_manager.widget.instance.pivot.localPosition = vec(widget_manager.widget.instance.pivot.localPosition.x, mk.y, mk.z)
				end
			elseif widget_manager.mode == 2 then
				local function rotate(x,y,z)
					widget_manager.widget.instance.pivot.localOrientation = widget_manager.objInitialOrientation * quat(diff.x + diff.y, vector3(x,y,z))
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
	if self.widget ~= nil then safe_destroy(self.widget)end
	if self.translate_mode == "global" and self.mode ~= 2 then mrot = quat(1, 0, 0, 0) end
	
	local mrotating = nil
	
	if self.mode == 2 then
		mrotating = true
	end

	self.widget = object (`widget`) (pos) { name = "widget_obj", mode = self.mode, rot = mrot, rotating = mrotating }
	self.widget:activate()
end

function widget_manager:set_mode(mode)
	self.mode = mode

	if self.widget ~= nil and self.widget.instance ~= nil and self.widget.instance.dragged ~= nil and self.widget.instance.dragged.instance ~= nil then
		local lc, rt = self.widget.instance.dragged.instance.body.worldPosition, self.widget.instance.dragged.instance.body.worldOrientation
		self.dragged = self.widget.instance.dragged
		safe_destroy(self.widget)
		self:enablewidget(lc, rt)
		self.dragged = nil
	end
end

function widget_manager:unselect()
	if self.selectedObj ~= nil and self.selectedObj.instance ~= nil then
		self.selectedObj.instance.gfx.wireframe = false
	end
	editor_interface.statusbar.selected.text = "None"
	self.selectedObj = nil

	safe_destroy(self.widget)
end

function widget_manager:select(mode)
    if mode == false then
		self.strdrag = nil
		-- main.frameCallbacks:removeByName("widget_manager")
		self.objInitialOrientation = nil
	else

		local cray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
		
		if self.selectedObj == nil then
			local _, b = physics_cast(main.camPos, cray, true, 0)
			if b ~= nil then
				self.selectedObj = b.owner
				editor_interface.statusbar.selected.text = self.selectedObj.name
				self.selectedObj.instance.gfx.wireframe = true
				self:enablewidget(self.selectedObj.instance.body.worldPosition, self.selectedObj.instance.body.worldOrientation)
				self.widget.instance.dragged = self.selectedObj

			end
		else
			local objlst = get_pc_ol(physics_cast(main.camPos, cray, false, 0))

			if objlst ~= nil then
				local wcc = nil
				
				for i = 1, #objlst do
					if objlst[i].wc ~= nil then
						wcc = objlst[i].wc
						break
					end
				end
				-- if is a widget component
				if wcc ~= nil then
					self.strdrag = wcc
					if self.mode == 1 then
						local gh = gfx_world_to_screen(main.camPos, main.camQuat, self.widget.instance.pivot.localPosition)
						self.msinitpos = mouse_pos_abs - vec2(gh.x, gh.y)
					elseif self.mode == 2 then
						self.msinitpos = mouse_pos_abs
						self.objInitialOrientation = self.widget.instance.pivot.localOrientation
					end
					-- self.objinitpos = self.widget.instance.pivot.localPosition
					input_filter_set_cursor_hidden(true)
				elseif self.selectedObj.instance ~= nil and self.selectedObj ~= self.lastobj then
					self.selectedObj.instance.gfx.wireframe = false
					self.selectedObj = self.lastobj
					editor_interface.statusbar.selected.text = self.selectedObj.name
					self.selectedObj.instance.gfx.wireframe = true
					self:enablewidget(self.selectedObj.instance.body.worldPosition, self.selectedObj.instance.body.worldOrientation)
					self.widget.instance.dragged = self.selectedObj
				end
			else
				self:unselect()
			end
		end	
	end
end

main.frameCallbacks:insert("widget_manager", wm_callback)
