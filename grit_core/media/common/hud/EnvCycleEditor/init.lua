-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--[[
TODO:
* Indicate current grad1-6 being edited somehow
* Fix edit boxes for ValueControl
* Colour palette
* Actually edit sky_cycle.lua
* Save functionality
* change time does not change currently editted control
* start with a particular control
--]]

hud_class "../ColourPicker" {

    init = function (self)
        self.alpha = 0

        local on_change = function() self:childChanged() end

        local scalesz = vec(388,20)
        local labsz = vec(41,20)

        self.hueScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgTexture="EnvCycleEditor/bg_hue.png",   bgColour=vec(1,1,1) })
        self.satScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgColour=vector3(1,0,0), mgTexture="EnvCycleEditor/bg_sat.png", mgAlpha=1 })
        self.valScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgTexture="EnvCycleEditor/bg_val.png",   bgColour=vec(1,1,1), gamma=true, maxValue=10 })
        self.aScale   = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, mgTexture="EnvCycleEditor/bg_alpha.png", mgColour=vec(1,1,1), mgAlpha=1, bgColour=vec(1,1,1) })

        -- why did putting a comma on the end of the line cause this file not to be included and error suppressed?
        self.hueLabel = gfx_hud_object_add("Label", { size=labsz, value="Hue" })
        self.satLabel = gfx_hud_object_add("Label", { size=labsz, value="Sat" })
        self.valLabel = gfx_hud_object_add("Label", { size=labsz, value="Val" })
        self.aLabel = gfx_hud_object_add("Label", { size=labsz, value="Alpha" })

        self.contents = gfx_hud_object_add("StackY", {
            parent = self, 
            padding = -1,
            gfx_hud_object_add("StackX", { padding = -1, self.hueLabel, self.hueScale, }),
            gfx_hud_object_add("StackX", { padding = -1, self.satLabel, self.satScale, }),
            gfx_hud_object_add("StackX", { padding = -1, self.valLabel, self.valScale, }),
            gfx_hud_object_add("StackX", { padding = -1, self.aLabel, self.aScale, }),
        })

        self.size = self.contents.size

        self.greyed = not not self.greyed
        self.aGreyed = not not self.aGreyed
        self.hsvGreyed = not not self.hsvGreyed

    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        self.hueScale:setGreyed(self.greyed or self.hsvGreyed)
        self.hueLabel:setGreyed(self.greyed or self.hsvGreyed)
        self.satScale:setGreyed(self.greyed or self.hsvGreyed)
        self.satLabel:setGreyed(self.greyed or self.hsvGreyed)
        self.valScale:setGreyed(self.greyed or self.hsvGreyed)
        self.valLabel:setGreyed(self.greyed or self.hsvGreyed)
        self.aScale:setGreyed(self.greyed or self.aGreyed)
        self.aLabel:setGreyed(self.greyed or self.aGreyed)
    end;

    destroy = function (self)
        self.contents = safe_destroy(self.contents)
    end;

    updateBgColour = function (self)
        local hsv = self:getColourHSV() or vec(1,1,1)
        self.satScale:setBackgroundColour(HSVtoRGB(vec(hsv.x, 1, 1)))
        self.valScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, 1)))
        self.aScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, math.min(1,hsv.z))))
    end;
    
    childChanged = function (self)
        if self.contents == nil then return end
        self:updateBgColour()
        self:onChange()
    end;
    
    getColourHSV = function (self)
        if self.hsvGreyed then return nil end
        return vec(self.hueScale.value, self.satScale.value, self.valScale.value)
    end;
    getColourRGB = function (self)
        if self.hsvGreyed then return nil end
        return HSVtoRGB(self:getColourHSV())
    end;
    setColourRGB = function (self, c)
        if c == nil then
            self.hsvGreyed = true
            self.hueScale:setValue(0)
            self.satScale:setValue(0)
            self.valScale:setValue(1)
        else
            local hsv = RGBtoHSV(c)
            self.hsvGreyed = false
            self.hueScale:setValue(hsv.x)
            self.satScale:setValue(hsv.y)
            self.valScale:setValue(hsv.z)
            self:updateBgColour()
        end
        self:updateAppearance()
    end;

    getAlpha = function (self)
        if self.aGreyed then return nil end
        return self.aScale.value
    end;
    setAlpha = function (self, a)
        if a == nil then
            self.aGreyed = true
            self.aScale:setValue(1)
        else
            self.aGreyed = false
            self.aScale:setValue(a)
            self:updateBgColour()
        end
        self:updateAppearance()
    end;
    
    onChange = function (self)
        echo("Colour: "..self:getColourRGB().."  Alpha: "..self:getAlpha())
    end;
    
}

hud_class "../EnvCycleEditor" (extends (BorderPane) {

    borderColour=vector3(0,0,0),

    colour=vector3(0,0,0),

    alpha=0.7,
    
    controlClicked = function (self, caption)
        if caption == nil then
            -- click in empty space
            self.colourPicker:setGreyed(true)
            return
        end
        local control = self.byCaption[caption]
        self.marker.position = control.derivedPosition - self.derivedPosition - vec(58,0)

        if control.className == "/common/hud/ColourControl" then
            self.colourPicker:setGreyed(false)
            self.currentlyClicked = nil
            if control.needsAlpha then
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(control.a)
            else
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(nil)
            end
            self.currentlyClicked = caption
        elseif control.className == "/common/hud/EnumControl" then
            control:advanceValue()
        else
            -- clicked on something else (what?)
            -- treat the same as empty space
            self.colourPicker:setGreyed(true)
        end
    end;
    
    colourPickerChanged = function (self)
        if self.currentlyClicked == nil then return end
        local caption = self.currentlyClicked
        local control = self.byCaption[caption]
        control:setColour(self.colourPicker:getColourRGB(), self.colourPicker:getAlpha())
    end;

    currentInstant = function (self)
        return sky_cycle[self.editIndex or 1] or sky_cycle[1]
    end;

    init = function (self)
        BorderPane.init(self)
        
        self.needsInputCallbacks = true
        self.needsFrameCallbacks = true

        self.editIndex = 1
        
        self.byCaption = { }
        local function add (kind, caption, tab)
            local base = {size=vector2(136,20), width=40, caption=caption, maxLength=5, clicked = function()self:controlClicked(caption)end}
            local o = gfx_hud_object_add(kind, extends (base) (tab or { }))
            self.byCaption[caption] = o
            return o
        end
        
        self.title = gfx_hud_text_add("/common/fonts/Impact24")
        --self.title.text = "Ｅｎｖｉｒｏｎｍｅｎｔ  Ｃｙｃｌｅ  Ｅｄｉｔｏｒ"
        -- fix spacing when font is fixed
        self.title.text = "ENVIRONMENT    CYCLE      EDITOR"

        self.colourPicker = gfx_hud_object_add("ColourPicker", { onChange = function () self:colourPickerChanged() end } )
        
        self.timeDescLabel = gfx_hud_object_add("Label", {
            value = "Editting time:";
            size = vec(96,20);
        })
        self.timeLabel = gfx_hud_object_add("Label", {
            size = vec(60,20);
        })
        self.timeLeftButton = gfx_hud_object_add("Button", {
            caption = "◄";
            pressedCallback = function (self2)
                self:timeChange(-1)
            end;
            size = vec(16,20);
        })
        self.timeRightButton = gfx_hud_object_add("Button", {
            caption = "►";
            pressedCallback = function (self2)
                self:timeChange(1)
            end;
            size = vec(16,20);
        })
        self.clockSetButton = gfx_hud_object_add("Button", {
            caption = "Copy to clock";
            pressedCallback = function (self2)
                env.secondsSinceMidnight = self:currentInstant().time * 60 * 60
            end;
            size = vec(100,20);
        })
        self.topControls = gfx_hud_object_add("StackX", {
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
        })
        self.bottomControls = gfx_hud_object_add("StackX", {
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
        self.contents = gfx_hud_object_add("StackY", {
            parent=self, 
            padding = 0,

            self.title,

            vector2(0,4),

            self.colourPicker,
            
            vector2(0,10),

            self.topControls,
            
            vector2(0,10),
            
            self.bottomControls,

            vector2(0,10),

            { "RIGHT", gfx_hud_object_add("StackX", {
                parent=self, 

                self.timeDescLabel,
                vector2(-1,0),
                self.timeLabel,
                vector2(2,0),
                self.timeLeftButton,
                self.timeRightButton,

                vector2(10,0),

                self.clockSetButton,
            }) },
        })

        self.marker = gfx_hud_object_add("Rect", { parent=self, texture="EnvCycleEditor/marker.png", zOrder=6})

        self.size = self.contents.size + vector2(20,20)
        self:updateChildrenSize()

        self:updateAppearance()
    end;

    -- direction 1 or -1
    timeChange = function (self, direction)
        self.editIndex = self.editIndex + direction
        if self.editIndex < 1 then self.editIndex = #sky_cycle end
        if self.editIndex > #sky_cycle then self.editIndex = 1 end
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        local env_instant = self:currentInstant()
        self.colourPicker:setGreyed(true)
        self.timeLabel:setValue(format_time(env_instant.time * 60 * 60))

        for i=1,6 do
            self.byCaption["Grad"..i]:setColour(vector3(unpack(env_instant.gradient[i],1,3)), unpack(env_instant.gradient[i],4,4))
        end
        for i=1,6 do
            self.byCaption["Sun Grad"..i]:setColour(vector3(unpack(env_instant.sunGradient[i],1,3)), unpack(env_instant.sunGradient[i],4,4))
        end
        self.byCaption["Fog Colour"]:setColour(vector3(unpack(env_instant.fog,2,4)))
        self.byCaption["Fog Density"]:setValue(("%0.3f"):format(unpack(env_instant.fog,1,1)))
        self.byCaption["Particle Light"]:setColour(vector3(unpack(env_instant.particleAmbient)))
        self.byCaption["Diffuse Light"]:setColour(vector3(unpack(env_instant.diff)))
        self.byCaption["Specular Light"]:setColour(vector3(unpack(env_instant.spec)))
        self.byCaption["Cloud Coverage"]:setValue(("%0.3f"):format(env_instant.cloudCoverage))
        self.byCaption["Cloud Colour"]:setColour(vector3(unpack(env_instant.cloudColour)))
        self.byCaption["Sun Size"]:setValue(("%0.3f"):format(env_instant.sunSize))
        self.byCaption["Sun Colour"]:setColour(vector3(unpack(env_instant.sunColour,1,3)), unpack(env_instant.sunColour,4,4))
        self.byCaption["Saturation"]:setValue(("%0.3f"):format(env_instant.saturation))
        self.byCaption["Sun Glare"]:setValue(("%2.0f"):format(env_instant.sunGlareDistance))
        self.byCaption["Horizon Glare"]:setValue(("%2.0f"):format(env_instant.horizonGlareElevation))
    end;

    destroy = function(self)
        self.contents = safe_destroy(self.contents)
        self.marker = safe_destroy(self.marker)
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

    frameCallback = function (self, elapsed)
        self.marker.alpha = math.sin(math.rad(seconds()*360)) + 1
    end;
        
})
