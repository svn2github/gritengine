-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "StackY" {
	padding = 0;
	init = function (self)
		self.alpha = 0
		self.alignment = { }
		self.contents = { }
		for k,v in ipairs(self.table) do
			local alignment = 0
			if type(v) == "table" then
				if v[1] == "LEFT" then
					alignment = 1
				elseif  v[1] == "CENTER" then
					alignment = 0
				elseif v[1] == "RIGHT" then
					alignment = -1
				else
					error("Unrecognised horizontal alignment: \""..tostring(v[1]).."\"")
				end
				v = v[2]
			end
			if type(v) == "vector2" then
				v = { size=v }
			end
			self.contents[k] = v
			self.alignment[k] = alignment
			v.parent = self
		end
		for k,v in ipairs(self.contents) do
			self[k] = nil
		end
		local w, h = 0, 0
		for k,v in ipairs(self.contents) do
			h = h + v.size.y + self.padding
			w = math.max(w, v.size.x)
		end
		if h > 0 then h = h - self.padding end
		local y = h / 2
		for k,v in ipairs(self.contents) do
			v.position = vector2(self.alignment[k]*(w - v.size.x)/2, y - v.size.y/2)				
			y = y - (v.size.y + self.padding)
		end
		self.size = vector2(w,h)
	end;
	destroy = function (self)
		for k,v in ipairs(self.contents or { }) do
			safe_destroy(v)
		end
		self.contents = nil
	end;
}

hud_class "StackX" {
	padding = 0;
	init = function (self)
		self.alpha = 0
		self.contents = { }
		self.alignment = { }
		for k,v in ipairs(self.table) do
			local alignment = 0
			if type(v) == "table" then
				if v[1] == "TOP" then
					alignment = 1
				elseif  v[1] == "CENTER" then
					alignment = 0
				elseif v[1] == "BOTTOM" then
					alignment = -1
				else
					error("Unrecognised vertical alignment: \""..tostring(v[1]).."\"")
				end
				v = v[2]
				if v == nil then
					error("Expected a GfxHud element in second element of table.")
				end
			end
			if type(v) == "vector2" then
				v = { size=v }
			end
			self.contents[k] = v
			self.alignment[k] = alignment
			v.parent = self
		end
		for k,v in ipairs(self.contents) do
			self[k] = nil
		end
		local h, w = 0, 0
		for k,v in ipairs(self.contents) do
			w = w + v.size.x + self.padding
			h = math.max(h, v.size.y)
		end
		if w > 0 then w = w - self.padding end
		local x = -w / 2
		for k,v in ipairs(self.contents) do
			v.position = vector2(x + v.size.x/2, self.alignment[k]*(h - v.size.y)/2)				
			x = x + (v.size.x + self.padding)
		end
		self.size = vector2(w,h)
	end;
	destroy = function (self)
		for k,v in ipairs(self.contents or { }) do
			safe_destroy(v)
		end
		self.contents = nil
	end;
}
