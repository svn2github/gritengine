-- testing purposes only (will be overridden by a complete window)

-- OPEN LEVEL DIALOG
open_level_dialog = gfx_hud_object_add('/editor/core/hud/Window', { title="Open Level", parent=hud_center,  position=vec2(0, 0), resizeable=false, size=vec2(500, 150)})
-- these lines are purely a ugly hack :)
open_level_dialog.draggable_area.size = vec2(open_level_dialog.size.x, open_level_dialog.draggable_area.size.y)
open_level_dialog.window.size = vec2(open_level_dialog.size.x - open_level_dialog.borderSize*2, open_level_dialog.size.y - open_level_dialog.borderSize*2)

open_level_dialog.openButton = gfx_hud_object_add(`/common/hud/Button`, {
	caption = "Open";
	pressedCallback = function (self)
		open_level(self.parent.parent.parent.fileName.value)
		self.parent.parent.parent.enabled = false
	end;
	size = vec(48,20);
})
open_level_dialog.fileName = gfx_hud_object_add(`/common/hud/EditBox`, {
	value = "/.lvl";
	size = vec(346,20);
	alignment = "LEFT";
})

open_level_dialog.box = gfx_hud_object_add(`/common/hud/Border`, {
	padding = 8;
	colour = 0.25 * vec(1,1,1);
	texture = `/common/hud/CornerTextures/Border04.png`;
	parent=open_level_dialog;
	child = gfx_hud_object_add(`/common/hud/StackX`, {
		padding = 0,
		open_level_dialog.fileName,
		vec(4, 0),
		open_level_dialog.openButton
	}),
})
-- SAVE LEVEL DIALOG
save_level_dialog = gfx_hud_object_add('/editor/core/hud/Window', { title="Save Level", parent=hud_center,  position=vec2(0, 0), resizeable=false, size=vec2(500, 150)})
-- these lines are purely a ugly hack :)
save_level_dialog.draggable_area.size = vec2(save_level_dialog.size.x, save_level_dialog.draggable_area.size.y)
save_level_dialog.window.size = vec2(save_level_dialog.size.x - save_level_dialog.borderSize*2, save_level_dialog.size.y - save_level_dialog.borderSize*2)

save_level_dialog.saveButton = gfx_hud_object_add(`/common/hud/Button`, {
	caption = "Save";
	pressedCallback = function (self)
		open_level(self.parent.parent.parent.fileName.value)
		self.parent.parent.parent.enabled = false
	end;
	size = vec(48,20);
})
save_level_dialog.fileName = gfx_hud_object_add(`/common/hud/EditBox`, {
	value = "/.lvl";
	size = vec(346,20);
	alignment = "LEFT";
})

save_level_dialog.box = gfx_hud_object_add(`/common/hud/Border`, {
	padding = 8;
	colour = 0.25 * vec(1,1,1);
	texture = `/common/hud/CornerTextures/Border04.png`;
	parent=save_level_dialog;
	child = gfx_hud_object_add(`/common/hud/StackX`, {
		padding = 0,
		save_level_dialog.fileName,
		vec(4, 0),
		save_level_dialog.saveButton
	}),
})

open_level_dialog.enabled = false
save_level_dialog.enabled = false