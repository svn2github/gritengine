hud_class `Main` {
    colour = vec(1, 0.5, 0)*0.5;
    
    padding = 16;
	
    
    init = function (self)
        self.needsParentResizedCallbacks = true
        
        local function newButton(caption, inittab)
            local button = gfx_hud_object_add(`Button`, inittab)
            button:setCaption(caption)
            return button
        end
        
        local function newContent(inittab)
            local content = gfx_hud_object_add(`../StackY`, inittab)
            content.parent = self
            content.enabled = false
            return content
        end
        
        self.mainContent = newContent({ padding = self.padding,
            newButton("Playground", {pressedCallback = function() 
                game_manager:enter("Playground")
            end}),
            newButton("Integrated Development Environment", {pressedCallback = function() 
                game_manager:enter("Integrated Development Environment")
            end}),
            newButton("End Game", {pressedCallback = function() 
                game_manager:exit("Integrated Development Environment")
            end}),
            newButton("Resume", {pressedCallback = function() 
                menu:setEnabled(false)
            end}),
            newButton("Settings", {pressedCallback = function() self:setContent(self.optionsContent) end}),
            newButton("Quit", {pressedCallback = quit}),     
        })
        
        local function getBoolStateString(var, truemsg, falsemsg)
            return (var and truemsg or falsemsg)
        end
        
        local function mouseInvStateString()
            return getBoolStateString(user_cfg.mouseInvert, "Mouse Invert: On", "Mouse Invert: Off")
        end
        
        local function speedoStateString()
            return getBoolStateString(user_cfg.metricUnits, "Speedo: Metric", "Speedo: Imperial")
        end
        
        local mouseSensWidget = function()
            local info = newButton("Sensitivity", {greyed = true,
                                                           captionColourGreyed = vec(0,0,0)})
            local slider = gfx_hud_object_add(`/common/hud/Scale`, {
                                                size = vec(256, 48),
                                                onChange = function(self)
                                                    user_cfg.mouseSensitivity = clamp(self.value, 0.001, 1)
                                                end;
                                             })
            info.parent = slider
            slider:setValue(user_cfg.mouseSensitivity)
            return gfx_hud_object_add(`../StackX`, {padding = 6, info, slider})
        end;
        
        self.optionsContent = newContent({ padding = self.padding,
            mouseSensWidget(),
            newButton(mouseInvStateString(), {
                pressedCallback = function(self)
                    user_cfg.mouseInvert = not user_cfg.mouseInvert
                    self:setCaption(mouseInvStateString())
                end
            }),
            newButton(speedoStateString(), {
                pressedCallback = function(self)
                    user_cfg.metricUnits = not user_cfg.metricUnits
                    self:setCaption(speedoStateString())
                end
            }),
			newButton("Controls", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.mainContent)
                end
            }),
        })
		
		self.controlsContent = newContent({ padding = self.padding,
			newButton("Core Controls", {
                pressedCallback = function()
                    self:setContent(self.coreControlsContentPageOne)
                end
            }),
			newButton("Ghost Controls", {
                pressedCallback = function()
                    self:setContent(self.ghostControlsContentPageOne)
                end
            }),
			newButton("Drive Controls", {
                pressedCallback = function()
                    self:setContent(self.driveControlsContentPageOne)
                end
            }),
			newButton("Foot Controls", {
                pressedCallback = function()
                    self:setContent(self.footControlsContentPageOne)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.optionsContent)
                end
            }),
        })
		--------------------------------------------------------------------------------------------------------
		----------                     Core Controls Listed In Settings Menu                      ----------
		--------------------------------------------------------------------------------------------------------
--[[
		self.coreControlsContentPageOne = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Clear Placed: "..user_core_bindings.clearPlaced, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Clear Projectiles: "..user_core_bindings.clearProjectiles, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Console: "..user_core_bindings.console, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Game Logic Frame Step: "..user_core_bindings.gameLogicFrameStep, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Game Logic Step: "..user_core_bindings.gameLogicStep, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Menu: "..user_core_bindings.menu, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.coreControlsContentPageTwo)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
		
		self.coreControlsContentPageTwo = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Physics Debug World: "..user_core_bindings.physicsDebugWorld, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Physics One To One: "..user_core_bindings.physicsOneToOne, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Physics Pause: "..user_core_bindings.physicsPause, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Physics Split Impulse: "..user_core_bindings.physicsSplitImpulse, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Physics Wire Frame: "..user_core_bindings.physicsWireFrame, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Record: "..user_core_bindings.record, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.coreControlsContentPageThree)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.coreControlsContentPageOne)
                end
            }),
        })
		
		self.coreControlsContentPageThree = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Screen Shot: "..user_core_bindings.screenShot, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Toggle Fullscreen: "..user_core_bindings.toggleFullScreen, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Toggle VSync: "..user_core_bindings.toggleVSync, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Wireframe: "..user_core_bindings.wireFrame, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.coreControlsContentPageTwo)
                end
            }),
        })
		
		--------------------------------------------------------------------------------------------------------
		----------                    Ghost Controls Listed In Settings Menu                     ----------
		--------------------------------------------------------------------------------------------------------
		self.ghostControlsContentPageOne = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Ascend: "..user_ghost_bindings.ascend, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Backwards: "..user_ghost_bindings.backwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Board: "..user_ghost_bindings.board, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Descend: "..user_ghost_bindings.descend, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Fast: "..user_ghost_bindings.fast, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Forwards: "..user_ghost_bindings.forwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.ghostControlsContentPageTwo)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
		
		self.ghostControlsContentPageTwo = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Grab: "..user_ghost_bindings.grab, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Placement Editor: "..user_ghost_bindings.placementEditor, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Prod: "..user_ghost_bindings.prod, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Simple Menu Show: "..user_ghost_bindings.simpleMenuShow, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Strafe Left: "..user_ghost_bindings.strafeLeft, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Strafe Right: "..user_ghost_bindings.strafeRight, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.ghostControlsContentPageThree)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.ghostControlsContentPageOne)
                end
            }),
        })
		
		self.ghostControlsContentPageThree = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Teleport Down: "..user_ghost_bindings.teleportDown, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Teleport Up: "..user_ghost_bindings.teleportUp, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.ghostControlsContentPageTwo)
                end
            }),
        })
]]
		
		--------------------------------------------------------------------------------------------------------
		----------                    Drive Controls Listed In Settings Menu                     ----------
		--------------------------------------------------------------------------------------------------------
		self.driveControlsContentPageOne = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Abandon: "..user_drive_bindings.driveAbandon, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Alt Down: "..user_drive_bindings.driveAltDown, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Alt Left: "..user_drive_bindings.driveAltLeft, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Alt Right: "..user_drive_bindings.driveAltRight, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
--[[
			newButton("Alt Up: "..user_drive_bindings.AltUp, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Backwards: "..user_drive_bindings.Backwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.driveControlsContentPageTwo)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
]]
        })
		
--[[
		self.driveControlsContentPageTwo = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Camera: "..user_drive_bindings.camera, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Forwards: "..user_drive_bindings.forwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Handbrake: "..user_drive_bindings.handbrake, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Lights: "..user_drive_bindings.lights, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.driveControlsContentPageThree)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                   self:setContent(self.driveControlsContentPageOne)
                end
            }),
        })
		
		self.driveControlsContentPageThree = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Special Down: "..user_drive_bindings.specialDown, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Special Left: "..user_drive_bindings.specialLeft, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Special Right: "..user_drive_bindings.specialRight, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Special Toggle: "..user_drive_bindings.specialToggle, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Special Up: "..user_drive_bindings.specialUp, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Steer Left: "..user_drive_bindings.left, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.driveControlsContentPageFour)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                   self:setContent(self.driveControlsContentPageTwo)
                end
            }),
        })
		
		self.driveControlsContentPageFour = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Steer Right: "..user_drive_bindings.right, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Zoom In: Scroll In", {--Need better way to detect the table
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Zoom Out: Scroll Out", { --Need better way to detect the table
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                   self:setContent(self.driveControlsContentPageThree)
                end
            }),
        })
		
		--------------------------------------------------------------------------------------------------------
		----------                    Foot Controls Listed In Settings Menu                     ----------
		--------------------------------------------------------------------------------------------------------
		self.footControlsContentPageOne = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Board: "..user_foot_bindings.board, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Backwards: "..user_foot_bindings.backwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Crouch: "..user_foot_bindings.crouch, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Forwards: "..user_foot_bindings.forwards, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Jump: "..user_foot_bindings.jump, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Run: "..user_foot_bindings.run, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Next Page -->", {
                pressedCallback = function()
                    self:setContent(self.footControlsContentPageTwo)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
		
		self.footControlsContentPageTwo = newContent({ padding = self.padding,  --Make a loop in the future to list all of them automatically
			newButton("Strafe Left: "..user_foot_bindings.left, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Strafe Right: "..user_foot_bindings.right, {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Zoom In: Scroll In", {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
			newButton("Zoom Out: Scroll Out", {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                   self:setContent(self.footControlsContentPageOne)
                end
            }),
        })
]]
        
        self:setContent(self.mainContent)
    end;

    destroy = function (self)
    end;
    
    setContent = function (self, content)
        if self.content then
            self.content.enabled = false
        end
        self.content = content
        self.content.enabled = true
    end;
    
    parentResizedCallback = function (self, psize)
        self.position = vec(psize.x/2, psize.y/2)
        self.size = psize
    end;

    setEnabled = function(self, v)
        self.enabled = v
        menu_binds.modal = v
        menu:setContent(menu.mainContent)
    end;

    escape = function(self)
    end;
}
