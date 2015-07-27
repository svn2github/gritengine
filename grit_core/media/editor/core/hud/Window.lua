-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `window_title_bar` {
	alpha = 1;
	size = vec(256, 24);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	draggingPos = vec2(0, 0);

	cornered=true;
	texture=`/editor/core/icons/titlebar.png`;
	
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
			self.parent.parent.position = vec2(mouse_pos_abs.x - self.draggingPos.x, mouse_pos_abs.y - self.draggingPos.y)
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.parent.parent.position.x, self.parent.parent.position.y)
			GED:setActiveWindow(self.parent.parent)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
	
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.size = vec2(self.parent.parent.size.x, self.size.y)
		end
	end;
}

hud_class `resizer` {
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
		elseif ev == "-left" then
			self.dragging = false
			self.parent.parent.parent.draggingPos = vec2(0, 0)
			self.parent.parent.parent.originalSize = vec2(0, 0)
			self.parent.parent.parent.originalPos = vec2(0, 0)		
        end
    end;
}

hud_class `window_border` {
	
	init = function (self)
		self.needsParentResizedCallbacks= true
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.size = vec2(self.parent.size.x, self.parent.size.y)
		end
	end;
}

hud_class `Window` {
	alpha = 0.7;
	zOrder = 0;
	showCloseBtn = true;
	resizeable = true;
	title = "Window";
	min_size = vec2(150, 150);
	size = vec2(512, 400);
	colour = vector3(0, 0.5, 1);
	borderSize = 2;

	init = function (self)
		self.needsFrameCallbacks = false;
		self.needsInputCallbacks = true;
		
		-- for resizing
		self.draggingPos = vec2(0, 0);
		self.originalSize = vec2(0, 0)
		self.originalPos = vec2(0, 0)

		if self.max_size == nil then
			self.max_size = vec2(gfx_window_size().x, gfx_window_size().y)
		end
		
		self.draggable_area = gfx_hud_object_add(`window_title_bar`, {
			--parent = self;
			position = vec2(0, 0);
			size = vec2(self.size.x, 24);
			colour = vector3(1, 1, 1);
			zOrder = 2;
			alpha=1;
		})

		self.close_btn = gfx_hud_object_add(`/common/hud/Button`, {				
				caption = "X";
				padding = vec(15, 2);
				cornered=true;
				texture=`../icons/FilledWhiteBorder042.png`;
				needsParentResizedCallbacks = true;
				parentResizedCallback = function(self, psize) self.position = vec2(psize.x/2-self.size.x/2, self.position.y) end;
				baseColour = vec(1,1,1) * 0.3;
				hoverColour = vec(1, 1, 1) * 0.45;
				clickColour = vec(1, 1, 1)* 0.7;
		})
		self.close_btn.border.enabled=false
		
		self.buttonPositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.draggable_area;
			offset = vec2(-self.close_btn.size.x/2-2, 0);
			factor = vec2(0.5, 0);
		})
		
		self.close_btn.parent = self.buttonPositioner 
		self.close_btn.pressedCallback = function (self)
			self.parent.parent.parent.parent.enabled = false
		end;
		
		-- disables the close button if you set showCLoseBtn to false when creates the window
		if self.showCloseBtn ~= nil then	
			if self.showCloseBtn == false then	
				self.close_btn.enabled = false
			end
		end

		self.titlePositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.draggable_area;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})
		
		self.window_title = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.window_title.parent = self.titlePositioner
		self.window_title.colour = vector3(0, 0, 0)
		self.window_title.position = vec(0, 0)
		
		self:setTitle(self.title)

		self.border = gfx_hud_object_add(`window_border`, {
			size = vec2(self.size.x, self.size.y);
			colour=vector3(0.6, 0.6, 0.6);
			alpha=1;
			parent= self;
			cornered=true;
			texture=`/editor/core/icons/window_border.png`;
			zOrder=3;
		})
		
		self.titleBarPositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(0, self.draggable_area.size.y/2);
			factor = vec2(0, 0.5);
		})		

		self.draggable_area.parent = self.titleBarPositioner

		self.left_resizer_Positioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.border;
			offset = vec2(8 - self.borderSize, 8 - self.borderSize);
			factor = vec2(-0.5, -0.5);
		})

		self.right_resizer_Positioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.border;
			offset = vec2(-8 + self.borderSize, 8 - self.borderSize);
			factor = vec2(0.5, -0.5);
		})

		self.left_resizer = gfx_hud_object_add(`resizer`, {
			size = vec2(16, 16);
			colour = vector3(0.5, 0.5, 0.5);
			parent=self.left_resizer_Positioner;
			position=vec2(0, 0);
			alpha=0;
			--texture=`../icons/res_lef.png`;
			needsInputCallbacks = true;
			mouseMoveCallback = function (self, local_pos, screen_pos, inside) if self.dragging == true then self.colour = vector3(1, 1, 1) end end;
		})

		self.right_resizer = gfx_hud_object_add(`resizer`, {
			size = vec2(16, 16);
			colour = vector3(1, 1, 1);
			parent=self.right_resizer_Positioner;
			position=vec2(0, 0);
			alpha=0.7;
			texture=`../icons/res_rig.png`;
		})
		if self.resizeable == false then
			self.left_resizer.enabled = false
			self.right_resizer.enabled = false
		end
		
		-- used just for initialize
		self.title = nil
		self.resizeable = nil
		self.showCloseBtn = nil
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false

		self:destroy()
	end;
	
	buttonCallback = function(self, ev)end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.right_resizer.dragging == true then
			local wsize = vec2(self.originalSize.x - (self.draggingPos.x + (gfx_window_size().x/2) - screen_pos.x) + math.abs((self.right_resizer.drag_offset.x + (self.right_resizer.size.x/2)) -self.right_resizer.size.x),  self.draggingPos.y + (gfx_window_size().y/2) - screen_pos.y + (self.right_resizer.drag_offset.y + (self.right_resizer.size.y/2)))
			
			self.size = vec2(math.clamp(wsize.x, self.min_size.x, self.max_size.x), math.clamp(wsize.y, self.min_size.y, self.max_size.y))
			self.position=vec2(self.originalPos.x - (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
		elseif self.left_resizer.dragging == true then
			local wsize = vec2(self.draggingPos.x + (gfx_window_size().x/2) - screen_pos.x + (self.left_resizer.drag_offset.x + (self.left_resizer.size.x/2)),  self.draggingPos.y + (gfx_window_size().y/2) - screen_pos.y + math.abs(self.left_resizer.drag_offset.y + (self.left_resizer.size.y/2)) )	
			
			self.size = vec2(math.clamp(wsize.x, self.min_size.x, self.max_size.x), math.clamp(wsize.y, self.min_size.y, self.max_size.y))
			self.position=vec2(self.originalPos.x + (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
		end
	end;

	setTitle = function(self, name)
		self.window_title.text  = name
		self.window_title.position = vec2(self.window_title.size.x / 2, self.window_title.position.y)
	end;
}

function create_window(w_title, pos, res, w_size, w_min_size, w_max_size, w_bk_colour, w_bk_alpha)
	local t_window = {}
	t_window = gfx_hud_object_add(`Window`, {
		title=w_title;
		parent=hud_center;
		position=pos;
		resizeable=res;
		size=w_size;
		min_size = w_min_size;
		colour = w_bk_colour or vec(0.3, 0.3, 0.3);
		alpha = w_bk_alpha or 1;
	})
	-- t_window.enabled = false
	return t_window
end