/* Copyright (c) Augusto P. Moura 2014
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "lua_wrappers_grit_editor.h"
#include"grit_editor.h"
#include <string>
#include <iostream>
#include "gfx/lua_wrappers_gfx.h"

static int global_open_file_dialog (lua_State *L)
{
TRY_START
        check_args(L,2);
        const char *title = luaL_checkstring(L,1);
		const char *filetypes = luaL_checkstring(L,2);

		const std::string &filename = open_file_dialog(title, filetypes);
        if (filename.empty()) {
                lua_pushnil(L);
                return 1;
        }
		lua_pushstring(L, filename.c_str());
        return 1;
TRY_END
}

static int global_save_file_dialog (lua_State *L)
{
TRY_START
        check_args(L,3);
        const char *title = luaL_checkstring(L,1);
		const char *filetypes = luaL_checkstring(L,2);
		const char *defaultExt = luaL_checkstring(L,3);
		
		const std::string filename = save_file_dialog(title, filetypes, defaultExt);
        if (filename.empty()) {
                lua_pushnil(L);
                return 1;
        }
		lua_pushstring(L, filename.c_str());
        return 1;
TRY_END
}

static int global_mouse_pick (lua_State *L)
{
TRY_START
        check_args(L,4);
		float posX = check_float(L, 1);
		float posY = check_float(L, 2);
		Ogre::Vector3 cam_pos = to_ogre(check_v3(L, 3));
		Ogre::Quaternion cam_orientation = to_ogre(check_quat(L, 4));
		GfxBodyPtr obj = mouse_pick(posX, posY, cam_pos, cam_orientation);

        //if (obj->isEnabled() == false) {
		//	lua_pushnil(L);
		//	return 1;
        //}
		CVERB << "w3" << std::endl;
		push_gfxbody(L, obj);
        return 1;
TRY_END
}

static const luaL_reg global[] = {
	{ "open_file_dialog", global_open_file_dialog },
	{ "save_file_dialog", global_save_file_dialog },
	{ "gfx_mouse_pick", global_mouse_pick },
	{NULL, NULL}
};

void grit_editor_lua_init (lua_State *L)
{
    register_lua_globals(L, global);
}