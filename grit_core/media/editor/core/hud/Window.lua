-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class 'parentDraggable' {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	draggingPos = vec2(0, 0);

	init = function (self)
		self.needsFrameCallbacks = true
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks = true
		
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
	frameCallback = function (self, elapsed)
		
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging == true then			
			self.parent.parent.parent.position = vec2((select(3, get_mouse_events()) - self.draggingPos.x), (select(4, get_mouse_events()) - self.draggingPos.y))
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = vec2((select(3, get_mouse_events())), (select(4, get_mouse_events()))) - vec2(self.parent.parent.parent.position.x, self.parent.parent.parent.position.y)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
	
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.size = vec2(self.parent.parent.parent.size.x, self.size.y)
		end
	end;
}

-- used by the frame class to resize
hud_class 'resizer' {
	alpha = 1;
	size = vec(20, 20);
	zOrder = 0;
	colour = vector3(1, 0, 0);

	init = function (self)
		self.needsInputCallbacks = true
		self.dragging = false;
		self.drag_offset = vec2(0, 0)
	end;
	destroy = function (self)
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if inside then
			self.drag_offset = local_pos
		end
		if self.dragging == true then			
			self.colour = vector3(0.8, 0.75, 0.7)
		end		
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.parent.parent.parent.draggingPos =  self.parent.parent.parent.position + (self.parent.parent.parent.size/2)
			self.parent.parent.parent.originalSize = self.parent.parent.parent.size
			self.parent.parent.parent.originalPos = self.parent.parent.parent.position
			self.colour = vector3(0.7, 0.7, 0.7)
		elseif ev == "-left" then
			self.dragging = false
			self.parent.parent.parent.draggingPos = vec2(0, 0)
			self.parent.parent.parent.originalSize = vec2(0, 0)
			self.parent.parent.parent.originalPos = vec2(0, 0)		
			self.colour = vector3(0.5, 0.5, 0.5)
        end
    end;
}

-- TODO:
-- Move all above classes to inside window,
-- Switch Window itself by self.window, so you can parent childs directly to the window,
-- When you set window size directly it needs to handle properly..

hud_class 'Window' {
	alpha = 0.9;
	zOrder = 0;
	showCloseBtn = true;
	resizeable = true;
	title = "Window";
	min_size = vec2(150, 150);
	--max_size = vec2(0, 0);
	size=vec2(512, 400);
	cornered=true;
	colour=vector3(0.6, 0.6, 0.6);
	borderSize=2;
	texture='/common/hud/CornerTextures/Filled04.png';
	
	init = function (self)
		self.needsFrameCallbacks = false;
		self.needsInputCallbacks = true;
		
		-- for resizing
		self.draggingPos = vec2(0, 0);
		self.originalSize = vec2(0, 0)
		self.originalPos = vec2(0, 0)

		
		-- the background uses the window size plus the border to be bigger than the rest
		self.size = vec2(self.size.x + self.borderSize*2, self.size.y + self.borderSize*2)
		
		self.draggable_area = gfx_hud_object_add('/editor/core/hud/parentDraggable', {
			--parent = self;
			position = vec2(0, 0);
			size = vec2(self.size.x, 24);
			colour = vector3(1, 1, 1);
			zOrder = 2;
			alpha=0.7;
		})

		self.close_btn = gfx_hud_object_add(`/common/hud/Button`, {				
				caption = "X";
				padding = vec(20, 4);
				cornered=false;
				borderTexture = "/common/hud/cornerTextures/SquareBorderWhite.png";
				needsParentResizedCallbacks = true;
				parentResizedCallback = function(self, psize) self.position = vec2(psize.x/2-self.size.x/2, self.position.y) end;
				baseColour = vec(1,1,1) * 0.3;
				hoverColour = vec(1, 0.5, 0) * 0.75;
				clickColour = vec(1, 0.5, 0);
		})
		self.close_btn.texture = nil
		
		self.buttonPositioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self.draggable_area;
			offset = vec2(-self.close_btn.size.x/2, 0);
			factor = vec2(0.5, 0);
		})
		
		self.close_btn.parent = self.buttonPositioner 
		self.close_btn.pressedCallback = function (self)
			self.parent.parent.parent.parent.parent.enabled = false
		end;
		
		-- disables the close button if you create showCLoseBtn to false when creates the window, and delete the variable
		if self.showCloseBtn ~= nil then	
			if self.showCloseBtn == false then	
				self.close_btn.enabled = false
				self.showCloseBtn = nil
			end
		end

		self.titlePositioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self.draggable_area;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})
		
		self.window_title = gfx_hud_text_add("/common/fonts/Arial12")
		self.window_title.parent = self.titlePositioner
		self.window_title.colour = vector3(0, 0, 0)
		self.window_title.position = vec(0, 0)
		
		self:setTitle(self.title)
		-- used just for initialize
		self.title = nil
		
		self.window = gfx_hud_object_add('/common/hud/Rect', {
			size = vec2(512, 400);
			colour = vector3(0.2, 0.2, 0.2);
			alpha=1;
			parent= self;
		})
		
		self.titleBarPositioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self.window;
			offset = vec2(0, self.draggable_area.size.y/2);
			factor = vec2(0, 0.5);
		})		

		self.draggable_area.parent = self.titleBarPositioner

		self.left_resizer_Positioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self.window;
			offset = vec2(5 - self.borderSize, 5 - self.borderSize);
			factor = vec2(-0.5, -0.5);
		})

		self.right_resizer_Positioner = gfx_hud_object_add('/common/hud/Positioner', {
			parent = self.window;
			offset = vec2(-5 + self.borderSize, 5 - self.borderSize);
			factor = vec2(0.5, -0.5);
		})

		self.left_resizer = gfx_hud_object_add('/editor/core/hud/resizer', {
			size = vec2(10, 10);
			colour = vector3(0.5, 0.5, 0.5);
			parent=self.left_resizer_Positioner;
			position=vec2(0, 0);
			alpha=0.7;
			needsInputCallbacks = true;
			mouseMoveCallback = function (self, local_pos, screen_pos, inside) if self.dragging == true then self.colour = vector3(1, 1, 1) end end;
		})

		self.right_resizer = gfx_hud_object_add('/editor/core/hud/resizer', {
			size = vec2(10, 10);
			colour = vector3(0.5, 0.5, 0.5);
			parent=self.right_resizer_Positioner;
			position=vec2(0, 0);
			alpha=0.7;			
		})
		if self.resizeable == false then
			self.left_resizer.enabled = false
			self.right_resizer.enabled = false
		end
		self.resizeable = nil
		
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false

		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		if self.right_resizer.dragging == true then
			local wsize = vec2(self.originalSize.x - (self.draggingPos.x + (gfx_window_size().x/2) - screen_pos.x) + math.abs((self.right_resizer.drag_offset.x + (self.right_resizer.size.x/2)) -self.right_resizer.size.x),  self.draggingPos.y + (gfx_window_size().y/2) - screen_pos.y + (self.right_resizer.drag_offset.y + (self.right_resizer.size.y/2)))	
			if wsize.x >= self.min_size.x then
				self.size = vec2(wsize.x, self.size.y)
			end
			if wsize.y >= self.min_size.y then
				self.size = vec2(self.size.x, wsize.y)
			end			
			self.position=vec2(self.originalPos.x - (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
			-- TODO: move it to parentResizedCallback
			self.draggable_area.size = vec2(self.size.x, self.draggable_area.size.y)
			self.window.size = vec2(self.size.x - self.borderSize*2, self.size.y - self.borderSize*2)
		elseif self.left_resizer.dragging == true then
			local wsize = vec2(self.draggingPos.x + (gfx_window_size().x/2) - screen_pos.x + (self.left_resizer.drag_offset.x + (self.left_resizer.size.x/2)),  self.draggingPos.y + (gfx_window_size().y/2) - screen_pos.y + math.abs(self.left_resizer.drag_offset.y + (self.left_resizer.size.y/2)) )	
			if wsize.x >= self.min_size.x then
				self.size = vec2(wsize.x, self.size.y)
			end
			if wsize.y >= self.min_size.y then
				self.size = vec2(self.size.x, wsize.y)
			end			
			self.position=vec2(self.originalPos.x + (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
			self.draggable_area.size = vec2(self.size.x, self.draggable_area.size.y)
			self.window.size = vec2(self.size.x - self.borderSize*2, self.size.y - self.borderSize*2)
		end
	end;

    buttonCallback = function (self, ev)
		
    end;

	setTitle = function(self, name)
		self.window_title.text  = name
		self.window_title.position = vec2(self.window_title.size.x / 2, self.window_title.position.y)
	end;
}