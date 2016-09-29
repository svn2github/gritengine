

if editor_core_binds ~= nil then editor_core_binds:destroy() end
editor_core_binds = InputFilter(45, `editor_core_binds`)

if editor_core_move_binds ~= nil then editor_core_move_binds:destroy() end
editor_core_move_binds = InputFilter(46, `editor_core_move_binds`)

if editor_edit_binds ~= nil then editor_edit_binds:destroy() end
editor_edit_binds = InputFilter(47, `editor_edit_binds`)

if editor_debug_binds ~= nil then editor_debug_binds:destroy() end
editor_debug_binds = InputFilter(48, `editor_debug_binds`)

if editor_debug_ghost_binds ~= nil then editor_debug_ghost_binds:destroy() end
editor_debug_ghost_binds = InputFilter(49, `editor_debug_ghost_binds`)

editor_core_binds.enabled = false
editor_core_move_binds.enabled = false
editor_edit_binds.enabled = false 
editor_debug_binds.enabled = false
editor_debug_ghost_binds.enabled = false

function editor_receive_button(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end
	if not hud_focus then
		local cobj = GED.controlObj

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
			if state == '+' then
				GED:deleteSelection()
			end

		elseif button == "duplicate" then
			if state == '+' then
				GED:duplicateSelection()
			end

		elseif button == "board" then
			if state == '+' then
				GED:toggleBoard()
			end

		elseif button == "walkBoard" then
			if state == '+' then
				GED:toggleBoard()
			end

		elseif button == "driveAbandon" then
			if state == '+' then
				GED:toggleBoard()
			end

		elseif button == "ghost" then
			if state == '+' then
				if inside_hud() then
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
				if inside_hud() then
					GED:leftMouseClick()
				end
			elseif state == '-' then
				GED:stopDraggingObj()
			end
		elseif button == "selectModeTranslate" then
			GED:setWidgetMode("translate")
		elseif button == "selectModeRotate" then
			GED:setWidgetMode("rotate")
		elseif button == "weaponPrimary" then
			if not mouse_inside_any_window() then
				if state == '+' then
					WeaponEffectManager:primaryEngage(main.camPos, main.camQuat)
				elseif state == '-' then
					WeaponEffectManager:primaryDisengage()
				end
			end
		elseif button == "weaponSecondary" then
			if not mouse_inside_any_window() then
				if state == '+' then
					WeaponEffectManager:secondaryEngage(main.camPos, main.camQuat)
				elseif state == '-' then
					WeaponEffectManager:secondaryDisengage()
				end
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
		else
			local pressed = state ~= '-'
			if state == '=' then return end

			if button == 'walkForwards' then
				cobj:setForwards(pressed)
			elseif button == 'walkBackwards' then
				cobj:setBackwards(pressed)
			elseif button == 'walkLeft' then
				cobj:setLeft(pressed)
			elseif button == 'walkRight' then
				cobj:setRight(pressed)
			elseif button == 'walkBoard' then
				if state == '+' then
					self:scanForBoard()
				end
			elseif button == 'walkJump' then
				cobj:setJump(pressed)
			elseif button == 'walkRun' then
				cobj:setRun(pressed)
			elseif button == 'walkCrouch' then
				cobj:setCrouch(pressed)
			elseif button == 'walkZoomIn' then
				cobj:controlZoomIn()
			elseif button == 'walkZoomOut' then
				cobj:controlZoomOut()
			elseif button == 'walkCamera' then
				-- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

			elseif button == 'driveForwards' then
				cobj:setForwards(pressed)
			elseif button == 'driveBackwards' then
				cobj:setBackwards(pressed)
			elseif button == 'driveLeft' then
				cobj:setLeft(pressed)
			elseif button == 'driveRight' then
				cobj:setRight(pressed)
			elseif button == 'driveZoomIn' then
				cobj:controlZoomIn()
			elseif button == 'driveZoomOut' then
				cobj:controlZoomOut()
			elseif button == 'driveCamera' then
				-- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

			elseif button == 'driveSpecialUp' then
				cobj:setSpecialUp(pressed)
			elseif button == 'driveSpecialDown' then
				cobj:setSpecialDown(pressed)
			elseif button == 'driveSpecialLeft' then
				cobj:setSpecialLeft(pressed)
			elseif button == 'driveSpecialRight' then
				cobj:setSpecialRight(pressed)
			elseif button == 'driveAltUp' then
				cobj:setAltUp(pressed)
			elseif button == 'driveAltDown' then
				cobj:setAltDown(pressed)
			elseif button == 'driveAltLeft' then
				cobj:setAltLeft(pressed)
			elseif button == 'driveAltRight' then
				cobj:setAltRight(pressed)
			elseif button == 'driveAbandon' then
				if state == '+' then
					self:abandonControlObj()
				end
			elseif button == 'driveHandbrake' then
				cobj:setHandbrake(pressed)
			elseif button == 'driveLights' then
				if state == '+' then
					cobj:setLights()
				end
			elseif button == 'driveSpecialToggle' then
				if state == '+' then
					cobj:special()
				end
			else
				print("Editor has no binding for button: "..button)
			end
		end
	end
end

