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

function ed_object_editor_page:select()
	self.camPos = main.camPos
	self.camQuat = main.camQuat
	gfx_option("RENDER_SKY", false)
	lens_flare.enabled = false
	
	local objs = object_all()
	for i = 1, #objs do
		if objs[i] ~= nil and not objs[i].destroyed and objs[i].instance ~= nil and objs[i].instance.gfx ~= nil and objs[i] ~= self.object then
			objs[i].instance.gfx.enabled = false
		end
	end
	
	if self.object ~= nil and not self.object.destroyed then
		self.object:activate()
		if self.object.instance.gfx ~= nil then
			self.object.instance.gfx.enabled = true
		end
		main.camPos = self.object.spawnPos
		GED:toggleBoard(self.object)
	end
end;

local function quatPitch(q)
	return math.deg(math.atan2(2*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z))
end

function ed_object_editor_page:unselect()
	if self.object ~= nil and not self.object.destroyed then
		GED:toggleBoard()
	end
	
	local objs = object_all()
	for i = 1, #objs do
		if objs[i] ~= nil and not objs[i].destroyed and objs[i].instance ~= nil and objs[i].instance.gfx ~= nil and not objs[i].objectEditor then
			objs[i].instance.gfx.enabled = true
		end
	end

	if self.object ~= nil and self.object.instance ~= nil and not self.object.destroyed then
		self.object.instance.gfx.enabled = false
	end		
	
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
	self.object = object (self.content_browser.currentdir.."/"..self.meshname) (0, 0, 0) { editorObject = true, objectEditor = true }
	self.object:activate()
end;

function ed_object_editor_page:destroy()
	
end;
