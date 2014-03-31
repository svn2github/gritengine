hud_class "Main" {
    colour = vec(1, 0.5, 0)*0.5;
    
    padding = 16;
    
    init = function (self)
        self.needsParentResizedCallbacks = true
        
        local function newButton(caption, inittab)
            local button = gfx_hud_object_add("Button", inittab)
            button:setCaption(caption)
            return button
        end
        
        local function newContent(inittab)
            local content = gfx_hud_object_add("../StackY", inittab)
            content.parent = self
            content.enabled = false
            return content
        end
        
        local function getBoolStateString(var, truemsg, falsemsg)
            return (var and truemsg or falsemsg)
        end
        
        local function mouseInvStateString()
            return getBoolStateString(user_cfg.mouseInvert, "Mouse Invert: On", "Mouse Invert: Off")
        end
        
        local function speedoStateString()
            return getBoolStateString(user_cfg.metricUnits, "Speedo: Metric", "Speedo: Imperial")
        end
        
        self.mainContent = newContent({ padding = self.padding,
            newButton("Resume", {pressedCallback = function() 
                menu_binds.modal = false
                menu.enabled = false
            end}),
            newButton("Settings", {pressedCallback = function() self:setContent(self.optionsContent) end}),
            newButton("Quit", {pressedCallback = quit}),     
        })
        
        self.optionsContent = newContent({ padding = self.padding,
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
            newButton("Go Back", {pressedCallback = function() self:setContent(self.mainContent) end}),
        })
        
        self:setContent(self.mainContent)
    end;

    destroy = function (self)
        safe_destroy(self.mainContent)
        safe_destroy(self.optionsContent)
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
