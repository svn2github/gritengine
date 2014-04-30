-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Rect` { }

BorderPane = {
    borderColour = vec(0, 0, 0);
    colour = vec(1, 1, 1);
    alpha = 1;
    init = function (self)
        self.top    = gfx_hud_object_add(`/common/hud/Rect`, {parent=self})
        self.bottom = gfx_hud_object_add(`/common/hud/Rect`, {parent=self})
        self.left   = gfx_hud_object_add(`/common/hud/Rect`, {parent=self})
        self.right  = gfx_hud_object_add(`/common/hud/Rect`, {parent=self})
        self:setBorderColour(self.borderColour)
        BorderPane.updateChildrenSize(self)
    end;

    updateChildrenSize = function (self)
        local sz = self.size

        self.top.size = vec(sz.x, 1)
        self.top.position = vec(0, -sz.y/2 + 0.5)

        self.bottom.size = vec(sz.x, 1)
        self.bottom.position = vec(0, sz.y/2 - 0.5)

        self.left.size = vec(1, sz.y)
        self.left.position = vec(-sz.x/2 + 0.5, 0)

        self.right.size = vec(1, sz.y)
        self.right.position = vec(sz.x/2 - 0.5, 0)
    end;

    setBorderColour = function (self, colour)
        self.top.colour = colour
        self.bottom.colour = colour
        self.left.colour = colour
        self.right.colour = colour
        self.borderColour = colour
    end;

    destroy = function (self)
    end;
}


hud_class `Positioner` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
    end;    
    parentResizedCallback = function (self, psize)
    	self.size = psize
        self.position = psize*self.factor + self.offset
    end;    
}   

hud_class `Stretcher` {     
    alpha = 0;
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
        self.child.parent = self
        self:updateChildrenSize()
    end;    
    updateChildrenSize = function (self)
    	self.child.size = self.size
        if self.child.updateChildrenSize then
            self.child:updateChildrenSize()
        end
    end;    
    calcRect = function (self, psize)
        return 0, 0, 300, 200
    end;
    parentResizedCallback = function (self, psize)
        local l, b, r, t = self:calcRect(psize)
        self:setRect(l, b, r, t)
        self:updateChildrenSize()
    end;
}   

hud_center = hud_center or gfx_hud_object_add(`Positioner`, { factor = vec(0.5, 0.5) })
hud_bottom_left = hud_bottom_left or gfx_hud_object_add(`Positioner`, { factor = vec(0.0, 0.0) })
hud_bottom_right = hud_bottom_right or gfx_hud_object_add(`Positioner`, { factor = vec(1.0, 0.0) })
hud_top_left = hud_top_left or gfx_hud_object_add(`Positioner`, { factor = vec(0.0, 1.0) })
hud_top_right = hud_top_right or gfx_hud_object_add(`Positioner`, { factor = vec(1.0, 1.0) })


