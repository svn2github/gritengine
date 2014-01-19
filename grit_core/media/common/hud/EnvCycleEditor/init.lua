-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

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
    updateColourPicker = function (self, control)
        if control == nil then
            self.colourPicker:setColourRGB(nil)
            self.colourPicker:setAlpha(nil)
            return
        end
        -- disable currentlyClicked in order to stop infinite recursion
        if control.className == "/common/hud/controls/ColourControl" then
            if control.needsAlpha then
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(control.a)
            else
                self.colourPicker:setColourRGB(control.colour)
                self.colourPicker:setAlpha(nil)
            end
        elseif control.className == "/common/hud/controls/ValueControl" then
            self.colourPicker:setValue(control.value, control.maxValue)
        else
            echo("Did not expect: "..control.caption)
        end
    end;
    
    -- Called when clicking on the label or the actual value.
    -- Changes the selected control, unselects everything, or
    -- toggles enums
    controlClicked = function (self, caption)
        if caption == nil then
            -- grey out the fucker
            self.marker.parent = self
            self.marker.enabled = false
            self.currentlyClicked = nil
            self:updateColourPicker(nil)
            return
        end
        local control = self.byCaption[caption]

        if control.className == "/common/hud/controls/ColourControl" then
            self:updateColourPicker(control)
            self.currentlyClicked = caption
            self.marker.parent = control
            if control.caption:sub(1,7) == "Palette" then
                self.marker.position = vec(0, control.size.y/2-4)
            else
                self.marker.position = vec(-control.size.x/2+4, 0)
            end
            self.marker.enabled = true
        elseif control.className == "/common/hud/controls/EnumControl" then
            control:advanceValue()
        elseif control.className == "/common/hud/controls/ValueControl" then
            self:updateColourPicker(control)
            self.currentlyClicked = caption
            self.marker.parent = control
            self.marker.position = vec(0, control.size.y+4/2)
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
        if control.className == "/common/hud/controls/ColourControl" then
            control:setColour(self.colourPicker:getColourRGB(), self.colourPicker:getAlpha())
            if name ~= nil then
                if control.a ~= nil then
                    self:currentInstant()[name] = vec4(control.colour.xyz, control.a)
                else
                    self:currentInstant()[name] = vec3(control.colour)
                end
                env_recompute()
            end
        elseif control.className == "/common/hud/controls/ValueControl" then
            control:setValue(self.colourPicker:getValue())
            self:currentInstant()[name] = tonumber(control.value)
            env_recompute()
        else
            error("Unrecognised control classname: "..control.className)
        end
    end;

    -- the user has changed the value in a value control
    valueChanged = function (self, caption)
        local control = self.byCaption[caption]

        -- set actual sky colour
        local name = caption_to_env[caption]
        if control.className == "/common/hud/controls/ColourControl" then
            local colour
            if control.a ~= nil then
                colour = vec4(control.colour, control.a)
            else
                colour = control.colour
            end
            if name ~= nil then
                self:currentInstant()[name] = colour
                env_recompute()
            end
            self:updateColourPicker(control)
        elseif control.className == "/common/hud/controls/ValueControl" then
            self:currentInstant()[name] = tonumber(control.value)
            self:updateColourPicker(control)
            env_recompute()
        elseif control.className == "/common/hud/controls/EnumControl" then
            self:currentInstant()[name] = control:getTextValue():upper()
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
            local o = gfx_hud_object_add("controls/"..kind, extends (base) (tab or { }))
            self.byCaption[caption] = o
            return o
        end
        
        self.title = gfx_hud_text_add("/common/fonts/Impact24")
        self.title.text = "Environment Cycle Editor"
        self.title.orientation = -90

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
            size = vec(316,20);
            alignment = "LEFT";
        })
        self.contents = gfx_hud_object_add("StackY", {
            padding = 0,

            gfx_hud_object_add("StackX", {
                padding = -1,
                gfx_hud_object_add("/common/hud/Label", { size=vec(50,20), value="Palette" }),
                add("ColourControl", "Palette1", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette2", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette3", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette4", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette5", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette6", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette7", { needsAlpha = true, showCaption = false } ),
                add("ColourControl", "Palette8", { needsAlpha = true, showCaption = false } ),
                vector2(16,0),
                self.timeLabel,
                vector2(2,0),
                self.timeLeftButton,
                self.timeRightButton,
            }),

            vector2(0,12),

            gfx_hud_object_add("StackX", {
                gfx_hud_object_add("StackY", {
                    padding = 0,

                    self.colourPicker,
                    
                    vector2(0,12),

                    gfx_hud_object_add("StackX", {
                        padding = 6,
                        
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
                    }),
                    
                    vector2(0,6),
                    
                    gfx_hud_object_add("StackX", {
                        padding = 6,
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
                    }),

                    vector2(0,12),
                    
                    gfx_hud_object_add("StackX", {
                        padding = 0,
                        self.fileName,
                        vector2(4,0),
                        self.loadButton,
                        vector2(4,0),
                        self.saveButton
                    }),
                }),

                vec(8,0),

                { "BOTTOM", self.title, }
            }),

        })
        self.contents.parent = self

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
