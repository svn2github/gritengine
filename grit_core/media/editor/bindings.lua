

if editor_core_binds ~= nil then editor_core_binds:destroy() end
editor_core_binds = InputFilter(45, `editor_core_binds`)

if editor_edit_binds ~= nil then editor_edit_binds:destroy() end
editor_edit_binds = InputFilter(46, `editor_edit_binds`)

if editor_debug_binds ~= nil then editor_debug_binds:destroy() end
editor_debug_binds = InputFilter(47, `editor_debug_binds`)

editor_core_binds.enabled = false
editor_edit_binds.enabled = false 
editor_debug_binds.enabled = false


local function inside()
    -- [dcunnin] If the intention of this is to detect whether the cursor is over a window,
    -- there must be a better way.
    --
    -- All these cross-cutting dependencies on other aspects of GUI layout have to go...
    if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
        if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 25 then
            if not mouse_inside_any_window() and not mouse_inside_any_menu() and addobjectelement == nil then
                return true
            end
        end
    end
    return false
end

    
function editor_receive_button(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end

    if button == "debug" then
        if state == '+' then
			GED:toggleDebugMode()
        end
    elseif button == "forwards" then
        GED.forwards = on_off

    elseif button == "forwards" then
        GED.forwards = on_off

    elseif button == "backwards" then
        GED.backwards = on_off

    elseif button == "strafeLeft" then
        GED.left = on_off

    elseif button == "strafeRight" then
        GED.right = on_off

    elseif button == "ascend" then
        GED.ascend = on_off
    elseif button == "descend" then
        GED.descend = on_off
    elseif button == "faster" then
        if state == '+' then
			GED.fast = true
        elseif state == '-' then
			GED.fast = false
        end
    elseif button == "delete" then
        GED:deleteSelection()

    elseif button == "duplicate" then
        GED:duplicateSelection()

    elseif button == "board" then
        -- ghost:pickDrive()

    elseif button == "ghost" then
        if state == '+' then
            if inside() then
                GED:setMouseCapture(true)
            end
        elseif state == '-' then
            GED:setMouseCapture(false)
        end

    elseif button == "toggleGhost" then
        if state == '+' then
            GED:toggleMouseCapture()
        end

    elseif button == "select" then
        if state == '+' then
            if inside then
                GED:selectObj()
            end
        elseif state == '-' then
            GED:stopDraggingObj()
        end

    elseif button == "weaponPrimary" then
        if state == '+' then
            WeaponEffectManager:primaryEngage(main.camPos, main.camQuat)
        elseif state == '-' then
            WeaponEffectManager:primaryDisengage()
        end

    elseif button == "weaponSecondary" then
        if state == '+' then
            WeaponEffectManager:secondaryEngage(main.camPos, main.camQuat)
        elseif state == '-' then
            WeaponEffectManager:secondaryDisengage()
        end

    elseif button == "weaponSwitchUp" then
        if state == '+' then
            WeaponEffectManager:select(WeaponEffectManager:getNext())
        end

    elseif button == "weaponSwitchDown" then
        if state == '+' then
            WeaponEffectManager:select(WeaponEffectManager:getPrev())
        end

    elseif button == "pausePhysics" then
        if state == '+' then
            main.physicsEnabled = not main.physicsEnabled
        end

    end
end

