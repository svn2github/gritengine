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

// Based on http://www.ogre3d.org/wiki/index.php/BulletDebugDrawer
// copyright ownership unknown

#ifndef BulletDebugDrawer_h
#define BulletDebugDrawer_h

#include <OgreFrameListener.h>
#include <OgreManualObject.h>

#include <btBulletCollisionCommon.h>

class BulletDebugDrawer: public btIDebugDraw
{
public:
    BulletDebugDrawer (Ogre::SceneManager *scm );
    ~BulletDebugDrawer (void);
    virtual void    drawLine (const btVector3 &from, const btVector3 &to, const btVector3 &color);
    virtual void    drawTriangle (const btVector3 &v0, const btVector3 &v1, const btVector3 &v2, const btVector3 &color, btScalar);
    virtual void    drawContactPoint (const btVector3 &PointOnB, const btVector3 &normalOnB, btScalar distance, int lifeTime, const btVector3 &color);
    virtual void    reportErrorWarning (const char *warningString);
    virtual void    draw3dText (const btVector3 &location, const char *textString);
    virtual void    setDebugMode (int debugMode);
    virtual int     getDebugMode () const;
    bool frameStarted (void);
    bool frameEnded (void);
private:
    struct ContactPoint{
        Ogre::Vector3 from;
        Ogre::Vector3 to;
        Ogre::ColourValue   color;
        size_t        dieTime;
    };
    DebugDrawModes             mDebugModes;
    Ogre::ManualObject        *mLines;
    Ogre::ManualObject        *mTriangles;
    Ogre::MaterialPtr          mat;
    std::vector<ContactPoint> *mContactPoints;
    std::vector<ContactPoint>  mContactPoints1;
    std::vector<ContactPoint>  mContactPoints2;
};


#endif
