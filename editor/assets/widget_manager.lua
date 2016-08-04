-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- MATERIALS
-- the plane
material `face` {
	diffuseColour=vec(1, 0.5, 0),
	backfaces=true,
	alpha=0.0,
	depthWrite=false,
}
-- the plane dragging
material `dragging_face` {
	diffuseColour=vec(1, 0.5, 0),
	backfaces=true,
	depthWrite=false,
	alpha=0.5
}
-- plane line 1
material `line_1` {
	diffuseColour=vec(0, 1, 0),
	emissiveMask=vec(0, 1, 0),
    additionalLighting=true,
	depthSort=false,
}
-- plane line 2
material `line_2` {
	diffuseColour=vec(1, 0, 0),
	emissiveMask=vec(1, 0, 0),
    additionalLighting=true,
}
-- all arrows line material
material `line` {
	diffuseColour=vec(0, 1, 0),
	emissiveMask=vec(0, 1, 0),
    additionalLighting=true,
}
-- line selected (when you are dragging, only the line turns yellow)
material `line_dragging` {
	diffuseColour=vec(1, 0.5, 0),
	emissiveMask=vec(1, 0.5, 0),
    additionalLighting=true,
}
-- all arrows `arrow` material
material `arrow` {
	diffuseColour=vec(0, 1, 0),
	emissiveMask=vec(0, 1, 0),
    additionalLighting=true,
}

material `green` {
	diffuseColour=vec(0, 1, 0),
	emissiveMask=vec(0, 1, 0),
    additionalLighting=true,
}

material `red` {
	diffuseColour=vec(1, 0, 0),
	emissiveMask=vec(1, 0, 0),
    additionalLighting=true,
}

material `blue` {
	diffuseColour=vec(0, 0, 1),
	emissiveMask=vec(0, 0, 1),
    additionalLighting=true,
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

get_material(`green`):setDepthBias(0, 0, 50000, 50000)
get_material(`red`):setDepthBias(0, 0, 50000, 50000)
get_material(`blue`):setDepthBias(0, 0, 50000, 50000)

get_material(`arrow`):setDepthBias(0, 0, 50000, 50000)
get_material(`line`):setDepthBias(0, 0, 50000, 50000)

get_material(`face`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_1`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_2`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_dragging`):setDepthBias(0, 0, 50000, 50000)

class `widget` {} {

    renderingDistance = 10000;
	editorObject = true;
	
    init = function (persistent)

    end;

    activate = function (persistent,instance)
        persistent.needsFrameCallbacks = true
		
		if valid_object(instance.pivot) then
			instance.pivot:destroy()
		end
		
        instance.pivot = gfx_body_make()
        instance.pivot.localPosition = persistent.spawnPos
        instance.pivot.localOrientation = persistent.rot
		
		instance.scale = 1
		
		instance.initialOrientations = instance.pivot.localOrientation
		instance.pivotInitialOrientation = {}
		
		persistent:updateArrows(persistent)
    end;

	updateArrows = function(persistent)
		local instance = persistent.instance
		local pivot_or = instance.pivot.localOrientation

		if instance.mode == nil then instance.mode = "translate" end
		if persistent.mode ~= nil then instance.mode = persistent.mode end
		
		if persistent.rotating ~= nil then instance.rotating = persistent.rotating end

		if widget_manager.dragged ~= nil then instance.dragged = widget_manager.dragged end

		instance.mode = widget_manager.mode

		if valid_object(instance.x) then
			instance.x:destroy()
		end
		
		instance.x = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_x"}
		instance.x:activate()
		instance.x.instance.gfx.localOrientation = pivot_or * euler(0, 0, -90)
		instance.x.instance.gfx:setMaterial(`arrow`, `red`)
		instance.x.instance.gfx:setMaterial(`line`, `red`)
		instance.x.instance.defmat = `red`
		instance.x.wc = "x"

		if valid_object(instance.y) then
			instance.y:destroy()
		end
		
		instance.y = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_y"}
		instance.y:activate()
		instance.y.instance.gfx:setMaterial(`arrow`, `green`)
		instance.y.instance.gfx:setMaterial(`line`, `green`)
		instance.y.instance.defmat = `green`
		instance.y.wc = "y"

		if valid_object(instance.z) then
			instance.z:destroy()
		end
		
		instance.z = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_z"}
		instance.z:activate()
		instance.z.instance.gfx.localOrientation = pivot_or * euler(90, 0, -90)
		instance.z.instance.gfx:setMaterial(`arrow`, `blue`)
		instance.z.instance.gfx:setMaterial(`line`, `blue`)
		instance.z.instance.defmat = `blue`
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
			instance.xy = object `dummy_plane` (0, 0, 0) {name="widget_xy"}
			instance.xy:activate()
			instance.xy.instance.gfx.localOrientation = pivot_or
			instance.xy.instance.defmat = `green`
			instance.xy.wc = "xy"

			instance.xz = object `dummy_plane` (0, 0, 0) {name="widget_xz"}
			instance.xz:activate()
			instance.xz.instance.gfx.localOrientation = pivot_or * euler(0, -90, -90)
			instance.xz.instance.gfx:setMaterial(`line_1`, `red`)
			instance.xz.instance.gfx:setMaterial(`line_2`, `blue`)
			instance.xz.instance.defmat = `green`
			instance.xz.wc = "xz"
	
			instance.yz = object `dummy_plane` (0, 0, 0) {name="widget_yz"}
			instance.yz:activate()
			instance.yz.instance.gfx.localOrientation = pivot_or * euler(90, 0, 90)
			instance.yz.instance.gfx:setMaterial(`line_1`, `blue`)
			instance.yz.instance.gfx:setMaterial(`line_2`, `green`)
			instance.yz.instance.defmat = `green`
			instance.yz.wc = "yz"
		end
	end;

    deactivate = function (persistent)
		persistent.needsFrameCallbacks = false
		local instance = persistent.instance
		instance.x:destroy()
		instance.y:destroy()
		instance.z:destroy()
		if instance.mode == "translate" or instance.mode == "scale" then
			instance.xy:destroy()
			instance.xz:destroy()
			instance.yz:destroy()
		end
		instance.pivot:destroy()
    end;	

	setOrientation = function(self, orientation)
		local inst = self.instance
		inst.pivot.localOrientation = orientation
		
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
	
    frameCallback = function (persistent, elapsed)
        -- if persistent.destroyed or not persistent.instance.pivot or not persistent.instance.pivot.destroyed then return end
		
		local inst = persistent.instance
		if not inst.pivot or persistent.destroyed then return end
		
		inst.scale = ((2 * math.tan(math.rad(gfx_option("FOV")) / 2)) * #(main.camPos - inst.pivot.localPosition))*0.025

		local vecsize = vec(inst.scale, inst.scale, inst.scale)
		
		local pivot_pos = inst.pivot.localPosition
		local new_orientation = inst.pivot.localOrientation
		
		if inst.x.instance and inst.y.instance and inst.z.instance then
			inst.x.instance.gfx.localPosition = pivot_pos
			inst.y.instance.gfx.localPosition = pivot_pos
			inst.z.instance.gfx.localPosition = pivot_pos
			
			inst.x.instance.gfx.localOrientation = new_orientation * euler(0, 0, -90)
			inst.y.instance.gfx.localOrientation = new_orientation
			inst.z.instance.gfx.localOrientation = new_orientation * euler(90, 0, -90)
			
			inst.x.instance.gfx.localScale = vecsize
			inst.y.instance.gfx.localScale = vecsize
			inst.z.instance.gfx.localScale = vecsize
		end
		
		if (inst.mode == "translate" or inst.mode == "scale") and
		(inst.xy.instance and inst.xz.instance and inst.yz.instance) then
			inst.xy.instance.gfx.localPosition = pivot_pos
			inst.xz.instance.gfx.localPosition = pivot_pos
			inst.yz.instance.gfx.localPosition = pivot_pos
			
			inst.xy.instance.gfx.localScale = vecsize
			inst.xz.instance.gfx.localScale = vecsize
			inst.yz.instance.gfx.localScale = vecsize
		end

		if inst.dragged ~= nil then
			for i = 1, #inst.dragged do
				if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and not inst.dragged[i].destroyed then
					local new_pos = vec(
						math.floor((pivot_pos.x + widget_manager.offsets[i].x) / nonzero(widget_manager.step_size) + 0.5 ) * widget_manager.step_size,
						math.floor((pivot_pos.y + widget_manager.offsets[i].y) / nonzero(widget_manager.step_size) + 0.5 ) * widget_manager.step_size,
						math.floor((pivot_pos.z + widget_manager.offsets[i].z) / nonzero(widget_manager.step_size) + 0.5 ) * widget_manager.step_size
					)
					
					inst.dragged[i].spawnPos = new_pos
					
					if inst.dragged[i].instance.body ~= nil then
						inst.dragged[i].instance.body.worldPosition = new_pos
					elseif inst.dragged[i].instance.gfx ~= nil then
						inst.dragged[i].instance.gfx.localPosition = new_pos
					elseif inst.dragged[i].instance.audio ~= nil then
						inst.dragged[i].instance.audio.position = new_pos
						inst.dragged[i].pos = new_pos
					end
				end
			end
		end
    end;
	
	rotate = function(persistent, rot)
		local inst = persistent.instance

		inst.pivot.localOrientation = inst.pivotInitialOrientation * rot
		
		for i = 1, #inst.dragged do
			if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and not inst.dragged[i].destroyed then
				local new_orientation = inst.initialOrientations[i] * rot

				if inst.dragged[i].instance.body ~= nil then
					inst.dragged[i].instance.body.worldOrientation = new_orientation
				elseif inst.dragged[i].instance.gfx ~= nil then
					inst.dragged[i].instance.gfx.localOrientation = new_orientation
				elseif inst.dragged[i].instance.audio ~= nil then
					inst.dragged[i].instance.audio.orientation = new_orientation
				end	
				
				inst.dragged[i].rot = new_orientation
			end
		end
	end;
	
	setInitialOrientations = function(persistent)
		local inst = persistent.instance

		inst.pivotInitialOrientation = inst.pivot.localOrientation
		inst.initialOrientations = {}
		for i = 1, #inst.dragged do
			if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and not inst.dragged[i].destroyed then
				local initialorientation
				
				if inst.dragged[i].instance.body ~= nil then
					initialorientation = inst.dragged[i].instance.body.worldOrientation
				elseif inst.dragged[i].instance.gfx ~= nil then
					initialorientation = inst.dragged[i].instance.gfx.localOrientation
				elseif inst.dragged[i].instance.audio ~= nil then
					initialorientation = inst.dragged[i].instance.audio.orientation
				end				
				
				inst.initialOrientations[#inst.initialOrientations+1] = initialorientation
			end
		end
	end;
}