-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Rect" { }

BorderPane = {
    borderColour = vector3(0,0,0);
    colour = vector3(1,1,1);
    alpha = 1;
    init = function (self)
        self.top    = gfx_hud_object_add("/common/hud/Rect", {parent=self})
        self.bottom = gfx_hud_object_add("/common/hud/Rect", {parent=self})
        self.left   = gfx_hud_object_add("/common/hud/Rect", {parent=self})
        self.right  = gfx_hud_object_add("/common/hud/Rect", {parent=self})
        self:setBorderColour(self.borderColour)
        BorderPane.updateChildrenSize(self)
    end;

    updateChildrenSize = function (self)
        local sz = self.size

        self.top.size = vector2(sz.x, 1)
        self.top.position = vector2(0, -sz.y/2 + 0.5)

        self.bottom.size = vector2(sz.x, 1)
        self.bottom.position = vector2(0, sz.y/2 - 0.5)

        self.left.size = vector2(1, sz.y)
        self.left.position = vector2(-sz.x/2 + 0.5, 0)

        self.right.size = vector2(1, sz.y)
        self.right.position = vector2(sz.x/2 - 0.5, 0)
    end;

    setBorderColour = function (self, colour)
        self.top.colour = colour
        self.bottom.colour = colour
        self.left.colour = colour
        self.right.colour = colour
        self.borderColour = colour
    end;

    destroy = function (self)
        self.bottom = safe_destroy(self.bottom)
        self.top = safe_destroy(self.top)
        self.left = safe_destroy(self.left)
        self.right = safe_destroy(self.right)
    end;
}


-- TODO: an official way of extending hud classes would probably be a good idea
hud_class "BorderPane" (BorderPane)


hud_class "Positioner" {     
    size = vector2(0,0);    
    factor = vector2(1,1);
    offset = vector2(0,0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
    end;    
    parentResizedCallback = function (self, psize)
    	self.size = psize
        self.position = math.floor(psize*self.factor + self.offset) -- floor to avoid a 0.5 pixel offset if width or height is an odd number    
    end;    
}   

hud_center = hud_center or gfx_hud_object_add("Positioner", { factor = vector2(0.5, 0.5) })
hud_bottom_left = hud_bottom_left or gfx_hud_object_add("Positioner", { factor = vector2(0.0, 0.0) })
hud_bottom_right = hud_bottom_right or gfx_hud_object_add("Positioner", { factor = vector2(1.0, 0.0) })
hud_top_left = hud_top_left or gfx_hud_object_add("Positioner", { factor = vector2(0.0, 1.0) })
hud_top_right = hud_top_right or gfx_hud_object_add("Positioner", { factor = vector2(1.0, 1.0) })


