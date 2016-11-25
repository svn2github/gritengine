safe_destroy(editor_interface)
hud_class `EditorInterface` `/common/gui/windownotebook` {
    init = function(self)
        self.needsInputCallbacks = true
        hud_class_get(`/common/gui/windownotebook`).init(self)
    end,
    mouseMoveCallback = function (self)
    end,
    buttonCallback = function (self, event)
        if event == '+left' then
            if inside_hud() then
                game_manager.currentMode:leftMouseClick()
            end
        elseif event == '-left' then
            game_manager.currentMode:stopDraggingObj()
        end
    end,
}

editor_interface = hud_object `EditorInterface` { }

include `pages/MapEditor.lua`
include `pages/NavigationEditor.lua`

-- add the button to the editor toolbar
add_editor_tool("Navigation Editor", map_editor_icons.navigation, function(self) open_navigation_page() end)

include `pages/ObjectEditor.lua`

-- store temporary pages
editor_interface.pagelist = {}

function new_object_ed_page(name, cntb, sel)
	editor_interface.pagelist[#editor_interface.pagelist+1] = ed_object_editor_page.new()
	editor_interface.pagelist[#editor_interface.pagelist].meshname = name
	editor_interface.pagelist[#editor_interface.pagelist].content_browser = cntb

	editor_interface.pagelist[#editor_interface.pagelist].button = editor_interface:addPage({
        caption = name,
        edge_colour = vec(0, 1, 1),
        page = editor_interface.pagelist[#editor_interface.pagelist],
        onSelect = function(self) self.page:select() end,
        onUnselect = function(self) self.page:unselect() end,
        onInit = function(self) self.page:init() end,
    })
	
	if sel then
		editor_interface.pagelist[#editor_interface.pagelist].button:select()
	end
end
