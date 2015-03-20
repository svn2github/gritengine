-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `ntfmessage` {
	alpha = 1;
	size = vec(100, 30);
	colour = vec(1, 0, 0);
	cornered = true;
	texture=`/common/hud/CornerTextures/Filled04.png`;
	
	init = function (self)
		self.text = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.text.parent = self
		self.text.text = self.value
		
		if self.colour.x + self.colour.y + self.colour.z >= 1.5 then
			self.text.colour = vec(0, 0, 0)
		else
			self.text.colour = vec(1, 1, 1)
		end
		self.size = vec(self.text.size.x + 20, self.size.y)
		self.position = vec(self.size.x, self.position.y)
		self.timelimit = 3
		self.currenttime = 0
		self.needsFrameCallbacks = true
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		if self.currenttime < self.timelimit then
			self.currenttime = self.currenttime + elapsed
				self.position = vec(math.max(self.position.x - (elapsed*self.position.x*5), 0), self.position.y)
		else
			self.alpha = self.alpha - elapsed
			self.text.alpha = self.alpha
			if self.alpha <= 0 then
				self:destroy()
			end
		end
	end;
}

-- TODO: move old messages up and fix messages positions

hud_class `notify_panel` {
	alpha = 0;
	size = vec(0, 0);
	zOrder = 0;

	init = function (self)
		self.messages = {}
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
		
	addMessage = function(self, msg, clr)
		self.messages[#self.messages+1] = gfx_hud_object_add(`ntfmessage`, { parent = self,  position=vec2(0, 0), value = msg, colour = clr})
	end;
}
if ntfpanel ~= nil then safe_destroy(ntfpanel) end
ntfpanel = gfx_hud_object_add(`notify_panel`, { parent=hud_bottom_right,  position=vec2(-160, 50)})