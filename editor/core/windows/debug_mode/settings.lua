hud_class `Settings` (extends(WindowClass)
{
	init = function (self)
		WindowClass.init(self)
		
		-- self.close_btn.pressedCallback = function (self)
			-- safe_destroy(self.parent.parent.parent)
		-- end;
		
		self.content = create_notebook(self)

		self.content.general_panel = create_panel()
		
		self.content.general_panel.warp = create_checkbox({
			caption = "Walk through walls",
			checked = editor_cfg.warp,
			parent = self.content.general_panel,
			align = vec(-1, 1);
			offset = vec(10, -7),
			onCheck = function(self)
				print(GREEN.."TODO")
			end,
			onUncheck = function(self)
				print(GREEN.."TODO")
			end,
		})

		self.content.general_panel.teleport = create_guitext({
			value = "Teleport to: ",
			parent = self.content.general_panel,
			align = vec(-1, 1);
			offset = vec(10, -25);		
		})

		self.content.general_panel.X = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.general_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(1, 0, 0);
		})

		self.content.general_panel.Y = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.general_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+55, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 1, 0);
		})		
		
		self.content.general_panel.Z = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.general_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+110, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 0, 1);
		})
		
		self.content.general_panel.button = create_button({
			caption = "Teleport";
			parent = self.content.general_panel;
			offset = vec(5+165, -45);
			align = vec(-1, 1);
			expand_x = false;
			expand_offset = vec(-20, 0);
			pressedCallback = function(self)
				main.camPos = vec(tonumber(self.parent.X.value), tonumber(self.parent.Y.value), tonumber(self.parent.Z.value))
			end;
			padding = vec(5, 2);
		})
		
		local function clearAllPlaced()
			for _, obj in ipairs(object_all()) do
				if obj.destroyed then 
					-- Skip
				elseif obj.debugObject == true then
					safe_destroy(obj)
				else
					obj:deactivate()
					obj.skipNextActivation = false
				end
			end		
		end
		
		-- PLACEMENT GUN
		self.content.placement_panel = create_panel()
		self.content.placement_panel.theme = create_guitext({
			value = "Class: ",
			parent = self.content.placement_panel,
			align = vec(-1, 1);
			offset = vec(10, -5);		
		})
		self.content.placement_panel.classb = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.placement_panel;
			value = `/common/veg/Tree_aelm`;
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.class = self.value
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -25);
			expand_x = true;
			expand_offset = vec(-20, 0);
		})		
		self.content.placement_panel.offsett = create_guitext({
			value = "Additional offset from ground: ",
			parent = self.content.placement_panel,
			align = vec(-1, 1);
			offset = vec(10, -45);		
		})		
		self.content.placement_panel.offset = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.placement_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.additionalOffset = tonumber(self.value) or 0
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -65);
		})
		self.content.placement_panel.button1 = create_button({
			caption = "Clear last placed object";
			parent = self.content.placement_panel;
			offset = vec(5, -95);
			align = vec(-1, 1);
			pressedCallback = function(self)
				if WeaponCreate.lastPlaced then
					safe_destroy(WeaponCreate.lastPlaced)
					WeaponCreate.lastPlaced = nil
				end
			end;

		})
		self.content.placement_panel.button2 = create_button({
			caption = "Clear all placed obejcts";
			parent = self.content.placement_panel;
			offset = vec(5, -130);
			align = vec(-1, 1);
			pressedCallback = function(self)
				clearAllPlaced()
			end;
		})

		-- OBJECT FIRING GUN
		self.content.object_panel = create_panel()
		self.content.object_panel.theme = create_guitext({
			value = "Class: ",
			parent = self.content.object_panel,
			align = vec(-1, 1);
			offset = vec(10, -5);		
		})
		self.content.object_panel.classb = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.object_panel;
			value = `/common/veg/Tree_aelm`;
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.class = self.value
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -25);
			expand_x = true;
			expand_offset = vec(-20, 0);
		})		
		self.content.object_panel.vel = create_guitext({
			value = "Velocity (m/s): ",
			parent = self.content.object_panel,
			align = vec(-1, 1);
			offset = vec(10, -45);		
		})		
		self.content.object_panel.velt = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.object_panel;
			value = "1";
			alignment = "LEFT";
			enterCallback = function(self)
				
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -65);
		})
		self.content.object_panel.teleport = create_guitext({
			value = "Spin: ",
			parent = self.content.object_panel,
			align = vec(-1, 1);
			offset = vec(10, -90);		
		})
		self.content.object_panel.X = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.object_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.spin = self.value
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -110);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(1, 0, 0);
		})
		self.content.object_panel.Y = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.object_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.spin = self.value
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+55, -110);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 1, 0);
		})		
		self.content.object_panel.Z = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.object_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponCreate.spin = self.value
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+110, -110);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 0, 1);
		})
		self.content.object_panel.button1 = create_button({
			caption = "Clear last placed object";
			parent = self.content.object_panel;
			offset = vec(5, -140);
			align = vec(-1, 1);
			pressedCallback = function(self)
				if WeaponCreate.lastPlaced then
					safe_destroy(WeaponCreate.lastPlaced)
					WeaponCreate.lastPlaced = nil
				end
			end;
		})
		self.content.object_panel.button2 = create_button({
			caption = "Clear all placed obejcts";
			parent = self.content.object_panel;
			offset = vec(5, -175);
			align = vec(-1, 1);
			pressedCallback = function(self)
				clearAllPlaced()
			end;
		})

		self.content.particles_panel = create_panel()
		self.content.particles_panel.theme = create_guitext({
			value = "Class: ",
			parent = self.content.particles_panel,
			align = vec(-1, 1);
			offset = vec(10, -5);		
		})
		self.content.particles_panel.classb = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.particles_panel;
			value = `/common/particles/Flame`;
			alignment = "LEFT";
			enterCallback = function(self)
				WeaponFlame.class = self.value
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -25);
			expand_x = true;
			expand_offset = vec(-20, 0);
		})		
		self.content.particles_panel.button1 = create_button({
			caption = "Clear all particles";
			parent = self.content.particles_panel;
			offset = vec(5, -55);
			align = vec(-1, 1);
			pressedCallback = function(self)
				print(GREEN.."TODO")
			end;
		})		
		
		
		
		self.content.prod_panel = create_panel()
		
		self.content.prod_panel.warp = create_checkbox({
			caption = "Push away",
			checked = true,
			parent = self.content.prod_panel,
			align = vec(-1, 1);
			offset = vec(10, -7),
			onCheck = function(self)
				print(GREEN.."TODO")
				
				self.parent.direction.text.alpha = 0.5
				self.parent.X.alpha = 0.5
				self.parent.Y.alpha = 0.5
				self.parent.Z.alpha = 0.5
				self.parent.X:setGreyed(true)
				self.parent.Y:setGreyed(true)
				self.parent.Z:setGreyed(true)
			end,
			onUncheck = function(self)
				print(GREEN.."TODO")
			
				self.parent.direction.text.alpha = 1
				self.parent.X.alpha = 1
				self.parent.Y.alpha = 1
				self.parent.Z.alpha = 1
				self.parent.X:setGreyed(false)
				self.parent.Y:setGreyed(false)
				self.parent.Z:setGreyed(false)
			end,
		})		
		
		self.content.prod_panel.direction = create_guitext({
			value = "Direction:",
			parent = self.content.prod_panel,
			align = vec(-1, 1);
			offset = vec(10, -25);
		})

		self.content.prod_panel.X = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.prod_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(1, 0, 0);
		})

		self.content.prod_panel.Y = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.prod_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+55, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 1, 0);
		})		
		
		self.content.prod_panel.Z = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.prod_panel;
			value = "0";
			alignment = "LEFT";
			enterCallback = function(self)
				print(GREEN.."TODO")
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(5+110, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 0, 1);
		})		
		
		self.content.prod_panel.direction.text.alpha = 0.5
		self.content.prod_panel.X.alpha = 0.5
		self.content.prod_panel.Y.alpha = 0.5
		self.content.prod_panel.Z.alpha = 0.5
		self.content.prod_panel.X:setGreyed(true)
		self.content.prod_panel.Y:setGreyed(true)
		self.content.prod_panel.Z:setGreyed(true)

		
		self.content.prod_panel.force = create_guitext({
			value = "Force to push at:",
			parent = self.content.prod_panel,
			align = vec(-1, 1);
			offset = vec(10, -65);		
		})		
		
		-- TODO
		
		
		-- self.content.grab_panel = create_panel()
		
		self.content:addPage(self.content.general_panel, "General")
		self.content:addPage(self.content.placement_panel, "Placement Gun")
		self.content:addPage(self.content.object_panel, "Object Firing Gun")
		-- self.content:addPage(self.content.delete_panel, "Delete Gun")
		self.content:addPage(self.content.particles_panel, "Particle Gun")
		self.content:addPage(self.content.prod_panel, "Prod Gun")
		-- self.content:addPage(self.content.grab_panel, "Grab Gun")
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