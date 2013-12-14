-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Stats" {

    width = 255;
    defaultColour = vector3(1,1,1)*.75;

    init = function (self)
        self.alpha = 0
        self.size = vector2(0,0)
        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        self:setSelection(self.keys)
    end;

    setSelection = function (self, keys)
        if self.labels ~= nil then
            for k,v in pairs(self.labels) do
                safe_destroy(v)
            end
        end
        self.keys = keys
        if self.keys == nil then
            self.keys = {}
            for k,v in pairs(self.stats) do
                if v then
                    self.keys[#self.keys+1] = k
                end
            end
            table.sort(self.keys)
        end
        self.labels = {}
        local tab = {
            parent = self,
            padding = -1,
        }
        for k,name in ipairs(self.keys) do
            local stat = self.stats[name]
            if stat ~= nil then
                local label = gfx_hud_object_add("/common/hud/Label", { size=vector2(self.width, 15), alignment = "RIGHT" })
                self.labels[name] = label
                tab[k] = label
            end
        end
        self.stack = gfx_hud_object_add("/common/hud/StackY", tab)

        self.stack.position = self.stack.size/2 * vector2(-1,1)
    end;

    destroy = function (self)
        self.stack = safe_destroy(self.stack)
        if self.labels ~= nil then
            for k,v in pairs(self.labels) do
                safe_destroy(v)
            end
        end
    end;

    frameCallback = function (self, elapsed)
        for _,name in pairs(self.keys) do
            local label = self.labels[name]
            if label ~= nil then
                local text, colour = self.stats[name]()
                label:setValue(text)
                label.colour = colour or self.defaultColour
            end
        end
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = math.abs(local_pos.x) <= self.stack.size.x and math.abs(local_pos.y) <= self.stack.size.y
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self:onClick()
        end
    end;
    
    onClick = function (self)
        error("No onClick function defined.");
    end;
}
