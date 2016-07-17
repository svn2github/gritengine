------------------------------------------------------------------------------
--  File Dialog
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

include`/editor/core/util.lua`

hud_class `window_editbox` (extends(table_concat_copy(GuiClass, EditBox))
{
	alpha = 1;
	init = function (self)
		GuiClass.init(self)
		EditBox.init(self)
	end;
	
	destroy = function (self)
		GuiClass.destroy(self)
		EditBox.destroy(self)
	end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
		self:parentresizecb(psize)
		self:updateChildrenSize()		
	end;
	
	parentresizecb = function (self, psize)

	end;

    setEditting = function (self, editting, no_callback)
		if not editting then self:enterCallback() end
		EditBox.setEditting(self, editting, no_callback)
		editor_core_move_binds.enabled = not editting
    end;
})

hud_class `browser_icon` {
	alpha = 0;
	size = vec(80, 80);
	colour = vec(1, 0, 0);
	zOrder = 0;
	
	hoverColour = _current_theme.colours.browser_icon.hover;
	clickColour = _current_theme.colours.browser_icon.click;
	defaultColour = _current_theme.colours.browser_icon.default;
	selectedColour = _current_theme.colours.browser_icon.selected;
	textHoverColour = _current_theme.colours.browser_icon.text_hover;
	textClickColour = _current_theme.colours.browser_icon.text_click;
	textSelectedColour = _current_theme.colours.browser_icon.text_selected;
	textDefaultColour = _current_theme.colours.browser_icon.text_default;
	
	name = "Default";
	type = "";
	
	init = function (self)
		self.needsInputCallbacks = true
		self.icon = create_rect({ texture = self.icon_texture, size = vec2(64, 64), parent = self, position = vec(0, 8) })
		self.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.text.text = self.name
		if self.text.size.x >= self.size.x then
			-- print("long name: "..self.name)
			self.text.text = self.name:reverse():sub(-9):reverse().."..."
			--self.name:reverse():gsub(".....", "...", 1):reverse()
		end
		self.text.position = vec2(0, -self.icon.size.y/2+5)
		self.text.parent = self
		self.text.colour = self.textDefaultColour
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if not self.dragging and self.parent.parent.selected ~= self then
			if inside then
				self.colour = self.hoverColour
				self.alpha = 0.5
			else
				self.colour = self.defaultColour
				self.alpha = 0
			end
		end
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.colour = self.clickColour
			self.text.colour = self.textClickColour
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
						self.colour = self.hoverColour
						self.text.colour = self.textHoverColour
					end
				
					if self.parent.parent.selected ~= self and self.parent.parent.selected ~= nil and self.parent.parent.selected.destroyed ~= true then
						self.parent.parent.selected.colour = self.parent.parent.selected.defaultColour
						self.parent.parent.selected.alpha = 0
					end
					self.parent.parent.selected = self
					self.colour = self.selectedColour
					self.text.colour = self.textSelectedColour

					self:pressedCallback()
				else
					self.colour = self.defaultColour
					self.text.colour = self.textDefaultColour
					self.alpha = 0
				end
			end
            self.dragging = false
        end
    end;

    pressedCallback = function (self)

    end;

	doubleClick = function(self)

	end;
}

hud_class `file_list` (extends(GuiClass)
{
	size = vec(0, 0);
	alpha = 1;
	icons_size = vec2(80, 80);
    icons_spacing = 4;
	selected = {};
	colour = _current_theme.colours.file_explorer.background;
	
    init = function (self)
		self.needsParentResizedCallbacks = true
		self.needsInputCallbacks = true
		self.items = {}
    end;
	
	parentResizedCallback = function (self, psize)
		self.size = vec(psize.x, self.size.y)
		self:reorganize()
	end;

	addItem = function(self, m_name, icon, pc, dpc)
		if icon == nil then icon = `/common/gui/icons/foldericon.png`end
		self.items[#self.items+1] = gfx_hud_object_add(`browser_icon`, {
			icon_texture = icon;
			position = vec2(0, 0);
			parent = self;
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
		
		self:reorganize()
		return self.items[#self.items]
	end;
	
	reorganize = function(self)
		local colums = math.floor(self.size.x / (#self.icons_size.x + self.icons_spacing))
		local icol, linepos, li = 1, 0, 1

		
		for i = 1, #self.items do
			self.items[i].position = vec2(-self.size.x/2 + ((li-1) * (self.icons_size.x )) + (li*self.icons_spacing) + self.icons_size.x/2, self.size.y/2 - self.icons_size.y/2 -linepos*(self.icons_size.y+self.icons_spacing))
			if(icol < colums) then
				li = li+1
				icol=icol+1
			else
				linepos=linepos+1
				icol=1
				li = 1
			end
		end
		
		self.iconarea = vec2(colums*(self.icons_size.x+self.icons_spacing), math.ceil(#self.items/colums)*(self.icons_size.y+self.icons_spacing))
		
		self.size = vec(self.size.x, self.iconarea.y)
		
		self:updateItems()
	end;
	clearAll = function(self)
		for i = 1, #self.items do
			safe_destroy(self.items[i])
			self.items[i] = nil
		end
	end;
	
	reset = function(self)
		self:reorganize()
		self:updateItems()

	end;	

	updateItems = function(self)
		for i = 1, #self.items do
			--if (self.items[i].position.y + self.position.y + self.items[i].size.y/2 < -self.parent.size.y/2 or self.items[i].position.y + self.position.y - self.items[i].size.y > self.parent.size.y/2) then
			-- TEMPORARY(until draw only inside parent): (after that, use the commented line above)
			if (self.items[i].position.y + self.position.y - self.items[i].size.y/2 < -self.parent.size.y/2-10 or self.items[i].position.y + self.position.y + self.items[i].size.y/2 > self.parent.size.y/2+10) then
				self.items[i].enabled = false
			else
				self.items[i].enabled = true
			end
		end	
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		if self.parent.scrollbar_y.dragging then
			self:updateItems()
		end
	end;

    buttonCallback = function (self, ev)
    end;
})

hud_class `FileDialog` (extends(WindowClass)
{
	btn_size = vec(100, 25);
	
	choices = { "All Files (*.*)" };
	
	init = function (self)
		WindowClass.init(self)
		
		self.currentdir = "/";
		
		self.ok_button = create_button({
			caption = "OK";
			parent = self;
			pressedCallback = function (self)
				self.parent:handleCallback()
			end;
			cornered = true;
			texture = _gui_textures.button;
			align = vec(1, -1);
			offset = vec(-10, 45);
			padding = vec(30, 4);
			size = self.btn_size;
		})		
		self.cancel_button = create_button({
			caption = "Cancel";
			parent = self;
			pressedCallback = function (self)
				self.parent.enabled = false
			end;
			cornered = true;
			texture = _gui_textures.button;
			align = vec(1, -1);
			offset = vec(-10, 15);
			padding = vec(30, 4);
			size = self.btn_size;
		})		
		self.selectbox = create_selectbox({
			parent = self;
			choices = self.choices;
			selection = 0;
			align = vec(-1, -1);
			offset = vec(5, 20);
			expand_x = true;
			expand_offset = vec(-130, 0);
			size = vec(22, 22);
			zOrder = 4;
		})	
		self.selectbox.onSelect = function(self)
			self.parent:update_file_explorer(self.parent.currentdir)
		end;
		
		self.file_edbox = gfx_hud_object_add(`window_editbox`, {
			parent = self;
			value = "";
			alignment = "LEFT";
			enterCallback = function(self)
				self.parent:handleCallback()
			end;
			size = vec(50, 20);
			align = vec(-1, -1);
			offset = vec(5, 45);
			expand_x = true;
			expand_offset = vec(-130, 0);
			
		})
		self.file_edbox:setEditting(true)
		
		self.scrollarea = gfx_hud_object_add(`/common/gui/ScrollArea`, {
			parent = self;
			expand_x = true;
			expand_y = true;
			expand_offset = vec(-120, -120);
			align = vec(-1, 1);
			offset = vec(115, -40);
			x_bar = false;
		})
		
		self.file_explorer = gfx_hud_object_add(`file_list`, {
			position = vec2(0, 0);
			parent = self;
			size = vec2(self.size.x-20, self.size.y-120);
			alpha = 0;
			zOrder = 1;
		})
		--self.file_explorer.enabled = false
		self.scrollarea:setContent(self.file_explorer)
		
		self.updir_btn = create_imagebutton({
			pressedCallback = function(self)
				if self.parent.currentdir == "/" or self.parent.currentdir == "" then return end
				self.parent.currentdir = self.parent.currentdir:reverse():sub(self.parent.currentdir:reverse():find("/", 2)+1):reverse()
				
				if self.parent.currentdir == "" then self.parent.currentdir = "/" end
				self.parent.dir_edbox:setValue(self.parent.currentdir)
				self.parent:update_file_explorer(self.parent.currentdir)
			end;
			icon_texture = _gui_textures.arrow_up;
			parent = self;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(15, -5);
			align = vec(-1, 1);
			zOrder = 4;
		})

		self.newfolder_btn = create_imagebutton({
			pressedCallback = do_nothing;
			icon_texture = _gui_textures.new_folder;
			parent = self;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(-35, -5);
			align = vec(1, 1);
		})

		self.iconsize_btn = create_imagebutton({
			pressedCallback = do_nothing;
			icon_texture = `/editor/core/icons/map_editor/content_browser.png`;-- TODO: replace by a specific icon
			parent = self;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(-5, -5);
			align = vec(1, 1);
		})

		self.dir_edbox = gfx_hud_object_add(`window_editbox`, {
			parent = self;
			value = self.currentdir;
			alignment = "LEFT";
			size = vec(50, 20);
			offset = vec(50, -8);
			align = vec(-1, 1);
			expand_x = true;
			expand_offset = vec(-120, 0);
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
		self.file_explorer.selected = nil
		m_dir = m_dir or ""
		local m_files, m_folders = get_dir_list(m_dir:gsub("/", "", 1))

		for i = 1, #m_folders do
			local nit = nil
			
			nit = self.file_explorer:addItem(m_folders[i], `/common/gui/icons/foldericon.png`)
			nit.type = "folder"
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
		--local selext = self.selectbox.selected.name:sub(-5):gsub([[\)]], "", 1)	
		local selext = self.selectbox.selected.name:_match("%((.-)%)"):sub(3)
		
		for i = 1, #m_files do
			if get_extension(m_files[i]) == selext then
				local nit = nil
				if selext == "lua" then
					-- TODO: this is not a good place to declare these editor icons
					nit = self.file_explorer:addItem(m_files[i], `/editor/core/icons/icons/luaicon.png`)
				elseif selext == "gmap" then
					nit = self.file_explorer:addItem(m_files[i], `/editor/core/icons/icons/worldicon.png`)
				else
					nit = self.file_explorer:addItem(m_files[i], `/common/gui/icons/fileicon.png`)
				end
				nit.type = "file"
				nit.pressedCallback = function (self)
					self.parent.parent.parent.file_edbox:setValue(self.name)
				end;
				
				nit.doubleClick = function(self)
					self.parent.parent.parent:handleCallback()
				end;
			end
		end
		if self.scrollarea ~= nil then
			self.scrollarea:reset()
		end
		if self.file_explorer ~= nil then
			self.file_explorer:reset()
		end
	end;

	handleCallback = function(self)
		if self.file_edbox.value ~= "" then
			local cd = self.currentdir
			-- remove the slash if it is the first character
			if cd:sub(1, 1) == "/" then
				cd = cd:sub(2)
			end
			
			-- add a slash if the last character isn't a slash
			if cd:sub(-1) ~= "/" and #cd > 0 then
				cd = cd.."/"
			end

			local filepath = cd..self.file_edbox.value

			local selext = self.selectbox.selected.name:_match("%((.-)%)"):sub(3)
			
			-- add the extension if the user forget it
			if get_extension(self.file_edbox.value) ~= selext then
				filepath = filepath.."."..selext
			end
			
			if self:callback(filepath) then
				self:destroy()
			end
		-- open the selected folder
		elseif self.file_explorer.selected ~= nil and self.file_explorer.selected.type == "folder" then
			self.file_explorer.selected:doubleClick()
		end
	end;
	callback = function(self, str)
		return true
	end;
})

open_file_dialog = nil
save_file_dialog = nil

function create_filedialog(options)
	local t_window = {}
	t_window = gfx_hud_object_add(`FileDialog`, options)
	_windows[#_windows+1] = t_window
	return t_window
end

function create_openfiledialog(options)
	if open_file_dialog ~= nil and not open_file_dialog.destroyed then
		open_file_dialog:destroy()
	end
	
	return create_filedialog(options)
end

function create_savefiledialog(options)
	if save_file_dialog ~= nil and not save_file_dialog.destroyed then
		save_file_dialog:destroy()
	end

	return create_filedialog(options)
end