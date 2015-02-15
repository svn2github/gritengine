include `../hud/select.lua`

hud_class `browser_icon2` {
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
		self.lp = local_pos
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


hud_class `content_browser_floating_object` {
	alpha = 1;
	size = vec(64, 64);
	texture = `../icons/objecticon.png`;
	id=0;
	obclass="";
	
	init = function (self)
		self.needsInputCallbacks = true;
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		
		self:destroy()
	end;
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self.position = vec2(mouse_pos_abs.x -gfx_window_size().x/2-self.draggingPos.x, mouse_pos_abs.y - gfx_window_size().y/2 -self.draggingPos.y)
    end;
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
		elseif ev == "-left" then

			local cast_ray = 1000 * gfx_screen_to_world(player_ctrl.camPos, player_ctrl.camDir, mouse_pos_abs)
			local dist = physics_cast(player_ctrl.camPos, cast_ray, true, 0)

			local cl = class_get(self.obclass)

			local pos = (player_ctrl.camPos + cast_ray * (dist or 0.02)) + (cl.placementZOffset or 0)
			
			object (self.obclass) (pos) {}

			safe_destroy(self)
			addobjectelement = nil
        end
    end;
	
}

addobjectelement = nil
function create_floating(offset, mclass)
	if addobjectelement == nil then
		addobjectelement = gfx_hud_object_add(`content_browser_floating_object`, {
			parent=hud_center,
			draggingPos=offset,
			obclass=mclass,
			position = vec2((select(3, get_mouse_events()))-gfx_window_size().x/2-offset.x, (select(4, get_mouse_events())) - gfx_window_size().y/2 -offset.y)
		})
	end
end

local content_browser = editor_interface.windows.content_browser

content_browser.btn_size = vec(100, 25)

content_browser.currentdir = "/"

content_browser.update_file_explorer = function(m_dir)
	content_browser.file_explorer:clearAll()
	m_dir = m_dir or ""
	local m_files, m_folders = get_dir_list(m_dir:gsub("/", "", 1))
	
	m_files = get_class_dir(m_dir)

	for i = 1, #m_folders do
		local nit = nil
		
		nit = content_browser.file_explorer:addItem(m_folders[i], `../icons/foldericon.png`)
		nit.doubleClick = function(self)
			if string.sub(content_browser.currentdir, -1) ~= "/" then
				content_browser.currentdir = content_browser.currentdir.."/"..self.name
			else
				content_browser.currentdir = content_browser.currentdir..self.name
			end
			content_browser.dir_edbox:setValue(content_browser.currentdir)
			content_browser.update_file_explorer(content_browser.currentdir)
		end	
	end

	for i = 1, #m_files do
			local nit = nil
			nit = content_browser.file_explorer:addItem(m_files[i], `../icons/objecticon.png`)
			nit.pressedCallback = function (self)
				self. adding = true
				create_floating(self.lp, content_browser.currentdir.."/"..self.name)
			end;
			nit.doubleClick = function(self)

			end;
			
	end
	if content_browser.file_explorer ~= nil then
		content_browser.file_explorer:reset()
	end
end;

content_browser.toolbar_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = content_browser;
	offset = vec2(0, -20);
	factor = vec2(0, 0.5);
})

content_browser.bottompart = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = content_browser;
	offset = vec2(0, 45);
	factor = vec2(0, -0.5);
})

content_browser.wndtoolbar = gfx_hud_object_add(`window_toolbar`, {colour=vec(0.3, 0.3, 0.3);
	parent=content_browser.toolbar_pos;
})
content_browser.wndtoolbar.size=vec(content_browser.size.x, 30)
content_browser.wndtoolbar.alpha=0


content_browser.m_content = gfx_hud_object_add(`dynamic_res_cb`, {colour=vec(0.2, 0.2, 0.2);
	parent=content_browser;
	position=vec2(0, 0);
	size = vec(120, 300);
	colour=vec(1, 0, 0);
	alpha=0;
})

content_browser.m_content.parentresizecb = function(self, psize)
	self.size = psize
	self:parentresizecb2(self, psize)
end;


content_browser.dir_tree = gfx_hud_object_add(`dynamic_res_cb`, {colour=vec(0.2, 0.2, 0.2);
	parent=content_browser.m_content;
	size = vec(180, content_browser.size.y-content_browser.wndtoolbar.size.y-30)
})

content_browser.dir_tree.position = vec(-content_browser.size.x/2+content_browser.dir_tree.size.x/2+10, -15)

-- content_browser.dir_tree.parentresizecb = function(self, psize)
	-- self.size = vec2(self.parent.size.x*0.3, self.parent.size.y-content_browser.wndtoolbar.size.y-60)
	-- self.position=vec(-content_browser.file_explorer.size.x/2, content_browser.dir_tree.position.y)
-- end;

content_browser.file_explorer = gfx_hud_object_add(`file_list`, {colour=vec(0.4, 0.4, 0.4);
	parent=content_browser.m_content;
})
content_browser.file_explorer.size = vec2(content_browser.size.x-content_browser.dir_tree.size.x-20, content_browser.size.y-content_browser.wndtoolbar.size.y-30)

content_browser.file_explorer.position = vec(content_browser.size.x/2-content_browser.file_explorer.size.x/2-10, -15)

content_browser.file_explorer.addItem = function(self, m_name, icon, pc, dpc)
	if icon == nil then icon = `../icons/foldericon.png`end
	self.items[#self.items+1] = gfx_hud_object_add(`browser_icon2`, {
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

-- content_browser.file_explorer.parentresizecb = function(self, psize)
	-- self.size = vec2(self.parent.size.x*0.7-20, self.parent.size.y-content_browser.wndtoolbar.size.y-60)
	-- self.position=vec(content_browser.dir_tree.size.x/2, content_browser.file_explorer.position.y)
-- end;

--content_browser.dir_tree.needsParentResizedCallbacks = true


content_browser.m_content.parentresizecb2 = function(self, psize)
	-- tree
	content_browser.dir_tree.size = vec2(content_browser.dir_tree.size.x, self.parent.size.y-content_browser.wndtoolbar.size.y-30)
	content_browser.dir_tree.position=vec(-self.parent.size.x/2+content_browser.dir_tree.size.x/2+10, content_browser.dir_tree.position.y)

	-- Content
	content_browser.file_explorer.size = vec2(self.parent.size.x-content_browser.dir_tree.size.x-20, self.parent.size.y-content_browser.wndtoolbar.size.y-30) 
	content_browser.file_explorer.position=vec(self.parent.size.x/2-content_browser.file_explorer.size.x/2-10, content_browser.file_explorer.position.y)
	content_browser.file_explorer:reorganize()
end;


content_browser.m_content.needsParentResizedCallbacks = true


content_browser.icons_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
	parent = content_browser.wndtoolbar;
	offset = vec2(-18, 0);
	factor = vec2(0.5, 0);
})

cbk = function()print("TODO")end

content_browser.updir_btn = gfx_hud_object_add(`image_button`, {
	pressedCallback=function()
		if content_browser.currentdir == "/" or content_browser.currentdir == "" then return end
		content_browser.currentdir = content_browser.currentdir:reverse():sub(content_browser.currentdir:reverse():find("/", 2)+1):reverse()
		
		if content_browser.currentdir == "" then content_browser.currentdir = "/" end
		content_browser.dir_edbox:setValue(content_browser.currentdir)
		content_browser.update_file_explorer(content_browser.currentdir)
	end;
	icon_texture=`../icons/arrow_icon.png`;
	position=vec2(0, 0);
	parent=content_browser.icons_pos;
	colour=vec(0.5, 0.5, 0.5);
	size=vec2(25, 25)
})

content_browser.dir_edbox = gfx_hud_object_add(`window_editbox`, {colour=vec(0.5, 0.5, 0.5);
	parent=content_browser.wndtoolbar;
	value = content_browser.currentdir;
	alignment = "LEFT";
	size=vec(50, 20);
})
content_browser.dir_edbox.position = vec2(-content_browser.updir_btn.size.x/2, content_browser.dir_edbox.position.y)
content_browser.dir_edbox.size = vec2(content_browser.size.x - content_browser.updir_btn.size.x*2, content_browser.dir_edbox.size.y)
content_browser.dir_edbox:updateChildrenSize()
content_browser.dir_edbox.parentresizecb = function(self, psize)
	self.position = vec2(-content_browser.updir_btn.size.x/2,self.position.y)
	self.size = vec2(self.parent.parent.size.x - content_browser.updir_btn.size.x*2, self.size.y)
end;

content_browser.dir_edbox.enterCallback = function()
	content_browser.update_file_explorer(content_browser.dir_edbox.value)
	content_browser.currentdir=content_browser.dir_edbox.value
end;

content_browser.update_file_explorer()
--content_browser.enabled = false