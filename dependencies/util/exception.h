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

#ifndef EXCEPTION_H
#define EXCEPTION_H

#include <cstdlib>
#include <string>
#include <sstream>
#include <iostream>

#include "intrinsics.h"

#define EXCEPTEX ExceptionStream(__FILE__,__LINE__)
#define EXCEPT ExceptionStream()
#define ENDL ExceptionStream::EndL()

#define ASSERT(x) do { if (!(x)) { EXCEPTEX << "Assertion failed: " << #x << std::endl; } } while (0)

#define HANDLE_BEGIN try {
#define HANDLE_END } catch (Exception &e) { my_lua_error(L, "Exception: "+e.msg); }

/** Simple exception object encapsulates a string. */
struct Exception {
    const std::string msg;
    Exception(const std::string &msg)
      : msg(msg) { }
};

/** Allows printing an exception to a stream. */
inline std::ostream &operator << (std::ostream &o, const Exception &e)
{ o << e.msg; return o; }

class ExceptionStream {

    std::stringstream ss;

    public:

    struct EndL { };

    ExceptionStream (const char *file, int line)
    {
        (*this)<<"Internal error at: ("<<file<<":"<<line<<"): ";
    }

    ExceptionStream ()
    {
    }

    ~ExceptionStream (void)
    {
    }

    typedef std::ostream &manip(std::ostream&);

    NORETURN1 ExceptionStream &operator<< (EndL) NORETURN2
    {
        throw Exception(ss.str());
    }

    ExceptionStream &operator<< (manip *o)
    {
        if (o == (manip*)std::endl) {
            throw Exception(ss.str());
        } else {
            ss << o;
        }
        return *this;
    }

    template<typename T> ExceptionStream &operator<<(T const &o)
    {
        ss << o;
        return *this;
    }

};

#endif
