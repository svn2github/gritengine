safe_destroy(editor_interface)
editor_interface = gui.windownotebook({})

include`pages/MapEditor.lua`
include`pages/NavigationEditor.lua`

-- add the button to the editor toolbar
add_editor_tool("Navigation Editor", map_editor_icons.navigation, function(self) open_navigation_page() end)

include`pages/ObjectEditor.lua`

-- store temporary pages
editor_interface.pagelist = {}

function new_object_ed_page(name, cntb, sel)
	editor_interface.pagelist[#editor_interface.pagelist+1] = ed_object_editor_page.new()
	editor_interface.pagelist[#editor_interface.pagelist].meshname = name
	editor_interface.pagelist[#editor_interface.pagelist].content_browser = cntb

	editor_interface.pagelist[#editor_interface.pagelist].button = editor_interface:addPage({ caption = name, edge_colour = vec(0, 1, 1), page = editor_interface.pagelist[#editor_interface.pagelist], onSelect = function(self) self.page:select() end, onUnselect = function(self) self.page:unselect() end, onInit = function(self) self.page:init() end })
	
	if sel then
		editor_interface.pagelist[#editor_interface.pagelist].button:select()
	end
end
