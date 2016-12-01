-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- MATERIALS
-- the plane
material `face` {
	diffuseMask = vec(1, 0.5, 0),
	backfaces = true,
	alphaMask = 0.0,
    sceneBlend = "ALPHA",
}
-- the plane dragging
material `face_dragging` {
	diffuseMask = vec(1, 1, 0),
	backfaces = true,
	alphaMask = 0.5,
    sceneBlend = "ALPHA",
}
-- plane line 1
material `line_1` {
	diffuseMask = vec(0, 1, 0),
	emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}
-- plane line 2
material `line_2` {
	diffuseMask = vec(1, 0, 0),
	emissiveMask = vec(1, 0, 0),
    additionalLighting = true,
}
-- all arrows line material
material `line` {
	diffuseMask = vec(0, 1, 0),
	emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `yellow` {
	diffuseMask = vec(1, 1, 0),
	emissiveMask = vec(1, 1, 0),
    additionalLighting = true,
}
-- all arrows `arrow` material
material `arrow` {
	diffuseMask = vec(0, 1, 0),
	emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `green` {
	diffuseMask = vec(0, 1, 0),
	emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `red` {
	diffuseMask = vec(1, 0, 0),
	emissiveMask = vec(1, 0, 0),
    additionalLighting = true,
}

material `blue` {
	diffuseMask = vec(0, 0, 1),
	emissiveMask = vec(0, 0, 1),
    additionalLighting = true,
}
-- CLASSES
class `dummy_plane` (BaseClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_translate` (BaseClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_scale` (BaseClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_rotate` (BaseClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}

--[[
-- These Ogre materials no-longer exist, we will have to figure out another way of rendering on top.
get_material(`green`):setDepthBias(0, 0, 50000, 50000)
get_material(`red`):setDepthBias(0, 0, 50000, 50000)
get_material(`blue`):setDepthBias(0, 0, 50000, 50000)

get_material(`arrow`):setDepthBias(0, 0, 50000, 50000)
get_material(`line`):setDepthBias(0, 0, 50000, 50000)

get_material(`face`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_1`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_2`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_dragging`):setDepthBias(0, 0, 50000, 50000)
]]

class `widget` {} {

    renderingDistance = 10000;
	editorObject = true;
	
    init = function (self)

    end;

    activate = function (self, instance)

		self:updateArrows(self.rot)
        self:updatePivot(self.spawnPos, self.rot)
		
		instance.scale = 1
		
		instance.pivotInitialOrientation = self.rot
		
    end;

	setMaterial = function(self, component, highlight)
		local inst = self.instance

		if valid_object(inst[component]) then
			if not highlight then
				if #component == 1 then
					inst[component].instance.gfx:setMaterial(`line`, inst[component].defmat)
				elseif #component == 2 then
					inst[component].instance.gfx:setMaterial(`line_1`, inst[component].defmat1)
					inst[component].instance.gfx:setMaterial(`line_2`, inst[component].defmat2)
					inst[component].instance.gfx:setMaterial(`face`, `face`)
					
					inst[component:sub(1, 1)].instance.gfx:setMaterial(`line`, inst[component:sub(1, 1)].defmat)
					inst[component:sub(2, 2)].instance.gfx:setMaterial(`line`, inst[component:sub(2, 2)].defmat)
				end
			else
				if #component == 1 then
					inst[component].instance.gfx:setMaterial(`line`, `yellow`)
				elseif #component == 2 then
					inst[component].instance.gfx:setMaterial(`line_1`, `yellow`)
					inst[component].instance.gfx:setMaterial(`line_2`, `yellow`)
					inst[component].instance.gfx:setMaterial(`face`, `face_dragging`)
					
					inst[component:sub(1, 1)].instance.gfx:setMaterial(`line`, `yellow`)
					inst[component:sub(2, 2)].instance.gfx:setMaterial(`line`, `yellow`)
				end
			end
		end
	end;
	
	updateArrows = function(self, pivot_or)
		local instance = self.instance

		if instance.mode == nil then instance.mode = "translate" end
		if self.mode ~= nil then instance.mode = self.mode end
		
		if self.rotating ~= nil then instance.rotating = self.rotating end

		instance.mode = widget_manager.mode

		if valid_object(instance.x) then
			instance.x:destroy()
		end
		
		instance.x = object (`arrow_`..instance.mode) (0, 0, 0) {name = "widget_x"}
		instance.x:activate()
		instance.x.instance.gfx.localOrientation = pivot_or * euler(0, 0, -90)
		instance.x.instance.gfx:setMaterial(`arrow`, `red`)
		instance.x.instance.gfx:setMaterial(`line`, `red`)
		instance.x.defmat = `red`
		instance.x.wc = "x"

		if valid_object(instance.y) then
			instance.y:destroy()
		end
		
		instance.y = object (`arrow_`..instance.mode) (0, 0, 0) {name = "widget_y"}
		instance.y:activate()
		instance.y.instance.gfx:setMaterial(`arrow`, `green`)
		instance.y.instance.gfx:setMaterial(`line`, `green`)
		instance.y.defmat = `green`
		instance.y.wc = "y"

		if valid_object(instance.z) then
			instance.z:destroy()
		end
		
		instance.z = object (`arrow_`..instance.mode) (0, 0, 0) {name = "widget_z"}
		instance.z:activate()
		instance.z.instance.gfx.localOrientation = pivot_or * euler(90, 0, -90)
		instance.z.instance.gfx:setMaterial(`arrow`, `blue`)
		instance.z.instance.gfx:setMaterial(`line`, `blue`)
		instance.z.defmat = `blue`
		instance.z.wc = "z"

		if valid_object(instance.xy) then
			instance.xy:destroy()
		end

		if valid_object(instance.xz) then
			instance.xz:destroy()
		end
		
		if valid_object(instance.yz) then
			instance.yz:destroy()
		end

		if instance.mode == "translate" or instance.mode == "scale" then
			instance.xy = object `dummy_plane` (0, 0, 0) {name = "widget_xy"}
			instance.xy:activate()
			instance.xy.instance.gfx.localOrientation = pivot_or
			instance.xy.defmat1 = `green`
			instance.xy.defmat2 = `red`
			instance.xy.wc = "xy"

			instance.xz = object `dummy_plane` (0, 0, 0) {name = "widget_xz"}
			instance.xz:activate()
			instance.xz.instance.gfx.localOrientation = pivot_or * euler(0, -90, -90)
			instance.xz.instance.gfx:setMaterial(`line_1`, `red`)
			instance.xz.instance.gfx:setMaterial(`line_2`, `blue`)
			instance.xz.defmat1 = `red`
			instance.xz.defmat2 = `blue`
			instance.xz.wc = "xz"
	
			instance.yz = object `dummy_plane` (0, 0, 0) {name = "widget_yz"}
			instance.yz:activate()
			instance.yz.instance.gfx.localOrientation = pivot_or * euler(90, 0, 90)
			instance.yz.instance.gfx:setMaterial(`line_1`, `blue`)
			instance.yz.instance.gfx:setMaterial(`line_2`, `green`)
			instance.yz.defmat1 = `blue`
			instance.yz.defmat2 = `green`
			instance.yz.wc = "yz"
		end
	end;

    deactivate = function (self)
		local instance = self.instance
		instance.x:destroy()
		instance.y:destroy()
		instance.z:destroy()
		if instance.mode == "translate" or instance.mode == "scale" then
			instance.xy:destroy()
			instance.xz:destroy()
			instance.yz:destroy()
		end
    end;	

	setOrientation = function(self, orientation)
		local inst = self.instance
        self.widgetOrientation = orientation
		
		if inst.x.instance and inst.y.instance and inst.z.instance then
			inst.x.instance.gfx.localOrientation = orientation * euler(0, 0, -90)
			inst.y.instance.gfx.localOrientation = orientation
			inst.z.instance.gfx.localOrientation = orientation * euler(90, 0, -90)
		end
		if (inst.mode == "translate" or inst.mode == "scale") and
		(inst.xy.instance and inst.xz.instance and inst.yz.instance) then
			inst.xy.instance.gfx.localOrientation = orientation
			inst.xz.instance.gfx.localOrientation = orientation * euler(0, -90, -90)
			inst.yz.instance.gfx.localOrientation = orientation * euler(90, 0, 90)				
		end
	end;

    updatePivot = function (self, new_position, new_orientation)

		local inst = self.instance

		local scale = ((2 * math.tan(math.rad(gfx_option("FOV")) / 2)) * #(main.camPos - new_position))*0.025
		local vecsize = scale * vec(1, 1, 1)

		if inst.x.instance and inst.y.instance and inst.z.instance then
			inst.x.instance.gfx.localPosition = new_position
			inst.y.instance.gfx.localPosition = new_position
			inst.z.instance.gfx.localPosition = new_position
			
			inst.x.instance.gfx.localOrientation = new_orientation * euler(0, 0, -90)
			inst.y.instance.gfx.localOrientation = new_orientation
			inst.z.instance.gfx.localOrientation = new_orientation * euler(90, 0, -90)
			
			inst.x.instance.gfx.localScale = vecsize
			inst.y.instance.gfx.localScale = vecsize
			inst.z.instance.gfx.localScale = vecsize
		end
		
		if (inst.mode == "translate" or inst.mode == "scale") and
		(inst.xy.instance and inst.xz.instance and inst.yz.instance) then
			inst.xy.instance.gfx.localPosition = new_position
			inst.xz.instance.gfx.localPosition = new_position
			inst.yz.instance.gfx.localPosition = new_position
			
			inst.xy.instance.gfx.localScale = vecsize
			inst.xz.instance.gfx.localScale = vecsize
			inst.yz.instance.gfx.localScale = vecsize
		end

        self.widgetPosition = new_position
        self.widgetOrientation = new_orientation
		
        if widget_manager.strdrag ~= nil then
            local editor = game_manager.currentMode
            for i, obj in ipairs(widget_manager.selectedObjs) do
                local obj_initial_pos = editor.map:getPosition(obj)
                local dpos = new_position - widget_manager.initialPosition * 2 + obj_initial_pos

                local new_pos
                if input_filter_pressed("Ctrl") then
                    new_pos = vec(
                        math.floor(dpos.x / widget_manager.step_size) * widget_manager.step_size + obj_initial_pos.x,
                        math.floor(dpos.y / widget_manager.step_size) * widget_manager.step_size + obj_initial_pos.y,
                        math.floor(dpos.z / widget_manager.step_size) * widget_manager.step_size + obj_initial_pos.z
                    )
                else
                    new_pos = widget_manager.initialPosition - obj_initial_pos + new_position
                end
                
                editor.map:proposePosition(obj, new_pos)
            end
        end
    end,
	
	rotate = function(self, rot)
        local editor = game_manager.currentMode
		local inst = self.instance

		if widget_manager.space_mode == "local" then
			self.widgetOrientation = inst.pivotInitialOrientation * rot
		else
			self.widgetOrientation = rot * inst.pivotInitialOrientation
		end
		
		for i, obj in ipairs(widget_manager.selectedObjs) do
            editor.map:proposeOrientation(obj, editor.map:getOrientation(obj) * rot)
		end
	end;
	
	setInitialOrientation = function(self)
		inst.pivotInitialOrientation = self.widgetOrientation
	end;

	highlight = function(self, component)
		if component == nil then
			if self.instance.highlighted then
				self:setMaterial(self.instance.highlighted, false)
				self.instance.highlighted = nil
			end
			return
		end
		local c_obj = self.instance[component]
			if c_obj and not c_obj.destroyed and c_obj.instance then
			if self.instance.highlighted then
				self:setMaterial(self.instance.highlighted, false)
			end
			self.instance.highlighted = component
			self:setMaterial(component, true)
		end
	end;
}
