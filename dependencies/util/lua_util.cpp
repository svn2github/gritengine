/* Copyright (c) David Cunningham and the Grit Game Engine project 2012
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

#include <cstdlib>
#include <cmath>

#include <string>
#include <map>
#include <sstream>
#include <iostream>

#include "console.h"
#include "lua_util.h"

// code nicked from ldblib.c
std::vector<struct stack_frame> traceback(lua_State *L1, int level)
{
    std::vector<struct stack_frame> r;
    lua_Debug ar;

    int top = 7;
    int bottom = 3;

    int i=0;
    while (lua_getstack(L1, level+(i++), &ar)) {
        if (i==top+1) {
            if (lua_getstack(L1, level+i+bottom, &ar)) {
                struct stack_frame sf;
                sf.gap = 1;
                r.push_back(sf);
                // skip a load of frames because the stack
                // is too big
                while (lua_getstack(L1, level+i+bottom, &ar))
                    i++;
                continue;
            }
        }

        lua_getinfo(L1, "Snl", &ar);

        struct stack_frame sf;

        sf.file = ar.short_src;

        sf.line = ar.currentline;

        if (*ar.namewhat != '\0') {       /* is there a name? */
            sf.func_name = ar.name;
        } else {
            if (*ar.what == 'm')
                sf.func_name = "global scope";
            else if (*ar.what == 'C')
                sf.func_name = "C function";
            else if (*ar.what == 't')
                sf.func_name = "Tail call";
            else {
                std::stringstream ss;
                ss << "func <"<<ar.short_src
                   << ":"<<ar.linedefined << ">";
                sf.func_name = ss.str();
            }
        }
        sf.gap = 0;
        r.push_back(sf);
    }

    return r;
}

void my_lua_error(lua_State *l, const std::string &msg)
{
    my_lua_error(l,msg.c_str());
}

void my_lua_error(lua_State *l, const std::string &msg, unsigned long level)
{
    my_lua_error(l,msg.c_str(),level);
}

void my_lua_error(lua_State *l, const char *msg)
{
    // default value of 1 because this function is called from within c
    // code implementing lua functions that just need to strip themselves
    // from the traceback
    my_lua_error(l,msg,1);
}

void my_lua_error(lua_State *l, const char *msg, unsigned long level)
{
    luaL_where(l,level);
    std::string str = check_string(l,-1);
    lua_pop(l,1);
    str += msg;
    lua_newtable(l);
    lua_pushnumber(l,level);
    lua_rawseti(l,-2,1);
    lua_pushstring(l,str.c_str());
    lua_rawseti(l,-2,2);
    lua_error(l);
    abort(); // never happens, keeps compiler happy
}

void check_args_max(lua_State *l, int expected)
{
    int got = lua_gettop(l);
    if (got>expected) {
        std::stringstream msg;
        msg << "Wrong number of arguments: " << got
            << " should be at most " << expected;
        my_lua_error(l,msg.str());
    }
}

void check_args_min(lua_State *l, int expected)
{
    int got = lua_gettop(l);
    if (got<expected) {
        std::stringstream msg;
        msg << "Wrong number of arguments: " << got
            << " should be at least " << expected;
        my_lua_error(l,msg.str());
    }
}

void check_args(lua_State *l, int expected)
{
    int got = lua_gettop(l);
    if (got!=expected) {
        std::stringstream msg;
        msg << "Wrong number of arguments: " << got
            << " should be " << expected;
        my_lua_error(l,msg.str());
    }
}


lua_Number check_int (lua_State *l, int stack_index,
              lua_Number min, lua_Number max)
{
    lua_Number n = luaL_checknumber(l, stack_index);
    if (n>=min && n<=max && n==floor(n)) return n;
    my_lua_error(l, "Not an integer in ["+str(min)+","+str(max)+"]: "+str(n));
    return 0; // unreachable
}

float check_float (lua_State *l, int stack_index)
{
    return (float) luaL_checknumber(l, stack_index);
}


bool check_bool (lua_State *l, int stack_index)
{
    if (!lua_isboolean(l,stack_index)) {
        std::stringstream msg;
        msg << "Expected a boolean at parameter " << stack_index;
        my_lua_error(l, msg.str());
    }
    return 0!=lua_toboolean(l,stack_index);
}

const char* check_string (lua_State *l, int stack_index)
{
    if (lua_type(l,stack_index) != LUA_TSTRING) {
        std::stringstream msg;
        msg << "Expected a string at parameter " << stack_index;
        my_lua_error(l, msg.str());
    }
    return lua_tostring(l,stack_index);
}

int my_do_nothing_lua_error_handler (lua_State *) { return 0; }

int my_lua_error_handler_cerr (lua_State *l)
{
    return my_lua_error_handler_cerr(l,l,1);
}

int my_lua_error_handler_cerr (lua_State *l, lua_State *coro, int levelhack)
{
    //check_args(l,1);
    int level = 0;
    if (lua_type(l,-1)==LUA_TTABLE) {
        lua_rawgeti(l,-1,1);
        level = luaL_checkinteger(l,-1);
        lua_pop(l,1);
        lua_rawgeti(l,-1,2);
    }
    level+=levelhack; // to remove the current function as well

    std::string str = check_string(l,-1);

    std::vector<struct stack_frame> tb = traceback(coro,level);

    if (tb.size()==0) {
        CERR<<"getting traceback: ERROR LEVEL TOO HIGH!"<<std::endl;
        level=0;
        tb = traceback(coro,level);
    }

    if (tb.size()==0) {
        CERR<<"getting traceback: EVEN ZERO TOO HIGH!"<<std::endl;
        return 1;
    }

    // strip file:line from message if it is there
    std::stringstream ss; ss<<tb[0].file<<":"<<tb[0].line<<": ";
    std::string str_prefix1 = ss.str();
    std::string str_prefix2 = str.substr(0,str_prefix1.size());
    if (str_prefix1==str_prefix2)
        str = str.substr(str_prefix1.size());

    CLOG << BOLD << RED << tb[0].file;
    int line = tb[0].line;
    if (line > 0) {
        CLOG << ":" << line;
    }
    CLOG << ": " << str << RESET << std::endl;
    for (size_t i=1 ; i<tb.size() ; i++) {
        if (tb[i].gap) {
            CLOG << "\t..." << RESET << std::endl;
        } else {
            CLOG << RED << "\t" << tb[i].file;
            int line = tb[i].line;
            if (line > 0) {
                CLOG << ":" << line;
            }
            CLOG << ": " << tb[i].func_name << RESET << std::endl;
        }
    }
    return 1;
}

size_t lua_alloc_stats_mallocs = 0;
size_t lua_alloc_stats_reallocs = 0;
size_t lua_alloc_stats_frees = 0;
size_t lua_alloc_stats_counter = 0;

void lua_alloc_stats_get (size_t &counter, size_t &mallocs,
              size_t &reallocs, size_t &frees)
{
    counter = lua_alloc_stats_counter;
    mallocs = lua_alloc_stats_mallocs;
    reallocs = lua_alloc_stats_reallocs;
    frees = lua_alloc_stats_frees;
}

void lua_alloc_stats_set (size_t mallocs, size_t reallocs, size_t frees)
{
    lua_alloc_stats_mallocs = mallocs;
    lua_alloc_stats_reallocs = reallocs;
    lua_alloc_stats_frees = frees;
}

void *lua_alloc (void *ud, void *ptr, size_t osize, size_t nsize)
{
    (void) ud;
    (void) osize;
    if (nsize==0) {
        if (ptr!=NULL) {
            lua_alloc_stats_frees++;
            lua_alloc_stats_counter--;
            free(ptr);
        }
        return NULL;
    } else {
        if (ptr==NULL) {
            lua_alloc_stats_mallocs++;
            lua_alloc_stats_counter++;
            return malloc(nsize);
        } else {
            lua_alloc_stats_reallocs++;
            return realloc(ptr,nsize);
        }
    }
}

void check_stack (lua_State *l, int size)
{
    if (!lua_checkstack(l,size)) {
        CERR << "lua_checkstack: Failed to guarantee " << size
             << ", current top is " << lua_gettop(l) << std::endl;
    }
}

bool has_tag(lua_State *l, int index, const char* tag)
{
    if (!lua_getmetatable(l,index)) return false;
    lua_getfield(l,LUA_REGISTRYINDEX,tag);
    bool ret = lua_equal(l,-1,-2)!=0;
    lua_pop(l,2);
    return ret;
}

// this version silently ignores nullified userdata
bool is_userdata (lua_State *L, int ud, const char *tname)
{ 
    void *p = lua_touserdata(L, ud); 
    if (p==NULL) return false;
    return has_tag(L,ud,tname);
} 


void register_lua_globals (lua_State *L, const luaL_reg *globals)
{
    if (getenv("GRIT_DUMP_GLOBALS")) {
        for (const luaL_reg *g = globals ; g->name != NULL ; ++g) {
            std::cout << g->name << std::endl;
        }
    }
    luaL_register(L, "_G", globals);
}

bool is_ptr (lua_State *L, int index, const char *tag)
{
    if (!lua_isuserdata(L, index)) return false;
    void *p = lua_touserdata(L, index);
    if (p == NULL) return false;
    if (!lua_getmetatable(L, index)) return false;
    lua_getfield(L, LUA_REGISTRYINDEX, tag);
    if (lua_rawequal(L, -1, -2)) {
        lua_pop(L, 2);  /* remove both metatables */
        return true;
    }
    lua_pop(L, 2);  /* remove both metatables */
    return false;
}


std::string type_name (lua_State *L, int index)
{
    return std::string(lua_typename(L, lua_type(L,index)));
}

void check_is_function (lua_State *L, int index)
{
    if (lua_type(L, index) == LUA_TFUNCTION) return;
    my_lua_error(L, "Expected a function at argument: "+str(index)+" but got "+type_name(L,index));
}



// vim: shiftwidth=4:tabstop=4:expandtab
