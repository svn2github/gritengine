lastobj = {};

hud_class `testmousetoworld` {
	alpha = 0;
	size = vec(0, 0);
	zOrder = 0;

	init = function (self)
		self.needsFrameCallbacks = true;
		-- self.needsInputCallbacks = true;
		self.texxt = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.texxt.parent = self
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.texxt:destroy()
		self:destroy()
	end;
	frameCallback = function (self, elapsed)
		self:fmcb()
	end;
	fmcb = function(self)
		local ms = vec2((select(3, get_mouse_events()) ), math.abs((select(4, get_mouse_events()))-gfx_window_size().y))

		local kr = get_mouse_world_dir(vec2(ms.x/gfx_window_size().x, ms.y/gfx_window_size().y), player_ctrl.camPos, player_ctrl.camDir)

		local d,b,n,m = physics_cast(player_ctrl.camPos, kr * 800, true, 0)

		if b ~= nil then
			if lastobj ~= b.owner and lastobj.instance ~= nil then
				lastobj.instance.gfx.wireframe = false
			end
			
			self.texxt.text = b.owner.name
			b.owner.instance.gfx.wireframe = true
			lastobj = b.owner
		end	
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and lastobj.instance ~= nil then
			placement_editor:manip(lastobj)
        elseif ev == "-left" then
			
        end
    end;	
}
if test ~= nil then safe_destroy(test) end
test = gfx_hud_object_add(`testmousetoworld`, {parent=hud_center})