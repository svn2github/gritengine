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

#ifndef SplineTable_h
#define SplineTable_h

#include <cstdlib>
#include <map>

#include "math_util.h"

/** Specialised function for returning a zero value for a given type. */
template<class T> inline T zero (void) { return 0; }
template<> inline Vector3 zero<Vector3> (void) { return Vector3(0,0,0); }
template<> inline Vector2 zero<Vector2> (void) { return Vector2(0,0); }

/** Flatten out the tangent t to zero if the current value is outside the range of prev and next. */
template<class T> inline T fix_tangent (T prev, T curr, T next, T t)
{
        if (next==curr || prev==curr) return 0;
        if (prev > curr && next > curr) return 0; // minimum
        if (prev < curr && next < curr) return 0; // maximum
        return t;
}

template<> inline Vector3 fix_tangent (Vector3 prev, Vector3 curr, Vector3 next, Vector3 t)
{
        return Vector3(
                fix_tangent(prev.x, curr.x, next.x, t.x),
                fix_tangent(prev.y, curr.y, next.y, t.y),
                fix_tangent(prev.z, curr.z, next.z, t.z)
        );
}

template<> inline Vector2 fix_tangent (Vector2 prev, Vector2 curr, Vector2 next, Vector2 t)
{
        return Vector2(
                fix_tangent(prev.x, curr.x, next.x, t.x),
                fix_tangent(prev.y, curr.y, next.y, t.y)
        );
}

/** Class that allows defining a curve of values at given increments along a
 * scalar x axis.  First points are added, then commit() is called.  Then the
 * class will interpolate looked-up x values.
 *
 * See: http://en.wikipedia.org/wiki/Cubic_Hermite_spline
 */
template<class T> class SplineTable {

    public:

        /** Define a new point in the spline.
         */
        void addPoint (float x, T y)
        {
                points[x] = y;
        }

        /** Does all the precomputation that is require to interpolate lookups.
         * This is essentially just computing tangents at all the points.
         */
        void commit (void)
        {
                // calculate tangents
                if (points.size()==0) return;
                if (points.size()==1) {
                        tangents[points.begin()->first] = zero<T>();
                        return;
                }
                if (points.size()==2) {
                        typename Map::iterator i = points.begin();
                        float lastx = i->first;
                        T lasty = i->second;
                        i++;
                        float nextx = i->first;
                        T nexty = i->second;
                        tangents[lastx] = tangents[nextx]
                                        = (nexty-lasty)/(nextx-lastx);
                        return;
                }

                {
                        MI i;
                        i = points.begin();
                        float lastx = i->first;
                        T lasty = i->second;
                        i++;
                        float nextx = i->first;
                        T nexty = i->second;
                        tangents[lastx] = (nexty-lasty)/(nextx-lastx);
                }

                MI next = points.begin(); std::advance(next,2);
                MI curr = points.begin(); std::advance(curr,1);
                MI last = points.begin(); std::advance(last,0);
                for (MI i_=points.end() ; next!=i_  ; next++, curr++, last++ ) {
                        float lastx = last->first;
                        T lasty = last->second;
                        float nextx = next->first;
                        T nexty = next->second;
                        T curry = curr->second;
                        tangents[curr->first] = fix_tangent(lasty,curry,nexty,(nexty-lasty)/(nextx-lastx));
                }

                {
                        MI i;
                        i = points.end(); std::advance(i,-2);
                        float lastx = i->first;
                        T lasty = i->second;
                        i++;
                        float nextx = i->first;
                        T nexty = i->second;
                        tangents[nextx] = (nexty-lasty)/(nextx-lastx);
                }

        }

        /** Return the highest x value for which a point was defined. */
        float maxX (void) {
                MI i = points.end();
                i--;
                return i->first;
        }

        /** Return the lowest x value for which a point was defined. */
        float minX (void) {
                MI i = points.begin();
                return i->first;
        }

        /** Return an interpolated value at the given x value. */
        T operator[] (float x) {
                if (points.size()==0) return zero<T>();
                if (points.size()==1) return points.begin()->second;

                {
                        float minx = minX(), maxx = maxX();
                        if (x<=minx) {
                                return points[minx] + (x-minx)*tangents[minx];
                        }
                        if (x>=maxx) {
                                return points[maxx] + (x-maxx)*tangents[maxx];
                        }
                }

                // note that due to the minx early return we do not need
                // to initialise these
                float x0 = 0;
                T y0 = zero<T>();

                for (MI i=points.begin(), i_=points.end() ; i!=i_ ; ++i) {
                        if (i->first > x) {
                                // i never == points.begin()
                                float x1 = i->first;
                                T y1 = i->second;
                                T m0 = tangents[x0], m1 = tangents[x1];
                                float h = x1 - x0;
                                float t = (x - x0)/h;
                                T r = zero<T>();
                                r += (1+2*t)*(1-t)*(1-t  ) * y0;
                                r += (    t)*(1-t)*(1-t  ) * h*m0;
                                r += (    t)*(t  )*(3-2*t) * y1;
                                r += (    t)*(t  )*(t-1  ) * h*m1;
                                return r;
                        }
                        x0 = i->first;
                        y0 = i->second;
                }
                // should never get here
                abort();
                return zero<T>();  // MSVC doesn't understand abort()
        }

        typedef std::map<float,T> Map;
        typedef typename Map::iterator MI;

        const Map &getTangents (void) const { return tangents; }
        const Map &getPoints (void) const { return points; }

    protected:

        Map points;
        Map tangents;

};

typedef SplineTable<float> Plot;
typedef SplineTable<Vector3> PlotV3;
typedef SplineTable<Vector2> PlotV2;


#endif

// vim: tabstop=8:shiftwidth=8:expandtab
