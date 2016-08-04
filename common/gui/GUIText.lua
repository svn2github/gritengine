------------------------------------------------------------------------------
--  GUI Text
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `GuiText` (extends(GuiClass)
{
	font = _current_theme.fonts.default;
	colour = _current_theme.colours.text.default;
	size = vec(0, 0);
	alpha = 0;
	value = "";
	textColour = _current_theme.colours.text.default;
	
	init = function (self)
		GuiClass.init(self)
		self.text = gfx_hud_text_add(self.font)
		self.text.parent = self
		self.text.colour = self.textColour
		self:setValue(self.value)
	end;
	
	destroy = function (self)
		GuiClass.destroy(self)
	end;
	
	setValue = function (self, value)
		self.text.text = tostring(value)
		--self.text.position = vec(self.text.size.x/2+2, 0)
		self.size = self.text.size+4
	end;	

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;
})

function gui.text(options)
	return gfx_hud_object_add(`GuiText`, options)
end
