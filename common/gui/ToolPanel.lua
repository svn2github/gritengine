------------------------------------------------------------------------------
--  Tool Panel
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO: align left, icon click to collapse/show

hud_class `ToolPanel` (extends(GuiClass)
{
	resizing = false;
	align = vec(1, -1);
	alpha = 0.7;
	colour = V_ZERO;
	
	lastDefinedSize = vec(50, 50);
	
	init = function (self)
		GuiClass.init(self)
		self.needsInputCallbacks = true
		
		self.icon = create_rect({
			parent = self,
			size = vec(15, 15),
			texture = _gui_textures.triangle.up,
			orientation=90
		})
		
	end;
	
	destroy = function (self)
		GuiClass.destroy(self)
	end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
		self:updateIcon()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if self.resizing then
			self.size = vec(gfx_window_size().x-mouse_pos_abs.x, self.size.y)
			GuiClass.alignUpdate(self, self.parent.size)
			self:updateIcon()
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside and mouse_pos_abs.x < self.derivedPosition.x-self.size.x/2+8 then
			self.resizing = true
		elseif ev == "-left" then
			self.resizing = false
        end
    end;
	
	updateIcon = function(self)
		self.icon.position = vec(-self.size.x/2-self.icon.size.x/2, self.size.y/2-25)
	end;
})

function create_toolpanel(options)
	return gfx_hud_object_add(`ToolPanel`, options)
end

-- safe_destroy(mtlpn)

-- mtlpn = create_toolpanel({ size = vec(150, 786), parent = hud_center, offset = vec(0, 20), expand_offset = vec(0, -75), expand_y = true })
