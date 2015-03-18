
hud_class `Expand_List_Item` {     
	size = vec(300, 20);
	alpha = 1;
	items = {};
	colour=vec(0.2, 0.5, 0.2);
	default_value="";
	name="ItemName";
	
	init = function (self)  
        self.needsParentResizedCallbacks = true;
		--self.needsFrameCallbacks = true
		self.tt = nil
		self.rdt = 0
		self.time_since_last_update = 0
		--self.colour=random_colour()
		self.colour=vec(0.5, 0.5, 0.5)
		self.title_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})
		self.title = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.title.parent= self.title_pos
		self:setTitle(self.name)
		
		self.value = gfx_hud_object_add(`/common/hud/EditBox`, {
			value = "/.lvl";
			size = vec((self.size.x/2) - self.title.size.x+15,20);
			alignment = "LEFT";
			parent=self;
		})
		
		self.value:setValue(self.default_value)
		
		
		self.value.onEditting = function (self, editting)
			if editting == false then
				self.parent:entercallback()
			end
		end;
		
		-- self.value_pos = gfx_hud_object_add('/common/hud/Positioner', {
			-- parent = self;
			-- offset = vec2(-self.value .size.x/2-5, 0);
			-- factor = vec2(0.5, 0);
		-- })
		
		-- self.value.parent = self.value_pos 
		
    end;

	setTitle = function(self, name)
		self.title.text  = name
		self.title.position = vec2(self.title.size.x / 2, self.title.position.y)
	end;

	parentResizedCallback = function (self, psize)
		self.size = vec2(psize.x, self.size.y)
		self.value.size = vec((self.size.x/2) +15,20);
		self.value.border.size = vec((self.size.x/2)+15,20);
		self.value.position = vec2(-self.value.size.x/2+self.size.x/2, self.value.position.y)
		self.value.text.position = vec2(-self.value.size.x/2+self.value.text.size.x/2+4, self.value.text.position.y)
	end;
	
    frameCallback = function (self)
        --local state = (seconds() % 5) / 0.5
		
		-- self.time_since_last_update = seconds() - self.time_since_last_update
		-- self.tt = self.tt + self.time_since_last_update
		if(self.tt == nil) then
			self.tt = seconds()
		end
		if (seconds() - self.tt >= self.rdt) then
			self.colour=random_colour()
			if (self.colour.x+self.colour.y+self.colour.z  >= 1.5) then
				self.title.colour = vec(0, 0, 0)
				self.value.text.colour = vec(1, 1, 1)
			else
				self.title.colour = vec(1, 1, 1)
				self.value.text.colour = vec(0, 0, 0)
			end
			
			-- local blackorwhite = 0
			-- if self.colour.x + self.colour.y + self.colour.z <= 1.5 then
				-- blackorwhite = 1
			-- end
			-- self.value.colour = vec(blackorwhite, blackorwhite, blackorwhite)
			
			self.value.colour = math.abs(self.colour -1)
			self.tt = seconds()
			self.rdt = math.random(10)
		end
    end;
}

hud_class `Expand_List` {     
	size = vec(0, 0);
	alpha = 1;
	items = {};
	caption = "Expand";
	init = function (self)  
        self.needsParentResizedCallbacks = true;
		--self.needsInputCallbacks = false;
		self.items = {}
		
		self.base = gfx_hud_object_add(`/common/hud/Rect`, {colour=vec(0.5, 0.5, 0.5), size=vec2(300, 20), parent=self, cornered=true;})
		self.base.texture = `../icons/FilledWhiteBorder042nt.png`;
		self.title_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.base;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})
		self.title = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.title.parent= self.title_pos
		self.title.text = self.caption
		self:setTitle(self.caption)

		self.expand_btn = gfx_hud_object_add(`/common/hud/Button`, {				
				caption = "-";
				padding = vec(8, 1);
				cornered=true;
				borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`;
				needsParentResizedCallbacks = true;
				parentResizedCallback = function(self, psize) self.position = vec2(psize.x/2-self.size.x/2, self.position.y) end;
				baseColour = vec(0.2, 0.2, 0.2);
				hoverColour = vec(1, 0.5, 0);
				clickColour = vec(0.7, 0.3, 0);
		})
		self.expand_btn.texture=`../icons/FilledWhiteBorder042.png`
		self.expand_btn.border.enabled = false
		--self.expand_btn.texture = `../icons/invdeg.png`;
		--self.expand_btn.border.texture = nil
		--self.expand_btn.border.enabled=false
		self.expand_btn.border.colour=vec(1, 0.5, 0)
		self.expand_button_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.base;
			offset = vec2(-self.expand_btn.size.x/2-5, 0);
			factor = vec2(0.5, 0);
		})
		
		self.expand_btn.parent = self.expand_button_pos 
		self.expand_btn.pressedCallback = function (self)
			if(self.parent.parent.parent.container.enabled)then
				self:setCaption("+")
				self.parent.parent.texture = `../icons/FilledWhiteBorder042.png`
			else
				self:setCaption("-")
				self.parent.parent.texture = `../icons/FilledWhiteBorder042nt.png`
			end
			self.parent.parent.parent:expand()
		end;

		self.container_pos = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.base;
			offset = vec2(0, -self.base.size.x/2);
			factor = vec2(0, -0.5);
		})
		
		self.container = gfx_hud_object_add(`/common/hud/Rect`, {
			colour=vec(0.3, 0.3, 0.3);
			alpha = 1;
			parent = self.base;

			size=vec2(300, 300);
		})

    end;

	setTitle = function(self, name)
		self.title.text  = name
		self.title.position = vec2(self.title.size.x / 2, self.title.position.y)
	end;
	
	expand = function (self)
		self.container.enabled = not self.container.enabled
	end;
	
	reorganize = function (self)
		self.container.size = vec2(self.container.size.x, #self.items*22)
		self.container.position = vec(0, -self.container.size.y/2-self.base.size.y/2)
		local tii = -1
		for i = 1, #self.items do
			self.items[i].position = vec2(0, self.container.size.y/2-self.items[i].size.y/2+tii)
			tii = tii - 22
		end
	end;	
	
	addItem = function (self, nm, defvalue, ecallback)
		self.items[#self.items+1] = gfx_hud_object_add(`Expand_List_Item`, {parent=self.container, position=vec(0, (#self.items+1)*-22), name=nm, default_value=defvalue, entercallback = ecallback})
		self:reorganize()
		return self.items[#self.items]
	end;	
	
	parentResizedCallback = function (self, psize)
		self.base.size = vec2(psize.x-8, self.base.size.y)
		self.container.size = vec2(psize.x-8, self.container.size.y)
		self.position = vec2(0, self.parent.border.size.y/2-self.parent.draggable_area.size.y/2)
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		--if inside then print("px") end
    end;

	btcallbacks = function(self)
	end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
        end
		self:btcallbacks()
    end;
}

function update_level_properties()
	if ty.items[8] ~= nil then
		if ty.items[1].value ~= hud_focus then
			ty.items[1].value:setValue(current_level.name)
		end
		
		if ty.items[2].value ~= hud_focus then
			ty.items[2].value:setValue(current_level.author)
		end

		if ty.items[3].value ~= hud_focus then
			ty.items[3].value:setValue(current_level.description)
		end
		
		if ty.items[4].value ~= hud_focus then
			ty.items[4].value:setValue(string.format('%.4f', current_level.spawn.pos.x).." "..string.format('%.4f', current_level.spawn.pos.y).." "..string.format('%.4f', current_level.spawn.pos.z))
		end
		if ty.items[5].value ~= hud_focus then
			ty.items[5].value:setValue(string.format('%.4f', current_level.spawn.rot.w).." "..string.format('%.4f', current_level.spawn.rot.x).." "..string.format('%.4f', current_level.spawn.rot.y).." "..string.format('%.4f', current_level.spawn.rot.z))
		end
		if ty.items[6].value ~= hud_focus then
			ty.items[6].value:setValue(tostring(env.clockRate))
		end
		
		if ty.items[7].value ~= hud_focus then
			ty.items[7].value:setValue(current_level.game_mode)
		end
		
		if current_level.include ~= nil and current_level.include[1] ~= nil then
			if ty.items[8].value ~= hud_focus then
				ty.items[8].value:setValue(current_level.include[1])
			end	
		end

		if current_level.include ~= nil and current_level.include[2] ~= nil then
			if ty.items[9].value ~= hud_focus then
				ty.items[9].value:setValue(current_level.include[2])
			end
		end
	end

end

-- Predeclare the global variable
ty = ty

function editor_init_windows()
    if ty ~= nil then safe_destroy(ty) end
    ty = gfx_hud_object_add(`Expand_List`, {
        parent=editor_interface.windows.level_properties,
        caption="Common",
        needsInputCallbacks = true;
        btcallbacks = function(self)
            update_level_properties()
        end;
    })
    ty.needsInputCallbacks = true

    ty:addItem("Name: ", "some level", function(self) current_level.name = self.value.value end)
    ty:addItem("Author: ", "someone", function(self) current_level.author = self.value.value end)
    ty:addItem("Description: ", "some description", function(self) current_level.description = self.value.value end)
    ty:addItem("Clock Rate: ", "", function(self) if tonumber(self.value.value) ~= nil then env.clockRate = tonumber(self.value.value) current_level.clock_rate = tonumber(self.value.value) end end)
    ty:addItem("Game Mode: ", "", function(self) current_level.game_mode = self.value.value end)
    ty:addItem("Include1: ", "", function(self) current_level.include[1] = self.value.value end)
    ty:addItem("Include2: ", "", function(self) current_level.include[2] = self.value.value end)
end
