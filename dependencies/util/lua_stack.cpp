/* Copyright (c) David Cunningham and the Grit Game Engine project 2014
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

#include <cstring>
#include <iostream>

#include "console.h"
#include "lua_stack.h"

std::string lua_current_dir (lua_State *L)
{
    lua_Debug dbg;
    for (int level=0 ; ; level++) {
        int r = lua_getstack(L, level, &dbg);
        if (r != 1) {
            // off the bottom of the stack
            return "/";
        }
        r = lua_getinfo(L, "S", &dbg);
        //CVERB << dbg.what << std::endl;
        //CVERB << dbg.source << std::endl;
        if (!strcmp(dbg.what, "C")) {
            // Maybe we are called from C, in which case just keep looking.
            // Note: this will always be the case for the first stack level.
            continue;
        }
        if (dbg.source[0] != '@') {
            // Didn't come from a file.
            continue;
        }
        std::string filename = &dbg.source[1];
        size_t last = filename.rfind('/');
        if (last == std::string::npos) {
            //  Must be a lua file in the root directory.
            return "/";
        }
        std::string dir(filename, 0, last+1);
        return dir;
    }
}
