-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Clock" {

    init = function (self)
        self.alpha = 0
        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        local font = "/common/fonts/Impact50"
        self.label = gfx_hud_object_add("Label", { size=self.size, parent=self, font=font })
        self.inside = false;
    end;

    destroy = function (self)
        self.label = safe_destroy(self.label)
    end;

    frameCallback = function (self, elapsed)
        local secs = env.secondsSinceMidnight
        self.label:setValue(format_time(env.secondsSinceMidnight))
    end;

    mouseMoveCallback = function (self, rel, abs, inside)
        self.inside = inside
    end;
    buttonCallback = function (self, key)
        if not self.inside then return end
        local interval = ui:shift() and 60*60 or 5*60
        if key == "+left" then
            env.secondsSinceMidnight = (env.secondsSinceMidnight - interval) % (24*60*60)
        elseif key == "+right" then
            env.secondsSinceMidnight = (env.secondsSinceMidnight + interval) % (24*60*60)
        elseif key == "+middle" then
            env.clockTicking = not env.clockTicking
        end
    end;
}
