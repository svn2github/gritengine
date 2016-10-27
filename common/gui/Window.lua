------------------------------------------------------------------------------
--  Window
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `window_title_bar`(extends(_gui.class)
{
	alpha = _current_theme.colours.window.titlebar_background_alpha;
	size = vec(256, 24);
	zOrder = 0;
	colour = _current_theme.colours.window.titlebar_background;
	dragging = false;
	draggingPos = vec2(0, 0);

	cornered = true;
	texture = _gui_textures.window.titlebar;
	align = guialign.top;
	
	init = function (self)
		_gui.class.init(self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks = true
		self.offset = vec(0, self.size.y)
	end;
	destroy = function (self)
		_gui.class.destroy(self)
		self.needsInputCallbacks = false
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging then
			self.parent.position = vec2(mouse_pos_abs.x - self.draggingPos.x, mouse_pos_abs.y - self.draggingPos.y)
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.parent.position.x, self.parent.position.y)
			set_active_window(self.parent)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
	
	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
		if self.parent ~= nil then
			self.size = vec2(self.parent.size.x, self.size.y)
		end
	end;
})

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
		self.needsInputCallbacks = true
		
		self.draggingPos = vec2(0, 0);
		self.originalSize = vec2(0, 0)
		self.originalPos = vec2(0, 0)

		if self.max_size == nil then
			self.max_size = vec2(gfx_window_size().x, gfx_window_size().y)
		end
		
		self.draggable_area = hud_object `window_title_bar` {
			position = vec2(0, 0);
			size = vec2(self.size.x, 24);
			zOrder = 4;
			parent = self;
		}

		self.close_btn = gui.button({				
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
				align = vec(1, 0);
				offset = vec(-2, 0);
		})

		self.close_btn.pressedCallback = function (self)
			self.parent.parent.enabled = false
			-- safe_destroy(self.parent.parent.parent)
		end;
		
		if self.showCloseBtn ~= nil then	
			if self.showCloseBtn == false then	
				self.close_btn.enabled = false
			end
		end

		self.titlePositioner = hud_object `/common/hud/Positioner` {
			parent = self.draggable_area;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		}
		
		self.window_title = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.window_title.parent = self.titlePositioner
		self.window_title.colour = _current_theme.colours.window.titlebar_text
		self.window_title.position = vec(0, 0)
		
		self:setTitle(self.title)

		self.border = gui.object({
			size = vec2(self.size.x, self.size.y);
			colour = _current_theme.colours.window.border;
			alpha = _current_theme.colours.window.border_alpha;
			parent= self;
			cornered = true;
			texture = _gui_textures.window.border;
			zOrder = 3;
			expand = true;
		})
		
		self.title = nil
		self.showCloseBtn = nil
	end;
	
	destroy = function (self)
		self:destroy()
	end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" then
			if self.resizeable then
				local mp = mouse_pos_abs
				local dpos = self.derivedPosition
				local size = self.size
				
				if mp.x > dpos.x + size.x/2 -15 and mp.x < dpos.x + size.x/2 and
				mp.y > dpos.y - size.y/2 and mp.y < dpos.y - size.y/2 +15 then
					self.right_resizer_dragging = true
					self.draggingPos =  mp
					self.originalSize = size
					self.originalPos = self.position
				elseif mp.x > dpos.x - size.x/2 and mp.x < dpos.x - size.x/2+15 and
				mp.y > dpos.y - size.y/2 and mp.y < dpos.y - size.y/2 +15 then
					self.left_resizer_dragging = true
					self.draggingPos =  mp
					self.originalSize = size
					self.originalPos = self.position
				end
			end
		elseif ev == "-left" then
			self.right_resizer_dragging = false
			self.left_resizer_dragging = false
			self.draggingPos = vec2(0, 0)
			self.originalSize = vec2(0, 0)
			self.originalPos = vec2(0, 0)		
        end
    end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.right_resizer_dragging then
			local wsize = vec2(self.originalSize.x + (-self.draggingPos.x + mouse_pos_abs.x), self.originalSize.y - (-self.draggingPos.y + mouse_pos_abs.y))

			self.size = vec2(math.clamp(wsize.x, self.min_size.x, self.max_size.x), math.clamp(wsize.y, self.min_size.y, self.max_size.y))
			self.position = vec2(self.originalPos.x - (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
		elseif self.left_resizer_dragging then
			local wsize = vec2(self.originalSize.x - (-self.draggingPos.x + mouse_pos_abs.x), self.originalSize.y - (-self.draggingPos.y + mouse_pos_abs.y))
			
			self.size = vec2(math.clamp(wsize.x, self.min_size.x, self.max_size.x), math.clamp(wsize.y, self.min_size.y, self.max_size.y))
			self.position = vec2(self.originalPos.x + (self.originalSize.x - self.size.x)/2, (self.originalPos.y + (self.originalSize.y - self.size.y)/2))	
		end
	end;

	setTitle = function(self, name)
		self.window_title.text  = name
		self.window_title.position = vec2(self.window_title.size.x / 2, self.window_title.position.y)
	end;
	
	isMouseInside = function(self)
		if mouse_pos_abs.x < self.derivedPosition.x + self.size.x/2 and
		mouse_pos_abs.x > self.derivedPosition.x - self.size.x/2 and
		mouse_pos_abs.y < self.derivedPosition.y + self.size.y/2 + self.draggable_area.size.y and
		mouse_pos_abs.y > self.derivedPosition.y - self.size.y/2 then
			return true
		end

		return false		
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
function gui.window(w_title, pos, res, w_size, w_min_size, w_max_size, w_bk_colour, w_bk_alpha)
	local t_window = {}
	
	if type(w_title) == "table" then
		t_window = hud_object `Window` (w_title)
	else
		t_window = hud_object `Window` {
			title = w_title;
			parent = hud_center;
			position = pos;
			resizeable = res;
			size = w_size;
			min_size = w_min_size;
			colour = w_bk_colour or _current_theme.colours.window.background;
			alpha = w_bk_alpha or 1;
		}
	end
	-- t_window.enabled = false
	_windows[#_windows+1] = t_window
	return t_window
end

function is_inside_window(window)
    if window.enabled then
		return window:isMouseInside()
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
