-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `definitions.lua`

class `widget` {} {

    renderingDistance = 10000;
	editorObject = true;
	
    init = function (persistent)

    end;

    activate = function (persistent,instance)
        persistent.needsStepCallbacks = true

        instance.pivot = gfx_body_make()
        instance.pivot.localPosition = persistent.spawnPos
        instance.pivot.localOrientation = persistent.rot
		
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
		
		if instance.x_a ~= nil then
			instance.x_a:destroy()
		end
		
		instance.x_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_x"}
		instance.x_a:activate()
		instance.x_a.instance.body.worldOrientation = pivot_or * euler(0, 0, -90)
		instance.x_a.instance.body.ghost = true
		instance.x_a.instance.gfx:setMaterial(`arrow`, `red`)
		instance.x_a.instance.gfx:setMaterial(`line`, `red`)
		instance.x_a.instance.defmat = `red`
		instance.x_a.wc = "x"

		if instance.y_a ~= nil then
			instance.y_a:destroy()
		end
		
		instance.y_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_y"}
		instance.y_a:activate()
		instance.y_a.instance.body.ghost = true
		instance.y_a.instance.gfx:setMaterial(`arrow`, `green`)
		instance.y_a.instance.gfx:setMaterial(`line`, `green`)
		instance.y_a.instance.defmat = `green`
		instance.y_a.wc = "y"

		if instance.z_a ~= nil then
			instance.z_a:destroy()
		end
		
		instance.z_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_z"}
		instance.z_a:activate()
		instance.z_a.instance.body.worldOrientation = pivot_or * euler(90, 0, -90)
		instance.z_a.instance.body.ghost = true
		instance.z_a.instance.gfx:setMaterial(`arrow`, `blue`)
		instance.z_a.instance.gfx:setMaterial(`line`, `blue`)
		instance.z_a.instance.defmat = `blue`
		instance.z_a.wc = "z"

		if instance.dummy_xy ~= nil then
			instance.dummy_xy:destroy()
		end

		if instance.dummy_xz ~= nil then
			instance.dummy_xz:destroy()
		end
		
		if instance.dummy_yz ~= nil then
			instance.dummy_yz:destroy()
		end

		if instance.mode == "translate" or instance.mode == "scale" then
			instance.dummy_xy = object `dummy_plane` (0, 0, 0) {name="widget_xy"}
			instance.dummy_xy:activate()
			instance.dummy_xy.instance.body.worldOrientation = pivot_or
			instance.dummy_xy.instance.body.ghost = true
			instance.dummy_xy.instance.defmat = `green`
			instance.dummy_xy.wc = "xy"

			instance.dummy_xz = object `dummy_plane` (0, 0, 0) {name="widget_xz"}
			instance.dummy_xz:activate()
			instance.dummy_xz.instance.body.worldOrientation = pivot_or * euler(0, -90, -90)
			instance.dummy_xz.instance.body.ghost = true
			instance.dummy_xz.instance.gfx:setMaterial(`line_1`, `red`)
			instance.dummy_xz.instance.gfx:setMaterial(`line_2`, `blue`)
			instance.dummy_xz.instance.defmat = `green`
			instance.dummy_xz.wc = "xz"
	
			instance.dummy_yz = object `dummy_plane` (0, 0, 0) {name="widget_yz"}
			instance.dummy_yz:activate()
			instance.dummy_yz.instance.body.worldOrientation = pivot_or * euler(90, 0, 90)
			instance.dummy_yz.instance.body.ghost = true
			instance.dummy_yz.instance.gfx:setMaterial(`line_1`, `blue`)
			instance.dummy_yz.instance.gfx:setMaterial(`line_2`, `green`)
			instance.dummy_yz.instance.defmat = `green`
			instance.dummy_yz.wc = "yz"
		end		
	end;

    deactivate = function (persistent)
		persistent.needsStepCallbacks = true
		local instance = persistent.instance
		instance.x_a:destroy()
		instance.y_a:destroy()
		instance.z_a:destroy()
		if instance.mode == "translate" or instance.mode == "scale" then
			instance.dummy_xy:destroy()
			instance.dummy_xz:destroy()
			instance.dummy_yz:destroy()
		end
    end;

    stepCallback = function (persistent, elapsed)
        local inst = persistent.instance
		
		local pivot_pos = inst.pivot.localPosition
		
		inst.x_a.instance.body.worldPosition = pivot_pos
		inst.y_a.instance.body.worldPosition = pivot_pos
		inst.z_a.instance.body.worldPosition = pivot_pos
		
		if inst.mode == "translate" or inst.mode == "scale" then
			inst.dummy_xy.instance.body.worldPosition = pivot_pos
			inst.dummy_xz.instance.body.worldPosition = pivot_pos
			inst.dummy_yz.instance.body.worldPosition = pivot_pos
		end

		for i = 1, #inst.dragged do
			if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and inst.dragged[i].destroyed == false then
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
		
		local new_orientation = inst.pivot.localOrientation
		
		inst.x_a.instance.body.worldOrientation = new_orientation * euler(0, 0, -90)
		inst.y_a.instance.body.worldOrientation = new_orientation
		inst.z_a.instance.body.worldOrientation = new_orientation * euler(90, 0, -90)		
    end;
	
	rotate = function(persistent, rot)
		local inst = persistent.instance

		inst.pivot.localOrientation = inst.pivotInitialOrientation * rot
		
		for i = 1, #inst.dragged do
			if inst.dragged[i] ~= nil and inst.dragged[i].instance ~= nil and inst.dragged[i].destroyed == false then
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
	end;	
	
}
-- keeps an uniform widget size, on different camera distances
-- TODO: add screen size somewhere
-- function gizmo_resize()
	-- local mfov = math.pi / 4
	-- local cam_obj_dist = nil
	-- if gizmo.node.parent ~= nil then
		-- cam_obj_dist = #(player_ctrl.camPos - gizmo.node.parent.localPosition)
	-- else
		-- cam_obj_dist = #(player_ctrl.camPos - gizmo.node.localPosition)
	-- end
	-- local wsize = (2 * math.tan(mfov / 2)) * cam_obj_dist
	-- local gsize = 0.025 * wsize
	-- gizmo.node.localScale = vector3(gsize, gsize, gsize)
-- end

-- function gizmo_fade(vl)
	-- if gizmo.x_a ~= nil and gizmo.x_a.instance ~= nil then
		-- gizmo.x_a.instance.gfx.fade = vl
		-- gizmo.y_a.instance.gfx.fade = vl
		-- gizmo.z_a.instance.gfx.fade = vl
		-- if gizmo.dummy_xy ~= nil and gizmo.dummy_xy.instance ~= nil then
			-- gizmo.dummy_xy.instance.gfx.fade = vl
			-- gizmo.dummy_xz.instance.gfx.fade = vl
			-- gizmo.dummy_yz.instance.gfx.fade = vl
		-- end
	-- end
-- end

include `widget_manager.lua`
