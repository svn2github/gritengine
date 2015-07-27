------------------------------------------------------------------------------
--  GUI button class
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `guibutton` (extends(GuiClass)
{
	padding = vec(8,6);

	alpha = 1;
	
	baseColour = vec(1,1,1) * 0.3;
	hoverColour = vec(1, 1, 1) * 0.45;
	clickColour = vec(1, 1, 1)* 0.7;
	colourGreyed = vec(1, 1, 1) * 0.9;
	
	captionBaseColour = vec(1, 1, 1) * 0.6;
	captionHoverColour = vec(1, 1, 1) * 0.4;
	captionClickColour = vec(1, 1, 1) * 0.1;
	captionColourGreyed = vec(1, 1, 1) * 0.1;
	
	font = `/common/fonts/Verdana12`;
	caption = "Button";
	
	cornered = true;
	texture = `../icons/FilledWhiteBorder042.png`;
	
	init = function (self)
		GuiClass.init(self)
		
		self.needsInputCallbacks = true

		self.text = gfx_hud_text_add(self.font)
		self.text.parent = self
		self.text.colour = self.captionBaseColour
		self:setCaption(self.caption)

		if not self.sizeSet then 
			self.size = self.text.size + self.padding * 2
		end

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
			self.dragging = false
		end

		self:refreshState()
	end;

	parentResizedCallback = function(self, psize)
		GuiClass.parentResizedCallback(self, psize)
	end;	
	
	pressedCallback = function (self)

	end;
})

function create_button(options)
	return gfx_hud_object_add(`guibutton`, options)
end