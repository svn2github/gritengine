-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- The classes in this file are intended to be used together to define a hierarchy layout of HUD
-- objects.  The HUD objects must be statically sized, and the parents expand to accomodate the
-- children.  This works well for static forms and the like.


-- StackY takes a list of statically-sized HUD objects and positions them vertically.
--
-- The stack also resizes itself to wrap the objects, essentially turning them into a single
-- object.
--
-- The elements are separated by padding, the amount of which can be overridden.
--
-- By putting in a vec2 as an element, more space can be added.
--
-- By default the stack is aligned CENTRE, but this can be modified by inserting
-- { align = 'LEFT' } or 'RIGHT' into the list, which affects all subsequent elements.
hud_class `StackY` {

    padding = 0;

    init = function (self)
        self.alpha = 0
        self.alignment = { }
        self.contents = { }
        local alignment = 0
        local counter = 1
        for k, v in ipairs(self.table) do
            if type(v) == "table" then
                for mk, mv in pairs(v) do
                    if mk == "align" then
                        if mv == "LEFT" then
                            alignment = -1
                        elseif mv == "CENTRE" then
                            alignment = 0
                        elseif mv == "RIGHT" then
                            alignment = 1
                        else
                            error("Unrecognised horizontal alignment: \""..tostring(mv).."\"")
                        end
                    else
                        error("Unrecognised modifier: "..tostring(mk))
                    end
                end
                v = nil
            elseif type(v) == "vector2" then
                v = { bounds=v }
            end
            if v then
                self.contents[counter] = v
                self.alignment[counter] = alignment
                counter = counter + 1
                v.parent = self
            end
        end
        for k,v in ipairs(self.contents) do
            self[k] = nil
        end
        local w, h = 0, 0
        for k,v in ipairs(self.contents) do
            h = h + v.bounds.y + self.padding
            w = math.max(w, v.bounds.x)
        end
        if h > 0 then h = h - self.padding end
        local y = h / 2
        for k,v in ipairs(self.contents) do
            v.position = vec(self.alignment[k]*(w - v.bounds.x)/2, y - v.bounds.y/2)                
            y = y - (v.bounds.y + self.padding)
        end
        self.size = vec(w, h)
    end;

    -- Recursively execute the same function on all nodes of the tree, if that function exists.
    callAll = function (self, funcname, ...)
        for k,v in ipairs(self.contents or { }) do
            local func = v[funcname]
            if func ~= nil then
                func(v, ...)
            else
                if v.callAll ~= nil then
                    v:callAll(funcname, ...)
                end
            end
        end
    end;

    destroy = function (self)
    end;
}


-- StackX takes a list of statically-sized HUD objects and positions them horizontally.
--
-- The stack also resizes itself to wrap the objects, essentially turning them into a single
-- object.
--
-- The elements are separated by padding, the amount of which can be overridden.
-- By putting in a vec2 as an element, more space can be added.
-- By default the stack is aligned CENTRE, but this can be modified by inserting
-- { align = 'TOP' } or 'BOTTOM' into the list, which affects all subsequent elements.
hud_class `StackX` {

    padding = 0;

    init = function (self)
        self.alpha = 0
        self.contents = { }
        self.alignment = { }
        local counter = 1
        local alignment = 0
        for k,v in ipairs(self.table) do
            if type(v) == "table" then
                for mk, mv in pairs(v) do
                    if mk == "align" then
                        if mv == "TOP" then
                            alignment = 1
                        elseif mv == "CENTRE" then
                            alignment = 0
                        elseif mv == "BOTTOM" then
                            alignment = -1
                        else
                            error("Unrecognised vertical alignment: \""..tostring(mv).."\"")
                        end
                    else
                        error("Unrecognised modifier: "..tostring(mk))
                    end
                end
                v = nil
            elseif type(v) == "vector2" then
                v = { bounds=v }
            end
            if v then
                self.contents[counter] = v
                self.alignment[counter] = alignment
                v.parent = self
                counter = counter + 1
            end
        end
        for k,v in ipairs(self.contents) do
            self[k] = nil
        end
        local h, w = 0, 0
        for k,v in ipairs(self.contents) do
            w = w + v.bounds.x + self.padding
            h = math.max(h, v.bounds.y)
        end
        if w > 0 then w = w - self.padding end
        local x = -w / 2
        for k,v in ipairs(self.contents) do
            v.position = vec(x + v.bounds.x/2, self.alignment[k]*(h - v.bounds.y)/2)                
            x = x + (v.bounds.x + self.padding)
        end
        self.size = vec(w, h)
    end;

    -- Recursively execute the same function on all nodes of the tree, if that function exists.
    callAll = function (self, funcname, ...)
        for k,v in ipairs(self.contents or { }) do
            local func = v[funcname]
            if func ~= nil then
                func(v, ...)
            else
                if v.callAll ~= nil then
                    v:callAll(funcname, ...)
                end
            end
        end
    end;

    destroy = function (self)
    end;
}


-- Border puts a border around a single object.  It introduces a bit of extra padding.
hud_class `Border` {

    padding = 4;
    texture = `CornerTextures/Border02.png`;
    size = vec(1, 1);
    cornered = true;

    init = function (self)
        self.child.parent = self
        self.size = self.child.bounds + vec(2,2)*self.padding
    end;

    callAll = function (self, funcname, ...)
        local func = self.child[funcname]
        if func ~= nil then
            func(self.child, ...)
        else
            if self.child.callAll ~= nil then
                self.child:callAll(funcname, ...)
            end
        end
    end;

    destroy = function (self)
    end;
}

