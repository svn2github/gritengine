hud_class `dragbar` {
	alpha = 1;
	size = vec(15, 50);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	draggingPos = vec2(0, 0);
	cornered=true;
	texture=`/common/hud/CornerTextures/Filled04.png`;
	
	init = function (self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks=true
		self.startpos = vec2(0, 0)
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside

		if self.dragging == true then
			self.startpos = vec2(0, self.parent.size.y/2-self.parent.up.size.y-self.size.y/2)
			if self.startpos.y ~= 0 then
				local pcent = (self.position.y + self.startpos.y) / (self.startpos.y * 2)
				self.parent.parent.parent.grid.position = vec2(0,(self.parent.parent.parent.size.y - self.parent.parent.parent.iconarea.y)*(pcent-1))
			else
				self.parent.parent.parent.grid.position = vec2(0, 0)
			end
			self:updateSize(self)
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.position.x, self.position.y)
			self.colour=vec(1, 0.8, 0.5)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.colour=vec(1, 1, 1)
        end
    end;
	updateSize = function(self)

	end;
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.startpos = vec2(0, self.parent.size.y/2-self.parent.up.size.y-self.size.y/2)
		end
		-- self:updateSize()
	end;
}

hud_class `rollbuttom` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
    end;
	
    parentResizedCallback = function (self, psize)
        --self.size = vec2(self.size.x, psize.y)
        self.position = psize*self.factor + self.offset
    end;
	
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self:refreshState()
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                self:pressedCallback()
            end
            self.dragging = false
        end
		self:refreshState()
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
	
	
    refreshState = function (self)
		if self.dragging and self.inside then
			self.colour = vec(1, 0.5, 0)
		elseif self.inside then
			self.colour = vec(1, 0.8, 0.5)
		else
			self.colour = vec(1, 1, 1)
		end
    end;
	
}   

hud_class `rollbar` {
	alpha = 1;
	size = vec(15, 256);
	zOrder = 0;
	colour=vec(0.2, 0.2, 0.2);
	cornered=true;
	texture=`/common/hud/CornerTextures/FilledWhiteBorder04.png`;
	
	init = function (self)
		self.needsFrameCallbacks = false;
		self.needsParentResizedCallbacks = true;
		self.up = gfx_hud_object_add(`rollbuttom`, {
			size=vec(15, 15);
			texture=`../icons/triangle_icon.png`;
			colour=vec(1, 1, 1);
			alpha=1;
			parent=self;
			offset = vec2(0, -7);
			factor = vec2(0, 0.5);
		})
		self.up.size=vec(15, 15);
		
		self.down = gfx_hud_object_add(`rollbuttom`, {
			size=vec(15, 15);
			texture=`../icons/triangle_icon2.png`;
			colour=vec(1, 1, 1);
			alpha=1;
			parent=self;
			offset = vec2(0, 7);
			factor = vec2(0, -0.5);
		})
		self.down.size=vec(15, 15);		
		
		self.roll = gfx_hud_object_add(`dragbar`, {size=vec(self.size.x, 50), colour=vec(0.8, 0.8, 0.8), parent=self})
		
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;

	parentResizedCallback = function(self, psize)
		self.size = vec2(self.size.x, psize.y)
		--self:updateRolDef()
	end;
	updateRolDef = function(self)
		--self.roll.startpos = vec2(0, self.size.y/2-self.up.size.y-self.roll.size.y/2)
	end;
}