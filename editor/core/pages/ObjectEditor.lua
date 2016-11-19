ed_object_editor_page = {}

function ed_object_editor_page.new()
	local self =
	{
		windows = {};
		object = nil;	
	}

	make_instance(self, ed_object_editor_page)
	return self
end;

local function toggle_vehicle_wheels(vehicle, v)
	local inst = vehicle.instance
	local wheels = inst.wheels
	if wheels ~= nil and wheels.front_left ~= nil and wheels.front_right ~= nil and
	wheels.rear_left ~= nil and
	wheels.rear_right ~= nil
	then
		wheels.front_left.wheelGfx.enabled = v
		wheels.front_right.wheelGfx.enabled = v
		wheels.rear_left.wheelGfx.enabled = v
		wheels.rear_right.wheelGfx.enabled = v
	end
end

function ed_object_editor_page:select()
	self.camPos = main.camPos
	self.camQuat = main.camQuat
	gfx_option("RENDER_SKY", false)
	lens_flare.enabled = false
	
	local objs = object_all()
	
	for i = 1, #objs do
		-- activate all object editor objects to hide them
		if objs[i] ~= nil and not objs[i].destroyed and objs[i].objectEditor then
			objs[i]:activate()
		end
	end	
	
	for i = 1, #objs do
		if objs[i] ~= nil and not objs[i].destroyed and objs[i].instance ~= nil and objs[i].instance.gfx ~= nil and objs[i] ~= self.object then
			objs[i].instance.gfx.enabled = false
			toggle_vehicle_wheels(objs[i], false)
		end
	end
	
	if self.object ~= nil and not self.object.destroyed then
		self.object:activate()
		if self.object.instance.gfx ~= nil then
			self.object.instance.gfx.enabled = true
			toggle_vehicle_wheels(self.object, true)
		end
		main.camPos = self.object.spawnPos
		GED:toggleBoard(self.object)
	end
end;

local function quatPitch(q)
	return math.deg(math.atan2(2*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z))
end

function ed_object_editor_page:hide()
	if self.object ~= nil and self.object.instance ~= nil and not self.object.destroyed then
		self.object.instance.gfx.enabled = false
		toggle_vehicle_wheels(self.object, false)
	end		
end;

function ed_object_editor_page:unselect()
	if self.object ~= nil and not self.object.destroyed then
		GED:toggleBoard()
	end
	
	local objs = object_all()
	for i = 1, #objs do
		if objs[i] ~= nil and not objs[i].destroyed and objs[i].instance ~= nil and objs[i].instance.gfx ~= nil and not objs[i].objectEditor then
			objs[i].instance.gfx.enabled = true
			toggle_vehicle_wheels(objs[i], true)
		end
	end

	self:hide()
	
	--safe_destroy(self.object)
	--self.object = nil
	gfx_option("RENDER_SKY", true)
	lens_flare.enabled = true
	main.camPos = self.camPos
	main.camQuat = self.camQuat
	GED.camPitch = quatPitch(main.camQuat)
	GED.camYaw = cam_yaw_angle()	
end;

function ed_object_editor_page:init()
	self.object = object (self.content_browser.currentdir.."/"..self.meshname) (0, 0, -10000) {
	editorObject = true,
	objectEditor = true,
	init = function(persistent) persistent.instance.gfx.enabled = false end
	}
	self.object:activate()
end;

function ed_object_editor_page:destroy()
	
end;
