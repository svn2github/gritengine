------------------------------------------------------------------------------
--  This is the widget manager class, creates and manages the widget object
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO:
-- Select objects without collision
-- Select sounds, particles

local dummy_bounds = vec(2, 2, 0.2)
local arrow_bounds = vec(1, 8, 1)

widget_manager = {
    mode = "translate";
    selectedObjs = {};
    offsets = {};
    rotationOffsets = {};
    initialPosition = vec(0, 0, 0);
    widget = nil;
    strdrag = nil;  -- nil if we're not currently dragging, otherwise the axis / plane
    space_mode = "local"; -- "world", "local"
    pivot_centre = "active object"; -- "individual origins", "active object" or "centre point"
    step_size = 0.5;
    highlight_widget = true;
};

-- reference: math_geom.c from Blender
local function isect_line_plane(line_a, line_b, plane_pos, plane_normal)
    local u = line_b - line_a
    local dot_p = dot(plane_normal, u)

    if math.abs(dot_p) > 1e-6 then
        local w = line_a - plane_pos
        local fac = -dot(plane_normal, w) / dot_p
        u = u * fac
        return line_a + u
    else -- parallel to plane
        return
    end
end

function widget_manager:enablewidget(pos, mrot)
    if self.widget ~= nil then
        safe_destroy(self.widget)
        main.frameCallbacks:removeByName("widget_manager")  
    end
    if self.space_mode == "world" then
        mrot = Q_ID
    end
    
    self.initialPosition = pos
    self.widget = Widget.new(pos, mrot)
    main.frameCallbacks:insert("widget_manager", wm_callback)
end

function widget_manager:setSpaceMode(mode)
    local editor = game_manager.currentMode
    self.space_mode = mode
    if self.widget then
        local new_rot = editor.map:getOrientation(self.selectedObjs[1])
        if mode == "world" then
            new_rot = Q_ID
        end
        -- Change orientation only.
        self.widget:updatePivot(self.widget.widgetPosition, new_rot)
    end
end

function widget_manager:set_mode(mode)
    self.mode = mode
    if self.widget ~= nil then
        self.widget:updateArrows(self.widget.widgetPosition)
    end
end

function widget_manager:setEditorToolbar(str)
    if editor_interface.map_editor_page.statusbar ~= nil then
        editor_interface.map_editor_page.statusbar:setText(tostring(str))
    end
end

function widget_manager:unselectAll()
    local editor = game_manager.currentMode

    for i, obj in ipairs(self.selectedObjs) do
        editor.map:setSelected(obj, false)
    end
    self.selectedObjs = {}
    
    self.setEditorToolbar("Selected: none")
    self.widget = safe_destroy(self.widget)
    
    main.frameCallbacks:insert("widget_manager", wm_callback)
end

function widget_manager:stopDragging()
    self:select(false)
end

function widget_manager:startDragging(widget_component)
    if self.widget == nil then return end
    self.strdrag = widget_component
    local pivot_pos = self.widget.widgetPosition
    if self.mode == "translate" then

        local plane_obj = self.widget[self.strdrag]
        local clicked_point_on_plane = isect_line_plane(
            main.camPos,
            main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs),
            pivot_pos,
            plane_obj.localOrientation * V_UP  -- normal of plane
        )
        self.initialobjposdelta = pivot_pos - clicked_point_on_plane

        local pivot_pos_ss = gfx_world_to_screen(main.camPos, main.camQuat, pivot_pos)
        self.msinitpos = mouse_pos_abs - pivot_pos_ss.xy

    elseif self.mode == "rotate" then
        self.msinitpos = mouse_pos_abs
        self.pivotInitialOrientation = self.widget.widgetOrientation

    end
    self.objinitpos = pivot_pos
end

function widget_manager:calcOffsets(widget_pos)
    local editor = game_manager.currentMode
    self.offsets = {}
    for i, obj in ipairs(self.selectedObjs) do
        self.offsets[i] = editor.map:getPosition(obj) - widget_pos
    end
end

function widget_manager:calcCentreOffsets()
    local editor = game_manager.currentMode
    -- calc the middle point
    local mid_point = V_ZERO

    for i, obj in ipairs(self.selectedObjs) do
        mid_point = mid_point + editor.map:getPosition(obj)
    end

    mid_point = mid_point / #self.selectedObjs

    -- set offsets
    self.offsets = {}
    for i, obj in ipairs(self.selectedObjs) do
        self.offsets[i] = editor.map:getPosition(obj) - mid_point
    end
    return mid_point
end

function widget_manager:updateWidgetFromSelection()
    -- TODO(dcunnin): Support multiple selected objects
    local selected = self.selectedObjs[1]
    if not selected then return end

    local editor = game_manager.currentMode
    local initial_position = editor.map:getPosition(selected)
    local initial_orientation = editor.map:getOrientation(selected)
    self:enablewidget(initial_position, initial_orientation)
end

function widget_manager:selectSingleObject()
    local editor = game_manager.currentMode
    -- self.offsets[1] = vec(0, 0, 0)

    local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
    local _, b = physics_cast(main.camPos, ray, true, 0)
    -- local b2 = self:selectNonPhysicalObjects()
    
    -- if b2 then
        -- if b and b.owner then
            -- if b.owner.instance and b.owner.instance then
                -- if #(main.camPos - b.owner.instance.body.worldPosition) > #(main.camPos - b2.pos) then
                
                -- end
            -- end
        -- end
    -- end
    
    if b ~= nil then
        local selected = b.owner.name
        
        if selected == self.selectedObjs[1] then return end
        
        self:unselectAll()

        self:setEditorToolbar("Selected: " .. selected)

        editor.map:setSelected(selected, true)
        self.selectedObjs = { selected }

        self:updateWidgetFromSelection()

    elseif self.selectedObjs[1] then
        self:unselectAll()
    end
end

function widget_manager:updateSelectedPos(new_position, new_orientation)
    self.widget:updatePivot(new_position, new_orientation)

    if self.strdrag ~= nil then
        local editor = game_manager.currentMode
        for i, obj in ipairs(self.selectedObjs) do
            local obj_initial_pos = editor.map:getPosition(obj)
            local dpos = new_position - self.initialPosition * 2 + obj_initial_pos

            local new_pos
            if input_filter_pressed("Ctrl") then
                new_pos = vec(
                    math.floor(dpos.x / self.step_size) * self.step_size + obj_initial_pos.x,
                    math.floor(dpos.y / self.step_size) * self.step_size + obj_initial_pos.y,
                    math.floor(dpos.z / self.step_size) * self.step_size + obj_initial_pos.z
                )
            else
                new_pos = self.initialPosition - obj_initial_pos + new_position
            end
            
            editor.map:proposePosition(obj, new_pos)
        end
    end
end


function widget_manager:addObject()
    local editor = game_manager.currentMode
    local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
    local _, b = physics_cast(main.camPos, ray, true, 0)
    if b ~= nil then
        local target_obj = b.owner.name
        local isonthelist = false
        for i, obj in ipairs(self.selectedObjs) do
            if valid_object(obj) then
                if obj.name == target_obj then
                    isonthelist = true
                end
            end
        end
        if not isonthelist then
            self.selectedObjs[#self.selectedObjs+1] = target_obj
        end
        self:setEditorToolbar("Selected: Multiple")
        editor.map:setSelected(target_obj, true)

        if self.widget ~= nil then
            local pivot_pos = editor.map:getPosition(target_obj)
            local pivot_rot = editor.map:getOrientation(target_obj)
            
            if self.pivot_centre == "active object" then
                self:calcOffsets(pivot_pos)
            else
                pivot_pos = self:calcCentreOffsets()
            end
            
            self:updateSelectedPos(pivot_pos, pivot_rot)
        end
    end    
end

function widget_manager:selectAll()
    local editor = game_manager.currentMode
    -- TODO(dcunnin): Get list of objects from map, not objects in scene.  They are 1:1, but
    -- it's a good idea anyway to encapsulate the use of objects to visualise the map.
    local objs = object_all()
    
    for i, b in ipairs(objs) do
        if valid_object(b) then
            local target_obj = b.name
            local isonthelist = false
            for i, obj in ipairs(self.selectedObjs) do
                if valid_object(obj) then
                    if obj == target_obj then
                        isonthelist = true
                    end
                end
            end
            if not isonthelist then
                self.selectedObjs[#self.selectedObjs+1] = target_obj
            end

            editor.map:setSelected(target_obj, true)
            if valid_object(self.widget) then
                local pivot_pos = editor.map:getPosition(target_obj)
                local pivot_rot = editor.map:getOrientation(target_obj)
                
                if self.pivot_centre == "active object" then
                    self:calcOffsets(pivot_pos)
                else
                    pivot_pos = self:calcCentreOffsets()
                end
                self:updateSelectedPos(pivot_pos, pivot_rot)
            end
        end    
    end
end

-- Reference: http://gamedev.stackexchange.com/questions/18436/most-efficient-aabb-vs-ray-collision-algorithms by Jeroen Baert
local function intersectRayAABoxV(origin, direction, p1, p2)
    local t1, t2 = {}, {}
    local t_near, t_far = -1000, 1000

    -- we test slabs in every direction
    local axis = { "x", "y", "z" }
    local i = axis[1]
    
    for j = 1, 3 do
        i = axis[j]
        -- ray parallel to planes in this direction
        if (direction[i] == 0) then
            if ((origin[i] < p1[i]) or (origin[i] > p2[i])) then
                return false -- parallel and outside box: no intersection possible
            end
        else
            -- ray not parallel to planes in this direction
            t1[i] = (p1[i] - origin[i]) / direction[i]
            t2[i] = (p2[i] - origin[i]) / direction[i]

            -- we want t1 to hold values for intersection with near plane
            if(t1[i] > t2[i]) then
                local tmpv = t1
                t1 = t2
                t2 = tmpv
            end
            if (t1[i] > t_near) then
                t_near = t1[i]
            end
            if (t2[i] < t_far) then
                t_far = t2[i]
            end
            if( (t_near > t_far) or (t_far < 0) ) then
                return false
            end
        end
    end

    return true, t_near, t_far
end

-- a bounding box ray tracer
function widget_manager:bbMouseSelect(pos, rot, scale)
    local iq = inv(rot)
    -- move our stuff to origin to calculate it properly
    local deltapos = main.camPos - pos
    -- rotates the camera position around using the widget orientation
    local ppos =  (iq*deltapos)+pos
    -- new camera orientation rotated by the widget orientation
    local rrot =  iq * main.camQuat

    local dir = 1000 * gfx_screen_to_world(ppos, rrot, mouse_pos_abs)
    local bmin, bmax = pos -scale/2, pos+scale/2
    return intersectRayAABoxV(ppos, dir, bmin, bmax)
end

--[[
function widget_manager:selectNonPhysicalObjects()
    local obj = nil

    for k, v in ipairs(object_all()) do
        if v and v.instance and not v.destroyed()  then
            if v.instance.body == nil then
                local found = nil
                if v.instance.gfx then
                    -- found = self:bbMouseSelect(v.pos, v.instance.gfx.localOrientation, v.instance.gfx.bb)
                elseif v.instance.audio then
                    found = self:bbMouseSelect(v.pos, Q_ID, vec(1, 1, 1))
                end
                
                if found then
                    if obj == nil then
                        obj = v
                    elseif (#(main.camPos - v.pos) < #(main.camPos - obj.pos)) then
                        obj = v
                    end
                end
            end
        end
    end
    return obj
end
]]

function widget_manager:rayCastToWidget()
    local obj = nil
    local lastdistance = nil
    if self.widget == nil then return end
    local scale = self.widget.scale
    
    local wi = self.widget
    local axm = { "x", "y", "z" }
    local dxm = { "xy", "xz", "yz" }

    for i = 1, 3 do
        local pos, orient
        local offset
        
        -- arrows
        pos, orient  = wi[axm[i]].localPosition, wi[axm[i]].localOrientation
        offset = orient * (4 * scale * V_FORWARDS)
        
        local kq, kna = self:bbMouseSelect(pos + offset, orient, arrow_bounds * scale)

        if kq and (lastdistance == nil or kna < lastdistance)  then
            obj = i == 1 and "x" or i == 2 and "y" or i == 3 and "z"
            lastdistance = kna
        end
        
        -- dummies
        if wi[dxm[i]] ~= nil then
            pos, orient  = wi[dxm[i]].localPosition, wi[dxm[i]].localOrientation

            offset =  ((orient * V_RIGHT) + (orient * V_FORWARDS)) * scale
            
            local _, knd = self:bbMouseSelect(pos + offset, orient, dummy_bounds * scale)
            
            if knd and (lastdistance == nil or knd < lastdistance) then
                obj = i == 1 and "xy" or i == 2 and "xz" or i == 3 and "yz"
                lastdistance = knd
            end
        end
    end
    
    return obj
end

function widget_manager:select(enabled, multi)
    local editor = game_manager.currentMode
    if enabled == false then
        if self.strdrag ~= nil then
            self.initialPosition = self.widget.widgetPosition
            editor.map:applyChange()
        end
        self.strdrag = nil
    else
        if #self.selectedObjs == 0 then
            self:selectSingleObject()
        else
            local widget_component = nil
            if self.widget ~= nil then
                widget_component = self:rayCastToWidget()
            end
            
            if widget_component then
                self:startDragging(widget_component)
            else
                if multi then
                    self:addObject()
                else
                    self:selectSingleObject()
                end
            end
        end    
    end
end

function widget_manager:setSelectedOrientation(rot)
    local editor = game_manager.currentMode
    for i, obj in ipairs(self.selectedObjs) do
        editor.map:proposeOrientation(obj, editor.map:getOrientation(obj) * rot)
    end
end
    
function wm_callback()
    local self = widget_manager

    if self.widget and not self.widget.destroyed then
    
        if self.highlight_widget and self.strdrag == nil then
            local widget_component = self:rayCastToWidget()
            
            if widget_component then
                self.widget:highlight(widget_component)
            else
                self.widget:highlight()
            end
        end
        
        -- widget dragging
        if self.msinitpos ~= nil and self.widget ~= nil then
            local mouse_delta = (mouse_pos_abs - self.msinitpos)
            local pivot_pos = self.widget.widgetPosition

            if self.strdrag ~= nil then
                if self.mode == "translate" then
                    local posx, posy, posz = pivot_pos.x,  pivot_pos.y, pivot_pos.z

                    local initpos = self.objinitpos
                    
                    local p = isect_line_plane(
                        main.camPos,
                        main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs),
                        initpos,
                        self.widget[self.strdrag].localOrientation * V_UP
                    ) + self.initialobjposdelta

                    if self.space_mode == "local" then
                        local pos = V_ZERO
                        local dir = self.widget[self.strdrag].localOrientation * V_NORTH
                        local offset = (inv(self.widget.widgetOrientation)*(p-initpos))
                        
                        if self.strdrag == "x" then
                            pos = dir * offset.x + initpos
                        elseif self.strdrag == "y" then
                            pos = dir * offset.y + initpos
                        elseif self.strdrag == "z" then
                            pos = dir * offset.z + initpos
                        elseif self.strdrag == "xy" then
                            pos = p
                        elseif self.strdrag == "xz" then
                            pos = p
                        elseif self.strdrag == "yz" then
                            pos = p
                        end
                        
                        posx, posy, posz = pos.x, pos.y, pos.z
                    else -- world
                        if self.strdrag == "x" then
                            posx = p.x
                        elseif self.strdrag == "y" then
                            posy = p.y
                        elseif self.strdrag == "z" then
                            posz = p.z
                        elseif self.strdrag == "xy" then
                            posx = p.x
                            posy = p.y
                        elseif self.strdrag == "xz" then
                            posx = p.x
                            posz = p.z
                        elseif self.strdrag == "yz" then
                            posy = p.y
                            posz = p.z
                        end                    
                    end
                    self:updateSelectedPos(vec(posx, posy, posz), self.widget.widgetOrientation)
                elseif self.mode == "rotate" then
                    local function rotate(x, y, z)
                        if self.widget ~= nil then
                            local rot = quat(mouse_delta.x + mouse_delta.y, vec(x, y, z))
                            local new_rot
                            if self.space_mode == "local" then
                                new_rot = self.pivotInitialOrientation * rot
                            else
                                new_rot = rot * self.pivotInitialOrientation
                            end
                            self.widget:updatePivot(self.widget.widgetPosition, new_rot)
                            self:setSelectedOrientation(rot)
                        end
                    end

                    -- TODO: 1 or -1 depends on camera angle
                    if self.strdrag == "y" then
                        rotate(0, 1, 0)
                    elseif self.strdrag == "z" then
                        rotate(0, 0, 1)
                    elseif self.strdrag == "x" then
                        rotate(-1, 0, 0)
                    end                
                end
            end    
        end
        self.widget:updatePivotScale()
    else
        main.frameCallbacks:removeByName("widget_manager")
    end
end

-- main.frameCallbacks:insert("widget_manager", wm_callback)
