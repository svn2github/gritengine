-- EditorMap abstracts the collection of objects in the map.  It is responsible for loading / saving
-- them and performing operations (e.g. adding / changing objects).  It also handles the undo
-- history.  It maintains the state of all the objects in the engine (that are used to visualise the
-- map).  The state of those objects should match the state in map.currentState.objects, up to user
-- interaction effects like selection / hiding of objects.
--
-- A map modification is performed as follows:
-- 1) Call proposeValue(name, v) to update the GUI with the new value of the object.  This does not
-- have any lasting change, as it does not update currentState.
-- 2) Either call cancelChange() or applyChange() to make the change permanent.  This updates the
-- undo history.


-- Open problems:
--
-- Need to rebuild all objects from scratch when recovering to an undo level, as we don't know what
-- was destroyed / created / changed.  It should be possible to compute a structural diff between
-- the two states to find out what has changed, and then only update those objects.  Alternatively
-- we can record the diff as opposed to recording the whole history.
--
-- Rebuilding the map each time leads to non-determistic effects with object placement (grass) and
-- car colours changing.  However, this is a general problem since removing an object and then
-- undoing it will cause any random initialization to be reset.
--
-- It is assumed Grit classes follow a certain protocol, e.g. instance.body, instance.gfx, body.rot,
-- etc.  This should be documented, and ideally a simpler "editor interface" should be defined for
-- objects to play nicely with the editor.


EditorMap = EditorMap or {
    undoLevelsMax = 100,
}

function EditorMap.new()
    local self = {
        -- Note that currentState and undoLevels must be immutable values.  This is important to
        -- allow saving memory by aliasing parts of the map that did not change in the history.
        currentState = map_build_empty(),
        -- Either nil or { names = {...}, state = {...} }
        proposed = nil,
        undoLevels = {},  -- 
        redoLevels = {},
        filename = nil,
    }
    make_instance(self, EditorMap)
    self:applyEnvironment()
    return self
end

function EditorMap:populateOne(name, object)
    local body = table.clone(object[3] or {})
    body.name = name
    object_add(object[1], object[2], body)
end

function EditorMap:depopulateOne(name)
    if object_has(name) then
        object_get(name):destroy()
    end
end

-- Add all visual representations of objects.
function EditorMap:populateMap()
    for name, object in pairs(self.currentState.objects) do
        self:populateOne(name, object)
    end
end

-- Remove all visual representations of objects.
function EditorMap:depopulateMap()
    for name, _ in pairs(self.currentState.objects) do
        self:depopulateOne(name)
    end
end

-- Return to the default (empty) map.
function EditorMap:reset()
    assert(self.proposed == nil)
    self:depopulateMap()
    self.currentState = map_build_empty()
    -- No need to populateMap, there are no objects.
    self.undoLevels = {}
    self.redoLevels = {}
    self.filename = nil
    self:applyEnvironment()
end

function EditorMap:undo()
    assert(self.proposed == nil)
    if #self.undoLevels == 0 then
        -- No more undo levels.
        return
    end
    self:depopulateMap()
    table.insert(self.redoLevels, 1, self.currentState)
    self.currentState = table.remove(self.undoLevels, 1)
    self:populateMap()
end

function EditorMap:redo()
    assert(self.proposed == nil)
    if #self.redoLevels == 0 then
        -- No more redo levels.
        return
    end
    self:depopulateMap()
    table.insert(self.undoLevels, 1, self.currentState)
    self.currentState = table.remove(self.redoLevels, 1)
    self:populateMap()
end

function EditorMap:setEditorCamPosOrientation(pos, orientation)
    self.currentState.editor.cam_pos, self.currentState.editor.cam_quat = pos, orientation
end

function EditorMap:getEditorCamPosOrientation()
    return self.currentState.editor.cam_pos, self.currentState.editor.cam_quat
end

-- Open a map from disk.
function EditorMap:open(filename)
    assert(self.proposed == nil)
    assert_path_file_type(filename, 'gmap')
    self:reset()
    self.currentState = include(filename)
    self:populateMap()
    self.filename = filename
    self.undoLevels = {}
    self:applyEnvironment()
end

-- Save to a file but do not change the current filename.
function EditorMap:export(filename)
    assert(self.proposed == nil)
    map_write_to_file(self.currentState, filename)
end

-- Save to the current filename.
function EditorMap:save()
    if self.filename == nil then    
        error 'Cannot call EditorMap:save() as there is no current filename.'
    end
    self:export(self.filename)
end

-- Also change the current filename to the one provided.
function EditorMap:saveAs(filename)
    self.filename = filename
    self:save()
end


function EditorMap:applyEnvironment()
    env.secondsSinceMidnight = self.currentState.environment.time
    -- Not this, we want to control time manually in the editor.
    -- env.clockRate = self.currentState.environment.clock_rate
    env.clockRate = 0
    if self.currentState.environment.env_cycle_file ~= nil then
        env_cycle = include(self.currentState.environment.env_cycle_file)
    end
    self:applyEnvCube()
    env_recompute()
end

function EditorMap:applyEnvCube()
    local tab = self.currentState.env_cubes
    env_cube_dawn = tab.dawn
    env_cube_noon = tab.noon
    env_cube_dusk = tab.dusk
    env_cube_dark = tab.dark
    env_recompute()
end

function EditorMap:generateEnvCube(pos, filename, hours)
    if filename == nil then
        math.randomseed(os.clock())
        filename = ("editor/cache/env/myenv_%04d"):format(math.random(1000) - 1)
    end

    hours = hours or { dawn = 6, noon = 12, dusk = 18, dark = 0 }

    local current_time = env.secondsSinceMidnight
    for name, hour in pairs(hours) do
        env.secondsSinceMidnight = hour * 60 * 60
        tex = ("%s.%s.envcube.tiff"):format(filename, name)
        gfx_bake_env_cube(tex, 128, pos, 0.7, vec(0, 0, 0))
        self.currentState.env_cubes['env_cube_'..name] = "/"..tex
    end
    env.secondsSinceMidnight = current_time

    self:applyEnvCube()
end

function EditorMap:pushUndoLevel(tab)
    if #self.undoLevels >= self.undoLevelsMax then
        self.undoLevels[#self.undoLevels] = nil
    end
    table.insert(self.undoLevels, 1, tab)
    -- As soon as we made a change, we forked history, so we cannot go forwards again.
    self.redoLevels = {}
end

-- Updates currentState to clone a path, so that we can modify it.  The path must lead to a table.
-- Returns the new deep table.
function EditorMap:clonePath(tab, path)
    for _, field in ipairs(path) do
        tab[field] = table.clone(tab[field])
        tab = tab[field]
    end
    return tab
end

-- Toggle the visual representation of an object being selected (does not do anything beyond
-- changing the appearance of the object).
function EditorMap:setSelected(name, v)
    local obj_decl = self.currentState.objects[name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(name))
    end

    -- Now update the visual representation.
    local obj_actual = object_get(name)
    local inst = obj_actual.instance
    if inst == nil then
        -- It's not streamed in right now, so we're done.
        return
    end
    if inst.gfx ~= nil then
        inst.gfx.wireframe = v
    end
end


-- Always fetches object data from currentState.
function EditorMap:getCurrentObject(name)
    return self.currentState.objects[name]
end


-- Always fetches object data from proposed state.
function EditorMap:getProposedObject(name)
    assert(self.proposed ~= nil)
    return self.proposed.state.objects[name]
end

function EditorMap:getPhysicalRepresentation(name)
    local obj_actual = object_get(name)
    if obj_actual.activated then
        return obj_actual.instance.body
    else
        return nil
    end
end

function EditorMap:iterCurrentObjects()
    return spairs(self.currentState.objects)
end


-- Internal function to make the object match the current / proposed state of the map.
function EditorMap:updateObjectVisualisation(name, obj)
    local obj_actual = object_get(name)
    if obj == nil then
        obj_actual:destroy()
        return
    end

    local pos, rot = obj[2], Q_ID
    if obj[3] ~= nil and obj[3].rot ~= nil then
        rot = obj[3].rot
    end

    obj_actual.pos = pos
    obj_actual.spawnPos = pos
    obj_actual.rot = rot
    local inst = obj_actual.instance
    if inst == nil then
        -- It's not streamed in right now, so we're done.
        return
    end
    if inst.body ~= nil then
        inst.body.worldPosition = pos
        inst.body.worldOrientation = rot or Q_ID
    elseif inst.gfx ~= nil then
        inst.gfx.localPosition = pos
        inst.gfx.localOrientation = rot or Q_ID
    elseif inst.audio ~= nil then
        inst.audio.position = pos
        inst.audio.orientation = rot or Q_ID
    end
end


-- Get an object's position.
function EditorMap:getPosition(name)
    local obj_decl = self:getCurrentObject(name)
    return obj_decl[2]
end

-- Set an object's position.
function EditorMap:proposePosition(name, v)
    local obj_decl = self:initProposed(name)
    obj_decl[2] = v
    self:updateObjectVisualisation(name, obj_decl)
end

-- Get an object's orientation.
function EditorMap:getOrientation(name)
    local obj_decl = self:getCurrentObject(name)
    local rot = Q_ID
    if obj_decl[3] ~= nil and obj_decl[3].rot ~= nil then
        rot = obj_decl[3].rot
    end
    return rot
end


-- Set an object's orientation.
function EditorMap:proposeOrientation(name, v)
    local obj_decl = self:initProposed(name)
    if v == Q_ID then
        obj_decl[3].rot = nil
    else
        obj_decl[3].rot = v
    end
    self:updateObjectVisualisation(name, obj_decl)
end


-- Rename an object.
function EditorMap:rename(old_name, new_name)
    assert(self.proposed == nil)
    local obj_decl = self:getCurrentObject(old_name)
    if self.currentState.objects[new_name] ~= nil then
        error(('Already an object called: "%s"'):format(new_name))
    end
    self:pushUndoLevel(table.clone(self.currentState))
    self.currentState.objects = table.clone(self.currentState.objects)
    self.currentState.objects[old_name] = nil
    self.depopulateOne(old_name, obj_decl)
    self.currentState.objects[new_name] = obj_decl
    self.populateOne(new_name, obj_decl)
end


-- Add an object.  The additional is only a proposal, it will be ratified by applyChange().
function EditorMap:add(name, class, pos, data)
    assert(self.proposed == nil)
    local obj_decl = self:getCurrentObject(name)
    if self.currentState.objects[name] ~= nil then
        error(('Already an object called: "%s"'):format(name))
    end
    obj_decl = self:initProposed(name, {class, pos, data})
    -- The object, if the change is cancelled, is cleaned up by updateObjectVisualisation.
    self:populateOne(name, obj_decl)
end


-- Delete an object.
function EditorMap:delete(name)
    assert(self.proposed == nil)
    local obj_decl = self:getCurrentObject(name)
    if self.currentState.objects[name] == nil then
        error(('No object called: "%s"'):format(name))
    end
    self:pushUndoLevel(table.clone(self.currentState))
    self.currentState.objects = table.clone(self.currentState.objects)
    self.currentState.objects[name] = nil
    self.depopulateOne(name, obj_decl)
end


function EditorMap:applyChange()
    if self.proposed == nil then
        -- If no changes to apply, then silently return.
        return
    end
    self:pushUndoLevel(self.currentState)
    self.currentState = self.proposed.state
    self.proposed = nil
end


function EditorMap:cancelChange()
    if self.proposed == nil then
        -- If no changes to cancel, then silently return.
        return
    end
    for _, name in ipairs(self.proposed.names) do
        self:updateObjectVisualisation(name, self:getCurrentObject(name))
    end
    self.proposed = nil
end


-- If obj is nil, then we're modifying an existing object.  Otherwise, we're
-- adding a new object.
function EditorMap:initProposed(name, obj)
    if self.proposed == nil then
        self.proposed = {
            names = {},
            state = table.clone(self.currentState),
        }
        self.proposed.state.objects = table.clone(self.proposed.state.objects)
    end

    if find(self.proposed.names, name) ~= nil then
        -- Already in it, nothing to do.
    else
        local obj_decl = self:getCurrentObject(name)
        self.proposed.names[#self.proposed.names] = name
        if obj == nil then
            -- Avoid aliasing the object or body, so we can modify it without
            -- those changes appearing in currentState.
            obj = table.clone(self.proposed.state.objects[name])
            obj[3] = table.clone(obj[3])
        end
        self.proposed.state.objects[name] = obj
    end

    return self.proposed.state.objects[name]
end

