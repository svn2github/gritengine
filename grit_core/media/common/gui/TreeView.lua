------------------------------------------------------------------------------
--  Tree View Class
--
--  (c) 2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

outllastcol = false

hud_class `TreeViewGroup` (extends(GuiClass)
{
	alpha = 0.2;
	size = vec(150, 20);
	zOrder = 0;
	extends_w = true;
	colour = vec(1, 0.5, 0.5);
	align = LEFT;
	
	icon = `/editor/core/icons/map_editor/open_15.png`;
	
	isNode = false; -- if all objects are attached to this group
	
	name = "Default";
	
	selected = false;
	
	canAddObjectChilds = true;
	canAddGroupChilds = true;
	
	opened = false;
	
	dragging = false;
	
	init = function (self)
		GuiClass.init(self)
		
		self.needsInputCallbacks = true
		
		self.colour = outllastcol and vec(0.5, 0.5, 0.5) or vec(0.6, 0.6, 0.6)
		self.defaultColour = self.colour
		
		outllastcol = not outllastcol
		
		self.childs = {}
		
		if self.canAddGroupChilds or self.canAddObjectChilds then
		
			self.iconcolapse = create_imagebutton({ parent = self, align= LEFT, offset = vec(3, 0), size = vec(15, 15), icon_texture = `/common/gui/icons/treeviewcolapsed.png`, alpha = 0, group = self })
			self.iconcolapse.pressedCallback = function(self)
				if self.group.opened then
					self.group:colapseChilds()
				else
					self.group:showChilds()
				end
				
				--self.group.opened = not self.group.opened
			end
			
			self.iconcolapse.enabled = false
		
		end
		
		self.iconx = create_gui_object({ parent = self, texture = self.icon, align = LEFT, size = vec(self.size.y-2, self.size.y-2), alpha = 1, offset = vec(20, 0), colour=vec(1, 0.8, 0.5) })
		self.text = create_guitext({ parent = self, align = LEFT, offset = vec(self.iconx.size.x + 20, 0), alpha=0 })
		self.text.colour = vec(1, 0, 0)
		self.text:setValue(self.name)
		--self.text.position = vec(20, 0)
	end;
	
	destroy = function (self)

		self:destroy()
	end;
	
	addChild = function (self, group)
		self.childs[#self.childs+1] = gfx_hud_object_add(`TreeViewGroup`,
			{ name = group, parent = self.root, offset = vec(self.offset.x+10, (-(#self.childs+1)*21)),  expand_x = true, expand_offset = vec(self.expand_offset.x-20, 0), root = self.root,align=TOP })
			
			
		self.childs[#self.childs].enabled = false
		--self.opened = true
		self.iconcolapse.icon.texture = `/common/gui/icons/treeviewcolapsed.png`
		self.iconcolapse.enabled = true
		
		--self.root.activeLines = self.root.activeLines +1
	end;
	
	colapseChilds = function(self)
		self.opened = false
		self.root.activeLines = self.root.activeLines - #self.childs
		
		self.iconcolapse.icon.texture = `/common/gui/icons/treeviewcolapsed.png`
		
		for i = 1, #self.childs do
			if self.childs[i].opened then
				self.childs[i]:colapseChilds()
			end
			self.childs[i].enabled = false
			
		end
		
		self.root:update()
	end;
	
	showChilds = function(self)
		self.opened = true
		self.root.activeLines = self.root.activeLines + #self.childs
		
		self.iconcolapse.icon.texture = `/common/gui/icons/treeviewopen.png`
		
		for i = 1, #self.childs do
			self.childs[i].enabled = true
		end
		
		self.root:update()
	end;
	
	update = function(self)
		self.offset = vec(self.offset.x, -(self.root.cline*21))
		self.root.cline = self.root.cline + 1
		if self.opened then
			for i = 1, #self.childs do
				self.childs[i]:update()
			end
		end
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		local kj = mouse_pos_abs - self.derivedPosition
		
		if self.dragging and #(kj - self.draggingPos) > 20 and not self.adding then
			self.adding = true
			
			print(#(kj - self.draggingPos))
			self.root:startMovingObject(self)
		end	
    end;
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - self.derivedPosition
		elseif ev == "-left" then
			if self.dragging and not self.adding then
				if self.root.selected ~= nil then
					self.root.selected.alpha=0
					self.root.selected.colour = vec(0, 0, 0)
				end
				self.root.selected = self
				
				self.alpha= 1
				self.colour = vec(0.3, 0.6, 1)			
			end
			
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.adding = false
        end
    end;	
})

hud_class `DraggingTreeViewObject` {
	alpha = 0;
	size = vec(150, 20);
	zOrder = 7;

	init = function (self)
		self.needsInputCallbacks = true
		
		self.iconx = create_rect({ parent = self, texture = self.icon, alpha = 1, size = vec(20, 20) })
		self.text = gfx_hud_text_add(`/common/fonts/Verdana12`)
		self.text.parent = self
		self.text.text = self.caption
		self.text.position = vec(self.text.size.x/2+self.iconx.size.x/2+4, 0)
		
	end;
	destroy = function (self)
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.position = vec2(mouse_pos_abs.x, mouse_pos_abs.y)

    end;
    buttonCallback = function (self, ev)
		
    end;	
}

hud_class `TreeView` (extends(GuiClass)
{
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	expand = true;
	activeLines = 0;
	
	cline = 0;
	
	init = function (self)
		GuiClass.init(self)
		self.childs = {}
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	addGroup = function(self, group, par)
		if par == nil then
			self.childs[#self.childs+1] = gfx_hud_object_add(`TreeViewGroup`, { name = group, parent = self, childs_child = true, offset = vec(0, -(self.activeLines+1)*21+20), expand_x = true, root = self, align = vec(0, 1) })
			self.activeLines = self.activeLines + 1
		else
			par:addChild(group)
		end
	end;
	
	-- addObject = function(self, obj, parent)
		-- if parent == nil then parent = self.childs end
		
		-- parent:addObjectChild(obj)
	-- end;
	
	update = function(self)
		self.cline = 0
		for i = 1, #self.childs do
			self.childs[i]:update()
		end
		self.cline = 0
		self.size = self.size
	end;

	startMovingObject = function(self, obj)
		self.floatingObject = gfx_hud_object_add(`DraggingTreeViewObject`, { icon = obj.icon, caption = obj.name })
		self.dragginGroup = obj
		--self.floatingObject = ""
		self.marker = create_rect({ parent = self, size = vec(self.size.x, 1), colour = vec(1, 0.5, 0) })
		self.marker.enabled = false
		self.needsInputCallbacks = true
	end;
	
	getObjectInLine = function(self, line)
		if line < activeLines and line > 0 then
			return 
		end
	end;	
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.floatingObject ~= nil then
			local nearest_group = nil
			
			local grpn = math.ceil((((self.derivedPosition.y - mouse_pos_abs.y)+self.size.y/2)) / 20)
			--print(((self.derivedPosition.y - mouse_pos_abs.y)+self.size.y/2))
			--print(grpn.." "..local_pos.y)
			nearest_group = self.childs[grpn]
			
			if nearest_group ~= nil and not nearest_group.destroyed then
				self.moveDraggingTo = nearest_group
				self.marker.enabled = true
				self.marker.position = nearest_group.position - vec(0, nearest_group.size.y/2+1)
			end
		end
		
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
		elseif ev == "-left" then
			safe_destroy(self.floatingObject)
			safe_destroy(self.marker)
			self.floatingObject = nil
			self.marker = nil
			if self.inside and self.moveDraggingTo then
				--self.dragginGroup
			end
        end
    end;	
})

-- safe_destroy(outl)
-- outl = gfx_hud_object_add(`TreeView`, { parent = editor_interface.map_editor_page.windows.object_properties, alpha = 0 })

-- outl:addGroup("Navigation")

-- outl.childs[1]:addChild("MyHouse01")
-- outl.childs[1]:addChild("MyCar2")
-- outl.childs[1]:addChild("Unnamed1")
-- outl.childs[1]:addChild("Tree34")

-- outl.childs[1].childs[4]:addChild("WOOOOOW")
-- outl.childs[1].childs[4]:addChild("WOOOOOW2")

-- outl.childs[1].childs[4].childs[2]:addChild("QQQQQQQQQQQQ")

-- for i = 1, 4 do
	-- outl:addGroup("Example "..i.."")
-- end