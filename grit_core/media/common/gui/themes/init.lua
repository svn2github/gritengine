editor_themes = {}

editor_themes['dark_orange'] =
{
	name = 'dark_orange';
	colours =
	{
		-- Menu bar
		menu_bar =
		{
			background = V_ID * 0.35;
			background_alpha = 1;
			button = V_ID * 0.4;
			button_hover = V_ID * 0.6;
			button_pressed = V_ID * 0.8;
			button_border = V_ID * 0.5;
			button_alpha = 0.5;
			button_caption = V_ID * 0.85;
			button_caption_greyed = V_ID * 0.4;
			button_caption_hover = V_ID;
			button_caption_pressed = V_ZERO;
		};
		-- Menu bar: menu
		menu =
		{
			background = V_ID * 0.4;
			background_alpha = 1;
			item_background = V_ID;
			item_hover = V_ID * 0.5;
			item_text = V_ID;
			item_text_hover = V_ID;
			item_alpha = 0;
			line = V_ID * 0.8;
			icon = V_ID;
			icon_alpha = 0;
		};
		-- Tool bar
		tool_bar =
		{
			background = V_ID * 0.35;
			alpha = 1;
			separator = V_ID * 0.9;
			separator_alpha = 0.3;
			icon = V_ID;
			icon_hover = vec(1, 0.7, 0.4);
			icon_pressed = vec(1, 0.5, 0);
		};
		tip =
		{
			background = vec(1, 1, 0.8);
			alpha = 1;
			text = V_ZERO;
		};
		status_bar =
		{
			background = V_ID * 0.35;
			alpha = 1;
			text = V_ID;
			line = vec(1, 0.5, 0);
		};
		-- Window
		window =
		{
			background = V_ID * 0.4;
			background_alpha = 0.7;
			titlebar_background = V_ID;
			titlebar_background_alpha = 1;
			titlebar_background_inactive = V_ID * 0.2;
			titlebar_background_inactive_alpha = 1;
			titlebar_text = V_ZERO;
			titlebar_text_inactive = V_ID;
			border = V_ID * 0.6;
			border_alpha = 1;
			closebtn_base = V_ID * 0.3;
			closebtn_hover = V_ID * 0.45;
			closebtn_pressed = V_ID * 0.7;
		};
		checkbox = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};
		radiobutton = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};		
		context_menu = 
		{
			background = V_ID;
			alpha = 1;
		};
		button = 
		{
			base = V_ID;
			hover = V_ID * 0.45;
			pressed = V_ID * 0.15;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};
		image_button = 
		{
			base = V_ID;
			hover = vec(1, 0.8, 0.5);
			pressed = vec(1, 0.5, 0);
			greyed = V_ID * 0.5;
			
			active = vec(0.2, 0.7, 1);
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};		
		selectbox = 
		{
			base = V_ID* 0.45;
			hover = V_ID * 0.6;
			pressed = V_ID * 0.3;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
			
			icon = vec(1, 1, 1);
			icon_alpha = 1;
			icon_hover = vec(1, 0.7, 0.2);
			icon_pressed = vec(1, 0.5, 0);			
			
			menu_base = V_ID;
			menu_alpha = 0;
			menu_hover = vec(1, 0.9, 0.5);
			menu_hover_alpha = 1;
			menu_text = V_ZERO;
			
		};		
		window_notebook = 
		{
			background = V_ID * 0.3;
			alpha = 1;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.35;
			btn_hover = V_ID * 0.4;
			btn_pressed = V_ID * 0.45;
			btn_selected = V_ID * 0.45;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0;
			btn_caption_selected = V_ID * 1;

			-- close btn
			close_btn_base = V_ID * 0.9;
			close_btn_hover = V_ID * 0.8;
			close_btn_pressed = V_ID * 0.5;
			close_btn_greyed = V_ID * 0.9;
			
			close_btn_caption_base = V_ID * 0.2;
			close_btn_caption_hover = V_ID * 0.1;
			close_btn_caption_pressed = V_ID * 1;
			close_btn_caption_greyed = V_ID * 0.1;			
			close_btn_alpha = 1;
		};
		notebook = 
		{
			background = V_ID * 0.3;
			alpha = 0;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.45;
			btn_hover = V_ID * 0.6;
			btn_pressed = V_ID * 0.5;
			btn_selected = V_ID * 0.3;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0.85;
			btn_caption_selected = V_ID * 1;

		};
		scroll_bar = 
		{
			background = V_ID * 0.2;
			base = V_ID;
			pressed = vec(1, 0.8, 0.5);
			hover = vec(1, 0.8, 0.5);
			alpha = 1;
		};			
	};
	fonts =
	{
		default = `/common/fonts/Verdana12`;
		
		menu_bar =
		{
			button = `/common/fonts/Verdana12`;
		};
		
		checkbox = `/common/fonts/Arial12`;
		
		radiobutton = `/common/fonts/Arial12`;
		
		button = `/common/fonts/Verdana12`;
		
		window_notebook = 
		{
			closebtn = `/common/fonts/Arial12`;
			button = `/common/fonts/Arial14`;
			button_selected = `/common/fonts/ArialBold14`;
		};
	};
};

_current_theme = editor_themes['dark_orange']