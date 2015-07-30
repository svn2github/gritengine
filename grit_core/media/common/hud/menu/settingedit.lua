-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `SettingEdit` {
  alpha = 0.5;
  colour = vec(128/255, 128/255, 128/255) * 0.5;
  caption="Setting";
  valueType="boolean";
  valueLocation = user_cfg;
  valueKey = "";

  init = function (self)
    self.needsInputCallbacks = true

    self.label = gfx_hud_object_add(`/common/hud/Label`, {
        value = self.caption;
        font = `/common/fonts/Impact24`;
        --size = vec(10, 40);
        colour = vec(1, 0, 0)*1;
        alpha = 0;
        --texture = `/common/hud/LoadingScreen/GritLogo.png`;
        parent = self;
      })
    self.label.size = self.label.text.size
    self.label.position = vec2(-(self.label.parent.size.x / 2) + ((self.label.size.x / 2) + 10), 0)

    if(self.valueType == "boolean")then
      self.setBackground = gfx_hud_object_add(`/common/hud/Rect`, {
          colour = vec(1, 1, 1) * 0.8;
          alpha = 0.5;
          size = vec(70, 35);
          --texture = `/editor/core/icons/checkbox_checked.png`;
          parent = self;
        })
      self.setBackground.position = vec2((self.setBackground.parent.size.x / 2) - ((self.setBackground.size.x / 2) + 5), 0)
      self.set = gfx_hud_object_add(`Button`, {
          --colour = vec(128/255, 128/255, 128/255) * 0.2;
          caption = tostring(self.valueLocation[self.valueKey]);
          font = `/common/fonts/Impact24`;
          size = vec(70, 35);
          borderTexture = nil;
          --texture = `/editor/core/icons/checkbox_checked.png`;
          parent = self;
          pressedCallback = function(self)
            self.parent.valueLocation[self.parent.valueKey] = not self.parent.valueLocation[self.parent.valueKey]
            self:setCaption(tostring(self.parent.valueLocation[self.parent.valueKey]))
          end;
        })
      self.set.position = vec2((self.set.parent.size.x / 2) - ((self.set.size.x / 2) + 5), 0)
    elseif(self.valueType == "string")then

    elseif(self.valueType == "number")then

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