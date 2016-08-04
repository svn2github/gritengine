------------------------------------------------------------------------------
--  The tip that appears when the cursor is over something
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `Tip` {
	alpha = _current_theme.colours.tip.alpha;
	size = vec(30, 18);
	zOrder = 5;
	caption = "";
	padding = 3;
	currentTime = 0;
	duration = 1.5;
	colour = _current_theme.colours.tip.background;
	
	init = function (self)
		self.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.text.parent = self
		self.text.colour = _current_theme.colours.tip.text
		self.text.text = self.caption
		self:update()
		self.position = self.pos + vec(self.size.x/2, -29)
		self.needsFrameCallbacks = true
	end;
	
	update = function(self)
		self.size = vec(self.text.size.x + self.padding*2, self.size.y)
	end;
	
	frameCallback = function (self, elapsed)
		self.currentTime = self.currentTime + elapsed
		if self.currentTime >= self.duration then
			self.needsFrameCallbacks = false
			self:destroy()
		end
	end;
	
	destroy = function (self)
		self.text:destroy()
	end;
}

_tip = {}
function gui.showtip(text)
	if _tip ~= nil and _tip.destroyed ~= nil then
		_tip:destroy()
	end
	_tip = gfx_hud_object_add(`Tip`, { caption = text or "", pos = mouse_pos_abs })
end;