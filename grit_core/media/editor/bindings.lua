

if editor_core_binds ~= nil then editor_core_binds:destroy() end
editor_core_binds = InputFilter(45, `editor_core_binds`)

if editor_edit_binds ~= nil then editor_edit_binds:destroy() end
editor_edit_binds = InputFilter(46, `editor_edit_binds`)
editor_edit_binds.modal = true

if editor_debug_binds ~= nil then editor_debug_binds:destroy() end
editor_debug_binds = InputFilter(47, `editor_debug_binds`)

editor_core_binds.enabled = false
editor_edit_binds.enabled = false 
editor_debug_binds.enabled = false


editor_core_binds.mouseMoveCallback = function (rel)
    local sens = user_cfg.mouseSensitivity

    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    GED.camYaw = (GED.camYaw + rel2.x) % 360
    GED.camPitch = clamp(GED.camPitch + rel2.y, -90, 90)

    main.camQuat = quat(GED.camYaw, V_DOWN) * quat(GED.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat
end 

    
function editor_receive_button(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end

    if button == "debug" then
        if state == '+' then
			GED:play()
        end
            -- must toggle between that and GED:return_editor() 
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

    elseif button == "ghost" then  -- used to be RMB
        if state == '+' then
            if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
                if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 25 then
                    if not mouse_inside_any_window() and not mouse_inside_any_menu() and addobjectelement == nil then
                        ch.enabled = true
						GED.ghosting = true
						editor_core_binds.mouseCapture = true
						editor_edit_binds.enabled = false
						editor_debug_binds.enabled = true
                    end
                end
            end
        elseif state == '-' then
            ch.enabled = false
            editor_core_binds.mouseCapture = false
            editor_edit_binds.enabled = true
            editor_debug_binds.enabled = false
        end

    elseif button == "select" then  -- used to be LMB
        if state == '+' then
            -- [dcunnin] If the intention of this is to detect whether the cursor is over a window,
            -- there must be a better way.
            if mouse_pos_abs.x > 40 and mouse_pos_abs.y > 20 then
                if (console.enabled and mouse_pos_abs.y < gfx_window_size().y - console_frame.size.y) or not console.enabled and mouse_pos_abs.y < gfx_window_size().y - 25 then
                    if not mouse_inside_any_window() and not mouse_inside_any_menu() and addobjectelement == nil then
                        GED:selectObj()
                    end
                end
            end
        elseif state == '-' then
            GED:stopDraggingObj()
        end

    end
end;


