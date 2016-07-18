hud_class `Settings` (extends(WindowClass)
{
	init = function (self)
		WindowClass.init(self)
		
		-- self.close_btn.pressedCallback = function (self)
			-- safe_destroy(self.parent.parent.parent)
		-- end;
		
		self.content = create_notebook(self)

		-- GENERAL
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
			offset = vec(10, -45);
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
			offset = vec(10+55, -45);
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
			offset = vec(10+110, -45);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 0, 1);
		})
		self.content.general_panel.button = create_button({
			caption = "Teleport";
			parent = self.content.general_panel;
			offset = vec(10+165, -45);
			align = vec(-1, 1);
			expand_x = false;
			expand_offset = vec(-20, 0);
			pressedCallback = function(self)
				main.camPos = vec(tonumber(self.parent.X.value), tonumber(self.parent.Y.value), tonumber(self.parent.Z.value))
			end;
			padding = vec(5, 2);
		})
		self.content.general_panel.pe = create_checkbox({
			caption = "Physics enabled",
			checked = main.physicsEnabled,
			parent = self.content.general_panel,
			align = vec(-1, 1);
			offset = vec(10, -70),
			onCheck = function(self)
				main.physicsEnabled = true
			end,
			onUncheck = function(self)
				main.physicsEnabled = false
			end,
		})
		self.content.general_panel.poto = create_checkbox({
			caption = "Physics one-to-one",
			checked = main.physicsOneToOne,
			parent = self.content.general_panel,
			align = vec(-1, 1);
			offset = vec(10, -90),
			onCheck = function(self)
				main.physicsOneToOne = true
			end,
			onUncheck = function(self)
				main.physicsOneToOne = false
			end,
		})


		
		-- DEBUG
		self.content.debug_panel = create_panel()
		
		self.content.debug_panel.fov = create_guitext({
			value = "FOV: ",
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -5);		
		})		
		
		self.content.debug_panel.foved = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.debug_panel;
			value = tostring(gfx_option("FOV"));
			alignment = "LEFT";
			enterCallback = function(self)
				gfx_option("FOV", tonumber(self.value))
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(50, -5);
		})		
		self.content.debug_panel.cmaps = create_checkbox({
			caption = "Use colour maps",
			checked = debug_cfg.colourMaps,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -30),
			onCheck = function(self)
				debug_cfg.colourMaps = true
			end,
			onUncheck = function(self)
				debug_cfg.colourMaps = false
			end,
		})
		self.content.debug_panel.dmaps = create_checkbox({
			caption = "Use diffuse maps",
			checked = debug_cfg.diffuseMaps,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -50),
			onCheck = function(self)
				debug_cfg.diffuseMaps = true
			end,
			onUncheck = function(self)
				debug_cfg.diffuseMaps = false
			end,
		})
		
		self.content.debug_panel.theme = create_guitext({
			value = "False Colour: ",
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -70);		
		})

		self.content.debug_panel.fc_selectbox = create_selectbox({
			parent = self.content.debug_panel;
			choices = {
				"false";
				"UV";
				"UV_STRETCH";
				"UV_STRETCH_BANDS";
				"NORMAL";
				"OBJECT_NORMAL";
				"NORMAL_MAP";
				"TANGENT";
				"BINORMAL";
				"UNSHADOWYNESS";
				"GLOSS";
				"SPECULAR";
				"SPECULAR_TERM";
				"SPECULAR_COMPONENT";
				"HIGHLIGHT";
				"FRESNEL";
				"FRESNEL_HIGHLIGHT";
				"DIFFUSE_COLOUR";
				"DIFFUSE_TERM";
				"DIFFUSE_COMPONENT";
				"VERTEX_COLOUR";
				"ENV_DIFFUSE_COMPONENT";
				"ENV_SPECULAR_COMPONENT";
				"ENV_DIFFUSE_LIGHT";
				"ENV_SPECULAR_LIGHT";
			};
			selection = 0;
			align = vec(-1, 1);
			offset = vec(100, -70);
			size = vec(200, 22);
		})
		self.content.debug_panel.fc_selectbox:select(tostring(debug_cfg.falseColour))

		self.content.debug_panel.fc_selectbox.onSelect = function(self)
			if self.selected.name == "false" then
				debug_cfg.falseColour = false
			elseif self.value == "true" then
				debug_cfg.falseColour = true
			else
				debug_cfg.falseColour = self.selected.name
			end
		end;		
		
		self.content.debug_panel.farc = create_guitext({
			value = "Far Clip: ",
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -95);		
		})		
		
		self.content.debug_panel.farced = gfx_hud_object_add(`/common/gui/window_editbox`, {
			parent = self.content.debug_panel;
			value = tostring(gfx_option("FAR_CLIP"));
			alignment = "LEFT";
			enterCallback = function(self)
				gfx_option("FAR_CLIP", tonumber(self.value))
			end;
			size = vec(50, 20);
			align = vec(-1, 1);
			offset = vec(70, -95);
		})			
		
		self.content.debug_panel.fcol = create_checkbox({
			caption = "Distance Fog",
			checked = debug_cfg.fog,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -120),
			onCheck = function(self)
				debug_cfg.fog = true
			end,
			onUncheck = function(self)
				debug_cfg.fog = false
			end,
		})
		self.content.debug_panel.fpro = create_checkbox({
			caption = "Fragment processing",
			checked = debug_cfg.fragmentProcessing,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -140),
			onCheck = function(self)
				debug_cfg.fragmentProcessing = true
			end,
			onUncheck = function(self)
				debug_cfg.fragmentProcessing = false
			end,
		})		
		self.content.debug_panel.gmaps = create_checkbox({
			caption = "Gloss maps",
			checked = debug_cfg.glossMaps,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -160),
			onCheck = function(self)
				debug_cfg.glossMaps = true
			end,
			onUncheck = function(self)
				debug_cfg.glossMaps = false
			end,
		})			
		self.content.debug_panel.hbl = create_checkbox({
			caption = "Heightmap blending",
			checked = debug_cfg.heightmapBlending,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -180),
			onCheck = function(self)
				debug_cfg.heightmapBlending = true
			end,
			onUncheck = function(self)
				debug_cfg.heightmapBlending = false
			end,
		})
		self.content.debug_panel.nmps = create_checkbox({
			caption = "Normal maps",
			checked = debug_cfg.normalMaps,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -200),
			onCheck = function(self)
				debug_cfg.normalMaps = true
			end,
			onUncheck = function(self)
				debug_cfg.normalMaps = false
			end,
		})		
		self.content.debug_panel.pdw = create_checkbox({
			caption = "Physics debug world",
			checked = debug_cfg.physicsDebugWorld,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -220),
			onCheck = function(self)
				debug_cfg.physicsDebugWorld = true
			end,
			onUncheck = function(self)
				debug_cfg.physicsDebugWorld = false
			end,
		})
		self.content.debug_panel.pw = create_checkbox({
			caption = "Physics wireframe",
			checked = debug_cfg.physicsWireFrame,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -240),
			onCheck = function(self)
				debug_cfg.physicsWireFrame = true
			end,
			onUncheck = function(self)
				debug_cfg.physicsWireFrame = false
			end,
		})		

		self.content.debug_panel.plmod = create_guitext({
			value = "Polygon Mode: ",
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -260);		
		})
		self.content.debug_panel.plmodsel = create_selectbox({
			parent = self.content.debug_panel;
			choices = {
				"SOLID";
				"SOLID_WIREFRAME";
				"WIREFRAME";
			};
			selection = 0;
			align = vec(-1, 1);
			offset = vec(110, -260);
			size = vec(200, 22);
		})
		self.content.debug_panel.plmodsel:select(tostring(debug_cfg.polygonMode))
		self.content.debug_panel.plmodsel.onSelect = function(self)
			debug_cfg.polygonMode = self.selected.name
		end;
		
		self.content.debug_panel.smmod = create_guitext({
			value = "Shading Model: ";
			parent = self.content.debug_panel;
			align = vec(-1, 1);
			offset = vec(10, -285);		
		})
		self.content.debug_panel.smmodsel = create_selectbox({
			parent = self.content.debug_panel;
			choices = {
				"SHARP";
				"HALF_LAMBERT";
				"WASHED_OUT";
			};
			selection = 0;
			align = vec(-1, 1);
			offset = vec(110, -285);
			size = vec(200, 22);
		})
		self.content.debug_panel.smmodsel:select(tostring(debug_cfg.shadingModel))
		self.content.debug_panel.smmodsel.onSelect = function(self)
			debug_cfg.shadingModel = self.selected.name
		end;		
		
		self.content.debug_panel.sc = create_checkbox({
			caption = "Shadow cast",
			checked = debug_cfg.shadowCast,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -310),
			onCheck = function(self)
				debug_cfg.shadowCast = true
			end,
			onUncheck = function(self)
				debug_cfg.shadowCast = false
			end,
		})
		self.content.debug_panel.sr = create_checkbox({
			caption = "Shadow receive",
			checked = debug_cfg.shadowReceive,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -330),
			onCheck = function(self)
				debug_cfg.shadowReceive = true
			end,
			onUncheck = function(self)
				debug_cfg.shadowReceive = false
			end,
		})
		self.content.debug_panel.ta = create_checkbox({
			caption = "Texture animation",
			checked = debug_cfg.textureAnimation,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -350),
			onCheck = function(self)
				debug_cfg.textureAnimation = true
			end,
			onUncheck = function(self)
				debug_cfg.textureAnimation = false
			end,
		})
		self.content.debug_panel.tf = create_checkbox({
			caption = "Texture fetches",
			checked = debug_cfg.textureFetches,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -370),
			onCheck = function(self)
				debug_cfg.textureFetches = true
			end,
			onUncheck = function(self)
				debug_cfg.textureFetches = false
			end,
		})
		self.content.debug_panel.ts = create_checkbox({
			caption = "Texture scale",
			checked = debug_cfg.textureScale,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -390),
			onCheck = function(self)
				debug_cfg.textureScale = true
			end,
			onUncheck = function(self)
				debug_cfg.textureScale = false
			end,
		})
		self.content.debug_panel.tm = create_checkbox({
			caption = "Translucency maps",
			checked = debug_cfg.translucencyMaps,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -410),
			onCheck = function(self)
				debug_cfg.translucencyMaps = true
			end,
			onUncheck = function(self)
				debug_cfg.translucencyMaps = false
			end,
		})
		self.content.debug_panel.vd = create_checkbox({
			caption = "Vertex diffuse",
			checked = debug_cfg.vertexDiffuse,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -430),
			onCheck = function(self)
				debug_cfg.vertexDiffuse = true
			end,
			onUncheck = function(self)
				debug_cfg.vertexDiffuse = false
			end,
		})
		self.content.debug_panel.vp = create_checkbox({
			caption = "Vertex processing",
			checked = debug_cfg.vertexProcessing,
			parent = self.content.debug_panel,
			align = vec(-1, 1);
			offset = vec(10, -450),
			onCheck = function(self)
				debug_cfg.vertexProcessing = true
			end,
			onUncheck = function(self)
				debug_cfg.vertexProcessing = false
			end,
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
			offset = vec(10, -25);
			expand_x = true;
			expand_offset = vec(-20, 0);
		})		
		self.content.placement_panel.offsett = create_guitext({
			value = "Additional ground offset: ",
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
			offset = vec(10, -65);
		})
		self.content.placement_panel.button1 = create_button({
			caption = "Clear last placed object";
			parent = self.content.placement_panel;
			offset = vec(10, -95);
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
			offset = vec(10, -130);
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
			offset = vec(10, -25);
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
			offset = vec(10, -65);
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
			offset = vec(10, -110);
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
			offset = vec(10+55, -110);
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
			offset = vec(10+110, -110);
			expand_x = false;
			expand_offset = vec(-20, 0);
			colour = vec(0, 0, 1);
		})
		self.content.object_panel.button1 = create_button({
			caption = "Clear last placed object";
			parent = self.content.object_panel;
			offset = vec(10, -140);
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
			offset = vec(10, -175);
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
			offset = vec(10, -25);
			expand_x = true;
			expand_offset = vec(-20, 0);
		})		
		self.content.particles_panel.button1 = create_button({
			caption = "Clear all particles";
			parent = self.content.particles_panel;
			offset = vec(10, -55);
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
			offset = vec(10, -45);
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
			offset = vec(10+55, -45);
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
			offset = vec(10+110, -45);
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
		self.content:addPage(self.content.debug_panel, "Debug Config")
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