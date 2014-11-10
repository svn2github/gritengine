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

#include "windows.h"
#include <Commdlg.h>
#include <string>
#include"OgreRenderWindow.h"
#include "OgreSceneQuery.h"
#include "gfx/gfx_pipeline.h"
#include "gfx/gfx_body.h"

// Opens a "Open File Dialog", and returns the filepath
std::string open_file_dialog(std::string windowTitle, const char* fileTypes);

// Opens a "Save File Dialog", and returns the filepath
std::string save_file_dialog(std::string windowTitle, const char* fileTypes, std::string defaultExt);

void grit_editor_init(Ogre::RenderWindow *ow, Ogre::SceneManager* sm);

GfxBodyPtr mouse_pick(float mouseScreenX, float mouseScreenY, Ogre::Vector3 cam_pos, Ogre::Quaternion cam_orientation);

Ogre::Vector3 get_mouse_world_dir(Ogre::Vector2 mouse_pos, Ogre::Vector3 cam_pos, Ogre::Quaternion cam_dir);