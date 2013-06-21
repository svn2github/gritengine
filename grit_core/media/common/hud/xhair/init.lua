-- (c) Alexey "Razzeeyy" Shmakov 2013, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--Razzeeyy's funny crosshair :3
disk_resource_load_indefinitely("xhair.png")

hud_class "xhair" {
    --    size = vector2(8,8);
    init = function (self)
        self.texture = "xhair.png"
        self.colors = {
            [1] = vector3(0,0,0); 
            [2] = vector3(2,2,2);
            [3] = vector3(2,2,0);
            [4] = vector3(0,2,2);
            [5] = vector3(2,0,2);
            [6] = vector3(2,0,0);
            [7] = vector3(0,2,0);
            [8] = vector3(0,0,2);
        }
        self.timeLasted = 1;
    end;
--[[    
    destroy = function (self)
    end;
--]]
    frameCallback = function (self, elapsed)
        self.timeLasted = self.timeLasted + elapsed
        local floored_time = math.floor(self.timeLasted)
        if floored_time > #self.colors then
            self.timeLasted = 1
            floored_time = 1
        end
        self.colour = self.colors[floored_time]
    end;
    toggleVisible = function(self)
        if self.needsFrameCallbacks then
            self.needsFrameCallbacks = false
        else
            self.needsFrameCallbacks = true
        end
    end
}
xhair = gfx_hud_object_add("xhair")
xhair.parent = center_screen

button_xhair = gfx_hud_object_add("../Button", {
    pressedCallback = function(self)
        xhair:toggleVisible()
    end;
    caption = "xhair";
    position = vector2(200, 90);
    size = vector2(32, 32);
    colour = vector3(1, 1, 0);
})
