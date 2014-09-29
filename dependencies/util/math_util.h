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

#ifndef MATH_UTIL_H
#define MATH_UTIL_H

#include <string>
#include <iostream>

struct Radian;
struct Degree;
struct Quaternion;
struct Vector3;

#include <cmath>
#include <cfloat>

#ifdef WIN32
#define my_isnan _isnan
#else
#define my_isnan isnan
#endif

#ifndef M_PI
#define M_PI 3.1415926535897932385f
#endif


template<class T> bool between (T x, T m, T M) { return std::less<T>()(m,x)&&std::less<T>()(x,M); }


// {{{ Degree & Radian

struct Radian {
    explicit Radian (float f_) : f(f_) { }
    Radian (void) { }
    Radian (const Degree &d);
    Radian (const Radian &r) : f(r.f) { }
    float inDegrees (void) const { return f / M_PI * 180; }
    float inRadians (void) const { return f; }
    Radian &operator = (const Radian &o) { f = o.inRadians(); return *this; }
    Radian operator - (void) { return Radian(-f); }
    Radian operator + (const Radian &r) { return Radian(f+r.f); }
    protected:
    float f;
};

struct Degree {
    explicit Degree (float f_) : f(f_) { }
    Degree (void) { }
    Degree (const Radian &r) : f(r.inDegrees()) { }
    Degree (const Degree &r) : f(r.f) { }
    float inDegrees (void) const { return f; }
    float inRadians (void) const { return f * M_PI / 180; }
    Degree &operator = (const Degree &o) { f = o.inDegrees(); return *this; }
    Degree operator - (void) { return Degree(-f); }
    Degree operator + (const Degree &r) { return Degree(f+r.f); }
    protected:
    float f;
};

inline Radian::Radian (const Degree &d) : f(d.inRadians()) { }

inline float gritcos (Radian r) { return cosf(r.inRadians()); }
inline float gritsin (Radian r) { return sinf(r.inRadians()); }
inline Radian gritacos (float x) { return Radian(acosf(x)); }
inline Radian gritasin (float x) { return Radian(asinf(x)); }

// }}}




// {{{ Quaternion

struct Quaternion {

    float w, x, y, z;

    Quaternion () { }
    Quaternion (float w_, float x_, float y_, float z_) : w(w_), x(x_), y(y_), z(z_) { }
    Quaternion (const Radian& a, const Vector3& axis);

    Quaternion& operator= (const Quaternion& o)
    { w = o.w; x = o.x; y = o.y; z = o.z; return *this; }
    friend Quaternion operator+ (const Quaternion& a, const Quaternion& b)
    { return Quaternion(a.w+b.w, a.x+b.x, a.y+b.y, a.z+b.z); }
    friend Quaternion operator- (const Quaternion& a, const Quaternion& b)
    { return Quaternion(a.w-b.w, a.x-b.x, a.y-b.y, a.z-b.z); }
    friend Quaternion operator* (const Quaternion& a, const Quaternion& b)
    {
        return Quaternion (a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
                           a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
                           a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z,
                           a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x);
    }
    friend Quaternion operator* (float a, const Quaternion& b)
    { return Quaternion(a*b.w, a*b.x, a*b.y, a*b.z); }
    friend Quaternion operator* (const Quaternion& a, float b)
    { return Quaternion(b*a.w, b*a.x, b*a.y, b*a.z); }
    friend Quaternion operator/ (float a, const Quaternion& b)
    { return Quaternion(a/b.w, a/b.x, a/b.y, a/b.z); }
    friend Quaternion operator/ (const Quaternion& a, float b)
    { return Quaternion(a.w/b, a.x/b, a.y/b, a.z/b); }
    friend Quaternion &operator*= (Quaternion& a, float b)
    { a = a * b; return a; }
    friend Quaternion &operator/= (Quaternion& a, float b)
    { a = a / b; return a; }
    friend Quaternion &operator+= (Quaternion& a, Quaternion &b)
    { a = a + b; return a; }
    friend Quaternion &operator*= (Quaternion& a, Quaternion &b)
    { a = a * b; return a; }
        

    Quaternion operator- () const { return Quaternion(-w,-x,-y,-z); }

    friend bool operator== (const Quaternion &a, const Quaternion &b)
    { return a.w==b.w && a.x==b.x && a.y==b.y && a.z==b.z; }

    friend bool operator!= (const Quaternion &a, const Quaternion &b) { return !(a == b); }

    float dot (const Quaternion &o) const { return w*o.w + x*o.x + y*o.y + z*o.z; }
    float length2 () const { return dot(*this); }
    float length () const { return ::sqrtf(length2()); }

    float normalise (void) { float l = this->length(); *this /= l; return l; }
    Quaternion normalisedCopy (void) const { Quaternion q = *this; q.normalise(); return q; }


    Quaternion unitInverse (void) const
    { return Quaternion(w,-x,-y,-z); }
    Quaternion inverse (void) const
    { return this->normalisedCopy().unitInverse(); }

    bool isNaN() const { return my_isnan(w) || my_isnan(x) || my_isnan(y) || my_isnan(z); }

    friend std::ostream& operator << (std::ostream& o, const Quaternion& q)
    {
        o << "Quaternion(" << q.w << ", " << q.x << ", " << q.y << ", " << q.z << ")";
        return o;
    } 

    void toMat (float (&mat)[3][3]) const
    {
        mat[0][0] = 1 - 2 * (y*y + z*z);
        mat[0][1] =     2 * (x*y - z*w);
        mat[0][2] =     2 * (x*z + y*w);

        mat[1][0] =     2 * (x*y + z*w);
        mat[1][1] = 1 - 2 * (x*x + z*z);
        mat[1][2] =     2 * (y*z - x*w);

        mat[2][0] =     2 * (x*z - y*w);
        mat[2][1] =     2 * (y*z + x*w);
        mat[2][2] = 1 - 2 * (x*x + y*y);
    }

};

// }}}


// {{{ Vector3

struct Vector3 {
    float x, y, z;

    Vector3 (void) { }
    Vector3 (float x_, float y_, float z_) : x(x_), y(y_), z(z_) { }

    Vector3& operator = (const Vector3& o)
    {
        x = o.x; y = o.y; z = o.z;
        return *this;
    }

    friend bool operator == (const Vector3 &a, const Vector3& b)
    { return a.x==b.x && a.y==b.y && a.z==b.z; }
    friend bool operator != (const Vector3 &a, const Vector3& b)
    { return ! (a==b); }
    friend bool operator < (const Vector3 &a, const Vector3& b)
    { return a.x<b.x && a.y<b.y && a.z<b.z; }
    friend bool operator > (const Vector3 &a, const Vector3& b)
    { return a.x>b.x && a.y>b.y && a.z>b.z; }
    friend bool operator <= (const Vector3 &a, const Vector3& b)
    { return a.x<=b.x && a.y<=b.y && a.z<=b.z; }
    friend bool operator >= (const Vector3 &a, const Vector3& b)
    { return a.x>=b.x && a.y>=b.y && a.z>=b.z; }

    friend Vector3 operator + (const Vector3 &a, const Vector3& b)
    { return Vector3(a.x+b.x, a.y+b.y, a.z+b.z); }
    friend Vector3 operator - (const Vector3 &a, const Vector3& b)
    { return Vector3(a.x-b.x, a.y-b.y, a.z-b.z); }
    friend Vector3 operator * (const Vector3 &a, const Vector3& b)
    { return Vector3(a.x*b.x, a.y*b.y, a.z*b.z); }
    friend Vector3 operator / (const Vector3 &a, const Vector3& b)
    { return Vector3(a.x/b.x, a.y/b.y, a.z/b.z); }

    friend Vector3 operator * (const float a, const Vector3& b)
    { return Vector3(a*b.x, a*b.y, a*b.z); }
    friend Vector3 operator * (const Vector3 &b, const float a)
    { return Vector3(a*b.x, a*b.y, a*b.z); }

    friend Vector3 operator / (const float a, const Vector3& b)
    { return Vector3(a/b.x, a/b.y, a/b.z); }
    friend Vector3 operator / (const Vector3 &a, const float b)
    { return a * (1/b); }

    friend const Vector3 &operator + (const Vector3& a)
    { return a; }
    friend Vector3 operator - (const Vector3& a)
    { return Vector3(-a.x, -a.y, -a.z); }

    friend Vector3 &operator += (Vector3 &a, const Vector3& b)
    { a.x+=b.x, a.y+=b.y, a.z+=b.z; return a; }
    friend Vector3 &operator += (Vector3 &a, const float b)
    { a.x+=b, a.y+=b, a.z+=b; return a; }
    friend Vector3 &operator -= (Vector3 &a, const Vector3& b)
    { a.x-=b.x, a.y-=b.y, a.z-=b.z; return a; }
    friend Vector3 &operator -= (Vector3 &a, const float b)
    { a.x-=b, a.y-=b, a.z-=b; return a; }
    friend Vector3 &operator *= (Vector3 &a, const Vector3& b)
    { a.x*=b.x, a.y*=b.y, a.z*=b.z; return a; }
    friend Vector3 &operator *= (Vector3 &a, const float b)
    { a.x*=b, a.y*=b, a.z*=b; return a; }
    friend Vector3 &operator /= (Vector3 &a, const Vector3& b)
    { a.x/=b.x, a.y/=b.y, a.z/=b.z; return a; }
    friend Vector3 &operator /= (Vector3 &a, const float b)
    { a.x/=b, a.y/=b, a.z/=b; return a; }

    float length2 (void) const { return this->dot(*this); }
    float length (void) const { return ::sqrtf(length2()); }

    float distance (const Vector3& o) const
    { return (*this - o).length(); }
    float distance2 (const Vector3& o) const
    { return (*this - o).length2(); }

    float dot (const Vector3& o) const { return x*o.x + y*o.y + z*o.z; }

    float normalise (void) { float l=length(); *this /= l; return l; }

    Vector3 cross (const Vector3& o) const
    { return Vector3(y*o.z - z*o.y,  z*o.x - x*o.z,  x*o.y - y*o.x); }

    Vector3 midPoint (const Vector3& o) const
    { return (*this+o)/2; }

    Radian angleBetween (const Vector3& o) const
    {
        float lp = ::sqrtf(length2() * o.length2());
        return Radian(acosf(this->dot(o) / lp));
    }

    bool isZeroLength (void) { return length2() < 1e-12; }

    // taken from OGRE (MIT license)
    Quaternion getRotationTo (Vector3 v1)
    {
        // Based on Stan Melax's article in Game Programming Gems
        // Copy, since cannot modify local
        Vector3 v0 = *this;
        v0.normalise();
        v1.normalise();

        float d = v0.dot(v1);
        // If dot == 1, vectors are the same
        if (d >= 1.0f) return Quaternion(1,0,0,0);

        if (d < (1e-6f - 1.0f)) {

            // rotate 180 degrees about the fallback axis
            // Generate an axis
            Vector3 axis = Vector3(1,0,0).cross(*this);
            if (axis.isZeroLength()) // pick another if colinear
                axis = Vector3(0,1,0).cross(*this);
            axis.normalise();
            return Quaternion(0, axis.x, axis.y, axis.z);

        } else {

            float s = ::sqrtf((1+d)*2);
            Vector3 axis = v0.cross(v1) / s;
            return Quaternion(s*0.5f, axis.x, axis.y, axis.z).normalisedCopy();

        }
    }

    // taken from OGRE (MIT license)
    Quaternion getRotationTo (Vector3 v1, const Vector3& fbaxis) const
    {
        // Based on Stan Melax's article in Game Programming Gems
        // Copy, since cannot modify local
        Vector3 v0 = *this;
        v0.normalise();
        v1.normalise();

        float d = v0.dot(v1);
        // If dot == 1, vectors are the same
        if (d >= 1.0f) return Quaternion(1,0,0,0);

        if (d < (1e-6f - 1.0f)) {

            // rotate 180 degrees about the fallback axis
            return Quaternion(0, fbaxis.x, fbaxis.y, fbaxis.z);

        } else {

            float s = ::sqrtf((1+d)*2);
            Vector3 axis = v0.cross(v1) / s;
            return Quaternion(s*0.5f, axis.x, axis.y, axis.z).normalisedCopy();

        }
    }

    Vector3 normalisedCopy (void) const
    { return *this / this->length(); }

    Vector3 reflect(const Vector3& normal) const
    { return *this - (2 * this->dot(normal) * normal); }

    /// Check whether this vector contains valid values
    bool isNaN (void) const
    { return my_isnan(x) || my_isnan(y) || my_isnan(z); }

    friend std::ostream& operator << (std::ostream& o, const Vector3& v)
    {
        o << "Vector3(" << v.x << ", " << v.y << ", " << v.z << ")";
        return o;
    }
};

// rotation of a vector by a quaternion
inline Vector3 operator * (const Quaternion &q, const Vector3& v)
{
    // nVidia SDK implementation
    Vector3 axis(q.x, q.y, q.z);
    Vector3 uv = axis.cross(v);
    Vector3 uuv = axis.cross(uv);
    uv *= (2.0f * q.w);
    uuv *= 2.0f;
    return v + uv + uuv;
}

inline Quaternion::Quaternion (const Radian& a, const Vector3& axis)
{
    float ha ( 0.5f*a.inRadians() );
    float s = sinf(ha);
    w = cosf(ha);
    x = s*axis.x;
    y = s*axis.y;
    z = s*axis.z;
}

// }}}


// {{{ Transform

// this class may be buggy...
struct Transform {

    Vector3 pos; // position
    float mat[3][3]; // to be interpreted as mat[row][col]

    Transform (void) { }
    Transform (const Vector3 &p, const Quaternion &r, const Vector3 &s)
    {
        pos = p;
        r.toMat(mat);
        for (int i=0 ; i<3 ; ++i) {
            mat[i][0] *= s.x;
            mat[i][1] *= s.y;
            mat[i][2] *= s.z;
        }
    }

    static Transform identity (void)
    {
        Transform t;
        t.pos = Vector3(0,0,0);
        for (int row=0 ; row<3 ; ++row) {
            for (int col=0 ; col<3 ; ++col) {
                t.mat[row][col] = row==col? 1 : 0;
            }
        }
        return t;
    }

    friend Vector3 operator * (const Transform &a, const Vector3 &b)
    {
        Vector3 c = a.pos;
        c.x += a.mat[0][0]*b.x + a.mat[0][1]*b.y + a.mat[0][2]*b.z;
        c.y += a.mat[1][0]*b.x + a.mat[1][1]*b.y + a.mat[1][2]*b.z;
        c.z += a.mat[2][0]*b.x + a.mat[2][1]*b.y + a.mat[2][2]*b.z;
        return c;
    }

    friend Transform operator * (const Transform &a, const Transform &b)
    {
        Transform t;
        for (int row=0 ; row<3 ; ++row) {
            for (int col=0 ; col<3 ; ++col) {
                t.mat[row][col] = 0;
                for (int i=0 ; i<3 ; ++i) {
                    t.mat[row][col] += a.mat[row][i] * b.mat[i][col];
                }
            }
        }
        t.pos = a * b.pos;
        return t;
    }

    Transform removeTranslation (void) const
    {
        Transform t = *this;
        t.pos = Vector3(0,0,0);
        return t;
    }

};


// }}}


// {{{ SimpleTransform (does not handle scale)

struct SimpleTransform {

    Vector3 pos; // position
    Quaternion quat; // rotation

    SimpleTransform (void) { }
    SimpleTransform (const Vector3 &p, const Quaternion &r)
    {
        pos = p;
        quat = r;
    }

    static SimpleTransform identity (void)
    {
        SimpleTransform t;
        t.pos = Vector3(0,0,0);
        t.quat = Quaternion(1,0,0,0);
        return t;
    }

    friend Vector3 operator * (const SimpleTransform &a, const Vector3 &b)
    {
        return a.pos + a.quat * b;
    }

    friend SimpleTransform operator * (const SimpleTransform &a, const SimpleTransform &b)
    {
        return SimpleTransform(a.pos + a.quat*b.pos, a.quat*b.quat);
    }

    SimpleTransform removeTranslation (void) const
    {
        SimpleTransform t = *this;
        t.pos = Vector3(0,0,0);
        return t;
    }

};


// }}}


// {{{ Vector2

struct Vector2 {
    float x, y;

    Vector2 (void) { }
    Vector2 (float x_, float y_) : x(x_), y(y_) { }

    Vector2& operator = (const Vector2& o)
    {
        x = o.x; y = o.y;
        return *this;
    }

    friend bool operator == (const Vector2 &a, const Vector2& b)
    { return a.x==b.x && a.y==b.y; }
    friend bool operator != (const Vector2 &a, const Vector2& b)
    { return ! (a==b); }
    friend bool operator < (const Vector2 &a, const Vector2& b)
    { return a.x<b.x && a.y<b.y; }
    friend bool operator > (const Vector2 &a, const Vector2& b)
    { return a.x>b.x && a.y>b.y; }
    friend bool operator <= (const Vector2 &a, const Vector2& b)
    { return a.x<=b.x && a.y<=b.y; }
    friend bool operator >= (const Vector2 &a, const Vector2& b)
    { return a.x>=b.x && a.y>=b.y; }

    friend Vector2 operator + (const Vector2 &a, const Vector2& b)
    { return Vector2(a.x+b.x, a.y+b.y); }
    friend Vector2 operator - (const Vector2 &a, const Vector2& b)
    { return Vector2(a.x-b.x, a.y-b.y); }
    friend Vector2 operator * (const Vector2 &a, const Vector2& b)
    { return Vector2(a.x*b.x, a.y*b.y); }
    friend Vector2 operator / (const Vector2 &a, const Vector2& b)
    { return Vector2(a.x/b.x, a.y/b.y); }

    friend Vector2 operator * (const float a, const Vector2& b)
    { return Vector2(a*b.x, a*b.y); }
    friend Vector2 operator * (const Vector2 &b, const float a)
    { return Vector2(a*b.x, a*b.y); }

    friend Vector2 operator / (const float a, const Vector2& b)
    { return Vector2(a/b.x, a/b.y); }
    friend Vector2 operator / (const Vector2 &a, const float b)
    { return a * (1/b); }

    friend const Vector2 &operator + (const Vector2& a)
    { return a; }
    friend Vector2 operator - (const Vector2& a)
    { return Vector2(-a.x, -a.y); }

    friend Vector2 &operator += (Vector2 &a, const Vector2& b)
    { a.x+=b.x, a.y+=b.y; return a; }
    friend Vector2 &operator += (Vector2 &a, const float b)
    { a.x+=b, a.y+=b; return a; }
    friend Vector2 &operator -= (Vector2 &a, const Vector2& b)
    { a.x-=b.x, a.y-=b.y; return a; }
    friend Vector2 &operator -= (Vector2 &a, const float b)
    { a.x-=b, a.y-=b; return a; }
    friend Vector2 &operator *= (Vector2 &a, const Vector2& b)
    { a.x*=b.x, a.y*=b.y; return a; }
    friend Vector2 &operator *= (Vector2 &a, const float b)
    { a.x*=b, a.y*=b; return a; }
    friend Vector2 &operator /= (Vector2 &a, const Vector2& b)
    { a.x/=b.x, a.y/=b.y; return a; }
    friend Vector2 &operator /= (Vector2 &a, const float b)
    { a.x/=b, a.y/=b; return a; }

    float length2 (void) const { return this->dot(*this); }
    float length (void) const { return ::sqrtf(length2()); }

    float distance (const Vector2& o) const
    { return (*this - o).length(); }
    float distance2 (const Vector2& o) const
    { return (*this - o).length2(); }

    float dot (const Vector2& o) const { return x*o.x + y*o.y; }

    float normalise (void) { float l=length(); *this /= l; return l; }

    // rotate clockwise by v
    Vector2 rotateBy (const Radian &v) const
    {
        float sn = gritsin(v);
        float cs = gritcos(v);
        return Vector2(x*cs + y*sn, - x*sn + y*cs);
    }

    float cross (const Vector2& o) const
    { return x*o.y - y*o.x; }

    Vector2 midPoint (const Vector2& o) const
    { return (*this+o)/2; }

    Vector2 normalisedCopy (void) const
    { return *this / this->length(); }

    /// Check whether this vector contains valid values
    bool isNaN (void) const
    { return my_isnan(x) || my_isnan(y); }

    friend std::ostream& operator << (std::ostream& o, const Vector2& v)
    {
        o << "Vector2(" << v.x << ", " << v.y << ")";
        return o;
    }
};

// }}}


// {{{ Vector4

struct Vector4 {
    float x, y, z, w;

    Vector4 (void) { }
    Vector4 (float x, float y, float z, float w) : x(x), y(y), z(z), w(w) { }

    Vector4 &operator = (const Vector4 &o)
    {
        x = o.x; y = o.y; z = o.z; w = o.w;
        return *this;
    }

    friend bool operator == (const Vector4 &a, const Vector4& b)
    { return a.x==b.x && a.y==b.y && a.z==b.z && a.w==b.w; }
    friend bool operator != (const Vector4 &a, const Vector4& b)
    { return ! (a==b); }
    friend bool operator < (const Vector4 &a, const Vector4& b)
    { return a.x<b.x && a.y<b.y && a.z<b.z && a.w<b.w; }
    friend bool operator > (const Vector4 &a, const Vector4& b)
    { return a.x>b.x && a.y>b.y && a.z>b.z && a.w>b.w; }
    friend bool operator <= (const Vector4 &a, const Vector4& b)
    { return a.x<=b.x && a.y<=b.y && a.z<=b.z && a.w<=b.w; }
    friend bool operator >= (const Vector4 &a, const Vector4& b)
    { return a.x>=b.x && a.y>=b.y && a.z>=b.z && a.w>=b.w; }

    friend Vector4 operator + (const Vector4 &a, const Vector4& b)
    { return Vector4(a.x+b.x, a.y+b.y, a.z+b.z, a.w+b.w); }
    friend Vector4 operator - (const Vector4 &a, const Vector4& b)
    { return Vector4(a.x-b.x, a.y-b.y, a.z-b.z, a.w-b.w); }
    friend Vector4 operator * (const Vector4 &a, const Vector4& b)
    { return Vector4(a.x*b.x, a.y*b.y, a.z*b.z, a.w*b.w); }
    friend Vector4 operator / (const Vector4 &a, const Vector4& b)
    { return Vector4(a.x/b.x, a.y/b.y, a.z/b.z, a.w/b.w); }

    friend Vector4 operator * (const float a, const Vector4& b)
    { return Vector4(a*b.x, a*b.y, a*b.z, a*b.w); }
    friend Vector4 operator * (const Vector4 &b, const float a)
    { return Vector4(a*b.x, a*b.y, a*b.z, a*b.w); }

    friend Vector4 operator / (const float a, const Vector4& b)
    { return Vector4(a/b.x, a/b.y, a/b.z, a/b.w); }
    friend Vector4 operator / (const Vector4 &a, const float b)
    { return a * (1/b); }

    friend const Vector4 &operator + (const Vector4& a)
    { return a; }
    friend Vector4 operator - (const Vector4& a)
    { return Vector4(-a.x, -a.y, -a.z, -a.w); }

    friend Vector4 &operator += (Vector4 &a, const Vector4& b)
    { a.x+=b.x, a.y+=b.y; a.z+=b.z; a.w+=b.w; return a; }
    friend Vector4 &operator += (Vector4 &a, const float b)
    { a.x+=b, a.y+=b; a.z+=b; a.w+=b; return a; }
    friend Vector4 &operator -= (Vector4 &a, const Vector4& b)
    { a.x-=b.x, a.y-=b.y; a.z-=b.z; a.w-=b.w; return a; }
    friend Vector4 &operator -= (Vector4 &a, const float b)
    { a.x-=b, a.y-=b; a.z-=b; a.w-=b; return a; }
    friend Vector4 &operator *= (Vector4 &a, const Vector4& b)
    { a.x*=b.x, a.y*=b.y; a.z*=b.z; a.w*=b.w; return a; }
    friend Vector4 &operator *= (Vector4 &a, const float b)
    { a.x*=b, a.y*=b; a.z*=b; a.w*=b; return a; }
    friend Vector4 &operator /= (Vector4 &a, const Vector4& b)
    { a.x/=b.x, a.y/=b.y; a.z/=b.z; a.w/=b.w; return a; }
    friend Vector4 &operator /= (Vector4 &a, const float b)
    { a.x/=b, a.y/=b; a.z/=b; a.w/=b;return a; }

    float length2 (void) const { return this->dot(*this); }
    float length (void) const { return ::sqrtf(length2()); }

    float distance (const Vector4& o) const
    { return (*this - o).length(); }
    float distance2 (const Vector4& o) const
    { return (*this - o).length2(); }

    float dot (const Vector4& o) const { return x*o.x + y*o.y + z*o.z + w*o.w; }

    float normalise (void) { float l=length(); *this /= l; return l; }

    Vector4 midPoint (const Vector4& o) const
    { return (*this+o)/2; }

    Vector4 normalisedCopy (void) const
    { return *this / this->length(); }

    /// Check whether this vector contains valid values
    bool isNaN (void) const
    { return my_isnan(x) || my_isnan(y) || my_isnan(z) || my_isnan(w); }

    friend std::ostream& operator<< (std::ostream& o, const Vector4& v)
    {
        o << "Vector4(" << v.x << ", " << v.y << ", " << v.z << ", " << v.w << ")";
        return o;
    }
};

// }}}


#endif
