------------------------------------------------------------------------------
--  Useful functions
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

function table_concat(tab1, tab2)
	if tab1 == nil and tab2 ~= nil then return tab2 end
	if tab2 == nil and tab1 ~= nil then return tab1 end

	for k, v in pairs(tab2) do
		if type(k) == "number" then
			tab1[#tab1+1] = v
		else
			tab1[k] = v
		end
	end
   return tab1
end

function table_concat_copy(tab1, tab2)
	if tab1 == nil and tab2 ~= nil then return tab2 end
	if tab2 == nil and tab1 ~= nil then return tab1 end

	local ntb = {}
	
	for k, v in pairs(tab1) do
		if type(k) == "number" then
			ntb[#ntb+1] = v
		else
			ntb[k] = v
		end
	end
	for k, v in pairs(tab2) do
		if type(k) == "number" then
			ntb[#ntb+1] = v
		else
			ntb[k] = v
		end
	end	
	
   return ntb
end

function get_extension(str)
   return str:match("[^.]+$")
end

function quatPitch(q)
	return math.deg(math.atan2(2*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z))
end

function mouse_pick_pos(bias, safe)
	local cast_ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local dist = physics_cast(main.camPos, cast_ray, true, 0)
	if dist then
		return (main.camPos + cast_ray * dist)
	end
end
