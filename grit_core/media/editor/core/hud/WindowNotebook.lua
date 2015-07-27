------------------------------------------------------------------------------
--  Window Notebook
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `roundbutton` (extends(GuiClass)
{
	padding = vec(8,6);

	alpha = 1;
	
	baseColour = vec(1,1,1) * 0.7;
	hoverColour = vec(1, 1, 1) * 0.45;
	clickColour = vec(1, 1, 1)* 0.8;
	colourGreyed = vec(1, 1, 1) * 0.9;
	
	captionBaseColour = vec(1, 1, 1) * 0;
	captionHoverColour = vec(1, 1, 1) * 1;
	captionClickColour = vec(1, 1, 1) * 0.1;
	captionColourGreyed = vec(1, 1, 1) * 0.1;
	
	font = `/common/fonts/Arial12`;
	caption = "x";

	texture = `../icons/circle10.png`;
	
	init = function (self)
		GuiClass.init(self)
		
		self.needsInputCallbacks = true

		self.text = gfx_hud_text_add(self.font)
		self.text.parent = self
		self.text.colour = self.captionBaseColour
		--self.text.position = vec(0, -1)
		self:setCaption(self.caption)

		-- if not self.sizeSet then 
			-- self.size = self.text.size + self.padding * 2
		-- end

		self.dragging = false;
		self.inside = false
		if self.greyed == nil then self.greyed = false end

		self:refreshState();
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
			self.colour = self.colourGreyed
		else
			if self.dragging and self.inside then
				self.colour = self.clickColour
				self.text.colour = self.captionClickColour
			elseif self.inside then
				self.colour = self.hoverColour
				self.text.colour = self.captionHoverColour
			else
				self.colour = self.baseColour
				self.text.colour = self.captionBaseColour
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
			if not self.destroyed then
				self.dragging = false
			else
				return
			end
		end

		self:refreshState()
	end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;	
	
    pressedCallback = function (self)
		
    end;
})

local function mdist(v1, v2)
	return math.sqrt((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2)
end


hud_class `window_page_button` {
    padding = vec(10,6);

    baseColour = vec(1, 1, 1);
    hoverColour = vec(1, 1, 1);
    clickColour = vec(1, 1, 1);

    font = `/fonts/Ubuntu14`;
    caption = "Map Editor";
    captionColour = vec(0, 0, 0);

	captionHoverColour = vec(0, 0, 0);
	captionClickColour = vec(0.85, 0.85, 0.85);
	alpha = 1;
	selected = false;
	captionSelectedColour = vec(0, 0, 0);
	selectedColour = vec(1, 1, 1)*0.95;
	
	draggingPos = vec2(0, 0);
	
	ID = 0;
	
	texture = `../icons/SquareFilledWhiteBorder.png`;
	cornered = true;
	
	zOrder = 1;
	
    init = function (self)
        self.needsInputCallbacks = true
		self.needsFrameCallbacks = false
		
        self.text = gfx_hud_text_add(self.font)
        self.text.parent = self
		self.text.position = vec(0, 0)
        self:setCaption(self.caption)

		self.close_btn = gfx_hud_object_add(`roundbutton`, { parent = self, align_right = true, position=vec(0, -2), offset = vec(-10, -2), pressedCallback = function(self) self.parent.parent:destroyTab(self.parent.ID) end })
		
        if not self.sizeSet then 
            -- self.size = vec(self.text.size.x + self.padding.x * 10, 25)
			self.size = vec(180, 25)
        end

		self.ornament = gfx_hud_object_add(`/common/hud/Rect`, { parent = self, size = vec(self.size.x, 4), position = vec(0, self.size.y/2-2), colour = random_colour() })
		
        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self:refreshState();
		
		self.destPos = self.position
    end;

    destroy = function (self)
		--self.parent.destroyTab(self.ID)
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
    end;

    refreshState = function (self)
		if self.selected then
			self.colour = self.selectedColour
			self.text.colour = self.captionSelectedColour
		else
			self.text.colour = self.captionColour
			if self.dragging and self.inside then
				self.colour = self.clickColour
				self.text.colour = self.captionClickColour
			elseif self.inside then
				self.colour = self.hoverColour
				self.text.colour = self.captionHoverColour
			else
				self.colour = self.baseColour
			end
		end
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		self.localPos = local_pos
		self:refreshState()
		
		if self.moving then
			-- swap if close enought, or has exceeded the position (when moving fast)
			if self.parent.buttons[self.ID-1] ~= nil and (mdist(self.position, self.parent.buttons[self.ID-1].position) < 15 or self.position.x < self.parent.buttons[self.ID-1].position.x) then
				self.parent:swap(self.ID, self.ID-1)
			elseif self.parent.buttons[self.ID+1] ~= nil and (mdist(self.position, self.parent.buttons[self.ID+1].position) < 15 or self.position.x > self.parent.buttons[self.ID+1].position.x) then
				self.parent:swap(self.ID, self.ID+1)
			end
			self.position = vec(mouse_pos_abs.x-self.parent.position.x-self.draggingPos.x, self.position.y)
			if not self.dragging then self.moving = false end
		else
			if self.dragging and mdist(local_pos, self.draggingPos) > 15 then
				self.zOrder = 2
				self.moving = true
			end
		end
	end;

	buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = self.localPos
		elseif ev == "-left" then
			if self.dragging then
				if self.inside and not self.selected and not self.moving then
					self:pressedCallback()
				end
				
				if self.moving then
					self.moving = false
					if self.position ~= self.destPos then
						self.needsFrameCallbacks = true
					end
				end
				
			end
			self.dragging = false
		end

		self:refreshState()
	end;

	frameCallback = function(self, elapsed)
		if self.destPos ~= nil then
			if mdist(self.position, self.destPos) > 0.99 then
				self.position = lerp(self.position, self.destPos, elapsed*5)
			else
				self.position = self.destPos
				self.needsFrameCallbacks = false
				self.zOrder = 1
			end
		end
	end;
	
    pressedCallback = function (self)
		self.parent.buttons[self.parent.selected].selected = false
		self.parent.buttons[self.parent.selected]:refreshState()
		self.parent:select(self.ID)
		self.selected = true
		self:refreshState()
		self:onSelect()
    end;
	
	onSelect = function (self)
		
	end;
	
	onUnselect = function (self)
		
	end;
}

hud_class `windownotebook` (extends(GuiClass)
{
	alpha = 1;
	size = vec(1, 25);
	zOrder = 0;
	colour = vec(1, 1, 1) * 0.85;
	pageButtonSize = vec(40, 20);
	pageButtonColour = vec(0.5, 0.5, 0.5);
	pageSelectedButtonColour = vec(0.6, 0.6, 0.6);
	selected = 1;
	expand_w = true;
	
	padding = 2;
	
	zOrder = 5;
	
	init = function (self)
		GuiClass.init(self)
		self.buttons = {}

	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
			
		self:destroy()
	end;
	
	parentResizedCallback = function (self, psize)
		GuiClass.parentResizedCallback(self, psize)
		self.position = vec(gfx_window_size().x/2, gfx_window_size().y-self.size.y/2)
		self:updateTabs()
	end;
	
	addPage = function (self, name, p_onSelect, p_onUnselect)
		name = name or "Page"
		p_onSelect = p_onSelect or do_nothing
		p_onUnselect = p_onUnselect or do_nothing
		
		local top_pos = 0
		if self.buttons[#self.buttons] ~= nil then
			top_pos = self.buttons[#self.buttons].position.x+self.buttons[#self.buttons].size.x/2
		else
			top_pos = -self.size.x/2
		end
		self.buttons[#self.buttons+1] = gfx_hud_object_add(`window_page_button`, {
			parent = self,
			caption = name,
			onSelect = p_onSelect,
			onUnselect = p_onUnselect,
			ID = #self.buttons+1,
		})
		
		self.buttons[#self.buttons].position = vec(top_pos+self.buttons[#self.buttons].size.x/2+self.padding*2, 0)
		self.buttons[#self.buttons].destPos = self.buttons[#self.buttons].position
	end;
	
	updateTabs = function (self)
		local top_pos = -self.size.x/2

		for i = 1, #self.buttons do
			if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
				self.buttons[i].position = vec(top_pos+self.buttons[i].size.x+self.padding*2, 0)
				self.buttons[i].destPos = self.buttons[i].position
				self.buttons[i].needsInputCallbacks = false
				top_pos = top_pos + self.buttons[i].position.x + self.buttons[i].size.x
			end
		end
	end;
	
	select = function (self, id)
		self.selected = id
	end;
	
	swap = function (self, id1, id2)
		local btn1dp = self.buttons[id1].destPos
		
		self.buttons[id1].destPos = self.buttons[id2].destPos
		
		self.buttons[id2].destPos = btn1dp
		self.buttons[id2].needsFrameCallbacks = true
		
		local btn1 = self.buttons[id1]

		self.buttons[id1] = self.buttons[id2]
		self.buttons[id2] = btn1
		
		self.buttons[id1].ID = id1
		self.buttons[id2].ID = id2
	end;
	
	destroyTab = function (self, id)
		local dest_positions = {}
		
		if id ~= #self.buttons then
			for i = id, #self.buttons do
				if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
					dest_positions[i] = self.buttons[i].destPos
				end
			end

			safe_destroy(self.buttons[id])
			for i = id+1, #self.buttons do
				if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
					self.buttons[i].destPos = dest_positions[i-1]
					self.buttons[i].needsFrameCallbacks = true
					if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
						self.buttons[i-1] = self.buttons[i]
						self.buttons[i-1].ID = self.buttons[i].ID-1
					end
				end
			end
			self.buttons[#self.buttons] = nil
		else
			safe_destroy(self.buttons[id])
			self.buttons[id] = nil
		end
	end;	
})

create_window_notebook = function(options)
	return gfx_hud_object_add(`windownotebook`, options)
end

safe_destroy(re)
re = create_window_notebook({})
for i = 0, 6 do
	re:addPage("Navigation Editor")
end