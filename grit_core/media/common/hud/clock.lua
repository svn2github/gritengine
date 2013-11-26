-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Clock" {

    init = function (self)
        self.alpha = 0
        self.needsFrameCallbacks = true
        self.label = gfx_hud_object_add("Label", { size=vector2(8*6+6, 13+5), parent=self })
        self.size = self.label.size
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
}
