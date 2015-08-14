------------------------------------------------------------------------------
--  Window
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `window_title_bar` {
	alpha = _current_theme.colours.window.titlebar_background_alpha;
	size = vec(256, 24);
	zOrder = 0;
	colour = _current_theme.colours.window.titlebar_background;
	dragging = false;
	draggingPos = vec2(0, 0);

	cornered = true;
	texture = _gui_textures.window.titlebar;
	
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
			set_active_window(self.parent.parent)
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

WindowClass = {
	colour = _current_theme.colours.window.background;
	alpha = _current_theme.colours.window.background_alpha;
	
	zOrder = 0;
	showCloseBtn = true;
	resizeable = true;
	title = "Window";
	
	min_size = vec2(150, 150);
	size = vec2(512, 400);

	borderSize = 2;

	init = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = true
		
		-- for resizing
		self.draggingPos = vec2(0, 0);
		self.originalSize = vec2(0, 0)
		self.originalPos = vec2(0, 0)

		if self.max_size == nil then
			self.max_size = vec2(gfx_window_size().x, gfx_window_size().y)
		end
		
		self.draggable_area = gfx_hud_object_add(`window_title_bar`, {
			position = vec2(0, 0);
			size = vec2(self.size.x, 24);
			zOrder = 2;
		})

		self.close_btn = create_button({				
				caption = "X";
				padding = vec(15, 2);
				cornered = true;
				texture = _gui_textures.window.closebtn;
				needsParentResizedCallbacks = true;
				baseColour = _current_theme.colours.window.closebtn_base;
				hoverColour = _current_theme.colours.window.closebtn_hover;
				clickColour = _current_theme.colours.window.closebtn_pressed;
				captionBaseColour = vec(1, 1, 1);
				parent = self.draggable_area;
				align_right = true;
				offset = vec(-2, 0);
		})

		self.close_btn.pressedCallback = function (self)
			self.parent.parent.parent.enabled = false
			-- safe_destroy(self.parent.parent.parent)
		end;
		
		-- disables the close button if you set showCLoseBtn to false when create the window
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
		self.window_title.colour = _current_theme.colours.window.titlebar_text
		self.window_title.position = vec(0, 0)
		
		self:setTitle(self.title)

		self.border = create_gui_object({
			size = vec2(self.size.x, self.size.y);
			colour = _current_theme.colours.window.border;
			alpha = _current_theme.colours.window.border_alpha;
			parent= self;
			cornered = true;
			texture = _gui_textures.window.border;
			zOrder = 3;
			expand = true;
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
			parent=self.left_resizer_Positioner;
			position=vec2(0, 0);
			alpha = 0;
			--texture=`../icons/res_lef.png`;
			needsInputCallbacks = true;
			mouseMoveCallback = function (self, local_pos, screen_pos, inside) if self.dragging == true then self.colour = vector3(1, 1, 1) end end;
		})

		self.right_resizer = gfx_hud_object_add(`resizer`, {
			size = vec2(16, 16);
			colour = V_ID;
			parent = self.right_resizer_Positioner;
			position = vec2(0, 0);
			alpha = 0.7;
			texture = _gui_textures.resizers.right;
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

hud_class `Window` (extends(WindowClass)
{
	init = function (self)
		WindowClass.init(self)
	end;
	
	destroy = function (self)
		WindowClass.destroy(self)
	end;
	
	buttonCallback = function(self, ev)
		WindowClass.buttonCallback(self, ev)
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		WindowClass.mouseMoveCallback(self, local_pos, screen_pos, inside)
	end;
})

_windows = {}

_current_window = _current_window

-- TODO: replace parameters by a single table
function create_window(w_title, pos, res, w_size, w_min_size, w_max_size, w_bk_colour, w_bk_alpha)
	local t_window = {}
	t_window = gfx_hud_object_add(`Window`, {
		title = w_title;
		parent = hud_center;
		position = pos;
		resizeable = res;
		size = w_size;
		min_size = w_min_size;
		colour = w_bk_colour or _current_theme.colours.window.background;
		alpha = w_bk_alpha or 1;
	})
	-- t_window.enabled = false
	_windows[#_windows+1] = t_window
	return t_window
end

function is_inside_window(window)
    if window.enabled then
        if mouse_pos_abs.x < gfx_window_size().x/2 + window.position.x + window.size.x/2 and
        mouse_pos_abs.x > gfx_window_size().x/2 + window.position.x - window.size.x/2 and
        mouse_pos_abs.y < gfx_window_size().y/2 + window.position.y + window.size.y/2 + window.draggable_area.size.y and
        mouse_pos_abs.y > gfx_window_size().y/2 + window.position.y - window.size.y/2 then
            return true
        end
    end
    return false
end

-- return true if the mouse cursor is inside any window
function mouse_inside_any_window()
	for i = 1, #_windows do
		if _windows[i] ~= nil and not _windows[i].destroyed then
			if is_inside_window(_windows[i]) then return true end
		end
	end
	
    if(env_cycle_editor.enabled and mouse_pos_abs.x < 530 and mouse_pos_abs.y < 430) or
    (music_player.enabled and mouse_pos_abs.x < 560 and mouse_pos_abs.y < 260)
    then
        return true
    end
    return false
end

function set_active_window(wnd)
	if _current_window ~= nil and not _current_window.destroyed and _current_window ~= wnd then
		_current_window.zOrder = 0
		_current_window.draggable_area.colour = _current_theme.colours.window.titlebar_background_inactive
		_current_window.window_title.colour = _current_theme.colours.window.titlebar_text_inactive
	end
	_current_window = wnd
	wnd.zOrder = 1
	wnd.draggable_area.colour = _current_theme.colours.window.titlebar_background
	wnd.window_title.colour = _current_theme.colours.window.titlebar_text
end;

function open_window(wnd)
    wnd.enabled = true
	set_active_window(wnd)
end;