-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `SettingEdit` {
  alpha = 0.5;
  colour = vec(128/255, 128/255, 128/255) * 0.5;
  caption="Setting";
  valueLocation = user_cfg;
  valueKey = "";

  init = function (self)
    self.needsInputCallbacks = true

    self.label = hud_object `/common/hud/Label` {
        value = self.caption;
        font = `/common/fonts/Impact24`;
        colour = vec(1, 0, 0)*1;
        alpha = 0;
        parent = self;
      }
    self.label.size = self.label.text.size
    self.label.position = vec2(-(self.label.parent.size.x / 2) + ((self.label.size.x / 2) + 10), 0)

    if type(self.valueLocation[self.valueKey]) == "boolean" then
      self.setBackground = hud_object `/common/hud/Rect` {
          colour = vec(1, 1, 1) * 0.8;
          alpha = 0.5;
          size = vec(70, 35);
          parent = self;
        }
      self.setBackground.position = vec2((self.setBackground.parent.size.x / 2) - ((self.setBackground.size.x / 2) + 5), 0)
      self.set = hud_object `/common/hud/Button` {
          caption = tostring(self.valueLocation[self.valueKey]);
          captionFont = `/common/fonts/Impact24`;
          size = vec(70, 35);
          captionPassiveColour = vec(0.9, 0.9, 0.9);
          captionClickColour = vec(1, 0.5, 0);
          captionHoverColour = vec(1, 1, 1);
          captionGreyedColour = vec(0.4, 0.4, 0.4);
          alpha = 0.5;
          backgroundPassiveColour = vec(0.25, 0.25, 0.25);
          backgroundClickColour = vec(0.25, 0.25, 0.25);
          backgroundGreyedColour = vec(0.25, 0.25, 0.25);
          backgroundHoverColour = vec(0.25, 0.25, 0.25);
          borderTexture = false;
          parent = self;
          pressedCallback = function(self)
            self.parent.valueLocation[self.parent.valueKey] = not self.parent.valueLocation[self.parent.valueKey]
            self:setCaption(tostring(self.parent.valueLocation[self.parent.valueKey]))
          end;
        }
      self.set.position = vec2((self.set.parent.size.x / 2) - ((self.set.size.x / 2) + 5), 0)
    elseif(type(self.valueLocation[self.valueKey]) == "string")then

    elseif(type(self.valueLocation[self.valueKey]) == "number")then

    end
  end;

  destroy = function (self)

  end;

  mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
    self.inside = inside
  end;

  buttonCallback = function (self, ev)
    if ev == "-left" and self.inside then

    end
  end;
}
