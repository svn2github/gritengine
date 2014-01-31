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

#include <cstdlib>
#include <cmath>

#include <algorithm>

#include "colour_conversion.h"

void RGBtoHSL (float R, float G, float B, float &H, float &S, float &L)
{

    float max_intensity = std::max(std::max(R,G),B);
    float min_intensity = std::min(std::min(R,G),B);

    float delta = max_intensity - min_intensity;

    L = 0.5f * (max_intensity + min_intensity);

    if (delta == 0) {
        // all channels the same (colour is grey)
        S = 0.0f;
        H = 0.0f;
        return;
    }

    if (L < 0.5f) {
        S = (max_intensity - min_intensity)/(max_intensity + min_intensity);
    } else {
        S = (max_intensity - min_intensity)/(2 - max_intensity - min_intensity);
    }
    if (max_intensity == R) {
        H = (G - B)/delta;
    }
    if (max_intensity == G) {
        H = 2 + (B - R)/delta;
    }
    if (max_intensity == B) {
        H = 4 + (R - G)/delta;
    }
    H /= 6;
    if (H < 0) H += 1;
}

static float HSLtoRGB_aux (float temp1, float temp2, float temp3)
{
    if (temp3 < 1)      return temp2  +  (temp1-temp2) * temp3;
    else if (temp3 < 3) return temp1;
    else if (temp3 < 4) return temp2  +  (temp1-temp2) * (4 - temp3);
    else                return temp2;
}

void HSLtoRGB (float H, float S, float L, float &R, float &G, float &B)
{
    if (S == 0) {
        // grey
        R = L;
        G = L;
        B = L;
        return;
    }

    float temp1 = L<0.5f ? L + L*S : L + S - L*S;
    float temp2 = 2*L - temp1;

    R = HSLtoRGB_aux(temp1, temp2, fmodf(6*H + 2, 6));
    G = HSLtoRGB_aux(temp1, temp2, 6*H);
    B = HSLtoRGB_aux(temp1, temp2, fmodf(6*H + 4, 6));
}

void HSVtoHSL (float h, float s, float v, float &hh, float &ss, float &ll)
{
    hh = h;
    ll = (2 - s) * v;
    ss = s * v;
    ss /= (ll <= 1) ? ll : 2 - ll;
    ll /= 2;
}

void HSLtoHSV (float hh, float ss, float ll, float &h, float &s, float &v)
{
    h = hh;
    ss *= (ll <= 0.5) ? ll : 1 - ll;
    v = ll + ss;
    s = 2 * ss / (ll + ss);
}

void RGBtoHSV (float R, float G, float B, float &H, float &S, float &V)
{
    float max_intensity = std::max(std::max(R,G),B);
    float min_intensity = std::min(std::min(R,G),B);

    V = max_intensity;

    float delta = max_intensity - min_intensity;

    if (delta == 0) {
        // grey
        H = 0;
        S = 0;
        return;
    }

    S = (delta / max_intensity);

    if (max_intensity == R) {
        H = (G - B)/delta;
    }
    if (max_intensity == G) {
        H = 2 + (B - R)/delta;
    }
    if (max_intensity == B) {
        H = 4 + (R - G)/delta;
    }
    H /= 6;
    if (H < 0) H += 1;
}

void HSVtoRGB (float H, float S, float V, float &R, float &G, float &B)
{
    if (S == 0.0) {
        // grey
        R = V;
        G = V;
        B = V;
        return;
    }

    float hh = fmodf(H * 6, 6);
    long i = (long)hh;
    float ff = hh - i;
    float p = V * (1.0 - S);
    float q = V * (1.0 - (S * ff));
    float t = V * (1.0 - (S * (1.0 - ff)));

    switch (i) {

        case 0:
        R = V;
        G = t;
        B = p;
        break;

        case 1:
        R = q;
        G = V;
        B = p;
        break;

        case 2:
        R = p;
        G = V;
        B = t;
        break;

        case 3:
        R = p;
        G = q;
        B = V;
        break;

        case 4:
        R = t;
        G = p;
        B = V;
        break;

        case 5:
        default:
        R = V;
        G = p;
        B = q;
        break;
    }
}

