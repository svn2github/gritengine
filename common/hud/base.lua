-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Rect` { }

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
hud_bottom = hud_bottom or gfx_hud_object_add(`Positioner`, { factor = vec(0.5, 0) })
hud_bottom_left = hud_bottom_left or gfx_hud_object_add(`Positioner`, { factor = vec(0.0, 0.0) })
hud_bottom_right = hud_bottom_right or gfx_hud_object_add(`Positioner`, { factor = vec(1.0, 0.0) })
hud_top = hud_top or gfx_hud_object_add(`Positioner`, { factor = vec(0.5, 1.0) })
hud_top_left = hud_top_left or gfx_hud_object_add(`Positioner`, { factor = vec(0.0, 1.0) })
hud_top_right = hud_top_right or gfx_hud_object_add(`Positioner`, { factor = vec(1.0, 1.0) })

hud_focus = hud_focus or nil
function hud_focus_grab(v)
    if hud_focus ~= nil and not hud_focus.destroyed then
        hud_focus:setFocus(false)
    end
    hud_focus = v
    if hud_focus ~= nil then
        hud_focus:setFocus(true)
    end
end
