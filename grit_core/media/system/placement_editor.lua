-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

placement_editor =
{
    handledObj;
    mode = 0; -- 0=move, 1=rotate
    stepValue = 1;
    
    screenText;
    textOpts = {charheight = 13};
    Y_offset = 60; -- in percents, between 0 and 100
}

local function callback(key)
    if key == nil then return false end
    if placement_editor.handledObj.instance == nil then
        placement_editor:manip(nil)
    end
    
    local body = placement_editor.handledObj.instance.body
    local mode = placement_editor.mode
    local step = placement_editor.stepValue
    local directionString = ""
    local modeString
    
    local function move(x,y,z)
       body.worldPosition = vector3(body.worldPosition.x+x, body.worldPosition.y+y, body.worldPosition.z+z) 
    end
    
    local function rotate(x,y,z)
        body.worldOrientation = body.worldOrientation * quat(step, vector3(x,y,z))
    end
    
    if key == "+m" then
        placement_editor.mode = 0
    elseif key == "+r" then
        placement_editor.mode = 1
    elseif key == "+=" or key == "==" then
        placement_editor.stepValue = step + 0.01
    elseif key == "+-" or key == "=-" then
        placement_editor.stepValue = step - 0.01
    elseif key == "+Up" or key == "=Up" then
        if mode == 0 then
            move(0,step,0)
            directionString = "+Y"
        elseif mode == 1 then
            rotate(0,-1,0)
        end
    elseif key == "+Down" or key == "=Down" then
        if mode == 0 then
            move(0,-step,0)
            directionString = "-Y"
        elseif mode == 1 then
            rotate(0,1,0)
        end 
    elseif key == "+Left" or key == "=Left" then
        if mode == 0 then
            move(-step,0,0)
            directionString = "-X"
        elseif mode == 1 then
            rotate(0,0,1)
        end
    elseif key == "+Right" or key == "=Right" then
        if mode == 0 then
            move(step,0,0)
            directionString = "+X"
        elseif mode == 1 then
            rotate(0,0,-1)
        end
    elseif key == "+i" or key == "=i" then
        if mode == 0 then
            move(0,0,step)
            directionString = "+Z"
        elseif mode == 1 then
            rotate(1,0,0)
        end
    elseif key == "+k" or key == "=k" then
        if mode == 0 then
            move(0,0,-step)
            directionString = "-Z"
        elseif mode == 1 then
            rotate(-1,0,0)
        end
    end
    
    
    if mode == 0 then
        modeString = "MOVE"
    elseif mode == 1 then
        modeString = "ROTATE"
    end

    --[[echo(placement_editor.handledObj)
    echo(dump(body.worldPosition))
    echo(dump(body.worldOrientation))
    echo(modeString)
    echo(directionString)--]]
    placement_editor.screenText.text = "Placement Editor\nObject: "..dump(placement_editor.handledObj).."\nPosition: "
    ..dump(body.worldPosition).."\nRotation: "..dump(body.worldOrientation).."\n"..modeString.." "..step.." "..directionString
    
    return false
end

function placement_editor:manip (obj)
    if obj == nil or self.handledObj ~= nil then
        print(dump(self.handledObj))
        print(self.handledObj.instance.body.worldPosition)
        print(self.handledObj.instance.body.worldOrientation)
    
        self.handledObj = nil
        get_hud_root():removeChild(self.screenText)
        ui.pressCallbacks:removeByName("placement_editor")
        
        return
    end

    self.handledObj = obj
    self.screenText = get_hud_root():addChild("ShadowText", self.textOpts)
    self.screenText.resize = function(w,h) return 5, h*self.Y_offset/100, w, h end
    
    ui.pressCallbacks:insert("placement_editor", callback)
    callback(nil)
end
