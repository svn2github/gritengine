hud_class `event_list_floating_item` {
	alpha = 0;
	size = vec(150, 20);
	value="No text";
	
	id=0;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.item = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=self.size;
			textColour=vec(0, 0, 0);
			alignment="LEFT";
			value=self.value;
			alpha=1;
			colour = vec(1, 0.9, 0.5);
		})
		
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self.position = vec2(mouse_pos_abs.x -gfx_window_size().x/2-self.draggingPos.x, mouse_pos_abs.y - gfx_window_size().y/2 -self.draggingPos.y)
    end;
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
		elseif ev == "-left" then
			safe_destroy(self)
			fltt = nil
        end
    end;
	
}
fltt = nil
function create_floating(offset, vl, sz)
	if fltt == nil then
		fltt = gfx_hud_object_add(`event_list_floating_item`, {
			parent=hud_center,
			draggingPos=offset,
			value = vl,
			size=sz,
			position = vec2((select(3, get_mouse_events()))-gfx_window_size().x/2-offset.x, (select(4, get_mouse_events())) - gfx_window_size().y/2 -offset.y)
		})
	end
end

hud_class `event_list_item` {
	alpha = 0;
	size = vec(150, 20);
	value="No text";
	id=0;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.item = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=self.size;
			textColour=vec(0, 0, 0);
			alignment="LEFT";
			value=self.value;
			alpha=0;
		})
		self.dragging = false;
		self.inside = false;
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self.lp = local_pos
		if inside then
			self.item.colour = vec(1, 0.9, 0.5)
			self.item.alpha = 1
		else
			self.item.colour = vec(1, 1, 1)
			self.item.alpha = 0
		end
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                create_floating(self.lp, self.value, self.size)
            end
            self.dragging = false
        end
    end;

	parentResizedCallback = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
	end;
	
}

hud_class `event_list` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	lastItem = 0;
	border = 2;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.menuitems = {}
		
		
		self.position = vec2(0, -32)
		self:reorganize()
	end;
	
	reorganize = function(self)
		-- menu item size
		for i=1, #self.menuitems do
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.size = vec2(self.size.x -4, self.menuitems[i].item.size.y)
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			else
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			end
		end
		
		-- menu item and text position
		for i = 1, #self.menuitems do
			self.menuitems[i].position = vec2(0,  self.size.y/2 - ((i-1) * self.menuitems[i].size.y) -self.border -self.menuitems[i].size.y/2)
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.text.position = vec2(-self.menuitems[i].item.size.x/2 + self.menuitems[i].item.text.size.x/2+5, self.menuitems[i].item.text.position.y)
			end
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
	end;

    buttonCallback = function (self, ev)

    end;
	
	parentResizedCallback = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
		self.position=vec2(0, 0)
		self:reorganize()
	end;
	
	
    addItem = function (self, itm)
		self.menuitems[#self.menuitems+1] = gfx_hud_object_add(`event_list_item`, { value=itm, parent=self, position=vec2(0, self.lastItem), size=vec2(150, 20), id=#self.menuitems })
		self.lastItem = self.lastItem - 20
		self.size = vec2(256, -self.lastItem +5)
		self.position=vec2(0, -self.size.y/2)
		self:reorganize()
    end;
}
if eventlist ~= nil then safe_destroy(eventlist) end
eventlist = gfx_hud_object_add(`event_list`, { parent=editor_interface.windows.event_editor })

local choices = {
	"LevelBegin",
	"LevelEnd",
	"SetHealth",
	"IncDechealth",
	
	"SpawnObject",
	"SpawnCar",
	"Destroy",
	"SetHudText",
	"Log",
	"Command",
	
};

for i = 1, #choices do
	eventlist:addItem(choices[i])
end