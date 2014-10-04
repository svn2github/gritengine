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
    end
    
    local function rotate(x,y,z)
        body.worldOrientation = body.worldOrientation * quat(step, vector3(x,y,z))
    end

    if input_filter_pressed("=") then
        placement_editor.stepValue = math.min(3, step + 0.01)
    elseif input_filter_pressed("-") then
        placement_editor.stepValue = math.max(0.01, step - 0.01)
    elseif input_filter_pressed("Up") then
        if widget.mode == 1 then
            move(0,step,0)
            directionString = "+Y"
        elseif widget.mode == 2 then
            rotate(0,-1,0)
        end
    elseif input_filter_pressed("Down") then
        if widget.mode == 1 then
            move(0,-step,0)
            directionString = "-Y"
        elseif widget.mode == 2 then
            rotate(0,1,0)
        end 
    elseif input_filter_pressed("Left") then
        if widget.mode == 1 then
            move(-step,0,0)
            directionString = "-X"
        elseif widget.mode == 2 then
            rotate(0,0,1)
        end
    elseif input_filter_pressed("Right") then
        if widget.mode == 1 then
            move(step,0,0)
            directionString = "+X"
        elseif widget.mode == 2 then
            rotate(0,0,-1)
        end
    elseif input_filter_pressed("i") then
        if widget.mode == 1 then
            move(0,0,step)
            directionString = "Z"
        elseif widget.mode == 2 then
            rotate(1,0,0)
        end
    elseif input_filter_pressed("k") then
        if widget.mode == 1 then
            move(0,0,-step)
            directionString = "-Z"
        elseif widget.mode == 2 then
            rotate(-1,0,0)
        end
    end
    
    if widget.mode == 1 then
        modeString = "MOVE"
    elseif widget.mode == 2 then
        modeString = "ROTATE"
    end
	
    return false
end

function placement_editor:manip (obj)
    if obj == nil or self.handledObj ~= nil then
		unselect_obj ()
        self.handledObj = nil
        main.frameCallbacks:removeByName("placement_editor")
		--print(BLUE..'Stop Edit')
        return
    end

    self.handledObj = obj

   -- print(BLUE..'Edit')
	select_obj()
    main.frameCallbacks:insert("placement_editor", callback)
    callback(nil)
end