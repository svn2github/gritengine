-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include "definitions.lua"

if gizmo ~= nil then
	safe_destroy(gizmo.x_a)
	safe_destroy(gizmo.y_a)
	safe_destroy(gizmo.z_a)
	safe_destroy(gizmo.dummy_xy)
	safe_destroy(gizmo.dummy_xz)
	safe_destroy(gizmo.dummy_yz)
end

gizmo = {}
gizmo.node = {}
gizmo.x_a = {}
gizmo.y_a = {}
gizmo.z_a = {}
gizmo.dummy_xy = {}
gizmo.dummy_xz = {}
gizmo.dummy_yz = {}

local function vlen(v1, v2)
    return math.sqrt(math.pow(v1.x-v2.x, 2)+math.pow(v1.y-v2.y, 2)+math.pow(v1.z-v2.z, 2))
end

function gizmo_resize()
	local mfov = math.pi / 4
	local cam_obj_dist = nil
	if gizmo.node.parent ~= nil then
		cam_obj_dist = vlen(player_ctrl.camPos, gizmo.node.parent.localPosition)
	else
		cam_obj_dist = vlen(player_ctrl.camPos, gizmo.node.localPosition)
	end
	local wsize = (2 * math.tan(mfov / 2)) * cam_obj_dist
	local gsize = 0.025 * wsize
	gizmo.node.localScale = vector3(gsize, gsize, gsize)
end

function destroy_gizmo()
	safe_destroy(gizmo.x_a)
	safe_destroy(gizmo.y_a)
	safe_destroy(gizmo.z_a)
	safe_destroy(gizmo.dummy_xy)
	safe_destroy(gizmo.dummy_xz)
	safe_destroy(gizmo.dummy_yz)
end

-- mode = translate, rotate, scale
create_gizmo = function(mode)
	if gizmo.node ~= nil or gizmo.node.activated ~= true then
		gizmo.node = gfx_body_make()
	end
	
	if type(mode) ~= "string" then
		if mode == 0 or mode == 1 then
			mode = "translate"
		elseif mode == 2 then
			mode = "rotate"
		elseif mode == 3 then
			mode = "scale"
		end
	end
	
	destroy_gizmo()
	
	if mode == "translate" or mode == "rotate" or mode == "scale" then
		gizmo.x_a = object ("/editor/core/arrows/arrow_"..mode) (0, 0, 0) {}
		gizmo.x_a:activate()
		gizmo.x_a.instance.gfx.localOrientation=euler(0, 0, -90)
		gizmo.x_a.instance.gfx:setMaterial("/editor/core/arrows/arrow", "/editor/core/arrows/red")
		gizmo.x_a.instance.gfx:setMaterial("/editor/core/arrows/line", "/editor/core/arrows/red")
		gizmo.x_a.instance.gfx.parent=gizmo.node
		gizmo.x_a.editor_object = true
		
		gizmo.y_a = object ("/editor/core/arrows/arrow_"..mode) (0, 0, 0) {}
		gizmo.y_a:activate()
		gizmo.y_a.instance.gfx:setMaterial("/editor/core/arrows/arrow", "/editor/core/arrows/green")
		gizmo.y_a.instance.gfx:setMaterial("/editor/core/arrows/line", "/editor/core/arrows/green")
		gizmo.y_a.instance.gfx.parent=gizmo.node
		gizmo.y_a.editor_object = true
		
		gizmo.z_a = object ("/editor/core/arrows/arrow_"..mode) (0, 0, 0) {}
		gizmo.z_a:activate()
		gizmo.z_a.instance.gfx.localOrientation=euler(90, 0, -90)
		gizmo.z_a.instance.gfx:setMaterial("/editor/core/arrows/arrow", "/editor/core/arrows/blue")
		gizmo.z_a.instance.gfx:setMaterial("/editor/core/arrows/line", "/editor/core/arrows/blue")
		gizmo.z_a.instance.gfx.parent=gizmo.node
		gizmo.z_a.editor_object = true
		
		if mode == "translate" or mode == "scale" then
			gizmo.dummy_xy = object "/editor/core/arrows/dummy_plane" (0, 0, 0) {}
			gizmo.dummy_xy:activate()
			gizmo.dummy_xy.instance.gfx.parent=gizmo.node
			gizmo.dummy_xy.editor_object = true
			
			gizmo.dummy_xz = object "/editor/core/arrows/dummy_plane" (0, 0, 0) {}
			gizmo.dummy_xz:activate()
			gizmo.dummy_xz.instance.gfx.localOrientation=euler(0, -90, -90)
			gizmo.dummy_xz.instance.gfx:setMaterial("/editor/core/arrows/line_1", "/editor/core/arrows/red")
			gizmo.dummy_xz.instance.gfx:setMaterial("/editor/core/arrows/line_2", "/editor/core/arrows/blue")
			gizmo.dummy_xz.instance.gfx.parent=gizmo.node
			gizmo.dummy_xz.editor_object = true
			
			gizmo.dummy_yz = object "/editor/core/arrows/dummy_plane" (0, 0, 0) {}
			gizmo.dummy_yz:activate()
			gizmo.dummy_yz.instance.gfx.localOrientation=euler(90, 0, 90)
			gizmo.dummy_yz.instance.gfx:setMaterial("/editor/core/arrows/line_1", "/editor/core/arrows/blue")
			gizmo.dummy_yz.instance.gfx:setMaterial("/editor/core/arrows/line_2", "/editor/core/arrows/green")
			gizmo.dummy_yz.instance.gfx.parent=gizmo.node
			gizmo.dummy_yz.editor_object = true
		end
	else
		print(RED.."This selection mode doesn't exist!")
	end
end

function gizmo_fade(vl)
	if gizmo.x_a ~= nil and gizmo.x_a.instance ~= nil then
		gizmo.x_a.instance.gfx.fade = vl
		gizmo.y_a.instance.gfx.fade = vl
		gizmo.z_a.instance.gfx.fade = vl
		if gizmo.dummy_xy ~= nil then
			gizmo.dummy_xy.instance.gfx.fade = vl
			gizmo.dummy_xz.instance.gfx.fade = vl
			gizmo.dummy_yz.instance.gfx.fade = vl
		end
	end
end

-- just for testing
create_gizmo("translate")

gizmo_fade(0)

-- the gizmo callbacks, for resizing
gizmo_cb = {}

local function gizmo_callback()
	gizmo_resize()
end

function gizmo_cb:start()
    main.frameCallbacks:insert("gizmo_cb", gizmo_callback)
    gizmo_callback(nil)
end
function gizmo_cb:stop()
	main.frameCallbacks:removeByName("gizmo_cb")
end

gizmo_cb:start()