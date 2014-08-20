local Line = {
    init = function (self)
        self.needsParentResizedCallbacks = true;
        --self.size = vec(0, 2);
        self:setThickness(2);
    end;
    
    parentResizedCallback = function (self, psize)
        self.size = vec(psize.x, self.size.y);
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
