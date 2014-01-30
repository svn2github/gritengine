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

class GfxTextBuffer;

#ifndef GFX_TEXT_BUFFER_H
#define GFX_TEXT_BUFFER_H

#include <cstdint>

#include <OgreHardwareBufferManager.h>
#include <OgreHardwareVertexBuffer.h>
#include <OgreHardwareIndexBuffer.h>

#include <math_util.h>

#include "GfxFont.h"

/** Encapsulate the code required to build GPU buffers for rendering text.*/
class GfxTextBuffer {

    GfxFont *font;

    Ogre::VertexData vData;
    Ogre::IndexData iData;
    Ogre::HardwareVertexBufferSharedPtr vBuf;
    Ogre::HardwareIndexBufferSharedPtr iBuf;
    Ogre::RenderOperation op;
    unsigned currentGPUCapacity; // due to lazy update, lags behind

    std::vector<float> rawVBuf;
    std::vector<uint16_t> rawIBuf;
    unsigned currentSize;
    Vector2 currentDimensions;

    Vector2 currentOffset;

    Vector2 wrap;

    bool dirty;

    public:

    GfxTextBuffer (GfxFont *font);

    ~GfxTextBuffer (void)
    {
        clear(true);
        vData.vertexDeclaration = NULL; // save OGRE from itself
    }

    /** Reset the buffer. */
    void clear (bool clear_gpu)
    {
        rawVBuf.clear();
        rawIBuf.clear();
        currentDimensions = Vector2(0,0);
        currentOffset = Vector2(0,0);
        currentSize = 0;
        dirty = true;
        if (clear_gpu) {
            copyToGPUIfNeeded(); // clear GPU buffers, (note this sets dirty = false again)
        }
    }

    struct Char {
        GfxFont::codepoint_t cp;
        Vector3 topColour;
        float topAlpha;
        Vector3 botColour;
        float botAlpha;
    };

    /** Basic interface: add a character. */
    void addRawChar (const Char &c);

    /** How many chars of the given word will fit on the rest of the line? */
    unsigned wordFit (const std::vector<Char> &word);

    /** Basic interface: add a word.  Obeys wrap, wraps if necessary. */
    void addRawWord (const std::vector<Char> &word);

    /** Basic interface: increase indent to next tab level. */
    void addTab (void);

    /** Basic interface: end of line.  Returns true if new line exceeds wrap.y. */
    void endLine (void);

    /** High level interface: Add a string that can contain \n,\t and ansi terminal colours.
     * \param text The text in UTF8.
     * \param top_colour and friends: Initial colours, overriden by use of ansi terminal colours.
     */
    void addFormattedString (const std::string &text, Vector3 top_colour, float top_alpha, Vector3 bot_colour, float bot_alpha);

    /** Sets the font (note that text will be corrupted unless font has compatible UVs, so consider clear() as well. */
    void setFont (GfxFont *v) { font = v; }

    /** Returns the font. */
    GfxFont *getFont (void) const { return font; }

    /** Returns the size of the text rectangle in pixels. */
    const Vector2 &getDimensions (void) const { return currentDimensions; }

    /** Set the max size.  This is used to wrap text during addFormattedString. */
    void setWrap (const Vector2 &v) { wrap = v; }

    /** Returns the max size. \see setWrap */
    const Vector2 &getWrap (void) const { return wrap; }

    /** Get an operation that can be used to render this text buffer. */
    const Ogre::RenderOperation &getRenderOperation (void) const { return op; }

    /** Copy the buffer to the GPU, enlarging GPU buffers if necessary. */
    void copyToGPUIfNeeded ();

};

#endif
