safe_destroy(CONTEXTMENU)
CONTEXTMENU = {}
function show_context_menu(m_items)
	if CONTEXTMENU ~= nil and CONTEXTMENU.destroyed ~= nil then
		CONTEXTMENU:destroy()
	end
	CONTEXTMENU = gfx_hud_object_add(`/editor/core/hud/menu`, { colour = vec(1, 1, 1), cornered=false, alpha=1, position=vec(0, 0), items = m_items, zOrder = 10 })
	CONTEXTMENU.position = mouse_pos_abs + vec2(CONTEXTMENU.size.x/2, -CONTEXTMENU.size.y/2)
	CONTEXTMENU.texture=nil
end;
