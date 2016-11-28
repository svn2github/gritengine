-- EditorMap abstracts the collection of objects in the map.  It is responsible for loading / saving
-- them and performing operations (e.g. adding / changing objects).  It also handles the undo
-- history.  It maintains the state of all the objects in the engine (that are used to visualise the
-- map).  The state of those objects should match the state in map.current.objects, up to user
-- interaction effects like selection / hiding of objects.


-- TODO:

EditorMap = EditorMap or {
    undoLevelsMax = 100,
}

function EditorMap.new()
    local self = {
        -- Note that current and undoLevels must be immutable values.  This is important to allow
        -- saving memory by aliasing parts of the map that did not change in the history.
        current = map_build_empty(),
        undoLevels = {},
        filename = nil,
    }
    make_instance(self, EditorMap)
    self:applyEnvironment()
    return self
end

-- Return to the default (empty) map.
function EditorMap:reset()
    for k, v in pairs(self.current.objects) do
        if object_has(k) then
            object_get(k):destroy()
        end
    end
    self.current = map_build_empty()
    self.undoLevels = {}
    self.filename = nil
    self:applyEnvironment()
end

-- Open a map from disk.
function EditorMap:open(filename)
    assert_path_file_type(filename, 'gmap')
    self:reset()
    self.current = include(filename)
    for name, object in pairs(self.current.objects) do
        local body = table.clone(object[3])
        body.name = name
        object_add(object[1], object[2], body)
    end
    self.filename = filename
    self.undoLevels = {}
    self:applyEnvironment()
end

-- Save to a file but do not change the current filename.
function EditorMap:export(filename)
    map_write_to_file(self.current, filename)
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
    env.secondsSinceMidnight = self.current.environment.time
    -- Not this, we want to control time manually in the editor.
    -- env.clockRate = self.current.environment.clock_rate
    env.clockRate = 0
    if self.current.environment.env_cycle_file ~= nil then
        env_cycle = include(self.current.environment.env_cycle_file)
    end
    self:applyEnvCube()
    env_recompute()
end

function EditorMap:applyEnvCube()
    local tab = self.current.env_cubes
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
        self.current.env_cubes['env_cube_'..name] = "/"..tex
    end
    env.secondsSinceMidnight = current_time

    self:applyEnvCube()
end

function EditorMap:pushUndoLevel()
    if #self.undoLevels >= self.undoLevelsMax then
        self.undoLevels[#self.undoLevels] = nil
    end
    table.insert(self.undoLevels, 1, self.current)
end

-- Updates current to clone a path, so that we can modify it.  The path must lead to a table.
-- Returns the new deep table.
function EditorMap:clonePath(path)
    local tab = table.clone(self.current)
    self.current = tab
    for _, field in ipairs(path) do
        tab[field] = table.clone(tab[field])
        tab = tab[field]
    end
    return tab
end

-- Toggle the visual representation of an object being selected (does not do anything beyond
-- changing the appearance of the object).
function EditorMap:setSelected(name, v)
    local obj_decl = self.current.objects[name]
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

-- Get an object's position.
function EditorMap:getPosition(name, v)
    local obj_decl = self.current.objects[name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(name))
    end
    return obj_decl[2]
end

-- Set an object's position.
function EditorMap:setPosition(name, v)
    local obj_decl = self.current.objects[name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(name))
    end
    self:pushUndoLevel()
    obj_decl = self:clonePath({'objects', name})
    obj_decl[2] = v

    -- Now update the visual representation.
    local obj_actual = object_get(name)
    obj_actual.pos = v
    obj_actual.spawnPos = v
    local inst = obj_actual.instance
    if inst == nil then
        -- It's not streamed in right now, so we're done.
        return
    end
    if inst.body ~= nil then
        inst.body.worldPosition = v
    elseif inst.gfx ~= nil then
        inst.gfx.localPosition = v
    elseif inst.audio ~= nil then
        inst.audio.position = v
    end
end

-- Get an object's orientation.
function EditorMap:getOrientation(name, v)
    local obj_decl = self.current.objects[name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(name))
    end
    return obj_decl[3].rot or Q_ID
end

-- Set an object's orientation.
function EditorMap:setOrientation(name, v)
    local obj_decl = self.current.objects[name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(name))
    end
    self:pushUndoLevel()
    local obj_body = self:clonePath({'objects', name, 3})
    if v == Q_ID then
        obj_body.rot = nil
    else
        obj_body.rot = v
    end

    -- Now update the visual representation.
    local obj_actual = object_get(name)
    obj_actual.rot = v
    local inst = obj_actual.instance
    if inst == nil then
        -- It's not streamed in right now, so we're done.
        return
    end
    if inst.body ~= nil then
        inst.body.worldOrientation = v
    elseif inst.gfx ~= nil then
        inst.gfx.localOrientation = v
    elseif inst.audio ~= nil then
        inst.audio.orientation = v
    end
end

-- Rename an object.
function EditorMap:rename(old_name, new_name)
    local obj_decl = self.current.objects[old_name]
    if obj_decl == nil then
        error(('No such object: "%s"'):format(old_name))
    end
    if self.current.objects[new_name] ~= nil then
        error(('Already an object called: "%s"'):format(new_name))
    end
    self:pushUndoLevel()
    self:clonePath({'objects'})
    self.current.objects[new_name] = obj_decl
    self.current.objects[old_name] = nil
end
