-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Clock" {

    init = function (self)
        self.alpha = 0
        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        self.label = gfx_hud_object_add("Label", { size=vector2(8*6+6, 13+5), parent=self })
        self.size = self.label.size
        self.inside = false;
    end;

    destroy = function (self)
        self.label = safe_destroy(self.label)
    end;

    frameCallback = function (self, elapsed)
        local secs = env.secondsSinceMidnight
        self.label.text.text = string.format("%02d:%02d:%02d",
                                        math.mod(math.floor(secs/60/60),24),
                                        math.mod(math.floor(secs/60),60),
                                        math.mod(secs,60))
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
