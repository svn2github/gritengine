local filename = select(1, ...)

if filename ~= nil then
	local file = open(filename)
	local mf
	if file.hasAlpha then
		mf = function(p) return vec4(file(p).xyz ^ 2.2, file(p).w) end
	else
		mf = function(p) return vec3(file(p).xyz ^ 2.2) end
	end
	make(vec(file.width, file.height), file.colourChannels, file.hasAlpha, mf):save(filename)
end