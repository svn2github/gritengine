local Line = {
    init = function (self)
        self.needsParentResizedCallbacks = true;
        --self.size = vec(0, 2);
        self:setThickness(2);
    end;
    
    parentResizedCallback = function (self, psize)
        --we use biggest screen side as a line length, to prevent VerticalLine shrinking
        --(self.size.x is actually a heigh of the vertical line so sometimes the line doesn't stroke thru all screen)
        self.size = vec(psize.x > psize.y and psize.x or psize.y, self.size.y);
    end;
    
    setThickness = function (self, width)
        self.size = vec(self.size.x, width);
    end;
    
    getThickness = function (self)
        return self.size.y;
    end;
}

hud_class `HorizontalLine` (Line);

hud_class `VerticalLine` (extends(Line){
    init = function (self)
        Line.init(self);
        self.orientation = 90;
    end;
});
