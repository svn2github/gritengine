-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `GameModeButton` {
  alpha = 0.5;
  colour = vec(128/255, 128/255, 128/255) * 0.5;
  caption="Gamemode";
  font = `/common/fonts/Impact50`;
  isSelected = false;

  init = function (self)
    self.needsInputCallbacks = true

    self.text = gfx_hud_text_add(self.font)
    self.text.parent = self
    self:setCaption(self.caption)

    self.dragging = false
    self.inside = false
    self.greyed = self.greyed or false

    self:refreshState();
  end;

  destroy = function (self)

  end;

  Update = function (gui) --For selection
    if(gui.isSelected)then
      gui.alpha = 1
      gui.colour = vec(50/255, 50/255, 50/255) * 0.5;
    else
      gui.alpha = 0.5
      gui.colour = vec(128/255, 128/255, 128/255) * 0.5;
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

  refreshState = function (self)
    --[[if self.greyed then
      self.text.colour = self.captionColourGreyed
    else
      if self.dragging and self.inside then
        self.text.colour = self.textColor
      elseif self.inside then
        self.text.colour = self.captionColourHover
      else
        self.text.colour = self.captionColour
      end
    end]]--
  end;

  mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
    self.inside = inside
  end;

  setCaption = function (self, v)
    self.caption = v
    self.text.text = self.caption
    --self.size = self.text.size
  end;

  setGreyed = function (self, v)
    self.greyed = v
    self:refreshState();
  end;

  buttonCallback = function (self, ev)
    if ev == "+left" and self.inside then
      self.dragging = true
    elseif ev == "-left" then
      if self.dragging and self.inside and not self.greyed then
        self:pressedCallback()
		if self.destroyed then return end
      end
      self.dragging = false
    end
    self:refreshState()
  end;

  pressedCallback = function (self)
    error "Button has no associated action."
  end;
}