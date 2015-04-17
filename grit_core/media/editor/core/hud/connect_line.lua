-- (c) Augusto P. Moura 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- Examples:
-- 1:
-- hudobj = gfx_hud_object_add(`/editor/core/hud/draggable`, { parent = hud_center, size=vec(64, 64), colour=vec(0, 0, 1), position=vec(100, -50) })
-- hudobj2 = gfx_hud_object_add(`/editor/core/hud/draggable`, { parent = hud_center, size=vec(64, 64), colour=vec(1, 0, 0), position=vec(50, -100)})
-- mln = gfx_hud_object_add(`connect_line`, { parent = hud_center; p1 = hudobj; p2 = hudobj2 })
-- 2:
-- mln = gfx_hud_object_add(`connect_line`, { parent = hud_center; p1 = vec(0, 0); p2 = vec(10, -50) })

hud_class `connect_line` {
	alpha = 1;
	size = vec(200, 5);
	colour = vector3(1, 1, 1);
	texture = `../icons/line.png`;
	p1 = vec(0, 0);
	p2 = vec(0, 0);
	
	init = function (self)
		if type(self.p1) == "userdata" and type(self.p2) == "userdata" then -- hud object
			self.needsFrameCallbacks = true
			self.update = self.updateLineObj
		else -- vector
			self.update = self.updateLineVec
			self:update()
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		self:update()
	end;

	updateLineObj = function(self)
		if self.p1 ~= nil and self.p2 ~= nil then
			local p2pos = vec2(self.p2.derivedPosition.x-gfx_window_size().x/2, self.p2.derivedPosition.y-gfx_window_size().y/2)
			self.orientation = math.deg(math.atan2(p2pos.x - (self.p1.derivedPosition.x-gfx_window_size().x/2), p2pos.y - (self.p1.derivedPosition.y-gfx_window_size().y/2)) )+90
			self.position = vec2((p2pos.x + (self.p1.derivedPosition.x-gfx_window_size().x/2))/2, (p2pos.y+(self.p1.derivedPosition.y- gfx_window_size().y/2))/2)
			self.size = vec2(math.sqrt(math.pow(p2pos.x - (self.p1.derivedPosition.x-gfx_window_size().x/2), 2) + math.pow(p2pos.y - (self.p1.derivedPosition.y- gfx_window_size().y/2),  2)), self.size.y)
		end
	end;
	
	updateLineVec = function(self)
		if self.p1 ~=nil and self.p2 ~=nil then
			local p2pos = vec2(self.p2.x-gfx_window_size().x/2, self.p2.y-gfx_window_size().y/2)
			self.orientation = math.deg(math.atan2(p2pos.x - (self.p1.x-gfx_window_size().x/2), p2pos.y - (self.p1.y-gfx_window_size().y/2)) )+90
			self.position = vec2((p2pos.x + (self.p1.x-gfx_window_size().x/2))/2, (p2pos.y+(self.p1.y- gfx_window_size().y/2))/2)
			self.size = vec2(math.sqrt(math.pow(p2pos.x - (self.p1.x-gfx_window_size().x/2), 2) + math.pow(p2pos.y - (self.p1.y- gfx_window_size().y/2),  2)), self.size.y)
		end
	end;
}