-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `ntfmessage` {
	alpha = 1;
	size = vec(100, 30);
	colour = vec(1, 0, 0);
	cornered = true;
	texture=`/common/hud/CornerTextures/Filled04.png`;
	tableid = 0;
	
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
		self.position = vec(0, 0)
		self.positionAnim = true
		self.timelimit = 3
		self.currenttime = 0
		self.needsFrameCallbacks = true
	end;
	
	moveTableIdsDown = function(self)
		for curtab=1,#ntfpanel.messages do
			ntfpanel.messages[curtab].tableid = ntfpanel.messages[curtab].tableid - 1
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		table.remove(ntfpanel.messages, self.tableid)
		self.moveTableIdsDown()
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		if self.currenttime < self.timelimit then
			self.currenttime = self.currenttime + elapsed
					self.position = vec((gfx_window_size().x + (self.size.x / 2)) - ((self.currenttime / self.timelimit) * (self.size.x)), (self.size.y * self.tableid) + 5)
		else
			self.alpha = self.alpha - (elapsed / self.timelimit)
			self.text.alpha = self.alpha
			if self.alpha <= 0 then
				self:destroy()
			end
		end
	end;
}

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
		print(#self.messages)
		self.messages[#self.messages+1] = gfx_hud_object_add(`ntfmessage`, { parent = self,  position=vec2(0, 0), value = msg, colour = clr, tableid = #self.messages+1})
		print("Notify created at position "..#self.messages.. " in the table!")
		print(#self.messages)
	end;
}
if ntfpanel ~= nil then safe_destroy(ntfpanel) end
ntfpanel = gfx_hud_object_add(`notify_panel`, {position=vec2(0, 50)})

function notify(msg, clr)
	if type(msg) == "string" then
		if clr == nil then
			clr = vec(0.65, 0.65, 0.65)
		end
		ntfpanel:addMessage(msg, clr)
	end
end