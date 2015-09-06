
hud_class `browser_icon2` {
	alpha = 0;
	size = vec(80, 80);
	colour=vec(1, 0, 0);
	zOrder = 0;
	hoverColour = vec(1, 0.5, 0);
	clickColour = vec(1, 0, 0);
	normalColour = vec(0.5, 0.5, 0.5);
	selectedColour = vec(1, 0.8, 0);
	name = "Default";
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.icon = create_rect({ texture=self.icon_texture, size=vec2(64, 64), parent=self, position=vec(0, 8)})
		self.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.text.text = self.name
		if self.text.size.x >= self.size.x then
			-- print("long name: "..self.name)
			self.text.text = self.name:reverse():sub(-9):reverse().."..."
			--self.name:reverse():gsub(".....", "...", 1):reverse()
		end
		self.text.position = vec2(0, -self.icon.size.y/2+5)
		self.text.parent = self
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		safe_destroy(_context_menu)
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		self.lp = local_pos
		if self.dragging ~= true and self.parent.parent.selected ~= self then
			if inside then
				self.colour = self.hoverColour
				self.alpha = 0.5
			else
				self.colour=self.normalColour
				self.alpha = 0
			end
		end
		self:mouseMoveCB(local_pos, screen_pos, inside)
	end;

    buttonCallback = function (self, ev)
        if ev == "+right" and self.inside then
			self.rightDragging = true
		elseif ev == "-right" then
			if self.inside and self.rightDragging then
				self:rightPressedCallback()
			end
			self.rightDragging = false
		end
		
		if ev == "+left" and self.inside then
            self.dragging = true
			self.draggingPos = self.lp
			self.colour = self.clickColour
			self.alpha = 1
			if self.lastClick ~= nil and seconds() - self.lastClick <= 1 then
				self:doubleClick()
				return
			end
			self.lastClick = seconds()
        elseif ev == "-left" then
            if self.dragging and not self.greyed then
				if self.inside then
					if self.parent.parent.selected ~= self then
						self.colour=self.hoverColour
					end
				
					if self.parent.parent.selected ~= self and self.parent.parent.selected ~= nil and self.parent.parent.selected.destroyed ~= true then
						self.parent.parent.selected.colour = self.parent.parent.selected.normalColour
						self.parent.parent.selected.alpha = 0
					end
					self.parent.parent.selected = self
					self.colour = self.selectedColour

					self:pressedCallback()
				else
					self.colour=self.normalColour
					self.alpha = 0
				end
			end
            self.dragging = false
        end
		self:bCallback(ev)
    end;

    bCallback = function (self, ev)

    end;
	
    pressedCallback = function (self)

    end;
	
    rightPressedCallback = function (self)

    end;	
	
	doubleClick = function(self)

	end;
	
    mouseMoveCB = function (self, local_pos, screen_pos, inside)

    end;
}

hud_class `dynamic_res_cb` {
	size = vec(0, 0);
	alpha = 1;
	icons_size = vec2(80, 80);
	
    init = function (self)
		self.needsParentResizedCallbacks = false;

    end;
	
	parentResizedCallback = function (self, psize)
		self:parentresizecb(psize)
	end;

	parentresizecb = function (self, psize)
		self.size = psize	
	end;
}

function char_count(str, char) 
    if not str then
        return 0
    end

    local count = 0 
    local byte_char = string.byte(char)
    for i = 1, #str do
        if string.byte(str, i) == byte_char then
            count = count + 1 
        end 
    end 
    return count
end

function get_class_dir(dir)
	local alc = class_all()
	local cnms = {}
	local classes = {}

	if dir == "/" or dir == "" then
		for i = 1, #alc do
			if char_count(alc[i].name:sub(2), "/") == 0 then
				classes[#classes+1] = alc[i].name:sub(2)
			end
		end
		return classes
	else
		for i = 1, #alc do
			if char_count(alc[i].name:sub(2), "/") == 0 then
				table.remove(alc, i)
			end
		end		
	end
	
	for i = 1, #alc do
		cnms[i] = string.gsub(alc[i].name, dir, ""):sub(2)
		
		if char_count(cnms[i], "/") == 0 and cnms[i] ~= "" then
			classes[#classes+1] = cnms[i]
		end
	end
	return classes
end

local function insidew()
    if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
        if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 52 then
            if not mouse_inside_any_window() and not mouse_inside_any_menu() then
                return true
            end
        end
    end
    return false
end

hud_class `content_browser_floating_object` {
	alpha = 1;
	size = vec(64, 64);
	texture = `/editor/core/icons/icons/objecticon.png`;
	id = 0;
	obclass = "";
	positioning = false;
	obj = nil;
	zOffset = 0;
	
	init = function (self)
		self.needsInputCallbacks = true
		local cl = class_get(self.obclass)
		self.zOffset = cl.placementZOffset or 0
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		
		self:destroy()
	end;
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self.position = vec2(mouse_pos_abs.x -gfx_window_size().x/2-self.draggingPos.x, mouse_pos_abs.y - gfx_window_size().y/2 -self.draggingPos.y)
		if insidew() then
			self.positioning = true
			local cast_ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
			local dist
			
			if self.obj ~= nil and not self.obj.destroyed and self.obj.instance ~= nil and self.obj.instance.body ~= nil then
			dist = physics_cast(main.camPos, cast_ray, true, 0, self.obj.instance.body)
			else
				dist = physics_cast(main.camPos, cast_ray, true, 0)
			end
			
			local pos = (main.camPos + cast_ray * (dist or 0.02)) + vec(0, 0, (self.zOffset or 0))
			
			if self.obj == nil then
				self.alpha = 0
				self.obj = object (self.obclass) (pos) { name = "Unnamed:"..self.obclass..":"..math.random(0, 50000) }
				self.obj:activate()
			else
				if self.obj.instance then
					if self.obj.instance.body then
						self.obj.instance.body.worldPosition = pos
					elseif self.obj.instance.gfx then
						self.obj.instance.gfx.localPosition = pos
					end
					self.obj.spawnPos = pos
				end
			end
		else
			self.alpha = 1
			safe_destroy(self.obj)
			self.obj = nil
		end
    end;
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			--
		elseif ev == "-left" then
			if not insidew() and self.positioning then
				safe_destroy(self.obj)
				self.obj = nil
			end
			if self.obj ~= nil and not self.obj.destroyed then
				current_map:registerObject(self.obj)
			end
			-- if insidew() then
				-- local cast_ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
				-- local dist = physics_cast(main.camPos, cast_ray, true, 0)

				-- local cl = class_get(self.obclass)

				-- local pos = (main.camPos + cast_ray * (dist or 0.02)) + (cl.placementZOffset or 0)
				
				-- object (self.obclass) (pos) { }
			-- end
			safe_destroy(self)
			addobjectelement = nil
        end
    end;
	
}

addobjectelement = nil
function create_floating(offset, mclass)
	if addobjectelement == nil then
		addobjectelement = gfx_hud_object_add(`content_browser_floating_object`, {
			parent = hud_center,
			draggingPos = offset,
			obclass = mclass,
			position = vec2((select(3, get_mouse_events()))-gfx_window_size().x/2-offset.x, (select(4, get_mouse_events())) - gfx_window_size().y/2 -offset.y)
		})
	end
end

hud_class `ContentBrowser` (extends(WindowClass)
{
	btn_size = vec(100, 25);
	currentdir = "/";
	
	init = function (self)
		WindowClass.init(self)
		
		-- self.close_btn.pressedCallback = function (self)
			-- safe_destroy(self.parent.parent.parent)
		-- end;
		
		self.dir_tree = create_gui_object({
			colour = vec(0.2, 0.2, 0.2);
			alpha = 1;
			parent = self;
			size = vec(180, self.size.y-120);
			align_left = true;
			align_top = true;
			offset = vec(5, -35);
			expand_y = true;
			expand_offset = vec(0, -35-10);
		})

		self.dir_tree.enabled = false
		
		self.file_explorer = gfx_hud_object_add(`/common/gui/file_list`, {
			colour = vec(0.5, 0.5, 0.5);
			parent = self;
		})
		self.file_explorer.size = vec2(self.size.x-20 -- self.dir_tree.size.x
		, self.size.y-70)
		self.file_explorer.position = vec(0--self.size.x/2-self.file_explorer.size.x/2-10
		, -15)

		self.file_explorer.parentresizecb = function(self, psize)
			self.size = vec2(psize.x--self.parent.dir_tree.size.x
			-20, psize.y-70)
		end;
		
		self.file_explorer.addItem = function(self, m_name, icon, pc, dpc, ccb)
			if icon == nil then icon = `/common/gui/icons/icons/foldericon.png`end
			self.items[#self.items+1] = gfx_hud_object_add(`browser_icon2`, {
				icon_texture = icon;
				position = vec2(0, 0);
				parent = self.grid;
				colour = vec(0.5, 0.5, 0.5);
				size = vec2(self.icons_size.x, self.icons_size.y);
				name = m_name;
			})
				
			if pc ~= nil then
				self.items[#self.items].pressedCallback = pc
			end
			
			if dpc ~= nil then
				self.items[#self.items].doubleClick = dpc
			end

			if ccb ~= nil then
				self.items[#self.items].clickCallback = ccb
			end
			
			self:reorganize()
			return self.items[#self.items]
		end;

		self.updir_btn = create_imagebutton({
			pressedCallback = function(self)
				if self.parent.currentdir == "/" or self.parent.currentdir == "" then return end
				self.parent.currentdir = self.parent.currentdir:reverse():sub(self.parent.currentdir:reverse():find("/", 2)+1):reverse()
				
				if self.parent.currentdir == "" then self.parent.currentdir = "/" end
				self.parent.dir_edbox:setValue(self.parent.currentdir)
				self.parent:update_file_explorer(self.parent.currentdir)
			end;
			icon_texture = _gui_textures.arrow_up;
			position = vec2(0, 0);
			parent = self;
			colour = vec(1, 1, 1)*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(-5, -5);
			align_right = true;
			align_top = true;			
		})

		self.dir_edbox = gfx_hud_object_add(`/common/gui/window_editbox`, {
			colour = vec(0.5, 0.5, 0.5);
			parent = self;
			value = self.currentdir;
			alignment = "LEFT";
			size = vec(50, 20);
			offset = vec(5, -8);
			align_left = true;
			align_top = true;
			expand_x = true;
			expand_offset = vec(-45, 0);
		})
		self.dir_edbox.enterCallback = function(self)
			self.parent:update_file_explorer(self.value)
			self.parent.currentdir = self.value
		end;
		self:update_file_explorer()
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
	
	update_file_explorer = function(self, m_dir)
		self.file_explorer:clearAll()
		m_dir = m_dir or ""
		local m_files, m_folders = get_dir_list(m_dir:gsub("/", "", 1))
		
		m_files = get_class_dir(m_dir)

		for i = 1, #m_folders do
			local nit = nil
			
			nit = self.file_explorer:addItem(m_folders[i], `/common/gui/icons/foldericon.png`)
			nit.doubleClick = function(self)
				if string.sub(self.parent.parent.parent.currentdir, -1) ~= "/" then
					self.parent.parent.parent.currentdir = self.parent.parent.parent.currentdir.."/"..self.name
				else
					self.parent.parent.parent.currentdir = self.parent.parent.parent.currentdir..self.name
				end
				self.parent.parent.parent.dir_edbox:setValue(self.parent.parent.parent.currentdir)
				self.parent.parent.parent:update_file_explorer(self.parent.parent.parent.currentdir)
			end	
		end

		for i = 1, #m_files do
				local nit = nil
				nit = self.file_explorer:addItem(m_files[i], `/editor/core/icons/icons/objecticon.png`)
				nit.pressedCallback = function (self)
					-- self. adding = true
					-- create_floating(self.lp, self.parent.parent.parent.currentdir.."/"..self.name)
				end;
				nit.doubleClick = function(self)

				end;
				
				nit.rightPressedCallback = function (self)
					cb_show_object_menu(self)
				end;
				
				nit.bCallback = function (self, ev)
					if (ev == "+right" or ev == "+left") and not _context_menu.destroyed and not is_inside_menu(_context_menu) then
						safe_destroy(_context_menu)
					end
				end;
				
				nit.mouseMoveCB = function (self, local_pos, screen_pos, inside)
					if self.dragging and #(local_pos - self.draggingPos) > 15 then
						self.adding = true
						create_floating(self.lp, self.parent.parent.parent.currentdir.."/"..self.name)
					end
				end;
		end
		if self.file_explorer ~= nil then
			self.file_explorer:reset()
		end
	end;
})

function cb_show_object_menu(selection)
	show_context_menu(
	{
		{
			callback = function()
				new_object_ed_page(selection.name, editor_interface.map_editor_page.windows.content_browser, true)
			end;
			name = "Edit Object";
			endPressedCallback = function (self)
				self.parent:destroy()
			end;
		},
		{
			callback = function()
				print("TODO")
			end;
			name = "Add in viewport";
			endPressedCallback = function (self)
				self.parent:destroy()
			end;
		},
	})
end

content_browserx = nil

function create_content_browser()
	if content_browserx ~= nil and not content_browserx.destroyed then
		content_browserx:destroy()
	end
	
	content_browserx = gfx_hud_object_add(`ContentBrowser`, {
		title = "Class Browser";
		parent = hud_center;
		position = vec(230, -200);
		resizeable = true;
		size = vec2(560, 320);
		min_size = vec2(470, 235);
		colour = _current_theme.colours.window.background;
		alpha = 1;	
	})
	_windows[#_windows+1] = content_browserx
	set_active_window(content_browserx)
	return content_browserx
end
