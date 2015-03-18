-- size of the whole screen

hud_class `DebugLayer` {

    buttonDescs = { };
    colour = vec(0.1, 0.1, 0.1);
    buttonPadding = vec(16, 4);
    zOrder = 6;

    init = function (self)
        self.needsParentResizedCallbacks = true
        self.buttons = { padding = 10 }

        self.consoleButton = gfx_hud_object_add(`Button`, {
            pressedCallback = function (button) self:onConsolePressed() end;
            caption = "Console";
            orientation = -90;
            padding = self.buttonPadding;
            parent=self;
        })

        for i, desc in ipairs(self.buttonDescs) do
            -- create 
            local panel = desc.panel
            self.buttons[i] = gfx_hud_object_add(`Button`, {
                pressedCallback = function (button) self:onPanePress(i) end;
                caption = desc.name;
                orientation = -90;
                padding = self.buttonPadding;
            })
        end

        self.buttonStack = gfx_hud_object_add(`StackY`, self.buttons)
        self.buttonStack.parent = self

        local sp = self.selectedPane
        self:selectPane(nil)
        self:selectPane(sp)
        self:selectConsole(self.consoleEnabled)

    end;

    onConsolePressed = function (self)
        self:selectConsole(not self.consoleEnabled)
    end;

    onPanePress = function (self, id)
        if self.selectedPane == id then
            self:selectPane(nil)
        else
            self:selectPane(id)
        end
    end;

    selectConsole = function (self, v)
        self.consoleEnabled = v
        console.enabled = self.consoleEnabled and self.enabled
    end;

    hidePane = function (self, pane)
        for name, desc in ipairs(self.buttonDescs) do
            if desc.panel == pane then
                self:selectPane(nil)
            end
        end
        if pane == console then
            self:selectConsole(false)
        end
    end;

    selectPane = function (self, id)
        self.selectedPane = id
        for i, desc in ipairs(self.buttonDescs) do
            local desc = self.buttonDescs[i]
            local should_enable = i == id and self.enabled
            if desc.panel.enabled ~= should_enable then
                desc.panel.enabled = should_enable
                if desc.onChange then
                    desc:onChange(should_enable)
                end
            end
        end
    end;

    setEnabled = function (self, v)
        self.enabled = v
        system_binds.modal = v
        ticker.enabled = not v
        self:selectConsole(self.consoleEnabled)  -- refresh console enable status
        self:selectPane(self.selectedPane)  -- refresh pane enable status
        if self.consoleEnabled then
            hud_focus_grab(console)
        end
    end;

    destroy = function (self)
    end;

    parentResizedCallback = function (self, psize)
        self:setRect(0, 0, 40, psize.y)
        self.buttonStack.position = vec(0, -psize.y/2 + self.buttonStack.size.y/2 + 8)
        self.consoleButton.position = vec(0, psize.y/2 - self.consoleButton.bounds.y / 2 - 8)
    end;
}

local selected_pane = nil
local console_enabled = true
if debug_layer ~= nil then
    selected_pane = debug_layer.selectedPane
    console_enabled = debug_layer.consoleEnabled
    safe_destroy(debug_layer)
end
debug_layer = gfx_hud_object_add(`DebugLayer`, {
    console = console;
    consoleEnabled = console_enabled;
    selectedPane = selected_pane;
    buttonDescs = {
        {
            name = "Env Cycle Editor";
            panel = env_cycle_editor;
            onChange = function (self, to)
                self.panel:setClosestToTime(env.secondsSinceMidnight/60/60)
            end;
        },
        {
            name = "Music Player";
            panel = music_player;
        },
    };
})
