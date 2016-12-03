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

class `Widget` {} {

    renderingDistance = 10000,

	editorObject = true,

    axisColours = {
        x = `red`,
        y = `green`,
        z = `blue`,
    },

    planeColours = {
        xy = { `green`, `red` },
        xz = { `red`, `blue` },
        yz = { `blue`, `green` },
    },

    init = function(self)
    end,
	
    activate = function(self, instance)
		self:updateArrows(self.rot)
        self:updatePivot(self.spawnPos, self.rot)
		instance.scale = 1
    end,

    -- (Re)creates the objects representing individual parts of the widget.
    -- Call this every time widget_manager.mode updates.
    -- The positions of the objects should then be controlled via updatePivot.
	updateArrows = function(self, pivot_or)
		local instance = self.instance

		if self.rotating ~= nil then instance.rotating = self.rotating end

        instance.x = safe_destroy(instance.x)
        instance.y = safe_destroy(instance.y)
        instance.z = safe_destroy(instance.z)
        instance.xy = safe_destroy(instance.xy)
        instance.xz = safe_destroy(instance.xz)
        instance.yz = safe_destroy(instance.yz)
    
        instance.x = gfx_body_make((`arrow_%s.mesh`):format(widget_manager.mode))
		instance.x.localOrientation = pivot_or * euler(0, 0, -90)
		instance.x:setMaterial(`arrow`, `red`)
		instance.x:setMaterial(`line`, `red`)

        instance.y = gfx_body_make((`arrow_%s.mesh`):format(widget_manager.mode))
		instance.y:setMaterial(`arrow`, `green`)
		instance.y:setMaterial(`line`, `green`)

        instance.z = gfx_body_make((`arrow_%s.mesh`):format(widget_manager.mode))
		instance.z.localOrientation = pivot_or * euler(90, 0, -90)
		instance.z:setMaterial(`arrow`, `blue`)
		instance.z:setMaterial(`line`, `blue`)

		if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
            instance.xy = gfx_body_make(`dummy_plane.mesh`)
			instance.xy.localOrientation = pivot_or

            instance.xz = gfx_body_make(`dummy_plane.mesh`)
			instance.xz.localOrientation = pivot_or * euler(0, -90, -90)
			instance.xz:setMaterial(`line_1`, `red`)
			instance.xz:setMaterial(`line_2`, `blue`)
	
            instance.yz = gfx_body_make(`dummy_plane.mesh`)
			instance.yz.localOrientation = pivot_or * euler(90, 0, 90)
			instance.yz:setMaterial(`line_1`, `blue`)
			instance.yz:setMaterial(`line_2`, `green`)
		end
	end,

    deactivate = function(self)
		local instance = self.instance
        safe_destroy(instance.x)
        safe_destroy(instance.y)
        safe_destroy(instance.z)
        safe_destroy(instance.xy)
        safe_destroy(instance.xz)
        safe_destroy(instance.yz)
    end,


    -- Call whenever the camera moves or self.widgetPosition is updated.
    updatePivotScale = function(self)
		local inst = self.instance

		local scale = ((2 * math.tan(math.rad(gfx_option("FOV")) / 2)) * #(main.camPos - self.widgetPosition))*0.025
		local scale3 = scale * vec(1, 1, 1)
        inst.x.localScale = scale3
        inst.y.localScale = scale3
        inst.z.localScale = scale3

		if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
			inst.xy.localScale = scale3
			inst.xz.localScale = scale3
			inst.yz.localScale = scale3
		end
    end,

    -- Call when the pivot is moved to a new location due to changes in selection, dragging, etc.
    updatePivot = function(self, new_position, new_orientation)

		local inst = self.instance

        inst.x.localPosition = new_position
        inst.y.localPosition = new_position
        inst.z.localPosition = new_position
        
        inst.x.localOrientation = new_orientation * euler(0, 0, -90)
        inst.y.localOrientation = new_orientation
        inst.z.localOrientation = new_orientation * euler(90, 0, -90)
        
		
		if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
			inst.xy.localPosition = new_position
			inst.xz.localPosition = new_position
			inst.yz.localPosition = new_position
		end

        self.widgetPosition = new_position
        self.widgetOrientation = new_orientation

        self:updatePivotScale()
    end,

    -- Choose which component should be highlighted (nil for none).
	highlight = function(self, highlighted_component)
		local inst = self.instance

        for _, component in ipairs{'xy', 'xz', 'yz'} do
            local line1, line2 = component:sub(1, 1), component:sub(2, 2)
            if highlighted_component == component then
                inst[component]:setMaterial(`line_1`, `yellow`)
                inst[component]:setMaterial(`line_2`, `yellow`)
                inst[component]:setMaterial(`face`, `face_dragging`)
                inst[line1]:setMaterial(`line`, `yellow`)
                inst[line2]:setMaterial(`line`, `yellow`)
            else
                inst[component]:setMaterial(`line_1`, self.planeColours[component][1])
                inst[component]:setMaterial(`line_2`, self.planeColours[component][2])
                inst[component]:setMaterial(`face`, `face`)
                inst[line1]:setMaterial(`line`, self.axisColours[line1])
                inst[line2]:setMaterial(`line`, self.axisColours[line2])
            end
        end
        for _, component in ipairs{'x', 'y', 'z'} do
            if highlighted_component == component then
                inst[component]:setMaterial(`line`, `yellow`)
            else
                inst[component]:setMaterial(`line`, self.axisColours[component])
            end
        end
	end,
}
