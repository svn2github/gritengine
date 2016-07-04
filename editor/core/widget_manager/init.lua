-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `definitions.lua`

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

		
		if widget_manager.mode == 1 then
			instance.mode = "translate"
		elseif widget_manager.mode == 2 then
			instance.mode = "rotate"
		elseif widget_manager.mode == 3 then
			instance.mode = "scale"
		end
		
		if valid_object(instance.x_a) then
			instance.x_a:destroy()
		end
		
		instance.x_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_x"}
		instance.x_a:activate()
		instance.x_a.instance.gfx.localOrientation = pivot_or * euler(0, 0, -90)
		instance.x_a.instance.gfx:setMaterial(`arrow`, `red`)
		instance.x_a.instance.gfx:setMaterial(`line`, `red`)
		instance.x_a.instance.defmat = `red`
		instance.x_a.wc = "x"

		if valid_object(instance.y_a) then
			instance.y_a:destroy()
		end
		
		instance.y_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_y"}
		instance.y_a:activate()
		instance.y_a.instance.gfx:setMaterial(`arrow`, `green`)
		instance.y_a.instance.gfx:setMaterial(`line`, `green`)
		instance.y_a.instance.defmat = `green`
		instance.y_a.wc = "y"

		if valid_object(instance.z_a) then
			instance.z_a:destroy()
		end
		
		instance.z_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_z"}
		instance.z_a:activate()
		instance.z_a.instance.gfx.localOrientation = pivot_or * euler(90, 0, -90)
		instance.z_a.instance.gfx:setMaterial(`arrow`, `blue`)
		instance.z_a.instance.gfx:setMaterial(`line`, `blue`)
		instance.z_a.instance.defmat = `blue`
		instance.z_a.wc = "z"

		if valid_object(instance.dummy_xy) then
			instance.dummy_xy:destroy()
		end

		if valid_object(instance.dummy_xz) then
			instance.dummy_xz:destroy()
		end
		
		if valid_object(instance.dummy_yz) then
			instance.dummy_yz:destroy()
		end

		if instance.mode == "translate" or instance.mode == "scale" then
			instance.dummy_xy = object `dummy_plane` (0, 0, 0) {name="widget_xy"}
			instance.dummy_xy:activate()
			instance.dummy_xy.instance.gfx.localOrientation = pivot_or
			instance.dummy_xy.instance.defmat = `green`
			instance.dummy_xy.wc = "xy"

			instance.dummy_xz = object `dummy_plane` (0, 0, 0) {name="widget_xz"}
			instance.dummy_xz:activate()
			instance.dummy_xz.instance.gfx.localOrientation = pivot_or * euler(0, -90, -90)
			instance.dummy_xz.instance.gfx:setMaterial(`line_1`, `red`)
			instance.dummy_xz.instance.gfx:setMaterial(`line_2`, `blue`)
			instance.dummy_xz.instance.defmat = `green`
			instance.dummy_xz.wc = "xz"
	
			instance.dummy_yz = object `dummy_plane` (0, 0, 0) {name="widget_yz"}
			instance.dummy_yz:activate()
			instance.dummy_yz.instance.gfx.localOrientation = pivot_or * euler(90, 0, 90)
			instance.dummy_yz.instance.gfx:setMaterial(`line_1`, `blue`)
			instance.dummy_yz.instance.gfx:setMaterial(`line_2`, `green`)
			instance.dummy_yz.instance.defmat = `green`
			instance.dummy_yz.wc = "yz"
		end		
	end;

    deactivate = function (persistent)
		persistent.needsFrameCallbacks = false
		local instance = persistent.instance
		instance.x_a:destroy()
		instance.y_a:destroy()
		instance.z_a:destroy()
		if instance.mode == "translate" or instance.mode == "scale" then
			instance.dummy_xy:destroy()
			instance.dummy_xz:destroy()
			instance.dummy_yz:destroy()
		end
		instance.pivot:destroy()
    end;	

    frameCallback = function (persistent, elapsed)
        -- if persistent.destroyed or not persistent.instance.pivot or not persistent.instance.pivot.destroyed then return end
		
		local inst = persistent.instance
		if not inst.pivot or persistent.destroyed then return end
		
		inst.scale = ((2 * math.tan(math.rad(gfx_option("FOV")) / 2)) * #(main.camPos - inst.pivot.localPosition))*0.025

		local vecsize = vec(inst.scale, inst.scale, inst.scale)
		
		local pivot_pos = inst.pivot.localPosition
		local new_orientation = inst.pivot.localOrientation
		
		if inst.x_a.instance and inst.y_a.instance and inst.z_a.instance then
			inst.x_a.instance.gfx.localPosition = pivot_pos
			inst.y_a.instance.gfx.localPosition = pivot_pos
			inst.z_a.instance.gfx.localPosition = pivot_pos
			
			inst.x_a.instance.gfx.localOrientation = new_orientation * euler(0, 0, -90)
			inst.y_a.instance.gfx.localOrientation = new_orientation
			inst.z_a.instance.gfx.localOrientation = new_orientation * euler(90, 0, -90)
			
			inst.x_a.instance.gfx.localScale = vecsize
			inst.y_a.instance.gfx.localScale = vecsize
			inst.z_a.instance.gfx.localScale = vecsize
		end
		
		if (inst.mode == "translate" or inst.mode == "scale") and
		(inst.dummy_xy.instance and inst.dummy_xz.instance and inst.dummy_yz.instance) then
			inst.dummy_xy.instance.gfx.localPosition = pivot_pos
			inst.dummy_xz.instance.gfx.localPosition = pivot_pos
			inst.dummy_yz.instance.gfx.localPosition = pivot_pos
			
			inst.dummy_xy.instance.gfx.localScale = vecsize
			inst.dummy_xz.instance.gfx.localScale = vecsize
			inst.dummy_yz.instance.gfx.localScale = vecsize			
			
		end

		if valid_object(inst.dragged) then
			for i = 1, #inst.dragged do
				if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and not inst.dragged[i].destroyed then
					local new_pos = vec(
						math.floor((pivot_pos.x + widget_manager.offsets[i].x) / nonzero(widget_manager.grid_size) + 0.5 ) * widget_manager.grid_size,
						math.floor((pivot_pos.y + widget_manager.offsets[i].y) / nonzero(widget_manager.grid_size) + 0.5 ) * widget_manager.grid_size,
						math.floor((pivot_pos.z + widget_manager.offsets[i].z) / nonzero(widget_manager.grid_size) + 0.5 ) * widget_manager.grid_size
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

include `widget_manager.lua`
