/* Copyright (c) David Cunningham and the Grit Game Engine project 2013
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

#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <limits>
#include <algorithm>

extern "C" {
    #include "lua.h"
    #include "lauxlib.h"
    #include "lualib.h"
}

#include "lua_wrappers_image.h"

#include "Image.h"
//#include "VoxelImage.h"

static void push_string (lua_State *L, const std::string &str) { lua_pushstring(L, str.c_str()); }

static void my_lua_error (lua_State *L, const std::string &msg, unsigned long level=1)
{
    luaL_where(L,level);
    std::string str = lua_tostring(L,-1);
    lua_pop(L,1);
    str += msg;
    push_string(L,str);
    lua_error(L);
}


void check_args (lua_State *L, int expected)
{
    int got = lua_gettop(L);
    if (got != expected) {
        std::stringstream msg;
        msg << "Wrong number of arguments: " << got
            << " should be " << expected;
        my_lua_error(L,msg.str());
    }
}

void check_is_function (lua_State *L, int index)
{
    if (lua_type(L, index) != LUA_TFUNCTION) {
        std::stringstream msg;
        msg << "Expected a function at argument " << index;
        my_lua_error(L,msg.str());
    }
}

template<class T> T* check_ptr (lua_State *L, int index, const char *tag)
{
    return *static_cast<T**>(luaL_checkudata(L, index, tag));
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


lua_Number check_int (lua_State *l, int stack_index,
              lua_Number min, lua_Number max)
{
    lua_Number n = luaL_checknumber(l, stack_index);
    if (n<min || n>max || n!=floor(n)) {
        std::stringstream msg;
        msg << "Not an integer ["<<min<<","<<max<<"]: " << n;
        my_lua_error(l,msg.str());
    }
    return n;
}

template <typename T>
T check_t (lua_State *l, int stack_index,
           T min = std::numeric_limits<T>::min(),
           T max = std::numeric_limits<T>::max())
{
    return (T) check_int(l, stack_index, min, max);
}

static void check_scoord (lua_State *L, int index, simglen_t &x, simglen_t &y)
{
    float x_, y_;
    lua_checkvector2(L, index, &x_, &y_);
    x = x_ < std::numeric_limits<simglen_t>::min() ? std::numeric_limits<simglen_t>::min()
      : x_ > std::numeric_limits<simglen_t>::max() ? std::numeric_limits<simglen_t>::max() : x_;
    y = y_ < std::numeric_limits<simglen_t>::min() ? std::numeric_limits<simglen_t>::min()
      : y_ > std::numeric_limits<simglen_t>::max() ? std::numeric_limits<simglen_t>::max() : y_;
}

static void check_coord (lua_State *L, int index, uimglen_t &x, uimglen_t &y)
{
    float x_, y_;
    lua_checkvector2(L, index, &x_, &y_);
    x = x_ < 0 ? 0 : x_ > std::numeric_limits<uimglen_t>::max() ? std::numeric_limits<uimglen_t>::max() : x_;
    y = y_ < 0 ? 0 : y_ > std::numeric_limits<uimglen_t>::max() ? std::numeric_limits<uimglen_t>::max() : y_;
}

chan_t get_pixel_channels (lua_State *L, int index)
{
    switch (lua_type(L, index)) {
        case LUA_TNUMBER: return 1;
        case LUA_TVECTOR2: return 2;
        case LUA_TVECTOR3: return 3;
        case LUA_TVECTOR4: return 4;
        default: return 0;
    }
}

template<chan_t ch> bool check_pixel (lua_State *L, Pixel<ch> &p, int index);

template<> bool check_pixel<1> (lua_State *L, Pixel<1> &p, int index)
{
    if (lua_type(L,index) != LUA_TNUMBER) return false;
    p[0] = lua_tonumber(L, index);
    return true;
}

template<> bool check_pixel<2> (lua_State *L, Pixel<2> &p, int index)
{
    if (lua_type(L,index) == LUA_TNUMBER) {
        p[0] = lua_tonumber(L, index);
        p[1] = p[0];
        return true;
    }
    if (lua_type(L,index) != LUA_TVECTOR2) return false;
    lua_checkvector2(L, index, &p[0], &p[1]);
    return true;
}

template<> bool check_pixel<3> (lua_State *L, Pixel<3> &p, int index)
{
    if (lua_type(L,index) == LUA_TNUMBER) {
        p[0] = lua_tonumber(L, index);
        p[1] = p[0];
        p[2] = p[0];
        return true;
    }
    if (lua_type(L,index) != LUA_TVECTOR3) return false;
    lua_checkvector3(L, index, &p[0], &p[1], &p[2]);
    return true;
}

template<> bool check_pixel<4> (lua_State *L, Pixel<4> &p, int index)
{
    if (lua_type(L,index) == LUA_TNUMBER) {
        p[0] = lua_tonumber(L, index);
        p[1] = p[0];
        p[2] = p[0];
        p[3] = p[0];
        return true;
    }
    if (lua_type(L,index) != LUA_TVECTOR4) return false;
    lua_checkvector4(L, index, &p[0], &p[1], &p[2], &p[3]);
    return true;
}


template<chan_t ch> void push_pixel (lua_State *L, Pixel<ch> &p);

template<> void push_pixel<1> (lua_State *L, Pixel<1> &p)
{
    lua_pushnumber(L, p[0]);
}

template<> void push_pixel<2> (lua_State *L, Pixel<2> &p)
{
    lua_pushvector2(L, p[0], p[1]);
}

template<> void push_pixel<3> (lua_State *L, Pixel<3> &p)
{
    lua_pushvector3(L, p[0], p[1], p[2]);
}

template<> void push_pixel<4> (lua_State *L, Pixel<4> &p)
{
    lua_pushvector4(L, p[0], p[1], p[2], p[3]);
}






void push_image (lua_State *L, ImageBase *image)
{
    if (image == NULL) {
        std::cerr << "INTERNAL ERROR: pushing a null image" << std::endl;
        abort();
    }
    void **self_ptr = static_cast<void**>(lua_newuserdata(L, sizeof(*self_ptr)));
    *self_ptr = image;
    luaL_getmetatable(L, IMAGE_TAG);
    lua_setmetatable(L, -2);
}


static int image_gc (lua_State *L)
{ 
    check_args(L, 1); 
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    delete self; 
    return 0; 
}

static int image_eq (lua_State *L)
{
    check_args(L, 2); 
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *that = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    lua_pushboolean(L, self==that); 
    return 1; 
}

static int image_tostring (lua_State *L)
{
    check_args(L,1);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    std::stringstream ss;
    ss << *self;
    push_string(L, ss.str());
    return 1;
}

static int image_save (lua_State *L)
{
    check_args(L,2);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    std::string filename = lua_tostring(L, 2);
    if (!image_save(self, filename)) my_lua_error(L, "Could not save: \""+filename+"\"");
    return 0;
}

template<chan_t ch> void foreach (lua_State *L, ImageBase *self_, int func_index)
{
    Image<ch> *self = static_cast<Image<ch>*>(self_);
    for (uimglen_t y=0 ; y<self->height ; ++y) {
        for (uimglen_t x=0 ; x<self->width ; ++x) {
            lua_pushvalue(L, func_index);
            push_pixel<ch>(L, self->pixel(x,y));
            lua_pushvector2(L, x, y);
            int status = lua_pcall(L, 2, 0, 0); 
            if (status != 0) {
                const char *msg = lua_tostring(L, -1);
                std::stringstream ss;
                ss << "During foreach on image at (" << x << "," << y << "): " << msg;
                my_lua_error(L, ss.str());
            }
        }
    }   
}

static int image_foreach (lua_State *L)
{
    check_args(L,2);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    check_is_function(L, 2);

    switch (self->channels()) {
        case 1:
        foreach<1>(L, self, 2);
        break;

        case 2:
        foreach<2>(L, self, 2);
        break;

        case 3:
        foreach<3>(L, self, 2);
        break;

        case 4:
        foreach<4>(L, self, 2);
        break;

        default:
        my_lua_error(L, "Channels must be either 1, 2, 3, or 4.");
    }

    return 0;
}

template<chan_t src_ch, chan_t dst_ch> Image<dst_ch> *map_with_lua_func (lua_State *L, ImageBase *src_, int func_index)
{
    Image<src_ch> *src = static_cast<Image<src_ch>*>(src_);
    uimglen_t width = src->width;
    uimglen_t height = src->height;
    Image<dst_ch> *dst = new Image<dst_ch>(width, height);
    Pixel<dst_ch> p(0);
    for (uimglen_t y=0 ; y<height ; ++y) {
        for (uimglen_t x=0 ; x<width ; ++x) {
            lua_pushvalue(L, func_index);
            push_pixel<src_ch>(L, src->pixel(x,y));
            lua_pushvector2(L, x, y);
            int status = lua_pcall(L, 2, 1, 0); 
            if (status == 0) {
                if (!check_pixel<dst_ch>(L, p, -1)) {
                    delete dst;
                    const char *msg = lua_tostring(L, -1);
                    std::stringstream ss;
                    ss << "While mapping the image at (" << x << "," << y << "): returned value \""<<msg<<"\" has the wrong type.";
                    my_lua_error(L, ss.str());
                }
                dst->pixel(x,y) = p;
            } else {
                const char *msg = lua_tostring(L, -1);
                delete dst;
                std::stringstream ss;
                ss << "While mapping the image at (" << x << "," << y << "): " << msg;
                my_lua_error(L, ss.str());
            }
            lua_pop(L, 1);
        }   
    }   
    return dst;
}

static int image_map (lua_State *L)
{
    check_args(L,3);
    // img, channels, func
    ImageBase *src = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    chan_t dst_ch = check_int(L, 2, 1, 4);
    check_is_function(L, 3);
    chan_t src_ch = src->channels();
    ImageBase *out = NULL;

    switch (src_ch) {
        case 1:
        switch (dst_ch) {
            case 1:
            out = map_with_lua_func<1,1>(L, src, 3);
            break;

            case 2:
            out = map_with_lua_func<1,2>(L, src, 3);
            break;

            case 3:
            out = map_with_lua_func<1,3>(L, src, 3);
            break;

            case 4:
            out = map_with_lua_func<1,4>(L, src, 3);
            break;

            default:
            my_lua_error(L, "Dest channels must be either 1, 2, 3, or 4.");
        }
        break;

        case 2:
        switch (dst_ch) {
            case 1:
            out = map_with_lua_func<2,1>(L, src, 3);
            break;

            case 2:
            out = map_with_lua_func<2,2>(L, src, 3);
            break;

            case 3:
            out = map_with_lua_func<2,3>(L, src, 3);
            break;

            case 4:
            out = map_with_lua_func<3,4>(L, src, 3);
            break;

            default:
            my_lua_error(L, "Dest channels must be either 1, 2, 3, or 4.");
        }
        break;

        case 3:
        switch (dst_ch) {
            case 1:
            out = map_with_lua_func<3,1>(L, src, 3);
            break;

            case 2:
            out = map_with_lua_func<3,2>(L, src, 3);
            break;

            case 3:
            out = map_with_lua_func<3,3>(L, src, 3);
            break;

            case 4:
            out = map_with_lua_func<3,4>(L, src, 3);
            break;

            default:
            my_lua_error(L, "Dest channels must be either 1, 2, 3, or 4.");
        }
        break;

        case 4:
        switch (dst_ch) {
            case 1:
            out = map_with_lua_func<4,1>(L, src, 3);
            break;

            case 2:
            out = map_with_lua_func<4,2>(L, src, 3);
            break;

            case 3:
            out = map_with_lua_func<4,3>(L, src, 3);
            break;

            case 4:
            out = map_with_lua_func<4,4>(L, src, 3);
            break;

            default:
            my_lua_error(L, "Dest channels must be either 1, 2, 3, or 4.");
        }
        break;

        default:
        my_lua_error(L, "Source channels must be either 1, 2, 3, or 4.");
    }

    push_image(L, out);
    return 1;
}

template<chan_t ch> void reduce_with_lua_func (lua_State *L, ImageBase *self_, Pixel<ch> zero, int func_index)
{
    Image<ch> *self = static_cast<Image<ch>*>(self_);

    for (uimglen_t y=0 ; y<self->height ; ++y) {
        for (uimglen_t x=0 ; x<self->width ; ++x) {
            lua_pushvalue(L, func_index);
            push_pixel<ch>(L, zero);
            push_pixel<ch>(L, self->pixel(x,y));
            lua_pushvector2(L, x, y);
            int status = lua_pcall(L, 3, 1, 0); 
            if (status == 0) {
                if (!check_pixel<ch>(L, zero, -1)) {
                    const char *msg = lua_tostring(L, -1);
                    std::stringstream ss;
                    ss << "While reducing the image at (" << x << "," << y << "): returned value \""<<msg<<"\" has the wrong type.";
                    my_lua_error(L, ss.str());
                }
            } else {
                const char *msg = lua_tostring(L, -1);
                std::stringstream ss;
                ss << "While mapping the image at (" << x << "," << y << "): " << msg;
                my_lua_error(L, ss.str());
            }
            lua_pop(L, 1);
        }   
    }
    push_pixel(L, zero);
}

static int image_reduce (lua_State *L)
{
    check_args(L,3);
    // img:A, zero:A, func:A,A -> A
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    check_is_function(L, 3);
    switch (self->channels()) {
        case 1: {
            Pixel<1> p;
            if (!check_pixel(L, p, 2)) my_lua_error(L, "Reduce 'zero' value had the wrong number of channels.");
            else reduce_with_lua_func(L, self, p, 3);
        }
        break;

        case 2: {
            Pixel<2> p;
            if (!check_pixel(L, p, 2)) my_lua_error(L, "Reduce 'zero' value had the wrong number of channels.");
            else reduce_with_lua_func(L, self, p, 3);
        }
        break;

        case 3: {
            Pixel<3> p;
            if (!check_pixel(L, p, 2)) my_lua_error(L, "Reduce 'zero' value had the wrong number of channels.");
            else reduce_with_lua_func(L, self, p, 3);
        }
        break;

        case 4: {
            Pixel<4> p;
            if (!check_pixel(L, p, 2)) my_lua_error(L, "Reduce 'zero' value had the wrong number of channels.");
            else reduce_with_lua_func(L, self, p, 3);
        }
        break;


        default:
        my_lua_error(L, "Image must have either 1, 2, 3, or 4 channels.");
    }
    return 1;
}

static int image_crop (lua_State *L)
{
    if (lua_gettop(L)!=3 && lua_gettop(L)!=4) {
        my_lua_error(L, "image_crop expected 3 or 4 params");
    }
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    simglen_t left, bottom;
    uimglen_t width, height;
    check_scoord(L, 2, left, bottom);
    check_coord(L, 3, width, height);
    ImageBase *out = NULL;
    if (lua_gettop(L) == 4) {
        switch (self->channels()) {
            case 1: {
                Pixel<1> p;
                if (!check_pixel(L, p, 4)) my_lua_error(L, "Crop background had the wrong number of channels.");
                else out = static_cast<Image<1>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 2: {
                Pixel<2> p;
                if (!check_pixel(L, p, 4)) my_lua_error(L, "Crop background had the wrong number of channels.");
                else out = static_cast<Image<2>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 3: {
                Pixel<3> p;
                if (!check_pixel(L, p, 4)) my_lua_error(L, "Crop background had the wrong number of channels.");
                else out = static_cast<Image<3>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 4: {
                Pixel<4> p;
                if (!check_pixel(L, p, 4)) my_lua_error(L, "Crop background had the wrong number of channels.");
                else out = static_cast<Image<4>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            default:
            my_lua_error(L, "Internal error: image seems to have an unusual number of channels.");
        }
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> p = Pixel<1>(0.0f);
                out = static_cast<Image<1>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 2: {
                Pixel<2> p = Pixel<2>(0.0f);
                out = static_cast<Image<2>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 3: {
                Pixel<3> p = Pixel<3>(0.0f);
                out = static_cast<Image<3>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            case 4: {
                Pixel<4> p = Pixel<4>(0.0f);
                out = static_cast<Image<4>*>(self)->crop(left,bottom,width,height,p);
            }
            break;

            default:
            my_lua_error(L, "Internal error: image seems to have an unusual number of channels.");
        }
    }
    push_image(L, out);
    return 1;
}

ScaleFilter scale_filter_from_string (lua_State *L, const std::string &s)
{
    if (s == "BOX") return SF_BOX;
    if (s == "BILINEAR") return SF_BILINEAR;
    if (s == "BSPLINE") return SF_BSPLINE;
    if (s == "BICUBIC") return SF_BICUBIC;
    if (s == "CATMULLROM") return SF_CATMULLROM;
    if (s == "LANCZOS3") return SF_LANCZOS3;
    my_lua_error(L, "Expected BOX, BILINEAR, BSPLINE, BICUBIC, CATMULLROM, or LANCZOS3.  Got: \""+s+"\"");
    return SF_BOX; // silly compilers
}

static int image_scale (lua_State *L)
{
    check_args(L, 3);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    uimglen_t width, height;
    check_coord(L, 2, width, height);
    std::string filter_type = luaL_checkstring(L, 3);
    ImageBase *out = self->scale(width, height, scale_filter_from_string(L, filter_type));
    push_image(L, out);
    return 1;
}

static int image_rotate (lua_State *L)
{
    check_args(L, 2);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    float angle = luaL_checknumber(L, 2);
    ImageBase *out = self->rotate(angle);
    push_image(L, out);
    return 1;
}

static int image_clone (lua_State *L)
{
    check_args(L, 1);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *out = self->clone(false, false);
    push_image(L, out);
    return 1;
}

static int image_flip (lua_State *L)
{
    check_args(L, 1);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *out = self->clone(false, true);
    push_image(L, out);
    return 1;
}

static int image_mirror (lua_State *L)
{
    check_args(L, 1);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *out = self->clone(true, false);
    push_image(L, out);
    return 1;
}

void ensure_compatible(lua_State *L, ImageBase *self, ImageBase *other)
{
    if (self->compatibleWith(other)) return;
    std::stringstream ss;
    ss << "Images are incompatible: " << *self << " and " << *other;
    my_lua_error(L, ss.str());
}

static int image_rms (lua_State *L)
{
    check_args(L,2);
    // img, float
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *other = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    ensure_compatible(L, self, other);
    lua_pushnumber(L, self->rms(other));
    return 1;
}

static int image_exp (lua_State *L)
{
    check_args(L,2);
    // img, float
    ImageBase *src = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    float index = luaL_checknumber(L, 2);
    ImageBase *out = src->pow(index);
    push_image(L, out);
    return 1;
}

static int image_abs (lua_State *L)
{
    check_args(L,1);
    ImageBase *src = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    push_image(L, src->abs());
    return 1;
}

static int image_set (lua_State *L)
{
    check_args(L,3);
    uimglen_t x;
    uimglen_t y;
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    check_coord(L, 2, x, y);

    if (x>=self->width || y>=self->height) {
        std::stringstream ss;
        ss << "Pixel coordinates out of range: (" << x << "," << y << ")";
        my_lua_error(L, ss.str());
    }
    switch (self->channels()) {
        case 1: {
            Pixel<1> p;
            if (!check_pixel(L, p, 3)) my_lua_error(L, "Cannot set this value to a 1 channel image.");
            else static_cast<Image<1>*>(self)->pixel(x,y) = p;
        }
        break;

        case 2: {
            Pixel<2> p;
            if (!check_pixel(L, p, 3)) my_lua_error(L, "Cannot set this value to a 2 channel image.");
            else static_cast<Image<2>*>(self)->pixel(x,y) = p;
        }
        break;

        case 3: {
            Pixel<3> p;
            if (!check_pixel(L, p, 3)) my_lua_error(L, "Cannot set this value to a 3 channel image.");
            else static_cast<Image<3>*>(self)->pixel(x,y) = p;
        }
        break;

        case 4: {
            Pixel<4> p;
            if (!check_pixel(L, p, 3)) my_lua_error(L, "Cannot set this value to a 4 channel image.");
            else static_cast<Image<4>*>(self)->pixel(x,y) = p;
        }
        break;

        default:
        my_lua_error(L, "Internal error: image seems to have an unusual number of channels.");
    }
    return 0;
}

static int image_draw_image (lua_State *L)
{
    check_args(L,3);
    ImageBase *dst = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *src = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    uimglen_t x;
    uimglen_t y;
    check_coord(L, 3, x, y);

    switch (dst->channels()) {
        case 1: {
            Image<1> *dst_ = static_cast<Image<1>*>(dst);
            switch (src->channels()) {
                case 2: {
                    dst_->drawImageNoDestAlpha(src,x,y);
                    break;
                }
                default: my_lua_error(L, "When using drawImage to a 1 channel image, source image must have 2 channels.");
            }
        }
        break;

        case 2: {
            Image<2> *dst_ = static_cast<Image<2>*>(dst);
            switch (src->channels()) {
                case 2: {
                    dst_->drawImage(src,x,y);
                    break;
                }
                case 3: {
                    dst_->drawImageNoDestAlpha(src,x,y);
                    break;
                }
                default: my_lua_error(L, "When using drawImage to a 2 channel image, source image must have 2 or 3 channels.");
            }
        }
        break;

        case 3: {
            Image<3> *dst_ = static_cast<Image<3>*>(dst);
            switch (src->channels()) {
                case 3: {
                    dst_->drawImage(src,x,y);
                    break;
                }
                case 4: {
                    dst_->drawImageNoDestAlpha(src,x,y);
                    break;
                }
                default: my_lua_error(L, "When using drawImage to a 3 channel image, source image must have 3 or 4 channels.");
            }
        }
        break;

        case 4: {
            Image<4> *dst_ = static_cast<Image<4>*>(dst);
            switch (src->channels()) {
                case 4: {
                    dst_->drawImage(src,x,y);
                    break;
                }
                default: my_lua_error(L, "When using drawImage to a 4 channel image, source image must have 4 channels.");
            }
        }
        break;

        default:
        my_lua_error(L, "Internal error: dest image seems to have an unusual number of channels.");
    }
    return 0;
}

static int image_max (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    if (!lua_isuserdata(L,a)) {
        std::swap(a,b);
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, self->max(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot max a 1 channel image by this value.");
                else push_image(L, static_cast<Image<1>*>(self)->max(other));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot max a 2 channel image by this value.");
                else push_image(L, static_cast<Image<2>*>(self)->max(other));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot max a 3 channel image by this value.");
                else push_image(L, static_cast<Image<3>*>(self)->max(other));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot max a 4 channel image by this value.");
                else push_image(L, static_cast<Image<4>*>(self)->max(other));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

static int image_min (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    if (!lua_isuserdata(L,a)) {
        std::swap(a,b);
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, self->min(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot min a 1 channel image by this value.");
                else push_image(L, static_cast<Image<1>*>(self)->min(other));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot min a 2 channel image by this value.");
                else push_image(L, static_cast<Image<2>*>(self)->min(other));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot min a 3 channel image by this value.");
                else push_image(L, static_cast<Image<3>*>(self)->min(other));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot min a 4 channel image by this value.");
                else push_image(L, static_cast<Image<4>*>(self)->min(other));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

static int image_lerp (lua_State *L)
{
    check_args(L,3);
    float alpha = luaL_checknumber(L, 3);
    int a = 1, b = 2;
    if (!lua_isuserdata(L,a)) {
        std::swap(a,b);
        alpha = 1-alpha;
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, self->lerp(other, alpha));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot lerp a 1 channel image by this value.");
                else push_image(L, static_cast<Image<1>*>(self)->lerp(other, alpha));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot lerp a 2 channel image by this value.");
                else push_image(L, static_cast<Image<2>*>(self)->lerp(other, alpha));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot lerp a 3 channel image by this value.");
                else push_image(L, static_cast<Image<3>*>(self)->lerp(other, alpha));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot lerp a 4 channel image by this value.");
                else push_image(L, static_cast<Image<4>*>(self)->lerp(other, alpha));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

bool check_bool(lua_State *L, int i)
{
    if (!lua_isboolean(L,i)) {
        std::stringstream ss;
        ss << "Expected a boolean in argument " << i;
        my_lua_error(L, ss.str());
    }
    return lua_toboolean(L,i);
}

static int image_convolve (lua_State *L)
{
    bool wrap_x = false;
    bool wrap_y = false;
    switch (lua_gettop(L)) {
        case 4: wrap_y = check_bool(L, 4);
        case 3: wrap_x = check_bool(L, 3);
        case 2: break;
        default: 
        my_lua_error(L, "image_convolve takes 2, 3, or 4 arguments");
    }
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *kernel = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    if (kernel->channels() != 1) {
        my_lua_error(L, "Convolution kernel must have only 1 channel.");
    }
    Image<1> *kern = static_cast<Image<1>*>(kernel);
    if (kernel->width % 2 != 1) {
        my_lua_error(L, "Convolution kernel width must be an odd number.");
    }
    if (kernel->height % 2 != 1) {
        my_lua_error(L, "Convolution kernel height must be an odd number.");
    }
    push_image(L, self->convolve(kern, wrap_x, wrap_y));
    return 1;
}

static int image_convolve_sep (lua_State *L)
{
    bool wrap_x = false;
    bool wrap_y = false;
    switch (lua_gettop(L)) {
        case 4: wrap_y = check_bool(L, 4);
        case 3: wrap_x = check_bool(L, 3);
        case 2: break;
        default: 
        my_lua_error(L, "image_convolve_sep takes 2, 3, or 4 arguments");
    }
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    ImageBase *kernel_x = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    if (kernel_x->channels() != 1) {
        my_lua_error(L, "Separable convolution kernel must have only 1 channel.");
    }
    Image<1> *kern_x = static_cast<Image<1>*>(kernel_x);
    if (kern_x->width % 2 != 1) {
        my_lua_error(L, "Separable convolution kernel width must be an odd number.");
    }
    if (kern_x->height != 1) {
        my_lua_error(L, "Separable convolution kernel height must be 1.");
    }
    Image<1> *kern_y = kern_x->rotate(90);
    ImageBase *nu = self->convolve(kern_x, wrap_x, wrap_y);
    ImageBase *nu2 = nu->convolve(kern_y, wrap_x, wrap_y);
    delete nu;
    delete kern_y;
    push_image(L, nu2);
    return 1;
}

static int image_normalise (lua_State *L)
{
    check_args(L,1);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    push_image(L, self->normalise());
    return 1;
}

template<chan_t sch, chan_t dch>
Image<dch> *image_do_swizzle (const Image<sch> *src, chan_t *mapping)
{
    Image<dch> *dst = new Image<dch>(src->width, src->height);
    for (uimglen_t y=0 ; y<src->height ; ++y) {
        for (uimglen_t x=0 ; x<src->width ; ++x) {
            for (chan_t c=0 ; c<dch ; ++c) {
                dst->pixel(x,y)[c] = src->pixel(x,y)[mapping[c]];
            }
        }
    }
    return dst;
}

// key guaranteed to be at most 4 letters long and only contain wxyz
static ImageBase *image_swizzle (const ImageBase *img, chan_t nu_chans, chan_t *mapping)
{
    switch (img->channels()) {
        case 1: {
            const Image<1> *src = static_cast<const Image<1>*>(img);
            switch (nu_chans) {
                case 1: return image_do_swizzle<1,1>(src, mapping);
                case 2: return image_do_swizzle<1,2>(src, mapping);
                case 3: return image_do_swizzle<1,3>(src, mapping);
                case 4: return image_do_swizzle<1,4>(src, mapping);
                default:;
            }
        } break;
        case 2: {
            const Image<2> *src = static_cast<const Image<2>*>(img);
            switch (nu_chans) {
                case 1: return image_do_swizzle<2,1>(src, mapping);
                case 2: return image_do_swizzle<2,2>(src, mapping);
                case 3: return image_do_swizzle<2,3>(src, mapping);
                case 4: return image_do_swizzle<2,4>(src, mapping);
                default:;
            }
        } break;
        case 3: {
            const Image<3> *src = static_cast<const Image<3>*>(img);
            switch (nu_chans) {
                case 1: return image_do_swizzle<3,1>(src, mapping);
                case 2: return image_do_swizzle<3,2>(src, mapping);
                case 3: return image_do_swizzle<3,3>(src, mapping);
                case 4: return image_do_swizzle<3,4>(src, mapping);
                default:;
            }
        } break;
        case 4: {
            const Image<4> *src = static_cast<const Image<4>*>(img);
            switch (nu_chans) {
                case 1: return image_do_swizzle<4,1>(src, mapping);
                case 2: return image_do_swizzle<4,2>(src, mapping);
                case 3: return image_do_swizzle<4,3>(src, mapping);
                case 4: return image_do_swizzle<4,4>(src, mapping);
                default:;
            }
        } break;
        default:;
    }
    return NULL;
}

static int image_index (lua_State *L)
{
    check_args(L,2);
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    const char *key = luaL_checkstring(L, 2);
    if (!::strcmp(key, "channels")) {
        lua_pushnumber(L, self->channels());
    } else if (!::strcmp(key, "width")) {
        lua_pushnumber(L, self->width);
    } else if (!::strcmp(key, "height")) {
        lua_pushnumber(L, self->height);
    } else if (!::strcmp(key, "size")) {
        lua_pushvector2(L, self->width, self->height);
    } else if (!::strcmp(key, "save")) {
        lua_pushcfunction(L, image_save);
    } else if (!::strcmp(key, "foreach")) {
        lua_pushcfunction(L, image_foreach);
    } else if (!::strcmp(key, "map")) {
        lua_pushcfunction(L, image_map);
    } else if (!::strcmp(key, "reduce")) {
        lua_pushcfunction(L, image_reduce);
    } else if (!::strcmp(key, "crop")) {
        lua_pushcfunction(L, image_crop);
    } else if (!::strcmp(key, "scale")) {
        lua_pushcfunction(L, image_scale);
    } else if (!::strcmp(key, "rotate")) {
        lua_pushcfunction(L, image_rotate);
    } else if (!::strcmp(key, "clone")) {
        lua_pushcfunction(L, image_clone);
    } else if (!::strcmp(key, "flip")) {
        lua_pushcfunction(L, image_flip);
    } else if (!::strcmp(key, "mirror")) {
        lua_pushcfunction(L, image_mirror);
    } else if (!::strcmp(key, "rms")) {
        lua_pushcfunction(L, image_rms);
    } else if (!::strcmp(key, "pow")) {
        lua_pushcfunction(L, image_exp);
    } else if (!::strcmp(key, "abs")) {
        lua_pushcfunction(L, image_abs);
    } else if (!::strcmp(key, "set")) {
        lua_pushcfunction(L, image_set);
    } else if (!::strcmp(key, "max")) {
        lua_pushcfunction(L, image_max);
    } else if (!::strcmp(key, "min")) {
        lua_pushcfunction(L, image_min);
    } else if (!::strcmp(key, "lerp")) {
        lua_pushcfunction(L, image_lerp);
    } else if (!::strcmp(key, "convolve")) {
        lua_pushcfunction(L, image_convolve);
    } else if (!::strcmp(key, "convolveSep")) {
        lua_pushcfunction(L, image_convolve_sep);
    } else if (!::strcmp(key, "normalise")) {
        lua_pushcfunction(L, image_normalise);
    } else if (!::strcmp(key, "drawImage")) {
        lua_pushcfunction(L, image_draw_image);
    } else {
        chan_t nu_chans = strlen(key);
        if (nu_chans<=4) {
            bool swizzle = true;
            chan_t mapping[4];
            for (chan_t c=0 ; c<nu_chans ; ++c) {
                chan_t src_chan = 0;
                switch (key[c]) {
                    case 'x': src_chan = 0; break;
                    case 'y': src_chan = 1; break;
                    case 'z': src_chan = 2; break;
                    case 'w': src_chan = 3; break;
                    default: swizzle = false;
                }
                mapping[c] = src_chan;
                if (src_chan >= self->channels()) {
                    my_lua_error(L, "Image does not have enough channels for swizzle: \""+std::string(key)+"\"");
                }
            }
            if (swizzle) {
                push_image(L, image_swizzle(self, nu_chans, mapping));
                return 1;
            } else {
                my_lua_error(L, "Not a readable Image field: \""+std::string(key)+"\"");
            }
    
        } else {
            my_lua_error(L, "Not a readable Image field: \""+std::string(key)+"\"");
        }
    }
    return 1;
}

static int image_call (lua_State *L)
{
    uimglen_t x;
    uimglen_t y;
    switch (lua_gettop(L)) {
        case 2:
        check_coord(L, 2, x, y);
        break;
        case 3:
        x = check_t<uimglen_t>(L, 2);
        y = check_t<uimglen_t>(L, 3);
        break;
        default:
        my_lua_error(L, "Only allowed: image(x,y) or image(vector2(x,y))");
        return 1;
    }
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);

    if (x>=self->width || y>=self->height) {
        std::stringstream ss;
        ss << "Pixel coordinates out of range: (" << x << "," << y << ")";
        my_lua_error(L, ss.str());
    }
    switch (self->channels()) {
        case 1:
        push_pixel<1>(L, static_cast<Pixel<1>&>(self->pixelSlow(x,y)));
        break;

        case 2:
        push_pixel<2>(L, static_cast<Pixel<2>&>(self->pixelSlow(x,y)));
        break;

        case 3:
        push_pixel<3>(L, static_cast<Pixel<3>&>(self->pixelSlow(x,y)));
        break;

        case 4:
        push_pixel<4>(L, static_cast<Pixel<4>&>(self->pixelSlow(x,y)));
        break;

        default:
        my_lua_error(L, "Internal error: image seems to have an unusual number of channels.");
    }
    return 1;
}

static int image_add (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    if (!lua_isuserdata(L,1)) {
        std::swap(a,b);
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, self->add(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot add this value to a 1 channel image.");
                else push_image(L, static_cast<Image<1>*>(self)->add(other));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot add this value to a 2 channel image.");
                else push_image(L, static_cast<Image<2>*>(self)->add(other));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot add this value to a 3 channel image.");
                else push_image(L, static_cast<Image<3>*>(self)->add(other));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot add this value to a 4 channel image.");
                else push_image(L, static_cast<Image<4>*>(self)->add(other));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

static int image_sub (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    bool swapped = false;
    if (!lua_isuserdata(L,a)) {
        std::swap(a,b);
        swapped = true;
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, swapped ? other->sub(self) : self->sub(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot subtract this value from a 1 channel image.");
                else push_image(L, static_cast<Image<1>*>(self)->sub(other, swapped));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot subtract this value from a 2 channel image.");
                else push_image(L, static_cast<Image<2>*>(self)->sub(other, swapped));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot subtract this value from a 3 channel image.");
                else push_image(L, static_cast<Image<3>*>(self)->sub(other, swapped));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot subtract this value from a 4 channel image.");
                else push_image(L, static_cast<Image<4>*>(self)->sub(other, swapped));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

static int image_mul (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    if (!lua_isuserdata(L,a)) {
        std::swap(a,b);
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, self->mul(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot multiply a 1 channel image by this value.");
                else push_image(L, static_cast<Image<1>*>(self)->mul(other));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot multiply a 2 channel image by this value.");
                else push_image(L, static_cast<Image<2>*>(self)->mul(other));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot multiply a 3 channel image by this value.");
                else push_image(L, static_cast<Image<3>*>(self)->mul(other));
            }
            break;

            case 4: {
                Pixel<4> other;
                if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot multiply a 4 channel image by this value.");
                else push_image(L, static_cast<Image<4>*>(self)->mul(other));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

static int image_div (lua_State *L)
{
    check_args(L,2);
    int a = 1, b = 2;
    bool swapped = false;
    if (!lua_isuserdata(L,1)) {
        std::swap(a,b);
        swapped = true;
    }
    ImageBase *self = check_ptr<ImageBase>(L, a, IMAGE_TAG);
    if (lua_isuserdata(L,b)) {
        ImageBase *other = check_ptr<ImageBase>(L, b, IMAGE_TAG);
        ensure_compatible(L, self, other);
        push_image(L, swapped ? other->div(self) : self->div(other));
    } else {
        switch (self->channels()) {
            case 1: {
                Pixel<1> other;
                if (!check_pixel<1>(L, other, b)) my_lua_error(L, "Cannot divide a 1 channel image by this value.");
                else push_image(L, static_cast<Image<1>*>(self)->div(other, swapped));
            }
            break;

            case 2: {
                Pixel<2> other;
                if (!check_pixel<2>(L, other, b)) my_lua_error(L, "Cannot divide a 2 channel image by this value.");
                else push_image(L, static_cast<Image<2>*>(self)->div(other, swapped));
            }
            break;

            case 3: {
                Pixel<3> other;
                if (!check_pixel<3>(L, other, b)) my_lua_error(L, "Cannot divide a 3 channel image by this value.");
                else push_image(L, static_cast<Image<3>*>(self)->div(other, swapped));
            }
            break;

            case 4: {
                Pixel<4> other; if (!check_pixel<4>(L, other, b)) my_lua_error(L, "Cannot divide a 4 channel image by this value.");
                else push_image(L, static_cast<Image<4>*>(self)->div(other, swapped));
            }
            break;

            default:
            my_lua_error(L, "Channels must be 1, 2, 3, or 4.");
        }
    }
    return 1;
}

// alpha blend (regular blend mode in photoshop)
static int image_pow (lua_State *L)
{
    check_args(L,2);
    ImageBase *icing = NULL; // icing ^ cake
    ImageBase *cake = NULL;
    if (is_ptr(L, 1, IMAGE_TAG)) {
        icing = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    }
    if (is_ptr(L, 2, IMAGE_TAG)) {
        cake = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
    }
    if (icing == NULL && cake == NULL) {
        my_lua_error(L, "Internal error: image_pow called with neither argument being an image.");
    }
    ImageBase *nu = NULL;
    if (icing != NULL && cake != NULL) {
        if (!icing->sizeCompatibleWith(cake)) {
            my_lua_error(L, "When blending images, sizes of images did not match.");
        }
        if (icing->channels() == cake->channels()) {
            nu = cake->blendImage(icing);
        } else if (icing->channels() == cake->channels()+1) {
            nu = cake->blendImageNoDestAlpha(icing);
        } else {
            my_lua_error(L, "When blending image 'icing' onto 'cake', icing's channels must be the same or 1 more than cake's channels.");
        }
    } else {
        if (cake == NULL) {
            chan_t pch = get_pixel_channels(L, 2);
            switch (pch) {
                case 0: my_lua_error(L, "Expected an image or pixel in first parameter of image blend");
                case 1: {
                    switch(icing->channels()) {
                        case 1: {
                            // just combine alpha channels (a bit weird, but makes sense)
                            Pixel<1> p; check_pixel(L, p, 2);
                            nu = icing->blendColourSwapped(p);
                        } break;
                        case 2: {
                            // alpha blend greyscale image on top of greyscale solid colour
                            Pixel<1> p; check_pixel(L, p, 2);
                            nu = icing->blendColourNoDestAlphaSwapped(p);
                        } break;
                        case 3: {
                            // promote pixel to 1 fewer channels
                            // assume icing has an alpha channel but cake alpha channel should be effectively 1
                            Pixel<2> p; check_pixel(L, p, 2);
                            nu = icing->blendColourNoDestAlphaSwapped(p);
                        } break;
                        case 4: {
                            // promote pixel to 1 fewer channels
                            // assume icing has an alpha channel but cake alpha channel should be effectively 1
                            Pixel<3> p; check_pixel(L, p, 2);
                            nu = icing->blendColourNoDestAlphaSwapped(p);
                        } break;
                        default: my_lua_error(L, "Internal error: weird number of channels.");
                    }
                } break;
                case 2: {
                    Pixel<2> p; check_pixel(L, p, 2);
                    switch(icing->channels()) {
                        case 2: {
                            // alpha blend greyscale image on top of greyscale solid colour with alpha
                            nu = icing->blendColourSwapped(p);
                        } break;
                        case 3: {
                            // assume icing has an alpha channel but cake alpha channel should be effectively 1
                            nu = icing->blendColourNoDestAlphaSwapped(p);
                        } break;
                        default: my_lua_error(L, "Mismatch in number of channels during blend operation.");
                    }
                } break;
                case 3: {
                    Pixel<3> p; check_pixel(L, p, 2);
                    switch(icing->channels()) {
                        case 3: {
                            // alpha blend 2+a channel image on top of 2+a channel solid colour
                            nu = icing->blendColourSwapped(p);
                        } break;
                        case 4: {
                            // assume icing has an alpha channel but cake is rgb
                            nu = icing->blendColourNoDestAlphaSwapped(p);
                        } break;
                        default: my_lua_error(L, "Mismatch in number of channels during blend operation.");
                    }
                } break;
                case 4: {
                    if (icing->channels() != 4)
                        my_lua_error(L, "When blending to a 4 channel colour, need a 4 channel image");
                    Pixel<4> p; check_pixel(L, p, 2);
                    nu = icing->blendColourSwapped(p);
                } break;
            }
        } else { // icing == NULL
            chan_t pch = get_pixel_channels(L, 1);
            switch (pch) {
                case 0: my_lua_error(L, "Expected an image or pixel in first parameter of image blend");
                case 1: {
                    if (cake->channels() == 1) {
                        // just combine alpha channels (a bit weird, but makes sense)
                        Pixel<1> p; check_pixel(L, p, 1);
                        nu = cake->blendColour(p);
                    } else {
                        my_lua_error(L, "Blending a single number on top of an image of >1 channels is ambiguous.");
                    }
                } break;
                case 2: {
                    Pixel<2> p; check_pixel(L, p, 1);
                    switch(cake->channels()) {
                        case 2: {
                            // alpha blend greyscale image on top of greyscale solid colour with alpha
                            nu = cake->blendColour(p);
                        } break;
                        case 1: {
                            // assume cake has an alpha channel but cake alpha channel should be effectively 1
                            nu = cake->blendColourNoDestAlpha(p);
                        } break;
                        default: my_lua_error(L, "Internal error: weird number of channels.");
                    }
                } break;
                case 3: {
                    Pixel<3> p; check_pixel(L, p, 1);
                    switch(cake->channels()) {
                        case 3: {
                            // alpha blend 2+a channel image on top of 2+a channel solid colour
                            nu = cake->blendColour(p);
                        } break;
                        case 2: {
                            // assume cake has an alpha channel but cake is rgb
                            nu = cake->blendColourNoDestAlpha(p);
                        } break;
                        default: my_lua_error(L, "Internal error: weird number of channels.");
                    }
                } break;
                case 4: {
                    Pixel<4> p; check_pixel(L, p, 1);
                    switch(cake->channels()) {
                        case 4: {
                            // alpha blend 2+a channel image on top of 2+a channel solid colour
                            nu = cake->blendColour(p);
                        } break;
                        case 3: {
                            // assume cake has an alpha channel but cake is rgb
                            nu = cake->blendColourNoDestAlpha(p);
                        } break;
                        default: my_lua_error(L, "Internal error: weird number of channels.");
                    }
                } break;
            }
        }
    }
    push_image(L, nu);
    return 1;
}

static int image_unm (lua_State *L)
{
    check_args(L,2); // quirk of lua -- takes 2 even though 1 is unused
    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    push_image(L, self->unm());
    return 1;
}



const luaL_reg image_meta_table[] = {
    {"__tostring", image_tostring},
    {"__gc",       image_gc},
    {"__index",    image_index},
    {"__eq",       image_eq},
    {"__call",     image_call},
    {"__mul",      image_mul},
    {"__unm",      image_unm}, 
    {"__add",      image_add}, 
    {"__sub",      image_sub}, 
    {"__div",      image_div}, 
    {"__pow",      image_pow},

    {NULL, NULL}
};




/*
void push_vimage (lua_State *L, VoxelImage *image)
{
    if (image == NULL) {
        std::cerr << "INTERNAL ERROR: pushing a null image" << std::endl;
        abort();
    }
    void **self_ptr = static_cast<void**>(lua_newuserdata(L, sizeof(*self_ptr)));
    *self_ptr = image;
    luaL_getmetatable(L, VIMAGE_TAG);
    lua_setmetatable(L, -2);
}


static int vimage_gc (lua_State *L)
{ 
    check_args(L, 1); 
    VoxelImage *self = check_ptr<VoxelImage>(L, 1, VIMAGE_TAG);
    delete self; 
    return 0; 
}

static int vimage_eq (lua_State *L)
{
    check_args(L, 2); 
    VoxelImage *self = check_ptr<VoxelImage>(L, 1, VIMAGE_TAG);
    VoxelImage *that = check_ptr<VoxelImage>(L, 2, VIMAGE_TAG);
    lua_pushboolean(L, self==that); 
    return 1; 
}

static int vimage_tostring (lua_State *L)
{
    check_args(L,1);
    VoxelImage *self = check_ptr<VoxelImage>(L, 1, VIMAGE_TAG);
    std::stringstream ss;
    ss << *self;
    push_string(L, ss.str());
    return 1;
}

static int vimage_render (lua_State *L)
{
    check_args(L,3);
    VoxelImage *self = check_ptr<VoxelImage>(L, 1, VIMAGE_TAG);
    uimglen_t width, height;
    check_coord(L, 2, width, height);
    float x,y,z;
    lua_checkvector3(L, 3, &x, &y, &z);

    Image<3> *rendered = new Image<3>(width, height);

    self->render(rendered, x, y, z);

    push_image(L, rendered);
    return 1;
}

static int vimage_index (lua_State *L)
{
    check_args(L,2);
    VoxelImage *self = check_ptr<VoxelImage>(L, 1, VIMAGE_TAG);
    const char *key = luaL_checkstring(L, 2);
    if (!::strcmp(key, "width")) {
        lua_pushnumber(L, self->width);
    } else if (!::strcmp(key, "height")) {
        lua_pushnumber(L, self->height);
    } else if (!::strcmp(key, "depth")) {
        lua_pushnumber(L, self->depth);
    } else if (!::strcmp(key, "size")) {
        lua_pushvector3(L, self->width, self->height, self->depth);
    } else if (!::strcmp(key, "render")) {
        lua_pushcfunction(L, vimage_render);
    } else {
        my_lua_error(L, "Not a readable VoxelImage field: \""+std::string(key)+"\"");
    }
    return 1;
}

const luaL_reg vimage_meta_table[] = {
    {"__tostring", vimage_tostring},
    {"__gc",       vimage_gc},
    {"__index",    vimage_index},
    {"__eq",       vimage_eq},

    {NULL, NULL}
};
*/



template<chan_t ch> Image<ch> *image_from_lua_func (lua_State *L, uimglen_t width, uimglen_t height, int func_index)
{
    Image<ch> *my_image = new Image<ch>(width, height);
    Pixel<ch> p(0);
    for (uimglen_t y=0 ; y<height ; ++y) {
        for (uimglen_t x=0 ; x<width ; ++x) {
            lua_pushvalue(L, func_index);
            lua_pushvector2(L, x, y);
            int status = lua_pcall(L, 1, 1, 0); 
            if (status == 0) {
                if (!check_pixel<ch>(L, p, -1)) {
                    delete my_image;
                    const char *msg = lua_tostring(L, -1);
                    std::stringstream ss;
                    ss << "While initialising the image at (" << x << "," << y << "): returned value \""<<msg<<"\" has the wrong type.";
                    my_lua_error(L, ss.str());
                }
                my_image->pixel(x,y) = p;
            } else {
                const char *msg = lua_tostring(L, -1);
                delete my_image;
                std::stringstream ss;
                ss << "While initialising the image at (" << x << "," << y << "): " << msg;
                my_lua_error(L, ss.str());
            }
            lua_pop(L, 1);
        }   
    }   
    return my_image;
}

template<chan_t ch> Image<ch> *image_from_lua_table (lua_State *L, uimglen_t width, uimglen_t height, int tab_index)
{
    unsigned int elements = luaL_getn(L, 3);
    if (elements != width * height) {
        std::stringstream ss;
        ss << "Initialisation table for image "<<width<<"x"<<height<<" has "<<elements<<" elements.";
        my_lua_error(L, ss.str());
    }

    Image<ch> *my_image = new Image<ch>(width, height);
    Pixel<ch> p(0);
    for (uimglen_t y=0 ; y<height ; ++y) {
        for (uimglen_t x=0 ; x<width ; ++x) {
            lua_rawgeti(L, tab_index, y*width+x+1);
            if (!check_pixel<ch>(L, p, -1)) {
                delete my_image;
                const char *msg = lua_tostring(L, -1);
                std::stringstream ss;
                ss << "While initialising the image at (" << x << "," << y << "): initialisation table value \""<<msg<<"\" has the wrong type.";
                my_lua_error(L, ss.str());
            }
            my_image->pixel(x,y) = p;
            lua_pop(L, 1);
        }   
    }   
    return my_image;
}

uimglen_t fact (uimglen_t x)
{
    uimglen_t counter = 1;
    for (uimglen_t i=2 ; i<=x ; ++i) {
        counter *= i;
    }
    return counter;
}

static int global_gaussian (lua_State *L)
{
    check_args(L,1);
    uimglen_t size = check_t<uimglen_t>(L, 1);
    Image<1> *my_image = new Image<1>(size, 1);
    for (uimglen_t x=0 ; x<size ; ++x) {
        my_image->pixel(x,0) = fact(size-1) / (fact(x) * fact(size-1-x));
    }
    push_image(L, my_image->normalise());
    delete my_image;
    return 1;
    
}

static int global_make (lua_State *L)
{
    check_args(L,3);
    // sz, channels, func
    uimglen_t width, height;
    check_coord(L, 1, width, height);
    chan_t channels = check_int(L, 2, 1, 4);
    ImageBase *image = NULL;
    switch (lua_type(L, 3)) {
        case LUA_TNUMBER:  {
            if (channels != 1) my_lua_error(L, "If initial colour is a number, image must have 1 channel.");
            float init[1] = { (float) lua_tonumber(L, 3) };
            image = image_make(width, height, init);
        }
        break;
        case LUA_TVECTOR2: {
            if (channels != 2) my_lua_error(L, "If initial colour is a vector2, image must have 2 channels.");
            float init[2];
            lua_checkvector2(L, 3, &init[0], &init[1]);
            image = image_make(width, height, init);
        }
        break;
        case LUA_TVECTOR3: {
            if (channels != 3) my_lua_error(L, "If initial colour is a vector3, image must have 3 channels.");
            float init[3];
            lua_checkvector3(L, 3, &init[0], &init[1], &init[2]);
            image = image_make(width, height, init);
        }
        break;
        case LUA_TFUNCTION: {
            switch (channels) {
                case 1:
                image = image_from_lua_func<1>(L, width, height, 3);
                break;

                case 2:
                image = image_from_lua_func<2>(L, width, height, 3);
                break;

                case 3:
                image = image_from_lua_func<3>(L, width, height, 3);
                break;

                case 4:
                image = image_from_lua_func<4>(L, width, height, 3);
                break;

                default:
                my_lua_error(L, "Channels must be either 1, 2, 3, or 4.");
            }
        }
        break;
        case LUA_TTABLE: {
            switch (channels) {
                case 1:
                image = image_from_lua_table<1>(L, width, height, 3);
                break;

                case 2:
                image = image_from_lua_table<2>(L, width, height, 3);
                break;

                case 3:
                image = image_from_lua_table<3>(L, width, height, 3);
                break;

                case 4:
                image = image_from_lua_table<4>(L, width, height, 3);
                break;

                default:
                my_lua_error(L, "Channels must be either 1, 2, 3, or 4.");
            }
        }
        break;
        default:
        my_lua_error(L, "Expected a number, vector, table, or function at index 3.");
    }

    push_image(L, image);
    return 1;
}

static int global_open (lua_State *L)
{
    check_args(L,1);
    std::string filename = luaL_checkstring(L,1);
    ImageBase *image = image_load(filename);
    if (image == NULL) {
        lua_pushnil(L);
    } else {
        push_image(L, image);
    }
    return 1;
}

static int global_rgb_to_hsl (lua_State *L)
{
    check_args(L,1);
    float r,g,b;
    lua_checkvector3(L, 1, &r, &g, &b);
    float h,s,l;
    RGBtoHSL(r,g,b, h,s,l);
    lua_pushvector3(L, h,s,l);
    return 1;
}

static int global_hsl_to_rgb (lua_State *L)
{
    check_args(L,1);
    float h,s,l;
    lua_checkvector3(L, 1, &h, &s, &l);
    float r,g,b;
    HSLtoRGB(h,s,l, r,g,b);
    lua_pushvector3(L, r,g,b);
    return 1;
}

static int global_hsv_to_hsl (lua_State *L)
{
    check_args(L,1);
    float hh,ss,ll;
    lua_checkvector3(L, 1, &hh, &ss, &ll);
    float h,s,l;
    HSVtoHSL(hh,ss,ll, h,s,l);
    lua_pushvector3(L, h,s,l);
    return 1;
}

static int global_hsl_to_hsv (lua_State *L)
{
    check_args(L,1);
    float h,s,l;
    lua_checkvector3(L, 1, &h, &s, &l);
    float hh,ss,ll;
    HSLtoHSV(h,s,l, hh,ss,ll);
    lua_pushvector3(L, hh,ss,ll);
    return 1;
}

static int global_rgb_to_hsv (lua_State *L)
{
    check_args(L,1);
    float r,g,b;
    lua_checkvector3(L, 1, &r, &g, &b);
    float h,s,v;
    RGBtoHSV(r,g,b, h,s,v);
    lua_pushvector3(L, h,s,v);
    return 1;
}

static int global_hsv_to_rgb (lua_State *L)
{
    check_args(L,1);
    float h,s,v;
    lua_checkvector3(L, 1, &h, &s, &v);
    float r,g,b;
    HSVtoRGB(h,s,v, r,g,b);
    lua_pushvector3(L, r,g,b);
    return 1;
}

static int global_colour (lua_State *L)
{
    check_args(L,2);
    chan_t channels = check_int(L, 1, 1, 4);
    lua_Number f = luaL_checknumber(L, 2);
    switch (channels) {
        case 1: lua_pushnumber(L, f); break;
        case 2: lua_pushvector2(L, f, f); break;
        case 3: lua_pushvector3(L, f, f, f); break;
        case 4: lua_pushvector4(L, f, f, f, f); break;
        default: my_lua_error(L, "Internal error: weird number of channels.");
    }
    return 1;
}

static int global_lerp (lua_State *L)
{
    check_args(L,3);
    if (lua_type(L,1) != lua_type(L,2)) {
        my_lua_error(L, "First two params of lerp must be the same type.");
    }
    lua_Number a = luaL_checknumber(L,3);
    float x1,y1,z1,w1, x2,y2,z2,w2;

    switch (lua_type(L, 1)) {
        case LUA_TNUMBER: {
            lua_Number v1 = lua_tonumber(L, 1);
            lua_Number v2 = lua_tonumber(L, 2);
            lua_pushnumber(L, (1-a)*v1 + a*v2);
        } break;

        case LUA_TVECTOR2:
        lua_checkvector2(L, 1, &x1, &y1);
        lua_checkvector2(L, 2, &x2, &y2);
        lua_pushvector2(L, (1-a)*x1 + a*x2, (1-a)*y1 + a*y2);
        break;

        case LUA_TVECTOR3:
        lua_checkvector3(L, 1, &x1, &y1, &z1);
        lua_checkvector3(L, 2, &x2, &y2, &z2);
        lua_pushvector3(L, (1-a)*x1 + a*x2, (1-a)*y1 + a*y2, (1-a)*z1 + a*z2);
        break;

        case LUA_TVECTOR4:
        lua_checkvector4(L, 1, &x1, &y1, &z1, &w1);
        lua_checkvector4(L, 2, &x2, &y2, &z2, &w2);
        lua_pushvector4(L, (1-a)*x1 + a*x2, (1-a)*y1 + a*y2, (1-a)*z1 + a*z2, (1-a)*w1 + a*w2);
        break;

        case LUA_TUSERDATA: {
            ImageBase *img1 = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
            ImageBase *img2 = check_ptr<ImageBase>(L, 2, IMAGE_TAG);
            push_image(L, img1->lerp(img2, a));
        }
        break;

        default:
        my_lua_error(L, "lerp() supports number, vector2, and vector3 only.");
        break;
    }
    return 1;
}

/*
static int global_make_voxel (lua_State *L)
{
    check_args(L,2);

    ImageBase *self = check_ptr<ImageBase>(L, 1, IMAGE_TAG);
    uimglen_t depth = check_t<uimglen_t>(L, 2);
    

    uimglen_t real_height = self->height / depth;
    if (real_height * depth != self->height) {
        my_lua_error(L, "Input image must have dimensions W*H where H=cube_height*cube_depth");
    }
    VoxelImage *vi = new VoxelImage(self->pixelSlow(0,0).raw(), self->channels(), self->width, real_height, depth, true);

    push_vimage(L, vi);
    return 1;
}
*/

static const luaL_reg global[] = {
    {"make", global_make},
    {"open", global_open},
    {"RGBtoHSL", global_rgb_to_hsl},
    {"HSLtoRGB", global_hsl_to_rgb},
    {"HSVtoHSL", global_hsv_to_hsl},
    {"HSLtoHSV", global_hsl_to_hsv},
    {"RGBtoHSV", global_rgb_to_hsv},
    {"HSVtoRGB", global_hsv_to_rgb},
    {"lerp", global_lerp},
    {"colour", global_colour},
    {"gaussian", global_gaussian},
 //   {"make_voxel", global_make_voxel},

    {NULL, NULL}
};


void lua_wrappers_image_init (lua_State *L)
{
    luaL_newmetatable(L, IMAGE_TAG);
    luaL_register(L, NULL, image_meta_table);
    lua_pop(L,1);

/*
    luaL_newmetatable(L, VIMAGE_TAG);
    luaL_register(L, NULL, vimage_meta_table);
    lua_pop(L,1);
*/

    luaL_register(L, "_G", global);
    lua_pop(L, 1);
}

void lua_wrappers_image_shutdown (lua_State *L)
{
    (void) L;
}
