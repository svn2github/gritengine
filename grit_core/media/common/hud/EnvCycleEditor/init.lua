-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--[[
TODO:
* Colour copy/paste
--]]

hud_class "../ColourPicker" {

    init = function (self)
        self.alpha = 0

        local on_change = function() self:childChanged() end

        local scalesz = vec(388,20)
        local labsz = vec(41,20)

        self.hueScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgTexture="EnvCycleEditor/bg_hue.png",   bgColour=vec(1,1,1) })
        self.satScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgColour=vector3(1,0,0), mgTexture="EnvCycleEditor/bg_sat.png", mgAlpha=1 })
        self.valScale = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, bgTexture="EnvCycleEditor/bg_val.png",   bgColour=vec(1,1,1), mgTexture="EnvCycleEditor/bg_val_simple.png", mgAlpha=0, mgColour=vec(1,1,1), gamma=true, maxValue=10 })
        self.aScale   = gfx_hud_object_add("Scale", { onChange = on_change, size=scalesz, mgTexture="EnvCycleEditor/bg_alpha.png", mgColour=vec(1,1,1), mgAlpha=1, bgColour=vec(1,1,1) })

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
        self.hGreyed = not not self.hGreyed
        self.sGreyed = not not self.sGreyed
        self.vGreyed = not not self.vGreyed

    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        self.hueScale:setGreyed(self.greyed or self.hGreyed)
        self.hueLabel:setGreyed(self.greyed or self.hGreyed)
        self.satScale:setGreyed(self.greyed or self.sGreyed)
        self.satLabel:setGreyed(self.greyed or self.sGreyed)
        self.valScale:setGreyed(self.greyed or self.vGreyed)
        self.valLabel:setGreyed(self.greyed or self.vGreyed)
        self.aScale:setGreyed(self.greyed or self.aGreyed)
        self.aLabel:setGreyed(self.greyed or self.aGreyed)
    end;

    destroy = function (self)
        self.contents = safe_destroy(self.contents)
    end;

    updateBgColour = function (self)
        local hsv = self:getColourHSV()
        if hsv == nil then
            self.satScale:setBackgroundColour(vec(1,1,1))
            self.valScale:setBackgroundColour(vec(1,1,1))
            self.aScale:setBackgroundColour(vec(1,1,1))
        else
            self.satScale:setBackgroundColour(HSVtoRGB(vec(hsv.x, 1, 1)))
            self.valScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, 1)))
            self.aScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, math.min(1,hsv.z))))
        end
    end;
    
    childChanged = function (self)
        if self.contents == nil then return end
        self:updateBgColour()
        self:onChange()
    end;
    
    getColourHSV = function (self)
        if self.hGreyed or self.sGreyed or self.vGreyed then return nil end
        return vec(self.hueScale.value, self.satScale.value, self.valScale.value)
    end;
    getColourRGB = function (self)
        if self.hGreyed or self.sGreyed or self.vGreyed then return nil end
        return HSVtoRGB(self:getColourHSV())
    end;
    setColourRGB = function (self, c)
        self.valScale.maxValue = 10
        self.valScale:setMidgroundAlpha(0)
        self.valScale:setGamma(true)
        if c == nil then
            self.hGreyed = true
            self.sGreyed = true
            self.vGreyed = true
            self.hueScale:setValue(0)
            self.satScale:setValue(0)
            self.valScale:setValue(1)
        else
            local hsv = RGBtoHSV(c)
            self.hGreyed = false
            self.sGreyed = false
            self.vGreyed = false
            self.hueScale:setValue(hsv.x)
            self.satScale:setValue(hsv.y)
            self.valScale:setValue(hsv.z)
            self:updateBgColour()
        end
        self:updateAppearance()
    end;
    setValue = function (self, v, max_value)
        self.valScale.maxValue = max_value
        self.valScale:setMidgroundAlpha(1)
        self.valScale:setGamma(false)
        self.hGreyed = true
        self.sGreyed = true
        self.vGreyed = false
        self.aGreyed = true
        self.hueScale:setValue(0)
        self.satScale:setValue(0)
        self.valScale:setValue(v)
        self:updateBgColour()
        self:updateAppearance()
    end;
    getValue = function (self)
        if self.vGreyed then return nil end
        return self.valScale.value
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

local caption_to_env = {
    ["Grad1"] = "grad1",
    ["Grad2"] = "grad2",
    ["Grad3"] = "grad3",
    ["Grad4"] = "grad4",
    ["Grad5"] = "grad5",
    ["Grad6"] = "grad6",
    ["Sun Grad1"] = "sunGrad1",
    ["Sun Grad2"] = "sunGrad2",
    ["Sun Grad3"] = "sunGrad3",
    ["Sun Grad4"] = "sunGrad4",
    ["Sun Grad5"] = "sunGrad5",
    ["Sun Grad6"] = "sunGrad6",
    ["Cloud Colour"] = "cloudColour",
    ["Cloud Coverage"] = "cloudCoverage",
    ["Diffuse Light"] = "diffuseLight",
    ["Specular Light"] = "specularLight",
    ["Particle Light"] = "particleLight",
    ["Fog Colour"] = "fogColour",
    ["Fog Density"] = "fogDensity",
    ["Horizon Glare"] = "horizonGlare",
    ["Sun Glare"] = "sunGlare",
    ["Light Source"] = "lightSource",
    ["Saturation"] = "saturation",
    ["Sun Colour"] = "sunColour",
    ["Sun Size"] = "sunSize",
    ["Sun Falloff"] = "sunFalloff",
}

hud_class "../EnvCycleEditor" (extends (BorderPane) {

    borderColour=vector3(0,0,0),

    colour=vector3(0,0,0),

    alpha=0.7,

    -- WAYS TO INTERACT:
    -- * change time, requires update of colours in controls and colour picker
    -- * type in value
    -- * load
    -- * drag colourpicker slider / type in value in the colour picker

    -- Updates colour picker with correct colour and greyness
    updateEnvValue = function (self, caption)
        local control = self.byCaption[caption]
        if control == nil then
            self.colourPicker:setColourRGB(nil)
            self.colourPicker:setAlpha(nil)
            return
        end
        -- disable currentlyClicked in order to stop infinite recursion
        local cc = self.currentlyClicked
        self.currentlyClicked = nil
        if control.className == "/common/hud/ColourControl" then
            if control.needsAlpha then
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(control.a)
            else
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(nil)
            end
        elseif control.className == "/common/hud/ValueControl" then
            self.colourPicker:setValue(control.value, control.maxValue)
        else
            echo("Did not expect: "..caption)
        end
        self.currentlyClicked = cc
    end;
    
    -- Called when clicking on the label or the actual value.
    -- Changes the selected control, unselects everything, or
    -- toggles enums
    controlClicked = function (self, caption)
        if caption == nil then
            -- grey out the fucker
            self.marker.enabled = false
            self.currentlyClicked = nil
            self:updateEnvValue(caption)
            return
        end
        local control = self.byCaption[caption]

        if control.className == "/common/hud/ColourControl" then
            self:updateEnvValue(caption)
            self.currentlyClicked = caption
            self.marker.position = control.derivedPosition - self.derivedPosition - vec(63,0)
            self.marker.enabled = true
        elseif control.className == "/common/hud/EnumControl" then
            control:advanceValue()
            local name = caption_to_env[caption]
            self:currentInstant()[name] = control:getTextValue():upper()
            env_recompute()
            --self:controlClicked(nil)
        elseif control.className == "/common/hud/ValueControl" then
            self:updateEnvValue(caption)
            self.currentlyClicked = caption
            self.marker.position = control.derivedPosition - self.derivedPosition - vec(63,0)
            self.marker.enabled = true
        else
            error("Unknown type of control.")
        end
    end;

    -- the user has changed the colour in the colour picker
    colourPickerChanged = function (self)
        if self.currentlyClicked == nil then return end
        local caption = self.currentlyClicked
        local control = self.byCaption[caption]

        -- set actual sky colour
        local name = caption_to_env[caption]
        if control.className == "/common/hud/ColourControl" then
            control:setColour(self.colourPicker:getColourRGB(), self.colourPicker:getAlpha())
            if control.a ~= nil then
                self:currentInstant()[name] = vec4(control.colour.xyz, control.a)
            else
                self:currentInstant()[name] = vec3(control.colour)
            end
        elseif control.className == "/common/hud/ValueControl" then
            control:setValue(self.colourPicker:getValue())
            self:currentInstant()[name] = tonumber(control.value)
        else
            error("Unrecognised control classname: "..control.className)
        end
        env_recompute()
    end;

    -- the user has changed the value in a value control
    valueChanged = function (self, caption)
        local control = self.byCaption[caption]

        -- set actual sky colour
        local name = caption_to_env[caption]
        if control.className == "/common/hud/ColourControl" then
            if control.a ~= nil then
                self:currentInstant()[name] = vec4(control.colour, control.a)
            else
                self:currentInstant()[name] = control.colour
            end
            self:updateEnvValue(caption)
            env_recompute()
        elseif control.className == "/common/hud/ValueControl" then
            self:currentInstant()[name] = tonumber(control.value)
            self:updateEnvValue(caption)
            env_recompute()
        else
            error("Unrecognised control classname: "..control.className)
        end
        env_recompute()
    end;

    currentInstant = function (self)
        return env_cycle[self.editIndex or 1] or env_cycle[1]
    end;

    controlEditting = function (self, control)
        self:controlClicked(control.caption)
    end;

    init = function (self)
        BorderPane.init(self)
        
        self.needsInputCallbacks = true
        self.needsFrameCallbacks = true

        self.editIndex = 1
        
        self.byCaption = { }
        local function add (kind, caption, tab)
            local base = {
                size = vector2(136,20);
                width = 40;
                caption = caption;
                maxLength = 5;
                onClick = function() self:controlClicked(caption) end;
                onChange = function(self2) self:valueChanged(self2.caption) end;
                onEditting = function(self2, editting) if editting then self:controlEditting(self2) end end;
            }
            local o = gfx_hud_object_add(kind, extends (base) (tab or { }))
            self.byCaption[caption] = o
            return o
        end
        
        self.title = gfx_hud_text_add("/common/fonts/Impact24")
        self.title.text = "Environment Cycle Editor"

        self.colourPicker = gfx_hud_object_add("ColourPicker", { onChange = function () self:colourPickerChanged() end } )
        
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
        self.loadButton = gfx_hud_object_add("Button", {
            caption = "Load";
            pressedCallback = function (self2)
                self:load()
            end;
            size = vec(48,20);
        })
        self.saveButton = gfx_hud_object_add("Button", {
            caption = "Save";
            pressedCallback = function (self2)
                self:save()
            end;
            size = vec(48,20);
        })
        self.fileName = gfx_hud_object_add("EditBox", {
            value = "/my_env_cycle.lua";
            size = vec(310,20);
            alignment = "LEFT";
        })
        self.topControls = gfx_hud_object_add("StackX", {
            padding = 8,
            
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
                    add("ColourControl", "Particle Light"),
                    add("ColourControl", "Diffuse Light"),
                    add("ColourControl", "Specular Light"),
                    add("ValueControl", "Saturation", {number=true, maxValue=1}),
                    add("EnumControl",  "Light Source", { options={"Sun","Moon"} }),
                }),
            }),
        })
        self.bottomControls = gfx_hud_object_add("StackX", {
            padding = 10,
            gfx_hud_object_add("StackY", {
                padding=4,
                gfx_hud_object_add("StackY", {
                    padding = -1;
                    add("ColourControl", "Fog Colour"),
                    add("ValueControl", "Fog Density", {number=true, maxValue=1}),
                    add("ValueControl",  "Cloud Coverage", {number=true, maxValue=1}),
                }),
            }),
            gfx_hud_object_add("StackY", {
                gfx_hud_object_add("StackY", {
                    padding = -1;
                    add("ValueControl",  "Horizon Glare", {number=true, maxValue=90, format="%3.1f"}),
                    add("ValueControl", "Sun Glare", {number=true, maxValue=100, format="%3.1f"}),
                    add("ColourControl", "Cloud Colour"),
                }),
            }),
            gfx_hud_object_add("StackY", {
                padding = 4;
                gfx_hud_object_add("StackY", {
                    padding = -1;
                    add("ValueControl",  "Sun Size", {number=true, maxValue=10, format="%2.2f"}),
                    add("ValueControl",  "Sun Falloff", {number=true, maxValue=10, format="%2.2f"}),
                    add("ColourControl", "Sun Colour", { needsAlpha = true } ),
                }),
            }),
        })
        self.contents = gfx_hud_object_add("StackY", {
            parent=self, 
            padding = 0,

            gfx_hud_object_add("StackX", {
                padding = 0,
                self.title,
                vector2(80,0),
                self.timeLabel,
                vector2(2,0),
                self.timeLeftButton,
                self.timeRightButton,
            }),

            vector2(0,10),

            self.colourPicker,
            
            vector2(0,10),

            self.topControls,
            
            vector2(0,10),
            
            self.bottomControls,

            vector2(0,10),
            
            gfx_hud_object_add("StackX", {
                padding = 0,
                self.fileName,
                vector2(8,0),
                self.loadButton,
                vector2(8,0),
                self.saveButton
            }),

        })

        self.marker = gfx_hud_object_add("Rect", { parent=self, texture="EnvCycleEditor/marker.png", zOrder=6})

        self.size = self.contents.size + vector2(16,16)
        self:updateChildrenSize()

        self:controlClicked("Grad6")

        self:updateFromEnvCycle()
    end;

    -- direction 1 or -1
    timeChange = function (self, direction)
        self.editIndex = self.editIndex + direction
        if self.editIndex < 1 then self.editIndex = #env_cycle end
        if self.editIndex > #env_cycle then self.editIndex = 1 end
        self:updateFromEnvCycle()
        env.secondsSinceMidnight = self:currentInstant().time * 60 * 60
    end;

    setClosestToTime = function (self, hours)
        if hours < 0 or hours >= 24 then error("Invalid time in hours: "..hours) end
        -- TODO: write me
        local the_env = nil
        local hours_dist = 12
        for i,env_cycle_instant in ipairs(env_cycle) do
            local dist = math.abs(env_cycle_instant.time - hours)
            if dist > 12 then dist = 24 - dist end
            if dist < hours_dist then
                hours_dist = dist
                the_env = i
            end
        end
        self.editIndex = the_env
        self:updateFromEnvCycle()
        env.secondsSinceMidnight = env_cycle[the_env].time * 60 * 60
    end;

    updateFromEnvCycle = function (self)
        local env_instant = self:currentInstant()
        self.timeLabel:setValue(format_time(env_instant.time * 60 * 60))

        for i=1,6 do
            self.byCaption["Grad"..i]:setColour(env_instant["grad"..i])
        end
        for i=1,6 do
            self.byCaption["Sun Grad"..i]:setColour(env_instant["sunGrad"..i])
        end
        self.byCaption["Fog Colour"]:setColour(env_instant.fogColour)
        self.byCaption["Fog Density"]:setValue(env_instant.fogDensity)
        self.byCaption["Particle Light"]:setColour(env_instant.particleLight)
        self.byCaption["Diffuse Light"]:setColour(env_instant.diffuseLight)
        self.byCaption["Specular Light"]:setColour(env_instant.specularLight)
        self.byCaption["Cloud Coverage"]:setValue(env_instant.cloudCoverage)
        self.byCaption["Cloud Colour"]:setColour(env_instant.cloudColour)
        self.byCaption["Sun Size"]:setValue(env_instant.sunSize)
        self.byCaption["Sun Falloff"]:setValue(env_instant.sunFalloff)
        self.byCaption["Sun Colour"]:setColour(env_instant.sunColour)
        self.byCaption["Saturation"]:setValue(env_instant.saturation)
        self.byCaption["Sun Glare"]:setValue(env_instant.sunGlare)
        self.byCaption["Horizon Glare"]:setValue(env_instant.horizonGlare)
        self.byCaption["Light Source"]:setValue(env_instant.lightSource == "SUN" and 1 or 2)

        self:controlClicked(self.currentlyClicked)
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
        self.marker.alpha = math.sin(math.rad(seconds()*360*2)) + 1
    end;

    load = function (self)
        xpcall(function()
            local filename = self.fileName.value
            include(filename)
            echo("Read env cycle from \""..filename.."\"")
            self:updateFromEnvCycle()
            env_recompute()
        end, error_handler)
    end;

    save = function (self)
        xpcall(function()
            local filename = self.fileName.value
            if filename:sub(1,1) ~= "/" then
                error("Filename must be absolute path.")
            end
            filename = filename:sub(2)
            local f = io.open(filename, "w")
            if f==nil then error("Could not open file", 1) end
            f:write("env_cycle = ")
            f:write(dump(env_cycle, false))
            f:close()
            echo("Wrote env cycle to \"/"..filename.."\"")
        end, error_handler)
    end;
        
})
