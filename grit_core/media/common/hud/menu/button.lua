-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Button` {
  caption = "X";
  captionColour = vec(0.9, 0.9, 0.9);
  captionColourClick = vec(1, 0.5, 0);
  captionColourHover = vec(1, 1, 1);
  captionColourGreyed = vec(0.4, 0.4, 0.4);
  font = `/common/fonts/Impact50`;
  edgeSize = vec2(3,40);
  edgeColour = vec(1, 102/255, 0);
  edgePosition = vec(0, 0);
  buttonType = "Setting";
  settingTableVariable = false;

  colour = vec(128/255, 128/255, 128/255) * 0.5;
  alpha = 0.5;

  init = function (self)
    self.needsInputCallbacks = true

    self.text = gfx_hud_text_add(self.font)
    self.text.parent = self
    self:setCaption(self.caption)

    self.edge = gfx_hud_object_add(`/common/hud/Rect`, {
        size = vec(0, 0);
        colour = vec(1, 0, 0)*1;
        alpha = 0;
        --texture = `/common/hud/LoadingScreen/GritLogo.png`;
        parent = self;
        position = vec2(0, 0);
      })
    self:setEdge()

    --self.size = self.text.size + 20

    self.dragging = false
    self.inside = false
    self.greyed = self.greyed or false

    self:refreshState();
  end;

  destroy = function (self)
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

  refreshState = function (self)
    if self.greyed then
      self.text.colour = self.captionColourGreyed
    else
      if self.dragging and self.inside then
        self.text.colour = self.edgeColour
      elseif self.inside then
        self.text.colour = self.captionColourHover
      else
        self.text.colour = self.captionColour
      end
    end
  end;
  
  setEdge = function (self)
    self.edge.colour = self.edgeColour
    self.edge.size = self.edgeSize
    self.edge.position = self.edgePosition
  end;

  mouseMoveCallback = function (self, local_pos, screen_pos, inside)
    self.inside = inside
    if(self.inside)then
      self.edge.alpha = 1
      self.text.shadow = vec(2, -2)
    else
      self.edge.alpha = 0
      self.text.shadow = vec(0, 0)
    end
    self:refreshState()
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
