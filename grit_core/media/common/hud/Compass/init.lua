-- (c) Alexey "Razzeeyy" Shmakov 2013, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Dave Cunningham and the Grit Game Engine Project, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "../Compass" {
	size = vector2(128,128);
    init = function (self)
        self.needsFrameCallbacks = true

        self.texture = "Compass/Body.png"
		
        --pointer denotes a camera direction on the compass
        self.pointer = gfx_hud_object_add("Rect", {texture = "Compass/Pointer.png", zOrder = 7, size=self.size})
        self.pointer.parent = self
        --needle denotes the player model direction (if any) or same as the cam direction
        self.needle = gfx_hud_object_add("Rect", {texture = "Compass/Needle.png", size=self.size})
        self.needle.parent = self

        --bearing displayed in degrees
        self.text = gfx_hud_text_add("TinyFont")
        self.text.text = "XXX"
        self.text.parent = self
        self.text.position = vector2(48,-50)
        self.text.colour = vector3(0,0,0)

        self.letterInset = vector2(5, 5)

        --the cardinal directions
        self.N = gfx_hud_text_add("TinyFont")
        self.N.text = "N"
        self.N.parent = self
        self.N.position = vector2(0, self.size.y/2-self.N.size.y/2-self.letterInset.y)
        self.N.colour = vector3(1,0,0)

        self.S = gfx_hud_text_add("TinyFont")
        self.S.text = "S"
        self.S.parent = self
        self.S.position = vector2(0, -(self.size.y/2-self.S.size.y/2-self.letterInset.y))
        self.S.colour = vector3(0.5,0.5,0.5)

        self.W = gfx_hud_text_add("TinyFont")
        self.W.text = "W"
        self.W.parent = self
        self.W.position = vector2(-(self.size.x/2-self.W.size.x/2-self.letterInset.x), 0)
        self.W.colour = vector3(0.5,0.5,0.5)

        self.E = gfx_hud_text_add("TinyFont")
        self.E.text = "E"
        self.E.parent = self
        self.E.position = vector2(self.size.x/2-self.W.size.x-self.letterInset.x, 0)
        self.E.colour = vector3(0.5,0.5,0.5)
    end;
    destroy = function (self)
        safe_destroy(self.pointer)
        safe_destroy(self.needle)
        safe_destroy(self.text)
        safe_destroy(self.N)
        safe_destroy(self.S)
        safe_destroy(self.W)
        safe_destroy(self.E)
    end;
    frameCallback = function (self, elapsed)
        local orientation = -player_ctrl.camYaw
        local o = player_ctrl.controlObj
        if o then
            if o and o.instance and o.instance.body then
                local v = o.instance.body.worldOrientation*V_FORWARDS
                self.needle.orientation = math.deg(math.atan2(v.x, v.y))+orientation
            else
                self.needle.orientation = 0
            end
        else
            self.needle.orientation = 0
        end
        self.text.text = string.format("%03d",player_ctrl.camYaw + 0.5)
        local radOrientation = math.rad(orientation)
        local s, c = math.sin(radOrientation), math.cos(radOrientation)
        self.N.position = vector2(s*(self.size.x/2-self.N.size.x/2-self.letterInset.x),
                                  c*(self.size.y/2-self.N.size.y/2-self.letterInset.y))

        radOrientation = math.rad(orientation+180)
        s, c = math.sin(radOrientation), math.cos(radOrientation)
        self.S.position = vector2(s*(self.size.x/2-self.S.size.x/2-self.letterInset.x),
                                  c*(self.size.y/2-self.S.size.y/2-self.letterInset.y))

        radOrientation = math.rad(orientation+270)
        s, c = math.sin(radOrientation), math.cos(radOrientation)
        self.W.position = vector2(s*(self.size.x/2-self.W.size.x/2-self.letterInset.x),
                                  c*(self.size.y/2-self.W.size.y/2-self.letterInset.y))

        radOrientation = math.rad(orientation+90)
        s, c = math.sin(radOrientation), math.cos(radOrientation)
        self.E.position = vector2(s*(self.size.x/2-self.E.size.x/2-self.letterInset.x),
                                  c*(self.size.y/2-self.E.size.y/2-self.letterInset.y)) 
    end;
}

