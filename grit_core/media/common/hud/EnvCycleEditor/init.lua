-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "../ColourPicker" {

    init = function (self)
        self.alpha = 0

        local on_change = function() self:childChanged() end

        self.hue = gfx_hud_object_add("Scale", { onChange = on_change, size=vector2(388,20), value=0, bgTexture="EnvCycleEditor/bg_hue.png",   bgColour=vector3(1,1,1) })
        self.sat = gfx_hud_object_add("Scale", { onChange = on_change, size=vector2(388,20), value=1, bgColour=vector3(1,0,0), mgTexture="EnvCycleEditor/bg_sat.png", mgAlpha=1 })
        self.val = gfx_hud_object_add("Scale", { onChange = on_change, size=vector2(388,20), value=1, bgTexture="EnvCycleEditor/bg_val.png",   bgColour=vector3(1,1,1), gamma=true, maxValue=10 })
        self.a   = gfx_hud_object_add("Scale", { onChange = on_change, size=vector2(388,20), value=1, bgTexture="EnvCycleEditor/bg_alpha.png", bgColour=vector3(1,1,1) })

        -- why did putting a comma on the end of the line cause this file not to be included and error suppressed?
        self.hueLabel = gfx_hud_object_add("Label", { size=vector2(41,20), value="Hue" })
        self.satLabel = gfx_hud_object_add("Label", { size=vector2(41,20), value="Sat" })
        self.valLabel = gfx_hud_object_add("Label", { size=vector2(41,20), value="Val" })
        self.aLabel = gfx_hud_object_add("Label", { size=vector2(41,20), value="Alpha" })

        self.contents = gfx_hud_object_add("StackY", {
            parent = self, 
            padding = -1,
            gfx_hud_object_add("StackX", {
                padding = -1,
                self.hueLabel,
                self.hue,
            }),
            gfx_hud_object_add("StackX", {
                padding = -1,
                self.satLabel,
                self.sat,
            }),
            gfx_hud_object_add("StackX", {
                padding = -1,
                self.valLabel,
                self.val,
            }),
            gfx_hud_object_add("StackX", {
                padding = -1,
                self.aLabel,
                self.a,
            }),
        })

        self.size = self.contents.size

        if self.greyed == nil then
             self.greyed = false
        end
        if self.colGreyed == nil then
             self.colGreyed = false
        end
        if self.aGreyed == nil then
             self.aGreyed = false
        end

    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self:updateAppearance()
    end;

    setGreyedColAlpha = function (self, col, alpha)
        self.colGreyed = col
        self.aGreyed = alpha
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        self.hue:setGreyed(self.greyed or self.colGreyed)
        self.hueLabel:setGreyed(self.greyed or self.colGreyed)
        self.sat:setGreyed(self.greyed or self.colGreyed)
        self.satLabel:setGreyed(self.greyed or self.colGreyed)
        self.val:setGreyed(self.greyed or self.colGreyed)
        self.valLabel:setGreyed(self.greyed or self.colGreyed)
        self.a:setGreyed(self.greyed or self.aGreyed)
        self.aLabel:setGreyed(self.greyed or self.aGreyed)
    end;

    destroy = function (self)
        self.contents = safe_destroy(self.contents)
    end;
    
    childChanged = function (self)
        if self.contents == nil then return end
        self.sat.sliderBackground.colour = HSVtoRGB(vector3(self.hue.value, 1, 1))
        self:onChange()
    end;
    
    getColour = function (self)
        return HSVtoRGB(vector3(self.hue.value, self.sat.value, self.val.value))
    end;
    setColour = function (self, c)
        local hsl = RGBtoHSV(c)
        self.hue:setValue(hsl.x)
        self.sat:setValue(hsl.y)
        self.val:setValue(hsl.z)
    end;

    getAlpha = function (self)
        return self.a.value
    end;
    setAlpha = function (self, v)
        self.a:setValue(v)
    end;
    
    onChange = function (self)
        echo("Colour: "..self:getColour().."  Alpha: "..self:getAlpha())
    end;
    
}

hud_class "../EnvCycleEditor" (extends (BorderPane) {

    borderColour=vector3(0,0,0),

    colour=vector3(0,0,0),

    alpha=0.5,
    
    controlClicked = function (self, caption)
        if caption == nil then
            self.colourPicker:setGreyedColAlpha(true, true)
            return
        end
        local control = self.byCaption[caption]
        if control.className == "/common/hud/ColourControl" then
            self.currentlyClicked = nil
            if control.needsAlpha then
                self.colourPicker:setGreyedColAlpha(false, false)
                self.colourPicker:setColour(control.colour)
                self.colourPicker:setAlpha(control.a)
            else
                self.colourPicker:setGreyedColAlpha(false, true)
                self.colourPicker:setColour(control.colour)
            end
            self.currentlyClicked = caption
        else
            self.colourPicker:setGreyedColAlpha(true, true)
        end
    end;
    
    colourPickerChanged = function (self)
        if self.currentlyClicked == nil then return end
        local caption = self.currentlyClicked
        local control = self.byCaption[caption]
        if control.needsAlpha then
            control:setColour(self.colourPicker:getColour(), self.colourPicker:getAlpha())
        else
            control:setColour(self.colourPicker:getColour())
        end
    end;

    init = function (self)
        BorderPane.init(self)
        
        self.needsInputCallbacks = true
        
        self.byCaption = { }
        local function add (kind, caption, tab)
            local base = {size=vector2(136,20), width=40, caption=caption, maxLength=5, clicked = function()self:controlClicked(caption)end}
            local o = gfx_hud_object_add(kind, extends (base) (tab or { }))
            self.byCaption[caption] = o
            return o
        end
        
        self.title = gfx_hud_text_add("/common/fonts/Impact24")
        --self.title.text = "Ｅｎｖｉｒｏｎｍｅｎｔ  Ｃｙｃｌｅ  Ｅｄｉｔｏｒ"
        self.title.text = "Environment Cycle Editor"

        self.colourPicker = gfx_hud_object_add("ColourPicker", { onChange = function () self:colourPickerChanged() end } )
        self.colourPicker:setGreyed(true, true)
        
        self.contents = gfx_hud_object_add("StackY", {
            parent=self, 
            padding = 0,

            self.title,

            vector2(0,10),

            self.colourPicker,
            
            vector2(0,10),

            gfx_hud_object_add("StackX", {
                padding = 10,
                
                { "TOP", gfx_hud_object_add("StackY", {
                    padding=-1,
                    add("ColourControl", "Grad6", { needsAlpha = true } ),
                    add("ColourControl", "Grad5", { needsAlpha = true } ),
                    add("ColourControl", "Grad4", { needsAlpha = true } ),
                    add("ColourControl", "Grad3", { needsAlpha = true } ),
                    add("ColourControl", "Grad2", { needsAlpha = true } ),
                    add("ColourControl", "Grad1", { needsAlpha = true } ),
                })},

                { "TOP", gfx_hud_object_add("StackY", {
                    padding=-1,
                    add("ColourControl", "Sun Grad6", { needsAlpha = true } ),
                    add("ColourControl", "Sun Grad5", { needsAlpha = true } ),
                    add("ColourControl", "Sun Grad4", { needsAlpha = true } ),
                    add("ColourControl", "Sun Grad3", { needsAlpha = true } ),
                    add("ColourControl", "Sun Grad2", { needsAlpha = true } ),
                    add("ColourControl", "Sun Grad1", { needsAlpha = true } ),
                })},

                gfx_hud_object_add("StackY", {
                    padding = 4;
                    gfx_hud_object_add("StackY", {
                        padding = -1;
                        add("ValueControl",  "Sun Size", {number=true}),
                        add("ColourControl", "Sun Colour", { needsAlpha = true } ),
                    }),
                    gfx_hud_object_add("StackY", {
                        padding = -1;
                        add("ValueControl",  "Cloud Coverage", {number=true}),
                        add("ColourControl", "Cloud Colour"),
                    }),
                    gfx_hud_object_add("StackY", {
                        padding = -1;
                        add("ValueControl",  "Horizon Glare", {number=true}),
                        add("ValueControl", "Sun Glare", {number=true}),
                    }),
                }),
            }),
            
            vector2(0,10),
            
            gfx_hud_object_add("StackX", {
                padding = 10,
                { "TOP", add("ValueControl", "Saturation") },
                { "TOP", gfx_hud_object_add("StackY", {
                    padding=-1,
                    add("ColourControl", "Fog Colour"),
                    add("ValueControl", "Fog Density", {number=true}),
                })},
                gfx_hud_object_add("StackY", {
                    padding = 4;
                    gfx_hud_object_add("StackY", {
                        padding = -1;
                        add("ColourControl", "Particle Light"),
                        add("ColourControl", "Diffuse Light"),
                        add("ColourControl", "Specular Light"),
                    }),
                    add("EnumControl",  "Light Source", { options={"Sun","Moon"} }),
                }),
            })
        })

        self.size = self.contents.size + vector2(20,20)
        self:updateChildrenSize()

        self.timeLeftButton = gfx_hud_object_add("Button", {
            parent = self;
            caption = "◄";
            pressedCallback = function (self)
                echo("derp")
            end;
            size = vec(16,20);
            position= -self.size/2 + vec(16,64);
        })
        self.timeRightButton = gfx_hud_object_add("Button", {
            parent = self;
            caption = "►";
            pressedCallback = function (self)
                echo("derp")
            end;
            size = vec(16,20);
            position= -self.size/2 + vec(32,64);
        })
        self.editButton = gfx_hud_object_add("Button", {
            parent = self;
            caption = "Edit";
            pressedCallback = function (self)
                echo("derp")
            end;
            size = vec(32,20);
            position= -self.size/2 + vec(24,44);
        })
        self.pauseButton = gfx_hud_object_add("Button", {
            parent = self;
            pressedCallback = function (self2)
                env.clockTicking = not env.clockTicking
                self:updatePaused()
            end;
            size = vec(100,20);
            position = -self.size/2 + vec(58,20);
        })
        self:updatePaused()
    end;
    updatePaused = function (self)
        if env.clockTicking then
            self.pauseButton.text.text = "Pause (∥)"
            self.timeLeftButton:setGreyed(true)
            self.timeRightButton:setGreyed(true)
            self.editButton:setGreyed(true)
        else
            self.pauseButton.text.text = "Play (▶)"
            self.timeLeftButton:setGreyed(false)
            self.timeRightButton:setGreyed(false)
            self.editButton:setGreyed(false)
        end
    end;

    destroy = function(self)
        self.contents = safe_destroy(self.contents)
        BorderPane.destroy(self)
    end;
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            self:controlClicked(nil)
        end
    end;
        
})

function doit (n)
    n = n or 6
    local sky = sky_cycle[n]
    for i=1,6 do
        env_cycle_editor.byCaption["Grad"..i]:setColour(vector3(unpack(sky.gradient[i],1,3)), unpack(sky.gradient[i],4,4))
    end
    for i=1,6 do
        env_cycle_editor.byCaption["Sun Grad"..i]:setColour(vector3(unpack(sky.sunGradient[i],1,3)), unpack(sky.sunGradient[i],4,4))
    end
    env_cycle_editor.byCaption["Fog Colour"]:setColour(vector3(unpack(sky.fog,1,3)), unpack(sky.fog,4,4))
    env_cycle_editor.byCaption["Particle Light"]:setColour(vector3(unpack(sky.particleAmbient)))
    env_cycle_editor.byCaption["Diffuse Light"]:setColour(vector3(unpack(sky.diff)))
    env_cycle_editor.byCaption["Specular Light"]:setColour(vector3(unpack(sky.spec)))
    env_cycle_editor.byCaption["Cloud Colour"]:setColour(vector3(unpack(sky.cloudColour)))
    env_cycle_editor.byCaption["Sun Colour"]:setColour(vector3(unpack(sky.sunColour,1,3)), unpack(sky.sunColour,4,4))
end
