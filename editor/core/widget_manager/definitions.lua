-- MATERIALS

-- the dummy_plane
material `face` {
	diffuseColour=vec(1, 0.5, 0),
	backfaces=true,
	alpha=0.0,
	depthWrite=false,
}
-- the dummy_plane dragging
material `dragging_face` {
	diffuseColour=vec(1, 0.5, 0),
	backfaces=true,
	depthWrite=false,
	alpha=0.5
}
-- dummy_plane line 1
material `line_1` {
	diffuseColour=vec(0, 1, 0),
	emissiveColour=vec(0, 1, 0),
	depthSort=false,
}
-- dummy_plane line 2
material `line_2` {
	diffuseColour=vec(1, 0, 0),
	emissiveColour=vec(1, 0, 0),
}
-- all arrows line material
material `line` {
	diffuseColour=vec(0, 1, 0),
	emissiveColour=vec(0, 1, 0),
}
-- line selected (when you are dragging, only the line turns yellow)
material `line_dragging` {
	diffuseColour=vec(1, 0.5, 0),
	emissiveColour=vec(1, 0.5, 0),
}
-- all arrows `arrow` material
material `arrow` {
	diffuseColour=vec(0, 1, 0),
	emissiveColour=vec(0, 1, 0),
}

material `green` {
	diffuseColour=vec(0, 1, 0),
	emissiveColour=vec(0, 1, 0),
}

material `red` {
	diffuseColour=vec(1, 0, 0),
	emissiveColour=vec(1, 0, 0),
}

material `blue` {
	diffuseColour=vec(0, 0, 1),
	emissiveColour=vec(0, 0, 1),
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