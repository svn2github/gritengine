
unload_icons = false

particle `LampIcon` {
    map = `icons/map_editor/lamp_icon.png`;
    frames = { 0,0, 128, 128, }; frame = 0;
    behaviour = function(particle, elapsed)
		if unload_icons then
			return false
		end
    end;
}       

function emit_lamp_icon (pos, colour, size)
    pos = pos or pick_pos(nil, true)
    if pos == nil then return end
    colour = colour or vector3(3,3,3)

    size = size or 1
    gfx_particle_emit(`LampIcon`, pos, {
        emissive = colour;
        diffuse = vec(0, 0, 0);
        dimensions = size*V_ID;
    })
end 

particle `SoundIcon` {
    map = `icons/map_editor/sound_icon.png`;
    frames = { 0,0, 128, 128, }; frame = 0;
    behaviour = function(particle, elapsed)
		particle.position = particle.p.pos
		if unload_icons then
			return false
		end
    end;
}       

function emit_sound_icon (pos, pr)
    pos = pos or pick_pos(nil, true)
    if pos == nil then return end
    local colour = vector3(1,1,1)
    local size = 1
    return gfx_particle_emit(`SoundIcon`, pos, {
        emissive = colour*0.5;
        diffuse = colour;
        dimensions = size*V_ID;
		p = pr;
    })
end 

function create_world_icons()
	unload_icons = false
	for k, v in ipairs(object_all()) do
		-- if v and not v.destroyed and v.instance and v.instance.audio then
		if class_get(v.className).type == "SoundEmitterClass" then
			emit_sound_icon(v.pos, v)
		end
	end
end

-- for k, v in ipairs(object_all()) do
	-- if v and not v.destroyed and v.instance and v.instance.audio then
		-- qw = v
	-- end
-- end