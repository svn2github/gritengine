local scale = (function(value, axis)
	if value <= 1 or value >= 0 then
		if axis == "x" then
			return gfx_window_size().x * value
		elseif axis == "y" then
			return gfx_window_size().y * value
		end
	end
end)

menubackground = gfx_hud_object_add(`/common/hud/Rect`, { --Using label with no text due to Rect dissapearing...
    size = vec(scale(1, "x"), scale(1, "y"));
	colour = vec(0.1,0.1,0.1);
    position = vec(scale(0.5, "x"), scale(0.5, "y"));
}) 

	------------------------------------------------------------------------
	-----------------------			 ALERT			 -----------------------
	------------------------------------------------------------------------
	
showguialert = (function (alerttext)
	local alert = gfx_hud_object_add(`/common/hud/Label`, {
		size = vec(scale(0.8, "x"), scale(0.2, "y"));
		colour = vec(1,0,0);
		alignment = "CENTER";  -- Also, "CENTER", or "RIGHT".
		value = alerttext ;
		position = vec(scale(0.5, "x"), scale(0.9, "y"));
		font = `/common/fonts/Impact50`;
		captionColour = vec(0, 0, 0);
		captionColourGreyed = vec(0.4, 0.4, 0.4);
		greyed = false;
		alpha = 1;
		--parent = menubackground; --Dont parent to allow other scripts to use it outside of the menu.
		zindex = 100;
	})
end)

	------------------------------------------------------------------------
	-----------------------  Grit Engine Label -----------------------
	------------------------------------------------------------------------
	
menutitlelabel = gfx_hud_object_add(`/common/hud/Label`, {
		size = vec(scale(0.4, "x"), scale(0.2, "y"));
		colour = vec(0.1,0.1,0.1);
		alignment = "CENTER";  -- Also, "CENTER", or "RIGHT".
		value = "Grit Engine ";
		position = vec(scale(0, "x"), scale(0.2, "y"));
		font = `/common/fonts/Impact50`;
		captionColour = vec(0, 0, 0);
		captionColourGreyed = vec(0.4, 0.4, 0.4);
		greyed = false;
		parent = menubackground;
		zindex = 100;
	})
	
	------------------------------------------------------------------------
	----------------------- 			 Play			 -----------------------
	------------------------------------------------------------------------
	
menuplaybutton = gfx_hud_object_add(`/common/hud/Button`, {
		size = vec(scale(0.2, "x"), scale(0.1, "y"));
		position = vec(scale(0, "x"), scale(0.1, "y"));
		font = `/common/fonts/Impact24`;
		caption = "Play";
		baseColour = vec(0, 0, 0);  -- Black
		hoverColour = vec(1, 0, 0);  -- Red
		clickColour = vec(1, 1, 1);  -- Yellow
		borderColour = vec(1, 1, 1);  -- White
		captionColour = vec(1, 1, 1);
		captionColourGreyed = vec(0.5, 0.5, 0.5);
		parent = menubackground;
		pressedCallback = function (self)
			console.enabled = true
			--debug_binds.modal = false --Pretty sure this is not needed anymore due to my configurations fix on console binding
			menubackground.enabled = false
			menubackground = nil
		end;
    })  
	
	------------------------------------------------------------------------
	-----------------------			 Editor			 -----------------------
	------------------------------------------------------------------------
	
menueditorbutton = gfx_hud_object_add(`/common/hud/Button`, {
		size = vec(scale(0.2, "x"), scale(0.1, "y"));
		position = vec(scale(0, "x"), scale(-0.01, "y"));
		font = `/common/fonts/Impact24`;
		caption = "Editor";
		baseColour = vec(0, 0, 0);  -- Black
		hoverColour = vec(1, 0, 0);  -- Red
		clickColour = vec(1, 1, 1);  -- Yellow
		borderColour = vec(1, 1, 1);  -- White
		captionColour = vec(1, 1, 1);
		captionColourGreyed = vec(0.5, 0.5, 0.5);
		parent = menubackground;
		pressedCallback = function (self)
			showguialert("Editor Button Coming Soon!")
			print("Editor Button Coming Soon!")
		end;
    })  
	
	------------------------------------------------------------------------
	-----------------------          Settings          -----------------------
	------------------------------------------------------------------------
	
menusettingsbutton = gfx_hud_object_add(`/common/hud/Button`, {
		size = vec(scale(0.2, "x"), scale(0.1, "y"));
		position = vec(scale(0, "x"), scale(-0.12, "y"));
		font = `/common/fonts/Impact24`;
		caption = "Settings";
		baseColour = vec(0, 0, 0);  -- Black
		hoverColour = vec(1, 0, 0);  -- Red
		clickColour = vec(1, 1, 1);  -- Yellow
		borderColour = vec(1, 1, 1);  -- White
		captionColour = vec(1, 1, 1);
		captionColourGreyed = vec(0.5, 0.5, 0.5);
		parent = menubackground;
		pressedCallback = function (self)
			showguialert("Settings Button Coming Soon!")
			print("Settings Button Coming Soon!")
		end;
    })  

console.enabled = false
debug_binds.modal = true
--showguialert("TEST")

--include `NewMenuGUI/init.lua`