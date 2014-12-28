/* Copyright (c) David Cunningham and the Grit Game Engine project 2015
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

#include <vector>
#include <string>
#include <iostream>
#include <fstream>

#include "console.h"
#include "exception.h"
#include "io_util.h"

InFile::InFile (const std::string &filename)
  : filename(filename)
{
    in.open(filename);
    if (!in.good()) {
        EXCEPT<<filename<<": "<<std::string(strerror(errno))<<std::endl;
    }
}

OutFile::OutFile (const std::string &filename)
  : filename(filename)
{
    out.open(filename);
    if (!out.good()) {
        EXCEPT<<filename<<": "<<std::string(strerror(errno))<<std::endl;
    }
}

static std::string collapse_path (const std::string &path)
{
    // first split into dirs
    std::vector<std::string> dirs;
    std::string next;
    for (unsigned i=0 ; i<path.length() ; ++i) {
        if (path[i] == '/') {
            dirs.push_back(next);
            next.clear();
        } else {
            next += path[i];
        }
    }
    dirs.push_back(next);

    std::vector<std::string> dirs2;
    // process ..
    for (unsigned i=0 ; i<dirs.size() ; ++i) {
        const std::string &d = dirs[i];
        if (d == ".") {
            continue;
        } else if (d == "..") {
            if (dirs2.size() == 0)
                EXCEPT << "Invalid path: " << path << ENDL;
            dirs2.pop_back();
        } else if (d == "") {
            continue;
        } else {
            dirs2.push_back(d);
        }
    }

    std::stringstream ss;
    for (unsigned i=0 ; i<dirs2.size() ; ++i) {
        ss << "/" + dirs2[i];
    }
    return ss.str();
}

std::string absolute_path (const std::string &dir, const std::string &rel)
{
    APP_ASSERT(dir[0] == '/');
    if (rel[0] == '/') return collapse_path(rel);
    return collapse_path(dir + rel);
}
