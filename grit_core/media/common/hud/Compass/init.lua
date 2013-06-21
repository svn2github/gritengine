-- (c) Alexey "Razzeeyy" Shmakov 2013, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Dave Cunningham and the Grit Game Engine Project, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--Razzeeyy's compass :3

hud_class "../Compass" {
	size = vector2(128,128);
    init = function (self)
        self.needsFrameCallbacks = true

        self.texture = "Compass/Body.png"
		
        self.pointer = gfx_hud_object_add("Rect", {texture = "Compass/Pointer.png", zOrder = 7, size=self.size})
        self.pointer.parent = self
        self.needle = gfx_hud_object_add("Rect", {texture = "Compass/Needle.png", size=self.size})
        self.needle.parent = self

        self.text = gfx_hud_text_add("TinyFont")
        self.text.text = "XXX"
        self.text.parent = self
        self.text.position = vector2(48,-50)
        self.text.colour = vector3(0,0,0)
    end;
    destroy = function (self)
        safe_destroy(self.pointer)
        safe_destroy(self.needle)
        safe_destroy(self.text)
    end;
    frameCallback = function (self, elapsed)
        self.needle.orientation = -player_ctrl.camYaw
        self.text.text = string.format("%03d",player_ctrl.camYaw + 0.5)
    end;
}

