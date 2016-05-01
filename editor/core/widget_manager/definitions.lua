-- MATERIALS

-- the dummy_plane
material `face` {
	diffuseColour=vector3(1, 0.5, 0),
	backfaces=true,
	alpha=0.0,
	depthWrite=false,
}
-- the dummy_plane dragging
material `dragging_face` {
	diffuseColour=vector3(1, 0.5, 0),
	backfaces=true,
	depthWrite=false,
	alpha=0.5
}
-- dummy_plane line 1
material `line_1` {
	diffuseColour=vector3(0, 1, 0),
	emissiveColour=vector3(0, 1, 0),
	depthSort=false,
}
-- dummy_plane line 2
material `line_2` {
	diffuseColour=vector3(1, 0, 0),
	emissiveColour=vector3(1, 0, 0),
}
-- all arrows line material
material `line` {
	diffuseColour=vector3(0, 1, 0),
	emissiveColour=vector3(0, 1, 0),
}
-- line selected (when you are dragging, only the line turns yellow)
material `line_dragging` {
	diffuseColour=vector3(1, 0.5, 0),
	emissiveColour=vector3(1, 0.5, 0),
}
-- all arrows `arrow` material
material `arrow` {
	diffuseColour=vector3(0, 1, 0),
	emissiveColour=vector3(0, 1, 0),
}

material `green` {
	diffuseColour=vector3(0, 1, 0),
	emissiveColour=vector3(0, 1, 0),
}

material `red` {
	diffuseColour=vector3(1, 0, 0),
	emissiveColour=vector3(1, 0, 0),
}

material `blue` {
	diffuseColour=vector3(0, 0, 1),
	emissiveColour=vector3(0, 0, 1),
}
-- CLASSES
class `dummy_plane` (ColClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_translate` (ColClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_scale` (ColClass) {
	renderingDistance = 1000.0;
	castShadows = false;
	editorObject = true;
}
class `arrow_rotate` (ColClass) {
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
