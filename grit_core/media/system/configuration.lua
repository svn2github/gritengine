-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print "Loading user configuration"

safe_include `/user_cfg.lua`

user_cfg = user_cfg or { }
debug_cfg = debug_cfg or { }
user_system_bindings = user_system_bindings or { }
user_editor_core_bindings = user_editor_core_bindings or { }
user_editor_edit_bindings = user_editor_edit_bindings or { }
user_editor_debug_bindings = user_editor_debug_bindings or { }
user_drive_bindings = user_drive_bindings or { }
user_foot_bindings = user_foot_bindings or { }


local user_cfg_default = {
    shadowRes = 1024;
    shadowEmulatePCF = false;
    shadowFilterTaps = 4;
    shadowFilterSize = 4;
    shadowFilterNoise = true;
    shadowFilterDither = false;
    shadowPCSSPadding = 0.8;
    shadowPCSSStart = 0.2;
    shadowPCSSEnd0 = 20;
    shadowPCSSEnd1 = 50;
    shadowPCSSEnd2 = 200;
    shadowPCSSAdj0 = 3;
    shadowPCSSAdj1 = 1;
    shadowPCSSAdj2 = 1;
    shadowPCSSSpreadFactor0 = 1;
    shadowPCSSSpreadFactor1 = 1;
    shadowPCSSSpreadFactor2 = 0.28;
    shadowFadeStart = 150;
    fullscreen = false;
    res = {800,600};
    visibility = 1;
    graphicsRAM = 512;
    lockMemory = true;
    screenshotFormat = "png";
    mouseInvert = true;
    mouseSensitivity = 0.06;
    vsync = true;
    anaglyph = false;
    crossEye = false;
    eyeSeparation = 0.06;
    monitorHeight = 0.27;
    monitorEyeDistance = 0.6;
    minPerceivedDepth = 0.3;
    maxPerceivedDepth = 2;
    anaglyphDesaturation = 0.5;
    anaglyphLeftMask = {1,0,0};
    anaglyphRightMask = {0,1,1};
    lowPowerMode = false;
    metricUnits = false;
    audioMasterVolume = 1;
    vehicleCameraTrack = true;
}

local user_cfg_doc = {
    shadowRes = "resolution of the shadow textures";
    shadowEmulatePCF = "antialias shadow edges";
    shadowFilterTaps = "quality of soft shadows";
    shadowFilterSize = "size of penumbra";
    shadowFilterNoise = "a cheap way of getting softer shadows";
    shadowFilterDither = "another cheap way of getting softer shadows";
    shadowPCSSPadding = "overlap between shadow regions";
    shadowPCSSStart = "distance from camera where shadows start";
    shadowPCSSEnd0 = "distance from camera to transition to 2nd shadow map";
    shadowPCSSEnd1 = "distance from camera to transition to 3rd shadow map";
    shadowPCSSEnd2 = "distance from camera where shadows end";
    shadowPCSSAdj0 = "'optimal adjust' for 1st shadow map";
    shadowPCSSAdj1 = "'optimal adjust' for 2nd shadow map";
    shadowPCSSAdj2 = "'optimal adjust' for 3rd shadow map";
    shadowPCSSSpreadFactor0 = "penumbra multiplier for 1st shadow map";
    shadowPCSSSpreadFactor1 = "penumbra multiplier for 2st shadow map";
    shadowPCSSSpreadFactor2 = "penumbra multiplier for 3rd shadow map";
    shadowFadeStart = "distance where shadow starts to fade";
    fullscreen = "as opposed to windowed mode";
    res = "desktop resolution when fullscreened";
    visibility = "factor on draw distance";
    graphicsRAM = "Size of textures+mesh cache to maintain";
    lockMemory = "avoids excessive disk IO";
    screenshotFormat = "format in which to store textures";
    mouseInvert = "whether forward motion should look down";
    mouseSensitivity = "how easy it is to turn with mouse";
    vsync = "avoid corruption due to out of sync monitor updates";
    anaglyph = "todo";
    crossEye = "todo";
    eyeSeparation = "todo";
    monitorHeight = "todo";
    monitorEyeDistance = "todo";
    minPerceivedDepth = "todo";
    maxPerceivedDepth = "todo";
    anaglyphDesaturation = "todo";
    anaglyphLeftMask = "todo";
    anaglyphRightMask = "todo";
    lowPowerMode = "Reduce FPS and physics accuracy";
    metricUnits = "Use the km/h units instead of mph units for HUD";
    audioMasterVolume = "Master audio volume";
    vehicleCameraTrack = "Camera automatically follows vehicles";
}

local user_cfg_spec = {
    shadowRes = { "one of", 128,256,512,1024,2048,4096 };
    shadowEmulatePCF = { "one of", false, true };
    shadowFilterTaps = { "one of", 1, 4, 9, 16, 25, 36 };
    shadowFilterSize = { "range", 0, 40 };
    shadowFilterNoise = { "one of", false, true };
    shadowFilterDither = { "one of", false, true };
    shadowPCSSPadding = { "range", 0, 100 };
    shadowPCSSStart = { "range", 0, 10000 };
    shadowPCSSEnd0 = { "range", 0, 10000 };
    shadowPCSSEnd1 = { "range", 0, 10000 };
    shadowPCSSEnd2 = { "range", 0, 10000 };
    shadowPCSSAdj0 = { "range", 0, 10000 };
    shadowPCSSAdj1 = { "range", 0, 10000 };
    shadowPCSSAdj2 = { "range", 0, 10000 };
    shadowPCSSSpreadFactor0 = { "range", 0, 20 };
    shadowPCSSSpreadFactor1 = { "range", 0, 20 };
    shadowPCSSSpreadFactor2 = { "range", 0, 20 };
    shadowFadeStart = { "range", 0, 10000 };
    res = { "table", 2, {"int range", 1, 4096}, {"int range", 1, 4096} };
    fullscreen = { "one of", false, true };
    visibility = { "range", 0, 5 }; 
    graphicsRAM = { "int range", 0, 2048 };
    lockMemory = { "one of", false, true };
    screenshotFormat = { "one of", "png","tga" };
    mouseInvert = { "one of", false, true };
    mouseSensitivity = { "range", 0, 10 };
    vsync = { "one of", false, true };
    anaglyph =  { "one of", false, true };
    crossEye =  { "one of", false, true };
    eyeSeparation =  { "range", 0, 0.5 }; 
    monitorHeight = { "range", 0.01, 1000 }; 
    monitorEyeDistance =  { "range", 0.01, 1000 }; 
    minPerceivedDepth =  { "range", 0.01, 1000 }; 
    maxPerceivedDepth =  { "range", 0.01, 1000 }; 
    anaglyphDesaturation =  { "range", 0, 1 }; 
    anaglyphLeftMask = { "table", 3, {"range", 0, 1}, {"range", 0, 1} };
    anaglyphRightMask =  { "table", 3, {"range", 0, 1}, {"range", 0, 1} };
    lowPowerMode = { "one of", false, true };
    metricUnits = { "one of", false, true };
    audioMasterVolume =  { "range", 0, 1 }; 
    vehicleCameraTrack = { "one of", false, true };
}
            

local debug_cfg_default = {
    shadowCast = true;
    shadowReceive = true;
    vertexProcessing = true;
    textureFetches = true;
    fragmentProcessing = true;
    heightmapBlending = true;
    falseColour = false;
    normalMaps = true;
    diffuseMaps = true;
    glossMaps = true;
    translucencyMaps = true;
    colourMaps = true;
    vertexDiffuse = true;
    fog = true;
    FOV = 55;
    farClip = 800;
    polygonMode = "SOLID";
    physicsWireFrame = false;
    physicsDebugWorld = true;
    textureAnimation = true;
    textureScale = true;
    shadingModel = "SHARP";
}

local debug_cfg_doc = {
    shadowCast = "enable casting phase";
    shadowReceive = "enable receiving phase";
    vertexProcessing = "for eliminating vertex shader work";
    textureFetches = "use proper fetches instead of procedural placeholders";
    fragmentProcessing = "for eliminating fragment shader work";
    heightmapBlending = "whether to use the heightmap when blending";
    falseColour = "various debug displays";
    normalMaps = "whether to use normal maps";
    diffuseMaps = "whether to use diffuse maps";
    glossMaps = "whether to use gloss maps";
    translucencyMaps = "whether to use translucency maps";
    colourMaps = "whether to use colour maps";
    vertexDiffuse = "whether to use the diffuse channel in the meshes";
    fog = "enable distance fog";
    FOV = "field of view in degrees";
    farClip = "how far away is maximum depth";
    polygonMode = "wireframe, etc";
    physicsWireFrame = "show physics meshes";
    physicsDebugWorld = "don't limit debug display to moving objects";
    textureAnimation = "whether or not to animate textures";
    textureScale = "enable support for texture scaling from materials";
    shadingModel = "the way lighting is calculated";
}

local debug_cfg_spec = {
    shadowCast = { "one of", false, true };
    shadowReceive = { "one of", false, true };
    vertexProcessing = { "one of", false, true };
    textureFetches = { "one of", false, true };
    fragmentProcessing = { "one of", false, true };
    heightmapBlending = { "one of", false, true };
    falseColour = { "one of", false, "UV", "UV_STRETCH", "UV_STRETCH_BANDS", "NORMAL", "OBJECT_NORMAL", "NORMAL_MAP", "TANGENT", "BINORMAL", "UNSHADOWYNESS", "GLOSS", "SPECULAR", "SPECULAR_TERM", "SPECULAR_COMPONENT", "HIGHLIGHT", "FRESNEL", "FRESNEL_HIGHLIGHT", "DIFFUSE_COLOUR", "DIFFUSE_TERM", "DIFFUSE_COMPONENT", "VERTEX_COLOUR", "ENV_DIFFUSE_COMPONENT", "ENV_SPECULAR_COMPONENT", "ENV_DIFFUSE_LIGHT", "ENV_SPECULAR_LIGHT" };
    polygonMode = { "one of", "SOLID", "SOLID_WIREFRAME", "WIREFRAME" };
    normalMaps = { "one of", false, true };
    diffuseMaps = { "one of", false, true };
    glossMaps = { "one of", false, true };
    translucencyMaps = { "one of", false, true };
    colourMaps = { "one of", false, true };
    vertexDiffuse = { "one of", false, true };
    fog = { "one of", false, true };
    FOV = { "range", 0, 120 };
    farClip = { "range", 1, 10000 };
    physicsWireFrame = { "one of", false, true };
    physicsDebugWorld = { "one of", false, true };
    textureAnimation = { "one of", false, true };
    textureScale = { "one of", false, true };
    shadingModel = { "one of", "SHARP", "HALF_LAMBERT", "WASHED_OUT" };
}



local default_user_system_bindings = {
    menu = "Escape";
    console = "Tab";
    screenShot = "F12";
}

local default_user_drive_bindings = {
    driveForwards = "w";
    driveBackwards = "s";
    driveLeft = "a";
    driveRight = "d";
    driveSpecialLeft = "q";
    driveSpecialRight = "e";
    driveSpecialUp = "PageUp";
    driveSpecialDown = "PageDown";
    driveAltUp = "Up";
    driveAltDown = "Down";
    driveAltLeft = "Left";
    driveAltRight = "Right";
    driveAbandon = "f";
    driveHandbrake = "Space";
    driveLights = "l";
    driveZoomIn = {"up","S+v"};
    driveZoomOut = {"down","v"};
    driveCamera = "c";
    driveSpecialToggle = "BackSpace";
}

local default_user_foot_bindings = {
    walkForwards = "w";
    walkBackwards = "s";
    walkLeft = "a";
    walkRight = "d";
    walkBoard = "f";
    walkJump = "Space";
    walkCrouch = "c";
    walkRun = "Shift";
    walkZoomIn = {"up","S+v"};
    walkZoomOut = {"down","v"};
    walkCamera = "c";
}

local default_user_editor_core_bindings = {
    debug = "F5";
    ghost = "right";
    forwards = "w";
    backwards = "s";
    strafeLeft = "a";
    strafeRight = "d";
    ascend = "Space";
    descend = "Shift";
    -- TODO: need some way of going faster
}

local default_user_editor_edit_bindings = {
    delete = "Delete";
    duplicate = "C+d";
    select = "left";
}

local default_user_editor_debug_bindings = {
    board = "f";
}


--[[
local drive_binding_functions = {
    forwards = {function() player_ctrl.controlObj:setPush(true) end, function() player_ctrl.controlObj:setPush(false) end};
    backwards = {function() player_ctrl.controlObj:setPull(true) end, function() player_ctrl.controlObj:setPull(false) end};
    steerLeft = {function() player_ctrl.controlObj:setShouldSteerLeft(true) end, function() player_ctrl.controlObj:setShouldSteerLeft(false) end};
    steerRight = {function() player_ctrl.controlObj:setShouldSteerRight(true) end, function() player_ctrl.controlObj:setShouldSteerRight(false) end};
    abandon = function() player_ctrl:abandonControlObj() end;
    handbrake = {function() player_ctrl.controlObj:setHandbrake(true) end, function() player_ctrl.controlObj:setHandbrake(false) end};
    lights = {function() player_ctrl.controlObj:setLights() end, nil, true};
    boost = {function() player_ctrl.controlObj:setBoost(true) end, function() player_ctrl.controlObj:setBoost(false) end};
    zoomIn = {function() player_ctrl.controlObj:controlZoomIn() end, nil, true};
    zoomOut = {function() player_ctrl.controlObj:controlZoomOut() end, nil, true};
    camera = {function() if player_ctrl.controlObj.controlUpdate == regular_chase_cam_update then
                            player_ctrl.controlObj.controlUpdate = top_down_cam_update
                         elseif player_ctrl.controlObj.controlUpdate == top_down_cam_update then
                            player_ctrl.controlObj.controlUpdate = top_angled_cam_update
                         else
                            player_ctrl.controlObj.controlUpdate = regular_chase_cam_update
                         end
              end, nil, true};
    realign = {function() player_ctrl.controlObj:realign() end, nil, true};
    specialUp = {function() player_ctrl.controlObj:setSpecialUp(true) end, function() player_ctrl.controlObj:setSpecialUp(false) end};
    specialDown = {function() player_ctrl.controlObj:setSpecialDown(true) end, function() player_ctrl.controlObj:setSpecialDown(false) end};
    specialLeft = {function() player_ctrl.controlObj:setSpecialLeft(true) end, function() player_ctrl.controlObj:setSpecialLeft(false) end};
    specialRight = {function() player_ctrl.controlObj:setSpecialRight(true) end, function() player_ctrl.controlObj:setSpecialRight(false) end};
    altUp = {function() player_ctrl.controlObj:setAltUp(true) end, function() player_ctrl.controlObj:setAltUp(false) end};
    altDown = {function() player_ctrl.controlObj:setAltDown(true) end, function() player_ctrl.controlObj:setAltDown(false) end};
    altLeft = {function() player_ctrl.controlObj:setAltLeft(true) end, function() player_ctrl.controlObj:setAltLeft(false) end};
    altRight = {function() player_ctrl.controlObj:setAltRight(true) end, function() player_ctrl.controlObj:setAltRight(false) end};
    specialToggle = function() player_ctrl.controlObj:special() end;
}

local foot_binding_functions = {
    forwards = {function() player_ctrl.controlObj:setForwards(true) end, function() player_ctrl.controlObj:setForwards(false) end};
    backwards = {function() player_ctrl.controlObj:setBackwards(true) end, function() player_ctrl.controlObj:setBackwards(false) end};
    strafeLeft = {function() player_ctrl.controlObj:setStrafeLeft(true) end, function() player_ctrl.controlObj:setStrafeLeft(false) end};
    strafeRight = {function() player_ctrl.controlObj:setStrafeRight(true) end, function() player_ctrl.controlObj:setStrafeRight(false) end};
    abandon = function() player_ctrl:abandonControlObj() end;
    jump = {function() player_ctrl.controlObj:setJump(true) end, function() player_ctrl.controlObj:setJump(false) end};
    run = {function() player_ctrl.controlObj:setRun(true) end, function() player_ctrl.controlObj:setRun(false) end};
    crouch = {function() player_ctrl.controlObj:setCrouch(true) end, function() player_ctrl.controlObj:setCrouch(false) end};
    zoomIn = {function() player_ctrl.controlObj:controlZoomIn() end, nil, true};
    zoomOut = {function() player_ctrl.controlObj:controlZoomOut() end, nil, true};
}
]]


local function process_user_table(name, given, default)
    for k, v in pairs(given) do
        if default[k] == nil then
            print(name.." contained unrecognised field \""..k.."\", ignoring.")
            given[k] = nil
        end
    end
    for k, v in pairs(default) do
        if given[k] == nil then
            given[k] = default[k]
        end
    end
end

process_user_table("user_cfg", user_cfg, user_cfg_default)
process_user_table("debug_cfg", debug_cfg, debug_cfg_default)
process_user_table("user_system_bindings", user_system_bindings, default_user_system_bindings)
process_user_table("user_editor_core_bindings", user_editor_core_bindings, default_user_editor_core_bindings)
process_user_table("user_editor_edit_bindings", user_editor_edit_bindings, default_user_editor_edit_bindings)
process_user_table("user_editor_debug_bindings", user_editor_debug_bindings, default_user_editor_debug_bindings)
process_user_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings)
process_user_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings)


local function process_bindings2(bindings, func, input_filter)
    local function bind_it(name, key)
        input_filter:bind(
            key,
            function () func(name, '+') end,
            function () func(name, '-') end,
            function () func(name, '=') end)
    end
    for name, key_or_keys in pairs(bindings) do
        if type(key_or_keys) == "table" then
            for _,key in ipairs(key_or_keys) do
                bind_it(name, key)
            end
        else
            bind_it(name, key_or_keys)
        end
    end
end

local function system_receive_button(button, state)
    if button == "menu" and state == '+' then
        menu:setEnabled(not menu.enabled)
    elseif button == "console" and state == '+' then
        if input_filter_pressed("Ctrl") then
            debug_layer:setEnabled(true)
            debug_layer:selectConsole(true)
            hud_focus_grab(console)
        else
            debug_layer:setEnabled(not debug_layer.enabled)
        end
    elseif button == "screenShot" and state == '+' then
        capturer:singleScreenShot()
    end
end

process_bindings2(user_system_bindings, system_receive_button, system_binds)
process_bindings2(user_editor_core_bindings, editor_receive_button, editor_core_binds)
process_bindings2(user_editor_edit_bindings, editor_receive_button, editor_edit_binds)
process_bindings2(user_editor_debug_bindings, editor_receive_button, editor_debug_binds)

local function play_receive_button(button, state)
    game_manager:receiveButton(button, state)
end

process_bindings2(user_drive_bindings, play_receive_button, playing_vehicle_binds)
process_bindings2(user_foot_bindings, play_receive_button, playing_actor_binds)






local function commit(c, p, flush, partial)

    flush = flush or false
    partial = partial or false

    gfx_option("AUTOUPDATE",false)

    local reset_shaders = false or flush
    local reset_materials = false or flush
    local reset_deferred_shaders = false or flush

    for k,v in pairs(p) do
        if c[k] ~= v then
            c[k] = v
    
            if k == "shadowRes" then
                gfx_option("SHADOW_RES",v)
                reset_shaders = true
            elseif k == "shadowCast" then
                gfx_option("SHADOW_CAST",v)
            elseif k == "shadowReceive" then
                gfx_option("SHADOW_RECEIVE",v)
                reset_materials = true
                reset_deferred_shaders = true
            elseif k == "shadowEmulatePCF" then
                gfx_option("SHADOW_EMULATE_PCF", v)
                reset_shaders = true
            elseif k == "shadowFilterTaps" then
                gfx_option("SHADOW_FILTER_TAPS",v)
                reset_shaders = true
            elseif k == "shadowFilterSize" then
                gfx_option("SHADOW_FILTER_SIZE",v)
                reset_shaders = true
            elseif k == "shadowFilterNoise" then
                gfx_option("SHADOW_FILTER_DITHER_TEXTURE",v)
                reset_shaders = true
                reset_materials = true
            elseif k == "shadowFilterDither" then
                gfx_option("SHADOW_FILTER_DITHER",v)
                reset_shaders = true
            elseif k == "shadowPCSSPadding" then
                gfx_option("SHADOW_PADDING",v)
                reset_shaders = true
            elseif k == "shadowPCSSStart" then
                gfx_option("SHADOW_START",v)
            elseif k == "shadowPCSSEnd0" then
                gfx_option("SHADOW_END0",v)
                reset_shaders = true
            elseif k == "shadowPCSSEnd1" then
                gfx_option("SHADOW_END1",v)
                reset_shaders = true
            elseif k == "shadowPCSSEnd2" then
                gfx_option("SHADOW_END2",v)
                reset_shaders = true
            elseif k == "shadowPCSSAdj0" then
                gfx_option("SHADOW_OPTIMAL_ADJUST0",v)
            elseif k == "shadowPCSSAdj1" then
                gfx_option("SHADOW_OPTIMAL_ADJUST1",v)
            elseif k == "shadowPCSSAdj2" then
                gfx_option("SHADOW_OPTIMAL_ADJUST2",v)
            elseif k == "shadowPCSSSpreadFactor0" then
                gfx_option("SHADOW_SPREAD_FACTOR0", v)
                reset_shaders = true
            elseif k == "shadowPCSSSpreadFactor1" then
                gfx_option("SHADOW_SPREAD_FACTOR1", v)
                reset_shaders = true
            elseif k == "shadowPCSSSpreadFactor2" then
                gfx_option("SHADOW_SPREAD_FACTOR2", v)
                reset_shaders = true
            elseif k == "shadowFadeStart" then
                gfx_option("SHADOW_FADE_START",v)
                reset_shaders = true

            elseif k == "FOV" then
                gfx_option("FOV",v)
            elseif k == "res" then
                gfx_option("FULLSCREEN_WIDTH",v[1])
                gfx_option("FULLSCREEN_HEIGHT",v[2])
            elseif k == "fullscreen" then
                gfx_option("FULLSCREEN",v)
            elseif k == "farClip" then
                gfx_option("FAR_CLIP",v)
            elseif k == "visibility" then
                core_option("VISIBILITY",v)
            elseif k == "vertexProcessing" then
                reset_materials = true
                reset_shaders = true
            elseif k == "textureFetches" then
                reset_shaders = true
            elseif k == "fragmentProcessing" then
                reset_materials = true
                reset_shaders = true
            elseif k == "heightmapBlending" then
                reset_shaders = true
            elseif k == "falseColour" then
                reset_shaders = true
                reset_materials = true
                if v == false then
                    gfx_option("RENDER_PARTICLES", true)
                    gfx_option("RENDER_SKY", true)
                    gfx_option("POINT_LIGHTS", true)
                    gfx_option("POST_PROCESSING", true)
                else
                    gfx_option("RENDER_PARTICLES", false)
                    gfx_option("RENDER_SKY", false)
                    gfx_option("POINT_LIGHTS", false)
                    gfx_option("POST_PROCESSING", false)
                end
        
            elseif k == "graphicsRAM" then
                gfx_option("RAM",v)
                --set_texture_budget(v*1024*1024)
                --set_mesh_budget(0)
            elseif k == "lockMemory" then
                if v then mlockall() else munlockall() end

            elseif k == "polygonMode" then
                gfx_option("WIREFRAME", v~="SOLID")
                gfx_option("WIREFRAME_SOLID", v=="SOLID_WIREFRAME")
            elseif k == "normalMaps" then
                reset_materials = true
            elseif k == "diffuseMaps" then
                reset_materials = true
            elseif k == "glossMaps" then
                reset_materials = true
            elseif k == "translucencyMaps" then
                reset_materials = true
            elseif k == "colourMaps" then
                reset_materials = true
            elseif k == "vertexDiffuse" then
                reset_shaders = true
            elseif k == "textureAnimation" then
                reset_materials = true
            elseif k == "textureScale" then
                reset_materials = true
            elseif k == "fog" then
                gfx_option("FOG",v)
                reset_shaders = true
            elseif k == "physicsWireFrame" then
                print("Physics wire frame: "..(v and "on" or "off"))
                physics_option("DEBUG_WIREFRAME", v)
            elseif k == "physicsDebugWorld" then
                print("Physics debug world: "..(v and "on" or "off"))
                main.physicsDebugWorld = v
            elseif k == "mouseSensitivity" then
                -- next mouse movement picks this up
            elseif k == "mouseInvert" then
                -- next mouse movement picks this up
            elseif k == "vsync" then
                gfx_option("VSYNC",v)
            elseif k == "screenshotFormat" then
                -- nothing to do, next screenshot will pick this up
            elseif k == "shadingModel" then
                reset_shaders = true
            elseif k == "anaglyph" then
                gfx_option("ANAGLYPH",v)
            elseif k == "crossEye" then
                gfx_option("CROSS_EYE",v)
            elseif k == "eyeSeparation" then
                gfx_option("EYE_SEPARATION",v)
            elseif k == "monitorHeight" then
                gfx_option("MONITOR_HEIGHT",v)
            elseif k == "monitorEyeDistance" then
                gfx_option("MONITOR_EYE_DISTANCE",v)
            elseif k == "minPerceivedDepth" then
                gfx_option("MIN_PERCEIVED_DEPTH",v)
            elseif k == "maxPerceivedDepth" then
                gfx_option("MAX_PERCEIVED_DEPTH",v)
            elseif k == "anaglyphDesaturation" then
                gfx_option("ANAGLYPH_DESATURATION",v)
            elseif k == "anaglyphLeftMask" then
                gfx_option("ANAGLYPH_LEFT_RED_MASK",v[1])
                gfx_option("ANAGLYPH_LEFT_GREEN_MASK",v[2])
                gfx_option("ANAGLYPH_LEFT_BLUE_MASK",v[3])
            elseif k == "anaglyphRightMask" then
                gfx_option("ANAGLYPH_RIGHT_RED_MASK",v[1])
                gfx_option("ANAGLYPH_RIGHT_GREEN_MASK",v[2])
                gfx_option("ANAGLYPH_RIGHT_BLUE_MASK",v[3])
            elseif k == "lowPowerMode" then
                -- next frame render picks this up too
                if v then
                    physics_option("STEP_SIZE", 0.05)
                    physics_option("SOLVER_ITERATIONS", 4)
                else
                    physics_option("STEP_SIZE", 0.005)
                    physics_option("SOLVER_ITERATIONS", 15)
                end
            elseif k == "metricUnits" then
                --
            elseif k == "audioMasterVolume" then
                audio_option("MASTER_VOLUME",v)
            elseif k == "vehicleCameraTrack" then
            else
                error("Unexpected: "..k)
            end
        end
    end

    gfx_option("AUTOUPDATE",true)

    if partial then return end

    if reset_deferred_shaders then
        do_reset_deferred_shaders()
    end

    if reset_shaders then
        do_reset_shaders()
    end

    if reset_materials then
        do_reset_materials()
    end
    
end

make_active_table(user_cfg, user_cfg_spec,  commit)
make_active_table(debug_cfg, debug_cfg_spec,  commit)

commit(user_cfg.c, user_cfg.p, false, true)
commit(debug_cfg.c, debug_cfg.p, false, true)
debug_cfg.autoUpdate = true
user_cfg.autoUpdate = true

commit(user_cfg.c, user_cfg.p, true, false)





function save_user_cfg(filename)
    filename = filename or "user_cfg.lua"
    local f = io.open(filename,"w")
    f:write([[
print('Reading user_cfg.lua')

-- This file is output automatically by Grit.
-- You may edit it, but stick to the basic format.
-- Any clever Lua code will be lost.
--
-- WARNING:  If you are changing from a default value
-- to a custom value, don't forget to uncomment the line
-- (remove the leading -- ) otherwise it will not be
-- processed and your changes will be lost.

]])

    local function write_table(table_name, tab, defaults, docs)
        f:write(table_name.." = {\n")
        local names, num, max_name_len = table.keys(tab,100)
        table.sort(names)
        for _,name in ipairs(names) do
            local val = tab[name]
            local dval = defaults[name]
            local doc = docs[name]
            local line = ''
            if val == dval then
                line = line .. "--"
            end
            line = line.."    "..tostring(name)..(" "):rep(max_name_len-#name).." = "..dump(val,false)..";"
            if doc ~= nil then
                local len_so_far = #line
                line = line..(" "):rep(50-len_so_far).."  -- "
                if val ~= dval then
                    line = line .. "DEFAULT: "..dump(dval,false).."  "
                end
                line = line.."("..doc..")"
            end
            f:write(line.."\n")
        end
        f:write("}\n\n")
    end

    -- use proposed rather than current settings, to avoid writing out the autoUpdate header
    write_table("user_cfg", user_cfg.p, user_cfg_default, user_cfg_doc)
    write_table("debug_cfg", debug_cfg.p, debug_cfg_default, debug_cfg_doc)
    write_table("user_system_bindings", user_system_bindings, default_user_system_bindings, {})
    write_table("user_editor_core_bindings", user_editor_core_bindings, default_user_editor_core_bindings, {})
    write_table("user_editor_edit_bindings", user_editor_edit_bindings, default_user_editor_edit_bindings, {})
    write_table("user_editor_debug_bindings", user_editor_debug_bindings, default_user_editor_debug_bindings, {})
    write_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings, {})
    write_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings, {})

    f:close()
end


