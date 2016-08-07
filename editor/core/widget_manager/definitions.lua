-- MATERIALS

-- the dummy_plane
material `face` {
	backfaces = true,

	diffuseMask = vec(1, 0.5, 0),
	alphaMask = 0.0,  -- Why?
    sceneBlend = "ALPHA",
}
-- the dummy_plane dragging
material `dragging_face` {
	diffuseMask = vec(1, 0.5, 0),
	backfaces = true,
	alphaMask = 0.5,
    sceneBlend = "ALPHA",
}
-- dummy_plane line 1
material `line_1` {
	diffuseMask = vec(0, 1, 0),
	emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}
-- dummy_plane line 2
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
-- line selected (when you are dragging, only the line turns yellow)
material `line_dragging` {
	diffuseMask = vec(1, 0.5, 0),
	emissiveMask = vec(1, 0.5, 0),
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

-- TODO(dcunnin): Provide an official way to render something last (debug overdraw).
--[[
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
