-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `definitions.lua`

class `widget` {} {

    renderingDistance = 4000;
	editor_object = true;
	
    init = function (persistent)
        -- persistent:addDiskResource(`test_girl_walk_baked.mesh`)
    end;

    activate = function (persistent,instance)
		if instance.mode == nil then instance.mode = "translate" end
		if persistent.mode ~= nil then instance.mode = persistent.mode end
		
		if persistent.rotating ~= nil then instance.rotating = persistent.rotating end

		if widget_manager.dragged ~= nil then instance.dragged = widget_manager.dragged end

		if type(instance.mode) == "number" then
			if instance.mode == 1 then
				instance.mode = "translate"
			elseif instance.mode == 2 then
				instance.mode = "rotate"
			elseif instance.mode == 3 then
				instance.mode = "scale"
			end
		end
		
        persistent.needsStepCallbacks = true

        instance.pivot = gfx_body_make()
        instance.pivot.localPosition = persistent.spawnPos
        instance.pivot.localOrientation = persistent.rot
		
		instance.x_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_x"}
		instance.x_a:activate()
		instance.x_a.instance.body.worldOrientation = instance.pivot.localOrientation * euler(0, 0, -90)
		instance.x_a.instance.body.ghost = true
		instance.x_a.instance.gfx:setMaterial(`arrow`, `red`)
		instance.x_a.instance.gfx:setMaterial(`line`, `red`)
		instance.x_a.instance.defmat = `red`
		instance.x_a.wc = "x"
		
		instance.y_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_y"}
		instance.y_a:activate()
		instance.y_a.instance.body.ghost = true
		instance.y_a.instance.gfx:setMaterial(`arrow`, `green`)
		instance.y_a.instance.gfx:setMaterial(`line`, `green`)
		instance.y_a.instance.defmat = `green`
		instance.y_a.wc = "y"
		
		instance.z_a = object (`arrow_`..instance.mode) (0, 0, 0) {name="widget_z"}
		instance.z_a:activate()
		instance.z_a.instance.body.worldOrientation = instance.pivot.localOrientation * euler(90, 0, -90)
		instance.z_a.instance.body.ghost = true
		instance.z_a.instance.gfx:setMaterial(`arrow`, `blue`)
		instance.z_a.instance.gfx:setMaterial(`line`, `blue`)
		instance.z_a.instance.defmat = `blue`
		instance.z_a.wc = "z"
		
		if instance.mode == "translate" or instance.mode == "scale" then
			instance.dummy_xy = object `dummy_plane` (0, 0, 0) {name="widget_xy"}
			instance.dummy_xy:activate()
			instance.dummy_xy.instance.body.worldOrientation = instance.pivot.localOrientation
			instance.dummy_xy.instance.body.ghost = true
			instance.dummy_xy.instance.defmat = `green`
			instance.dummy_xy.wc = "xy"
			
			instance.dummy_xz = object `dummy_plane` (0, 0, 0) {name="widget_xz"}
			instance.dummy_xz:activate()
			instance.dummy_xz.instance.body.worldOrientation = instance.pivot.localOrientation * euler(0, -90, -90)
			instance.dummy_xz.instance.body.ghost = true
			instance.dummy_xz.instance.gfx:setMaterial(`line_1`, `red`)
			instance.dummy_xz.instance.gfx:setMaterial(`line_2`, `blue`)
			instance.dummy_xz.instance.defmat = `green`
			instance.dummy_xz.wc = "xz"
			
			instance.dummy_yz = object `dummy_plane` (0, 0, 0) {name="widget_yz"}
			instance.dummy_yz:activate()
			instance.dummy_yz.instance.body.worldOrientation = instance.pivot.localOrientation * euler(90, 0, 90)
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
		
		inst.x_a.instance.body.worldPosition = inst.pivot.localPosition
		inst.y_a.instance.body.worldPosition = inst.pivot.localPosition
		inst.z_a.instance.body.worldPosition = inst.pivot.localPosition
		
		if inst.mode == "translate" or inst.mode == "scale" then
			inst.dummy_xy.instance.body.worldPosition = inst.pivot.localPosition
			inst.dummy_xz.instance.body.worldPosition = inst.pivot.localPosition
			inst.dummy_yz.instance.body.worldPosition = inst.pivot.localPosition
		end
		
		if inst.dragged ~= nil and inst.dragged.instance ~= nil and inst.dragged.destroyed == false then
			inst.dragged.instance.body.worldPosition = inst.pivot.localPosition
			inst.dragged.spawnPos = inst.pivot.localPosition
			
			if inst.rotating == true then
				inst.dragged.instance.body.worldOrientation = inst.pivot.localOrientation
				inst.dragged.rot = inst.pivot.localOrientation
			
				inst.x_a.instance.body.worldOrientation = inst.dragged.instance.body.worldOrientation * euler(0, 0, -90)
				inst.y_a.instance.body.worldOrientation = inst.dragged.instance.body.worldOrientation
				inst.z_a.instance.body.worldOrientation = inst.dragged.instance.body.worldOrientation * euler(90, 0, -90)
			end
		end
    end;
}

-- function gizmo_resize()
	-- local mfov = math.pi / 4
	-- local cam_obj_dist = nil
	-- if gizmo.node.parent ~= nil then
		-- cam_obj_dist = vlen(player_ctrl.camPos, gizmo.node.parent.localPosition)
	-- else
		-- cam_obj_dist = vlen(player_ctrl.camPos, gizmo.node.localPosition)
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