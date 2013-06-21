-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons BY-NC-SA license: http://creativecommons.org/licenses/by-nc-sa/3.0/

------------------------
---- Watermark logo ----
------------------------

hud_class "watermark" {
 init = function (self)
        self.needsFrameCallbacks = false
        self.texture = "textures/logo_detached_prealpha.png"
    end;
frameCallback = function (self, elapsed)
    end;
}

watermark = gfx_hud_object_add("watermark", {parent=hud_top_left, position=vector2(128,-32)})