------------------------------------------------------------------------------
--  File Dialog
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO: after implementing the scroll area, update the file list

-- TODO: move this class to another place, or update /common/hud/editbox
hud_class `window_editbox` (extends(GuiClass)
{
    textColour = vec(1, 1, 1);
    borderColour = vec(1, 1, 1)*0.5;
    padding = 4;
    colour = 0.25 * vec(1, 1, 1);
    texture = `/common/hud/CornerTextures/Filled02.png`;
    cornered = true;
    font = `/common/fonts/Verdana12`;
    value = "Text";
    number = false;
    alignment = "CENTER";
	alpha = 1;
	
    init = function (self)
		GuiClass.init(self)
		self.needsParentResizedCallbacks = true;  
        self.needsInputCallbacks = true
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self

        self.border = create_rect({
            texture = `/common/hud/CornerTextures/Border02.png`;
            colour = self.borderColour;
            cornered = true;
            parent = self;
        })

        self.caret = create_rect({
            texture = `/common/hud/CornerTextures/Caret.png`;
            colour = self.textColour;
            cornered = true;
            parent = self;
        })

        self.inside = false
        self:setGreyed(not not self.greyed)
        self.caret.enabled = false

        self:setValue(self.value)
    end;

    updateText = function (self)
        self.text.text = self.before .. self.after
        self:updateChildrenSize()
        self.value = self.before .. self.after
    end;
    
    setGreyed = function (self, v, no_callback)
        if v then
            self.text.colour = vec(0.5, 0.5, 0.5)
            self:setEditting(false, no_callback)
        else
            self.text.colour = self.textColour
        end
        self.greyed = v
    end;
    
    destroy = function (self)
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside and local_pos
    end;

    onEditting = function (self, editting)
    end;
    
    setEditting = function (self, editting, no_callback)
        local currently_editting = hud_focus == self
        if currently_editting == editting then return end
        if self.greyed then return end
        hud_focus_grab(editting and self or nil)
        self:onEditting(editting)
    end;

    setFocus = function (self, editting)
        self.caret.enabled = editting
        self.needsFrameCallbacks = editting
    end;

	enterCallback = function(self)

	end;
	
	
    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" then
            if not self.inside then
                self:setEditting(false)
            else
                self:setEditting(true)
                local txt = self.value
                local pos = text_char_pos(self.font, txt, self.inside.x + self.size.x/2 - self.padding)
                self.before = txt:sub(1, pos)
                self.after = txt:sub(pos+1)
                self:updateText()
            end
        elseif hud_focus == self then
            if ev == "+Return" then
                self:setEditting(false)
				self:enterCallback()
            elseif ev == "+BackSpace" or ev == "=BackSpace" then
                self.before = self.before:sub(1, -2)
                self:updateText()
                self:onChange(self)
            elseif ev == "+Delete" or ev == "=Delete" then
                self.after = self.after:sub(2)
                self:updateText()
                self:onChange(self)
            elseif ev == "+Left" or ev == "=Left" then
                if #self.before > 0 then
                    local char = self.before:sub(-1, -1)
                    self.before = self.before:sub(1, -2)
                    self.after = char .. self.after
                    self:updateText()
                end
            elseif ev == "+Right" or ev == "=Right" then
                if #self.after > 0 then
                    local char = self.after:sub(1, 1)
                    self.after = self.after:sub(2)
                    self.before = self.before .. char
                    self:updateText()
                end
            elseif ev:sub(1,1) == ":" then
                if self.maxLength == nil or #self.value < self.maxLength then
                    local key = ev:sub(2)
                    local text = self.value
                    if not self.number or
                       key:match("[0-9]") or
                       (key == "." and not text:match("[.]"))
                    then
                        self.before = self.before .. ev:sub(2)
                        self:updateText()
                        self:onChange(self)
                    end
                end
            end
        end
    end;
    
    frameCallback = function (self)
        local state = (seconds() % 0.5) / 0.5
        self.caret.enabled = state < 0.66
    end;

    updateChildrenSize = function (self)
        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
            self.text.position = - vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)
        elseif self.alignment == "RIGHT" then
            self.text.position = vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)
        end
        self.caret.size = vec(self.caret.size.x, self.size.y-4)
        self.border.size = self.size
        local tw = gfx_font_text_width(self.font, self.before)
        self.caret.position = vec(self.text.position.x -self.text.size.x/2 + tw, 0)
    end;
    
    onChange = function (self)
        -- By default, do nothing, since often people will only care when enter is pressed.
    end;
    
    setValue = function (self, value)
        self.before = value
        self.after = ""
        self:updateText()
    end;

	parentResizedCallback = function (self, psize)
		GuiClass.parentResizedCallback(self, psize)
		self:parentresizecb(psize)
		self:updateChildrenSize()
	end;  	

	parentresizecb = function (self, psize)

	end;  	
})

hud_class `browser_icon` {
	alpha = 0;
	size = vec(80, 80);
	colour = vec(1, 0, 0);
	zOrder = 0;
	hoverColour = vec(1, 0.5, 0);
	clickColour = vec(1, 0, 0);
	normalColour = vec(0.5, 0.5, 0.5);
	selectedColour = vec(1, 0.8, 0);
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
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.dragging ~= true and self.parent.parent.selected ~= self then
			if inside then
				self.colour = self.hoverColour
				self.alpha = 0.5
			else
				self.colour = self.normalColour
				self.alpha = 0
			end
		end
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.colour=self.clickColour
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
					self.colour = self.normalColour
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
	
    init = function (self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
		self.items = {}
		self.grid = create_rect({ alpha = 0, parent = self })
		
		self.rollbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(-5, 0);
			factor = vec2(0.5, 0);
			zOrder = 7;
		})

		self.rollbar = gfx_hud_object_add(`/common/gui/rollbar`, { parent = self.rollbar_pos })
		self.rollbar.roll.updateSize = function(self)
			if self.parent.parent.parent.iconarea ~= nil then
				if self.parent.parent.parent.iconarea.y ~= 0 then
					self.size = vec2(self.size.x, math.min(self.parent.parent.parent.size.y / (self.parent.parent.parent.iconarea.y / self.parent.parent.parent.size.y), self.parent.parent.parent.size.y-self.parent.up.size.y*2))
				end
				self.position = vec2(self.position.x, math.clamp(mouse_pos_abs.y - self.draggingPos.y, -(self.parent.size.y/2 -self.size.y/2-self.parent.up.size.y), self.parent.size.y/2 -self.size.y/2-self.parent.down.size.y))
			end
		end;
    end;
	
	parentResizedCallback = function (self, psize)
		self:parentresizecb(psize)
		self:reorganize()
	end;

	parentresizecb = function (self, psize)
		self.size = psize	
	end;	
	
	addItem = function(self, m_name, icon, pc, dpc)
		if icon == nil then icon = `/common/gui/icons/foldericon.png`end
		self.items[#self.items+1] = gfx_hud_object_add(`browser_icon`, {
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
		
		for i = 1, #self.items do
			if (self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y - self.items[i].size.y > self.size.y/2) then
				self.items[i].enabled = false
			else
				self.items[i].enabled = true
			end
		end
	end;
	clearAll = function(self)
		for i = 1, #self.items do
			safe_destroy(self.items[i])
			self.items[i]=nil
		end
	end;

    reset = function (self)
		self.grid.position = vec(0, 0)
		self:updateItems()
		self.rollbar.roll:updateSize()
    end;	

	updateItems = function(self)
		for i = 1, #self.items do
			-- if (self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y - self.items[i].size.y > self.size.y/2) then
			-- TEMPORARY(until draw only inside parent): (after that, use the commented line above)
			if (self.items[i].position.y + self.grid.position.y - self.items[i].size.y/2 < -self.size.y/2 or self.items[i].position.y + self.grid.position.y + self.items[i].size.y/2 > self.size.y/2) then
				self.items[i].enabled = false
			else
				self.items[i].enabled = true
			end
		end	
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		--if self.rollbar.roll.dragging == true then
			self:updateItems()
		--end
	end;

    buttonCallback = function (self, ev)
    end;
})

hud_class `FileDialog` (extends(WindowClass)
{
	btn_size = vec(100, 25);
	currentdir = "/";
	
	init = function (self)
		WindowClass.init(self)
		
		self.ok_button = create_button({
			caption = "OK";
			parent = self;
			pressedCallback = function (self)
				self.parent:handleCallback()
			end;
			cornered = true;
			texture = _gui_textures.button;
			align_right = true;
			align_bottom = true;
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
			align_right = true;
			align_bottom = true;
			offset = vec(-10, 15);
			padding = vec(30, 4);
			size = self.btn_size;
		})		
		self.selectbox = create_selectbox({
			parent = self;
			choices = { "Grit Level (*.lvl)", "Lua Script (*.lua)" };
			selection = 0;
			align_bottom = true;
			align_left = true;
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
			colour = vec(0.5, 0.5, 0.5);
			parent = self;
			value = "";
			alignment = "LEFT";
			enterCallback = function(self)
				self.parent:handleCallback()
			end;
			size = vec(50, 20);
			align_left = true;
			align_bottom = true;
			offset = vec(5, 45);
			expand_x = true;
			expand_offset = vec(-130, 0);
			
		})
		self.file_edbox:setEditting(true)

		self.file_explorer = gfx_hud_object_add(`file_list`, {
			colour = vec(0.5, 0.5, 0.5);
			parent = self;
			position = vec2(0, 20);
			size = vec2(self.size.x-20, self.size.y-120);
			parentresizecb = function(self, psize)
				self.size = vec2(psize.x-20, psize.y-120)
			end;
		})

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
			colour = vec(0.5, 0.5, 0.5);
			size = vec2(25, 25);
			offset = vec(-65, -5);
			align_right = true;
			align_top = true;
		})

		self.newfolder_btn = create_imagebutton({
			pressedCallback = do_nothing;
			icon_texture = _gui_textures.new_folder;
			parent = self;
			colour = vec(0.5, 0.5, 0.5);
			size = vec2(25, 25);
			offset = vec(-35, -5);
			align_right = true;
			align_top = true;	
		})

		self.iconsize_btn = create_imagebutton({
			pressedCallback = do_nothing;
			icon_texture = `/editor/core/icons/map_editor/content_browser.png`;-- TODO: replace by a specific icon
			parent = self;
			colour = vec(0.5, 0.5, 0.5);
			size = vec2(25, 25);
			offset = vec(-5, -5);
			align_right = true;
			align_top = true;
		})

		self.dir_edbox = gfx_hud_object_add(`window_editbox`, {
			colour = vec(0.5, 0.5, 0.5);
			parent = self;
			value = self.currentdir;
			alignment = "LEFT";
			size = vec(50, 20);
			offset = vec(5, -8);
			align_left = true;
			align_top = true;
			expand_x = true;
			expand_offset = vec(-100, 0);
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
		local selext = self.selectbox.selected.name:sub(-5):gsub([[\)]], "", 1)	
		
		for i = 1, #m_files do
			if m_files[i]:sub(-4) == selext then
				local nit = nil
				if selext == ".lua" then
					-- TODO: this is not a good place to declare these editor icons
					nit = self.file_explorer:addItem(m_files[i], `/editor/core/icons/icons/luaicon.png`)
				elseif selext == ".lvl" then
					nit = self.file_explorer:addItem(m_files[i], `/editor/core/icons/icons/lvlicon.png`)
				else
					nit = self.file_explorer:addItem(m_files[i], `/common/gui/icons/icons/fileicon.png`)
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

			local selext = self.selectbox.selected.name:sub(-5):gsub([[\)]], "", 1)
			
			-- add the extension if the user forget it
			if self.file_edbox.value:sub(-4) ~= selext then
				filepath = filepath..selext
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