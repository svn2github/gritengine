-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- abandon all hope, ye who enters here...
print("Loading simplemenu.lua")

if simple_menu == nil then
	--echo "creating simple_menu table"
	simple_menu = {
		currentMenu=nil;
		Y_offset = 51; -- in percents, between 0 and 100
		textOpts = {charHeight=13};
	}
else
	ui.pressCallbacks:removeByName("simple_menu")
end

do
	-- include user menu data
	local filename = "user_menu.lua"
	local file = io.open(filename, "r")	
	if file ~= nil then
		file:close()
		print "Reading user_menu.lua: success"
		include("/"..filename)
	else
		print "Reading user_menu.lua: fail"
	
		-- clean up. if it's not needed remove this shame, please :P
		filename = nil
		file = nil
	end
end

function simple_menu:load_keybinds()
	-- checks whether file exists
			--if exists include settings from it and return
			--else write defaults to that file and include them and return
	local filename = "user_menu_keybinds.lua"
	local file = io.open(filename, "r")
	if file ~= nil then
		file:close()
		print("Reading "..filename)
		include("/"..filename)

		local isloaded
		if simple_menu.Entries ~= nil then -- check if succesfly loaded keybinds
			--[[
			for i=0, 9, 1 do
				echo(i.." "..simple_menu.Entries[i])
		 		if simple_menu.Entries[i] == nil then
					echo(simple_menu.Entries[i])
					local isloaded = false
					print(filename.." is corrupted.")
					break
				end				
			end
			if isloaded ~= nil and isloaded ~= false then
			--]]
				return
			--end
		end
	end

	print("Restoring "..filename)
	local defaults =
	{
		[0] = ":0";
		[1] = ":1";
		[2] = ":2";
		[3] = ":3";
		[4] = ":4";
		[5] = ":5";
		[6] = ":6";
		[7] = ":7";
		[8] = ":8";
		[9] = ":9";
	}
	local r = "{\n"
		for i=0, 9, 1 do
			r=r.."\t["..i.."] = \""..defaults[i].."\";\n"
		end
	r = r.."}"
	
	local file = io.open(filename, "w")
	file:write("simple_menu.Entries = ")
	file:write(r)
	file:write("\n")
	file:close()

	print("Reading "..filename)
	include("/"..filename)
end


function simple_menu:show(menu)
	--echo("executing simple_menu:show")

	if menu == simple_menu.currentMenu or menu == nil then -- hide menu, also toggle it
		if self.showingMenu ~= nil then
			get_hud_root():removeChild(self.showingMenu)
			self.showingMenu = nil
		end
		if self.bodyPane ~= nil then
			get_hud_root():removeChild(self.bodyPane)
			self.bodyPane = nil
		end
		self.currentMenu = nil
	else
		simple_menu.parentMenu = simple_menu.currentMenu;
		simple_menu.currentMenu=menu;

		if self.showingMenu ~= nil then	--remove old one from drawing list
			get_hud_root():removeChild(self.showingMenu)
			self.showingMenu=nil
		end

		if self.bodyPane == nil then
			self.bodyPane = get_hud_root():addChild("Pane")
        		self.bodyPane.material = "system/Console"
		end

		-- "generate" and display new menu
		self.showingMenu = self.bodyPane:addChild("ShadowText", self.textOpts)
		self.showingMenu.resize = function(w,h) return 5, h*self.Y_offset/100, w, h end
		self.showingMenu.text = (self.currentMenu.Title or "Simple menu") .. "\n"
		
		local highLen = 18
		for i = 1, 9, 1 do --add menu items
			if self.currentMenu[i] ~= nil then
				self.showingMenu.text = self.showingMenu.text.." "..i..") "..self.currentMenu[i][1].."\n"
				if string.len(self.currentMenu[i][1]) > highLen then
					highLen = string.len(self.currentMenu[i][1])
				end
			end
		end
		self.bodyPane.resize = function (w,h) return 0, 0, (highLen+3)*8, h end

		--if not set otherwise, 0 entry always map to exit
		if self.currentMenu[0] == nil then
			if self.currentMenu.MenuType ~= nil then
				if self.currentMenu.MenuType == "root" then
					self.currentMenu[0] = {"exit", function() simple_menu:show(nil) end}
				elseif self.currentMenu.MenuType == "child" then
					self.currentMenu[0] = {"back", function() simple_menu:show(self.parentMenu) end}
				end
				self.showingMenu.text = self.showingMenu.text.." 0) "..self.currentMenu[0][1].."\n"
			end
		else
			self.showingMenu.text = self.showingMenu.text.." 0) "..self.currentMenu[0][1].."\n"
		end
	end
end

function simple_menu:callback(key)
	--echo "simplemenu callback called"
	--echo ("key:"..key)

	if player_ctrl.mode ~= 0 and self.showingMenu ~= nil then --if not in ghost mode hide the menu and return
		self:show(nil)
		return
	end

	--echo "simple menu processing keypresses"
	
	local key_entry = nil
	for i = 0, 9, 1 do -- try to find binding for the keypress
		if simple_menu.Entries[i] == key then -- if keypress matched to the binding
			key_entry = i	-- assing the apropriate index
			--echo("matched key entry: "..key_entry)
			break
		end
	end
		
	if self.currentMenu ~= nil and self.currentMenu[key_entry] ~= nil then -- if the requested function exists
		--echo "calling apropriate entry's function"
		self.currentMenu[key_entry][2]() -- call the apropriate function
	end
end

simple_menu.load_keybinds()
ui.pressCallbacks:insert("simple_menu",function(key) simple_menu:callback(key) end)
