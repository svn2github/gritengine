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
            newButton("Resume", {pressedCallback = function() 
                menu_binds.modal = false
                menu.enabled = false
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
                    self:setContent(self.ghostControlsContent)
                end
            }),
			newButton("Drive Controls", {
                pressedCallback = function()
                    self:setContent(self.driveControlsContent)
                end
            }),
			newButton("Foot Controls", {
                pressedCallback = function()
                    self:setContent(self.footControlsContent)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.optionsContent)
                end
            }),
        })
		
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
		
		self.ghostControlsContent = newContent({ padding = self.padding,
			newButton("ToDo: Loop to list controls", {
                pressedCallback = function()
                    print("Controls coming soon!")
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
		
		self.driveControlsContent = newContent({ padding = self.padding,
			newButton("ToDo: Loop to list controls", {
                pressedCallback = function()
                    print("Controls coming soon!")--self:setContent(self.mainContent)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
		
		self.footControlsContent = newContent({ padding = self.padding,
			newButton("ToDo: Loop to list controls", {
                pressedCallback = function()
                    print("Controls coming soon!")--self:setContent(self.mainContent)
                end
            }),
            newButton("Go Back", {
                pressedCallback = function()
                    self:setContent(self.controlsContent)
                end
            }),
        })
        
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
}
