editor_themes = {}

editor_themes['dark_orange'] = {
	name = 'dark_orange';
	colours = {
		-- Menu bar
		menu_bar = {
			background = vec(0.3, 0.3, 0.3);
			background_alpha = 1;
		};
		-- Menu bar: menu
		menu = {
			background = vec(1, 1, 1);
			background_alpha = 0.7;
			button_background = vec(0.5, 0.5, 0.5);
			button_background_hover = vec(0.8, 0.3, 0);
			button_background_pressed = vec(1, 0.5, 0);
			button_text = vec(1, 1, 1);
			button_text_hover = vec(0, 0, 0);
			button_text_pressed = vec(0, 0, 0);
			item = vec(1, 1, 1);
			item_selected = vec(1, 0.5, 0);
			item_text  = vec(0, 0, 0);
			item_text_selected = vec(1, 0.5, 0);
		};
		-- Tool bar
		tool_bar = {
			icon = vec(1, 1, 1);
			icon_hover = vec(1, 0.7, 0.4);
			icon_pressed = vec(1, 0.5, 0);
		};
		-- Window
		window = {
			background = vec(0.3, 0.3, 0.3);
			background_alpha = 1;
			title_background = vec(1, 1, 1);
			title_background_alpha = 1;
			title_background_inactive = vec(0.2, 0.2, 0.2);
			title_background_inactive_alpha = 1;
			title_text = vec(0, 0, 0);
			title_text_inactive = vec(1, 1, 1);
		};
	};
	icons = {
	};
	textures = {
	};
	fonts = {
		default = `common/fonts/Verdana12`;
	};
}