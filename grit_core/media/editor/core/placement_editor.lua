-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- Just temporary use, will be replaced probably

placement_editor =
{
	handledObj;
	stepValue = 1;
}

local function callback()
	if placement_editor.handledObj == nil then
       main.frameCallbacks:removeByName("placement_editor")
	   return
    end
    
	if placement_editor.handledObj.instance == nil then
        placement_editor:manip(nil)
    end
    
    local body = placement_editor.handledObj.instance.body
    local step = placement_editor.stepValue
    local directionString = ""
    local modeString
    
    local function move(x,y,z)
		body.worldPosition = vector3(body.worldPosition.x+x, body.worldPosition.y+y, body.worldPosition.z+z)
		placement_editor.handledObj.spawnPos = vector3(body.worldPosition.x+x, body.worldPosition.y+y, body.worldPosition.z+z)
		-- needs to set lod spawnPos, but how?
		-- if placement_editor.handledObj.lod ~= nil then
			
		-- end
	end
    
	local function rotate(x,y,z)
		body.worldOrientation = body.worldOrientation * quat(step, vector3(x,y,z))
    end

    if input_filter_pressed("=") then
        placement_editor.stepValue = math.min(3, step + 0.01)
    elseif input_filter_pressed("-") then
        placement_editor.stepValue = math.max(0.01, step - 0.01)
    elseif input_filter_pressed("Up") then
        if editor.selection.mode == 1 then
            move(0,step,0)
            directionString = "+Y"
        elseif editor.selection.mode == 2 then
            rotate(0,-1,0)
        end
    elseif input_filter_pressed("Down") then
        if editor.selection.mode == 1 then
            move(0,-step,0)
            directionString = "-Y"
        elseif editor.selection.mode == 2 then
            rotate(0,1,0)
        end 
    elseif input_filter_pressed("Left") then
        if editor.selection.mode == 1 then
            move(-step,0,0)
            directionString = "-X"
        elseif editor.selection.mode == 2 then
            rotate(0,0,1)
        end
    elseif input_filter_pressed("Right") then
        if editor.selection.mode == 1 then
            move(step,0,0)
            directionString = "+X"
        elseif editor.selection.mode == 2 then
            rotate(0,0,-1)
        end
    elseif input_filter_pressed("i") then
        if editor.selection.mode == 1 then
            move(0,0,step)
            directionString = "Z"
        elseif editor.selection.mode == 2 then
            rotate(1,0,0)
        end
    elseif input_filter_pressed("k") then
        if editor.selection.mode == 1 then
            move(0,0,-step)
            directionString = "-Z"
        elseif editor.selection.mode == 2 then
            rotate(-1,0,0)
        end
    end
    
    if editor.selection.mode == 1 then
        modeString = "MOVE"
    elseif editor.selection.mode == 2 then
        modeString = "ROTATE"
    end
	
    return false
end

function placement_editor:manip (obj)
    if obj == nil or self.handledObj ~= nil then
		unselect_obj ()
        self.handledObj = nil
		gizmo.node.parent = nil
		gizmo_fade(0)
        main.frameCallbacks:removeByName("placement_editor")
		--print(BLUE..'Stop Edit')
        return
    end

    self.handledObj = obj

   -- print(BLUE..'Edit')
	select_obj()
	gizmo_resize()
	local mode = nil
	
	if editor.selection.mode == 0 or editor.selection.mode == 1 then
		mode = "translate"
	elseif editor.selection.mode == 2 then
		mode = "rotate"
	elseif editor.selection.mode == 3 then
		mode = "scale"
	end
	
	if gizmo.x_a == nil or gizmo.x_a.activated ~= true then
		create_gizmo(editor.selection.mode)
	end
	
	gizmo.node.parent = obj.instance.gfx
	gizmo_fade(1)
    main.frameCallbacks:insert("placement_editor", callback)
    callback(nil)
end