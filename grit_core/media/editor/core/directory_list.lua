-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- list files and folders in a given directory
function get_dir_list(directory)
    local i, folders, popen = 0, {}, io.popen
	-- get folders
	if os.getenv("OS") ~= nil then
		-- Windows
		for filename in popen('dir "'..directory..'" /b /ad'):lines() do
			i = i + 1
			folders[i] = filename
		end
	else
		-- Linux (TODO)
	end
	i = 0
	-- get files
	local files = {}
	if os.getenv("OS") ~= nil then
		-- Windows
		for filename in popen('dir "'..directory..'"/b /a-d'):lines() do
			i = i + 1
			files[i] = filename
		end
	else
		-- Linux (TODO)
	end
	local ff = {}
	ff.folders = folders
	ff.files = files
    return ff
end