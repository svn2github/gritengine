include `../hud/select.lua`

hud_class `window_button` {
    padding=vec(8,6);

    baseColour = vec(0.3,0.3,0.3);
    hoverColour = vec(1, 0.5, 0) * 0.75;
    clickColour = vec(1, 0.5, 0);

    borderColour = vec(1, 1, 1) * 0.6;

    font = `/common/fonts/Verdana12`;
    caption = "Button";
    captionColour = vec(1, 1, 1);
    captionColourGreyed = vec(1, 1, 1) * 0.4;

    init = function (self)
        self.needsInputCallbacks = true

        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self
        self:setCaption(self.caption)

        if not self.sizeSet then 
            self.size = self.text.size + self.padding * 2
        end

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        -- self.border = gfx_hud_object_add(`/common/hud/Rect`, {
            -- texture=self.borderTexture,
            -- colour=self.borderColour,
            -- parent=self,
            -- cornered=true
        -- })
        
        self:updateChildrenSize()
        self:refreshState();
    end;

    updateChildrenSize = function (self)
        --self.border.size = self.size
    end;
   
    destroy = function (self)
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self:refreshState();
    end;

    refreshState = function (self)
        if self.greyed then
            self.text.colour = self.captionColourGreyed
            self.colour = self.baseColour
        else
            self.text.colour = self.captionColour
            if self.dragging and self.inside then
                self.colour = self.clickColour
				self.text.colour = vec(0, 0, 0)
            elseif self.inside then
                self.colour = self.hoverColour
            else
                self.colour = self.baseColour
            end
        end
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

}

hud_class `window_toolbar` {
	size = vec(0, 0);
	alpha = 1;
    
    init = function (self)
		self.needsParentResizedCallbacks = true;
    end;
	parentResizedCallback = function (self, psize)
		self.size = vec2(self.parent.parent.size.x, self.size.y)
	end;
}

hud_class `image_button` {
	alpha = 1;
	size=vec2(32, 32);
    hoverColour = vec(1, 0.8, 0.5);
    clickColour = vec(1, 0.5, 0);
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
	colour=vec(0.3, 0.3, 0.3);
	
	init = function (self)
		self.needsInputCallbacks = true
		self.dragging = false;
		self.inside = false;
		self.normalColour=self.colour
		if self.icon_texture ~= nil then
			self.icon = gfx_hud_object_add(`/common/hud/Rect`, {texture= self.icon_texture, size=self.size*0.8, parent=self})
		end
	end;

    destroy = function (self)
		self:destroy()
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.dragging ~= true then
			if inside then
				self.colour = self.hoverColour
			else
				self.colour=self.normalColour
			end
		end
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
			self.colour=self.clickColour
			self.icon.position=vec2(self.icon.position.x, self.icon.position.y - 1)
        elseif ev == "-left" then
            if self.dragging and not self.greyed then
                self.icon.position=vec2(self.icon.position.x, self.icon.position.y + 1)
				if self.inside then
					self.colour=self.hoverColour
					self:pressedCallback()
				else
					self.colour=self.normalColour
				end
			end
            self.dragging = false
			
        end
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
}

hud_class `window_editbox` {

    textColour = vec(1, 1, 1);
    borderColour = 0.4 * vec(1, 1, 1);
    padding = 4;
    colour = 0.25 * vec(1, 1, 1);
    texture = `/common/hud/CornerTextures/Filled02.png`;
    cornered = true;
    font = `/common/fonts/Verdana12`;
    value = "Text";
    number = false;
    alignment = "CENTER";

    init = function (self)

		self.needsParentResizedCallbacks = true;  
        self.needsInputCallbacks = true
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self

        self.border = gfx_hud_object_add(`/common/hud/Rect`, {
            texture = `/common/hud/CornerTextures/Border02.png`;
            colour = self.borderColour;
            cornered = true;
            parent = self;
        })

        self.caret = gfx_hud_object_add(`/common/hud/Rect`, {
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
		-- print("")
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
		self:parentresizecb(psize)
		self:updateChildrenSize()
	end;  	

	parentresizecb = function (self, psize)

	end;  	
}

hud_class `browser_icon` {
	alpha = 0;
	size = vec(80, 80);
	colour=vec(1, 0, 0);
	zOrder = 0;
	hoverColour = vec(1, 0.5, 0);
	clickColour=vec(1, 0, 0);
	normalColour = vec(0.5, 0.5, 0.5);
	selectedColour=vec(1, 0.8, 0);
	name="Default";
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.icon = gfx_hud_object_add(`/common/hud/Rect`, {texture=self.icon_texture, size=vec2(64, 64), parent=self, position=vec(0, 8)})
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
			-- HERE
			else
				self.colour=self.normalColour
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

					-- HERE					
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
    end;

    pressedCallback = function (self)
        print "Button has no associated action."
    end;
	
	doubleClick = function(self)

	end;
}

hud_class `file_list` {
	size = vec(0, 0);
	alpha = 1;
	icons_size = vec2(80, 80);
    icons_spacing = 4;
	selected = {};
	
    init = function (self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
		self.items = {}
		self.grid = gfx_hud_object_add(`/common/hud/Rect`, {alpha=0, parent=self})
		
		self.rollbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(-5, 0);
			factor = vec2(0.5, 0);
			zOrder=7;
		})

		self.rollbar = gfx_hud_object_add(`../hud/rollbar`, { parent=self.rollbar_pos })
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
		if icon == nil then icon = `../icons/foldericon.png`end
		self.items[#self.items+1] = gfx_hud_object_add(`browser_icon`, {
			icon_texture=icon;
			position=vec2(0, 0);
			parent=self.grid;
			colour=vec(0.5, 0.5, 0.5);
			size=vec2(self.icons_size.x, self.icons_size.y);
			name=m_name;
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
}

---------------------- OPEN LEVEL DIALOG ----------------------

if(open_level_dialog ~= nil)then
	safe_destroy(open_level_dialog)
end

open_level_dialog = create_window('Open Level', vec2(0, 0), false, vec2(720, 465), vec2(720, 465), vec2(800, 600))

open_level_dialog.btn_size = vec(100, 25)

open_level_dialog.currentdir = "/"

open_level_dialog.update_file_explorer = function(m_dir)
	open_level_dialog.file_explorer:clearAll()
	m_dir = m_dir or ""
	local m_files, m_folders = get_dir_list(m_dir:gsub("/", "", 1))

	for i = 1, #m_folders do
		local nit = nil
		
		nit = open_level_dialog.file_explorer:addItem(m_folders[i], `../icons/foldericon.png`)
		nit.doubleClick = function(self)
			if string.sub(open_level_dialog.currentdir, -1) ~= "/" then
				open_level_dialog.currentdir = open_level_dialog.currentdir.."/"..self.name
			else
				open_level_dialog.currentdir = open_level_dialog.currentdir..self.name
			end
			open_level_dialog.dir_edbox:setValue(open_level_dialog.currentdir)
			open_level_dialog.update_file_explorer(open_level_dialog.currentdir)
		end	
	end
	local selext = open_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)	
	
	for i = 1, #m_files do
		if m_files[i]:sub(-4) == selext then
			local nit = nil
			if selext == ".lua" then
				nit = open_level_dialog.file_explorer:addItem(m_files[i], `../icons/luaicon.png`)
			elseif selext == ".lvl" then
				nit = open_level_dialog.file_explorer:addItem(m_files[i], `../icons/lvlicon.png`)
			else
				nit = open_level_dialog.file_explorer:addItem(m_files[i], `../icons/fileicon.png`)
			end
			
			nit.pressedCallback = function (self)
				open_level_dialog.file_edbox:setValue(self.name)
			end;
			
			nit.doubleClick = function(self)
				local selext = open_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)

				local fcdir = {}
				
				if open_level_dialog.currentdir:sub(-1) == "/" then
					fcdir = open_level_dialog.currentdir:reverse():sub(2):reverse()
				else
					fcdir = open_level_dialog.currentdir
				end		

				if open_level_dialog.file_edbox.value:sub(-4) ~= ".lvl" then
					GED:open_level(fcdir.."/"..open_level_dialog.file_edbox.value..selext)
				else
					GED:open_level(fcdir.."/"..open_level_dialog.file_edbox.value)
				end
				open_level_dialog.enabled=false
			end;
		end
	end
	if open_level_dialog.file_explorer ~= nil then
		open_level_dialog.file_explorer:reset()
	end
end;

open_level_dialog.open_selected_level = function()
	local selext = open_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)

	local fcdir = {}
	
	if open_level_dialog.currentdir:sub(-1) == "/" then
		fcdir = open_level_dialog.currentdir:reverse():sub(2):reverse()
	else
		fcdir = open_level_dialog.currentdir
	end		

	if open_level_dialog.file_edbox.value:sub(-4) == ".lvl" or open_level_dialog.file_edbox.value:sub(-4) == ".lua" then
		GED:open_level(fcdir.."/"..open_level_dialog.file_edbox.value)
	else
		GED:open_level(fcdir.."/"..open_level_dialog.file_edbox.value..selext)
	end
	open_level_dialog.enabled=false
end;

open_level_dialog.toolbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = open_level_dialog;
	offset = vec2(0, -20);
	factor = vec2(0, 0.5);
})

open_level_dialog.bottompart = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = open_level_dialog;
	offset = vec2(0, 45);
	factor = vec2(0, -0.5);
})

open_level_dialog.buttons_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = open_level_dialog.bottompart;
	offset = vec2(-60, 0);
	factor = vec2(0.5, 0);
	zOrder=7;
})

open_level_dialog.cancel_btn = gfx_hud_object_add(`window_button`, {
	caption="Cancel";
	parent=open_level_dialog.buttons_pos;
	pressedCallback = function (self)
		open_level_dialog.enabled=false
	end;
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
})
open_level_dialog.cancel_btn.size = open_level_dialog.btn_size
open_level_dialog.cancel_btn.position = vec(0, -15)

open_level_dialog.file_edbox = gfx_hud_object_add(`window_editbox`, {colour=vec(0.5, 0.5, 0.5);
	parent=open_level_dialog.bottompart;
	value = "";
	alignment = "LEFT";
	enterCallback = function(self)
		open_level_dialog.open_selected_level()
	end;
})
open_level_dialog.file_edbox.parentresizecb = function(self, psize)
	self.position = vec2(-open_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - open_level_dialog.btn_size.x-20, self.size.y)
end;

open_level_dialog.file_edbox:setEditting(true)
open_level_dialog.file_edbox.size=vec(open_level_dialog.file_edbox.parent.size.x - open_level_dialog.btn_size.x-20, 20)
open_level_dialog.file_edbox.position=vec(-open_level_dialog.btn_size.x/2-5, 15)
open_level_dialog.file_edbox:updateChildrenSize()

open_level_dialog.open_button = gfx_hud_object_add(`window_button`, {
	caption="Open";
	parent=open_level_dialog.buttons_pos;
	pressedCallback = function (self)
		open_level_dialog.open_selected_level()
	end;
	
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
})
open_level_dialog.open_button.size=vec(100, 25)
open_level_dialog.open_button.position=vec(0, 15)

open_level_dialog.file_selbox = gfx_hud_object_add(`../hud/selectbox`, {
	parent=open_level_dialog.bottompart;
	choices={ "Grit Level (*.lvl)", "Lua Script (*.lua)" };
	selection=0;
})
open_level_dialog.file_selbox.parentresizecb = function(self, psize)
	self.position = vec2(-open_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - open_level_dialog.btn_size.x-20, self.size.y)
end;

open_level_dialog.file_selbox.onSelect = function(self)
	open_level_dialog.update_file_explorer(open_level_dialog.currentdir)
end;

open_level_dialog.file_selbox.size=vec(open_level_dialog.file_selbox.parent.size.x - open_level_dialog.btn_size.x-20, 20)
open_level_dialog.file_selbox.position=vec(-open_level_dialog.btn_size.x/2-5, -15)

open_level_dialog.wndtoolbar = gfx_hud_object_add(`window_toolbar`, {colour=vec(0.3, 0.3, 0.3);
	parent=open_level_dialog.toolbar_pos;
})
open_level_dialog.wndtoolbar.size=vec(open_level_dialog.file_edbox.parent.size.x, 30)
open_level_dialog.wndtoolbar.alpha=0

open_level_dialog.file_explorer = gfx_hud_object_add(`file_list`, {colour=vec(0.4, 0.4, 0.4);
	parent=open_level_dialog;
	position=vec2(0, 20);
})
open_level_dialog.file_explorer.size = vec2(open_level_dialog.file_explorer.parent.size.x-20, open_level_dialog.file_explorer.parent.size.y-open_level_dialog.wndtoolbar.size.y-100)

open_level_dialog.file_explorer.parentresizecb = function(self, psize)
	self.size = vec2(self.parent.size.x-20, self.parent.size.y-open_level_dialog.wndtoolbar.size.y-100)
end;

open_level_dialog.icons_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = open_level_dialog.wndtoolbar;
	offset = vec2(-45, 0);
	factor = vec2(0.5, 0);
})

cbk = function()print("TODO")end

open_level_dialog.updir_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=function()
		if open_level_dialog.currentdir == "/" or open_level_dialog.currentdir == "" then return end
		open_level_dialog.currentdir = open_level_dialog.currentdir:reverse():sub(open_level_dialog.currentdir:reverse():find("/", 2)+1):reverse()
		
		if open_level_dialog.currentdir == "" then open_level_dialog.currentdir = "/" end
		open_level_dialog.dir_edbox:setValue(open_level_dialog.currentdir)
		open_level_dialog.update_file_explorer(open_level_dialog.currentdir)
	end;
	icon_texture=`../icons/arrow_icon.png`;
	position=vec2(-45, 0);
	parent=open_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

open_level_dialog.newfolder_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=cbk;
	icon_texture=`../icons/new_folder.png`;
	position=vec2(-15, 0);
	parent=open_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

open_level_dialog.iconsize_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=cbk;
	icon_texture=`../icons/content_browser.png`;
	position=vec2(15, 0);
	parent=open_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

open_level_dialog.dir_edbox = gfx_hud_object_add(`window_editbox`, {colour=vec(0.5, 0.5, 0.5);
	parent=open_level_dialog.wndtoolbar;
	value = open_level_dialog.currentdir;
	alignment = "LEFT";
	size=vec(50, 20);
})
open_level_dialog.dir_edbox.position = vec2(-open_level_dialog.btn_size.x/2-5, open_level_dialog.dir_edbox.position.y)
open_level_dialog.dir_edbox.size = vec2(open_level_dialog.dir_edbox.parent.parent.size.x - open_level_dialog.btn_size.x-20, open_level_dialog.dir_edbox.size.y)
open_level_dialog.dir_edbox:updateChildrenSize()
open_level_dialog.dir_edbox.parentresizecb = function(self, psize)
	self.position = vec2(-open_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - open_level_dialog.btn_size.x-20, self.size.y)
end;

open_level_dialog.dir_edbox.enterCallback = function()
	open_level_dialog.update_file_explorer(open_level_dialog.dir_edbox.value)
	open_level_dialog.currentdir=open_level_dialog.dir_edbox.value
end;

open_level_dialog.update_file_explorer()
open_level_dialog.enabled = false

---------------------- SAVE LEVEL DIALOG ----------------------

if(save_level_dialog ~= nil)then
	safe_destroy(save_level_dialog)
end

save_level_dialog = create_window('Save Level', vec2(0, 0), false, vec2(720, 465), vec2(720, 465), vec2(800, 600))

save_level_dialog.btn_size = vec(100, 25)

save_level_dialog.currentdir = "/"

save_level_dialog.update_file_explorer = function(m_dir)
	save_level_dialog.file_explorer:clearAll()
	m_dir = m_dir or ""
	local m_files, m_folders = get_dir_list(m_dir:gsub("/", "", 1))

	for i = 1, #m_folders do
		local nit = nil
		
		nit = save_level_dialog.file_explorer:addItem(m_folders[i], `../icons/foldericon.png`)
		nit.doubleClick = function(self)
			if string.sub(save_level_dialog.currentdir, -1) ~= "/" then
				save_level_dialog.currentdir = save_level_dialog.currentdir.."/"..self.name
			else
				save_level_dialog.currentdir = save_level_dialog.currentdir..self.name
			end
			save_level_dialog.dir_edbox:setValue(save_level_dialog.currentdir)
			save_level_dialog.update_file_explorer(save_level_dialog.currentdir)
		end	
	end
	local selext = save_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)	
	
	for i = 1, #m_files do
		if m_files[i]:sub(-4) == selext then
			local nit = nil
			if selext == ".lua" then
				nit = save_level_dialog.file_explorer:addItem(m_files[i], `../icons/luaicon.png`)
			elseif selext == ".lvl" then
				nit = save_level_dialog.file_explorer:addItem(m_files[i], `../icons/lvlicon.png`)
			else
				nit = save_level_dialog.file_explorer:addItem(m_files[i], `../icons/fileicon.png`)
			end
			
			nit.pressedCallback = function (self)
				save_level_dialog.file_edbox:setValue(self.name)
			end;
			
			nit.doubleClick = function(self)
				local selext = save_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)

				local fcdir = {}
				
				if save_level_dialog.currentdir:sub(-1) == "/" then
					fcdir = save_level_dialog.currentdir:reverse():sub(2):reverse()
				else
					fcdir = save_level_dialog.currentdir
				end		

				if save_level_dialog.file_edbox.value:sub(-4) ~= ".lvl" then
					GED:save_current_level_as(fcdir.."/"..save_level_dialog.file_edbox.value..selext)
				else
					GED:save_current_level_as(fcdir.."/"..save_level_dialog.file_edbox.value)
				end
				save_level_dialog.enabled=false
			end;
		end
	end
	if save_level_dialog.file_explorer ~= nil then
		save_level_dialog.file_explorer:reset()
	end
end;

save_level_dialog.save_selected_level = function()
	local selext = save_level_dialog.file_selbox.selected.name:sub(-5):gsub([[\)]], "", 1)

	local fcdir = {}
	
	if save_level_dialog.currentdir:sub(-1) == "/" then
		fcdir = save_level_dialog.currentdir:reverse():sub(2):reverse()
	else
		fcdir = save_level_dialog.currentdir
	end
	
	if fcdir:sub(1, 1) == "/" then
		fcdir = fcdir:sub(2)
	end

	if fcdir ~= "" then
		fcdir = fcdir.."/"
	end
	
	if save_level_dialog.file_edbox.value:sub(-4) == ".lvl" or save_level_dialog.file_edbox.value:sub(-4) == ".lua" then
		GED:save_current_level_as(fcdir..save_level_dialog.file_edbox.value)
	else
		GED:save_current_level_as(fcdir..save_level_dialog.file_edbox.value..selext)
	end
	
	save_level_dialog.enabled=false
end;

save_level_dialog.toolbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = save_level_dialog;
	offset = vec2(0, -20);
	factor = vec2(0, 0.5);
})

save_level_dialog.bottompart = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = save_level_dialog;
	offset = vec2(0, 45);
	factor = vec2(0, -0.5);
})

save_level_dialog.buttons_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = save_level_dialog.bottompart;
	offset = vec2(-60, 0);
	factor = vec2(0.5, 0);
	zOrder=7;
})

save_level_dialog.cancel_btn = gfx_hud_object_add(`window_button`, {
	caption="Cancel";
	parent = save_level_dialog.buttons_pos;
	pressedCallback = function (self)
		save_level_dialog.enabled=false
	end;
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
})
save_level_dialog.cancel_btn.size = save_level_dialog.btn_size
save_level_dialog.cancel_btn.position = vec(0, -15)

save_level_dialog.file_edbox = gfx_hud_object_add(`window_editbox`, {colour=vec(0.5, 0.5, 0.5);
	parent=save_level_dialog.bottompart;
	value = "";
	alignment = "LEFT";
	enterCallback = function(self)
		save_level_dialog.save_selected_level()
	end;
})
save_level_dialog.file_edbox.parentresizecb = function(self, psize)
	self.position = vec2(-save_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - save_level_dialog.btn_size.x-20, self.size.y)
end;

save_level_dialog.file_edbox:setEditting(true)
save_level_dialog.file_edbox.size=vec(save_level_dialog.file_edbox.parent.size.x - save_level_dialog.btn_size.x-20, 20)
save_level_dialog.file_edbox.position=vec(-save_level_dialog.btn_size.x/2-5, 15)
save_level_dialog.file_edbox:updateChildrenSize()

save_level_dialog.save_button = gfx_hud_object_add(`window_button`, {
	caption="Save";
	parent = save_level_dialog.buttons_pos;
	pressedCallback = function (self)
		save_level_dialog.save_selected_level()
	end;
	
	cornered=true;
	texture=`../icons/FilledWhiteBorder042.png`;
})
save_level_dialog.save_button.size = vec(100, 25)
save_level_dialog.save_button.position = vec(0, 15)

save_level_dialog.file_selbox = gfx_hud_object_add(`../hud/selectbox`, {
	parent=save_level_dialog.bottompart;
	choices={ "Grit Level (*.lvl)", "Lua Script (*.lua)" };
	selection=0;
})
save_level_dialog.file_selbox.parentresizecb = function(self, psize)
	self.position = vec2(-save_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - save_level_dialog.btn_size.x-20, self.size.y)
end;

save_level_dialog.file_selbox.onSelect = function(self)
	save_level_dialog.update_file_explorer(save_level_dialog.currentdir)
end;

save_level_dialog.file_selbox.size=vec(save_level_dialog.file_selbox.parent.size.x - save_level_dialog.btn_size.x-20, 20)
save_level_dialog.file_selbox.position=vec(-save_level_dialog.btn_size.x/2-5, -15)

save_level_dialog.wndtoolbar = gfx_hud_object_add(`window_toolbar`, {colour=vec(0.3, 0.3, 0.3);
	parent=save_level_dialog.toolbar_pos;
})
save_level_dialog.wndtoolbar.size=vec(save_level_dialog.file_edbox.parent.size.x, 30)
save_level_dialog.wndtoolbar.alpha=0

save_level_dialog.file_explorer = gfx_hud_object_add(`file_list`, {colour=vec(0.4, 0.4, 0.4);
	parent=save_level_dialog;
	position=vec2(0, 20);
})
save_level_dialog.file_explorer.size = vec2(save_level_dialog.file_explorer.parent.size.x-20, save_level_dialog.file_explorer.parent.size.y-save_level_dialog.wndtoolbar.size.y-100)

save_level_dialog.file_explorer.parentresizecb = function(self, psize)
	self.size = vec2(self.parent.size.x-20, self.parent.size.y-save_level_dialog.wndtoolbar.size.y-100)
end;

save_level_dialog.icons_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = save_level_dialog.wndtoolbar;
	offset = vec2(-45, 0);
	factor = vec2(0.5, 0);
})

cbk = function()print("TODO")end

save_level_dialog.updir_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=function()
		if save_level_dialog.currentdir == "/" or save_level_dialog.currentdir == "" then return end
		save_level_dialog.currentdir = save_level_dialog.currentdir:reverse():sub(save_level_dialog.currentdir:reverse():find("/", 2)+1):reverse()
		
		if save_level_dialog.currentdir == "" then save_level_dialog.currentdir = "/" end
		save_level_dialog.dir_edbox:setValue(save_level_dialog.currentdir)
		save_level_dialog.update_file_explorer(save_level_dialog.currentdir)
	end;
	icon_texture=`../icons/arrow_icon.png`;
	position=vec2(-45, 0);
	parent=save_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

save_level_dialog.newfolder_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=cbk;
	icon_texture=`../icons/new_folder.png`;
	position=vec2(-15, 0);
	parent=save_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

save_level_dialog.iconsize_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=cbk;
	icon_texture=`../icons/content_browser.png`;
	position=vec2(15, 0);
	parent=save_level_dialog.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

save_level_dialog.dir_edbox = gfx_hud_object_add(`window_editbox`, {colour=vec(0.5, 0.5, 0.5);
	parent=save_level_dialog.wndtoolbar;
	value = save_level_dialog.currentdir;
	alignment = "LEFT";
	size=vec(50, 20);
})
save_level_dialog.dir_edbox.position = vec2(-save_level_dialog.btn_size.x/2-5, save_level_dialog.dir_edbox.position.y)
save_level_dialog.dir_edbox.size = vec2(save_level_dialog.dir_edbox.parent.parent.size.x - save_level_dialog.btn_size.x-20, save_level_dialog.dir_edbox.size.y)
save_level_dialog.dir_edbox:updateChildrenSize()
save_level_dialog.dir_edbox.parentresizecb = function(self, psize)
	self.position = vec2(-save_level_dialog.btn_size.x/2-5,self.position.y)
	self.size = vec2(self.parent.parent.size.x - save_level_dialog.btn_size.x-20, self.size.y)
end;

save_level_dialog.dir_edbox.enterCallback = function()
	save_level_dialog.update_file_explorer(save_level_dialog.dir_edbox.value)
	save_level_dialog.currentdir=save_level_dialog.dir_edbox.value
end;

save_level_dialog.update_file_explorer()
save_level_dialog.enabled = false