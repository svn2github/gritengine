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

#ifndef IO_UTIL_H
#define IO_UTIL_H

#include <cstdlib>
#include <cstdio>
#include <cstring>

#include <string>
#include <iostream>
#include <fstream>

#include "exception.h"

void io_util_open (const std::string &filename, std::ofstream &out);
void io_util_open (const std::string &filename, std::ifstream &in);

template<class T> void io_util_write (const std::string &filename, std::ostream &out, const T &v)
{
    out.write((char*)&v, sizeof(v));
    if (!out.good()) {
        EXCEPT<<filename<<": "<<std::string(strerror(errno))<<std::endl;
    }   
}

template<class T> void io_util_read (const std::string &filename, std::istream &in, T &v)
{
    in.read((char*)&v, sizeof(v));
    if (!in.good()) {
        EXCEPT<<filename<<": "<<std::string(strerror(errno))<<std::endl;
    }   

}

#endif