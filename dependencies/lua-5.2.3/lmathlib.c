/*
** $Id: lmathlib.c,v 1.83.1.1 2013/04/12 18:48:47 roberto Exp $
** Standard mathematical library
** See Copyright Notice in lua.h
*/


#include <stdlib.h>
#include <math.h>

#define lmathlib_c
#define LUA_LIB

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


#undef PI
#define PI	((lua_Number)(3.1415926535897932384626433832795))
#define RADIANS_PER_DEGREE	((lua_Number)(PI/180.0))



static int math_abs (lua_State *L) {
  lua_pushnumber(L, l_mathop(fabs)(luaL_checknumber(L, 1)));
  lua_Number v;
  float x, y, z, w;
  switch (lua_type(L,1)) {
    case LUA_TNUMBER:
    v = lua_tonumber(L,1);
    lua_pushnumber(L,fabs(v));
    return 1;
    case LUA_TVECTOR2:
    lua_checkvector2(L,1,&x,&y);
    lua_pushvector2(L,fabsf(x),fabsf(y));
    return 1;
    case LUA_TVECTOR3:
    lua_checkvector3(L,1,&x,&y,&z);
    lua_pushvector3(L,fabsf(x),fabsf(y),fabsf(z));
    return 1;
    case LUA_TVECTOR4:
    lua_checkvector4(L,1,&x,&y,&z,&w);
    lua_pushvector4(L,fabsf(x),fabsf(y),fabsf(z),fabsf(w));
    return 1;
  }
  luaL_error(L, "ceil takes a number, vector2, vector3, or vector4.");
  return 1;
}

static int math_sin (lua_State *L) {
  lua_pushnumber(L, l_mathop(sin)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_sinh (lua_State *L) {
  lua_pushnumber(L, l_mathop(sinh)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_cos (lua_State *L) {
  lua_pushnumber(L, l_mathop(cos)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_cosh (lua_State *L) {
  lua_pushnumber(L, l_mathop(cosh)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_tan (lua_State *L) {
  lua_pushnumber(L, l_mathop(tan)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_tanh (lua_State *L) {
  lua_pushnumber(L, l_mathop(tanh)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_asin (lua_State *L) {
  lua_pushnumber(L, l_mathop(asin)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_acos (lua_State *L) {
  lua_pushnumber(L, l_mathop(acos)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_atan (lua_State *L) {
  lua_pushnumber(L, l_mathop(atan)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_atan2 (lua_State *L) {
  lua_pushnumber(L, l_mathop(atan2)(luaL_checknumber(L, 1),
                                luaL_checknumber(L, 2)));
  return 1;
}

static int math_ceil (lua_State *L) {
  lua_Number v;
  float x, y, z, w;
  switch (lua_type(L,1)) {
    case LUA_TNUMBER:
    v = lua_tonumber(L,1);
    lua_pushnumber(L,ceil(v));
    return 1;
    case LUA_TVECTOR2:
    lua_checkvector2(L,1,&x,&y);
    lua_pushvector2(L,ceilf(x),ceilf(y));
    return 1;
    case LUA_TVECTOR3:
    lua_checkvector3(L,1,&x,&y,&z);
    lua_pushvector3(L,ceilf(x),ceilf(y),ceilf(z));
    return 1;
    case LUA_TVECTOR4:
    lua_checkvector4(L,1,&x,&y,&z,&w);
    lua_pushvector4(L,ceilf(x),ceilf(y),ceilf(z),ceilf(w));
    return 1;
  }
  luaL_error(L, "ceil takes a number, vector2, vector3, or vector4.");
  return 1;
}

static int math_floor (lua_State *L) {
  lua_Number v;
  float x, y, z, w;
  switch (lua_type(L,1)) {
    case LUA_TNUMBER:
    v = lua_tonumber(L,1);
    lua_pushnumber(L,floor(v));
    return 1;
    case LUA_TVECTOR2:
    lua_checkvector2(L,1,&x,&y);
    lua_pushvector2(L,floorf(x),floorf(y));
    return 1;
    case LUA_TVECTOR3:
    lua_checkvector3(L,1,&x,&y,&z);
    lua_pushvector3(L,floorf(x),floorf(y),floorf(z));
    return 1;
    case LUA_TVECTOR4:
    lua_checkvector4(L,1,&x,&y,&z,&w);
    lua_pushvector4(L,floorf(x),floorf(y),floorf(z),floorf(w));
    return 1;
  }
  luaL_error(L, "floor takes a number, vector2, vector3, or vector4.");
  return 1;
}

static int math_fmod (lua_State *L) {
  lua_pushnumber(L, l_mathop(fmod)(luaL_checknumber(L, 1),
                               luaL_checknumber(L, 2)));
  return 1;
}

static int math_modf (lua_State *L) {
  lua_Number ip;
  lua_Number fp = l_mathop(modf)(luaL_checknumber(L, 1), &ip);
  lua_pushnumber(L, ip);
  lua_pushnumber(L, fp);
  return 2;
}

static int math_sqrt (lua_State *L) {
  lua_pushnumber(L, l_mathop(sqrt)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_pow (lua_State *L) {
  if (lua_gettop(L) != 2) {
    luaL_error(L, "Wrong number of arguments: use math.pow(number, number) or math.pow(quat, number)");
  }
  if (lua_type(L, 1) != LUA_TNUMBER && lua_type(L, 1) != LUA_TQUAT) {
    luaL_error(L, "Invalid type for 1st parameter, use math.pow(number, number) or math.pow(quat, number)");
  }
  if (lua_type(L, 2) != LUA_TNUMBER) {
    luaL_error(L, "math.pow second argument must be a number");
  }

  if (lua_type(L, 1) == LUA_TNUMBER) {
      lua_pushnumber(L, pow(lua_tonumber(L, 1), lua_tonumber(L, 2)));
  } else {
    float w, x, y, z,  l;
    float index;
    lua_checkquat(L, 1, &w, &x, &y, &z);
    index = (float)lua_tonumber(L, 2);
    l = sqrtf(x*x + y*y + z*z);
    if (l==0) {
      lua_pushquat(L, 1, 0, 0, 0);
    } else {
      float angle, sangle;
      float w2, x2, y2, z2;
      angle = index * acosf(w); /* without the factor of 2 */
      sangle = sinf(angle);
      w2 = cosf(angle);
      x2 = sangle * x/l;
      y2 = sangle * y/l;
      z2 = sangle * z/l;
      lua_pushquat(L, w2, x2, y2, z2);
    }
  }
  return 1;
}

static int math_log (lua_State *L) {
  lua_Number x = luaL_checknumber(L, 1);
  lua_Number res;
  if (lua_isnoneornil(L, 2))
    res = l_mathop(log)(x);
  else {
    lua_Number base = luaL_checknumber(L, 2);
    if (base == (lua_Number)10.0) res = l_mathop(log10)(x);
    else res = l_mathop(log)(x)/l_mathop(log)(base);
  }
  lua_pushnumber(L, res);
  return 1;
}

#if defined(LUA_COMPAT_LOG10)
static int math_log10 (lua_State *L) {
  lua_pushnumber(L, l_mathop(log10)(luaL_checknumber(L, 1)));
  return 1;
}
#endif

static int math_exp (lua_State *L) {
  lua_pushnumber(L, l_mathop(exp)(luaL_checknumber(L, 1)));
  return 1;
}

static int math_deg (lua_State *L) {
  lua_pushnumber(L, luaL_checknumber(L, 1)/RADIANS_PER_DEGREE);
  return 1;
}

static int math_rad (lua_State *L) {
  lua_pushnumber(L, luaL_checknumber(L, 1)*RADIANS_PER_DEGREE);
  return 1;
}

static int math_frexp (lua_State *L) {
  int e;
  lua_pushnumber(L, l_mathop(frexp)(luaL_checknumber(L, 1), &e));
  lua_pushinteger(L, e);
  return 2;
}

static int math_ldexp (lua_State *L) {
  lua_Number x = luaL_checknumber(L, 1);
  int ep = luaL_checkint(L, 2);
  lua_pushnumber(L, l_mathop(ldexp)(x, ep));
  return 1;
}



static int math_min (lua_State *L) {
  int n = lua_gettop(L);  /* number of arguments */
  lua_Number dmin = luaL_checknumber(L, 1);
  int i;
  for (i=2; i<=n; i++) {
    lua_Number d = luaL_checknumber(L, i);
    if (d < dmin)
      dmin = d;
  }
  lua_pushnumber(L, dmin);
  return 1;
}


static int math_max (lua_State *L) {
  int n = lua_gettop(L);  /* number of arguments */
  lua_Number dmax = luaL_checknumber(L, 1);
  int i;
  for (i=2; i<=n; i++) {
    lua_Number d = luaL_checknumber(L, i);
    if (d > dmax)
      dmax = d;
  }
  lua_pushnumber(L, dmax);
  return 1;
}


static float do_clamp (float a, float b, float c)
{
  if (a<b) return b;
  if (a>c) return c;
  return a;
}

static int math_clamp (lua_State *L) {
  if (lua_gettop(L)!=3) return luaL_error(L, "wrong number of arguments");
  switch (lua_type(L,1)) {
    case LUA_TNUMBER: {
      lua_Number a, b, c;
      a = luaL_checknumber(L,1);
      b = luaL_checknumber(L,2);
      c = luaL_checknumber(L,3);
      if (a<b) a = b;
      if (a>c) a = c;
      lua_pushnumber(L, a);
    } break;
    case LUA_TVECTOR2: {
      float xa, ya;
      float xb, yb;
      float xc, yc;
      lua_checkvector2(L, 1, &xa, &ya);
      lua_checkvector2(L, 2, &xb, &yb);
      lua_checkvector2(L, 3, &xc, &yc);
      lua_pushvector2(L, do_clamp(xa,xb,xc), do_clamp(ya,yb,yc));
    } break;
    case LUA_TVECTOR3: {
      float xa, ya, za;
      float xb, yb, zb;
      float xc, yc, zc;
      lua_checkvector3(L, 1, &xa, &ya, &za);
      lua_checkvector3(L, 2, &xb, &yb, &zb);
      lua_checkvector3(L, 3, &xc, &yc, &zc);
      lua_pushvector3(L, do_clamp(xa,xb,xc), do_clamp(ya,yb,yc), do_clamp(za,zb,zc));
    } break;
    case LUA_TVECTOR4: {
      float xa, ya, za, wa;
      float xb, yb, zb, wb;
      float xc, yc, zc, wc;
      lua_checkvector4(L, 1, &xa, &ya, &za, &wa);
      lua_checkvector4(L, 2, &xb, &yb, &zb, &wb);
      lua_checkvector4(L, 3, &xc, &yc, &zc, &wc);
      lua_pushvector4(L, do_clamp(xa,xb,xc), do_clamp(ya,yb,yc), do_clamp(za,zb,zc), do_clamp(wa,wb,wc));
    } break;
    default: return luaL_error(L, "clamp only works on number, vector2, vector3, vector4");
  }
  return 1;
}


static int math_random (lua_State *L) {
  /* the `%' avoids the (rare) case of r==1, and is needed also because on
     some systems (SunOS!) `rand()' may return a value larger than RAND_MAX */
  lua_Number r = (lua_Number)(rand()%RAND_MAX) / (lua_Number)RAND_MAX;
  switch (lua_gettop(L)) {  /* check number of arguments */
    case 0: {  /* no arguments */
      lua_pushnumber(L, r);  /* Number between 0 and 1 */
      break;
    }
    case 1: {  /* only upper limit */
      lua_Number u = luaL_checknumber(L, 1);
      luaL_argcheck(L, (lua_Number)1.0 <= u, 1, "interval is empty");
      lua_pushnumber(L, l_mathop(floor)(r*u) + (lua_Number)(1.0));  /* [1, u] */
      break;
    }
    case 2: {  /* lower and upper limits */
      lua_Number l = luaL_checknumber(L, 1);
      lua_Number u = luaL_checknumber(L, 2);
      luaL_argcheck(L, l <= u, 2, "interval is empty");
      lua_pushnumber(L, l_mathop(floor)(r*(u-l+1)) + l);  /* [l, u] */
      break;
    }
    default: return luaL_error(L, "wrong number of arguments");
  }
  return 1;
}


static int math_randomseed (lua_State *L) {
  srand(luaL_checkunsigned(L, 1));
  (void)rand(); /* discard first value to avoid undesirable correlations */
  return 0;
}


static const luaL_Reg mathlib[] = {
  {"abs",   math_abs},
  {"acos",  math_acos},
  {"asin",  math_asin},
  {"atan2", math_atan2},
  {"atan",  math_atan},
  {"ceil",  math_ceil},
  {"cosh",   math_cosh},
  {"cos",   math_cos},
  {"deg",   math_deg},
  {"exp",   math_exp},
  {"floor", math_floor},
  {"fmod",   math_fmod},
  {"frexp", math_frexp},
  {"ldexp", math_ldexp},
#if defined(LUA_COMPAT_LOG10)
  {"log10", math_log10},
#endif
  {"log",   math_log},
  {"max",   math_max},
  {"min",   math_min},
  {"clamp", math_clamp},
  {"modf",   math_modf},
  {"pow",   math_pow},
  {"rad",   math_rad},
  {"random",     math_random},
  {"randomseed", math_randomseed},
  {"sinh",   math_sinh},
  {"sin",   math_sin},
  {"sqrt",  math_sqrt},
  {"tanh",   math_tanh},
  {"tan",   math_tan},
  {NULL, NULL}
};


/*
** Open math library
*/
LUAMOD_API int luaopen_math (lua_State *L) {
  luaL_newlib(L, mathlib);
  lua_pushnumber(L, PI);
  lua_setfield(L, -2, "pi");
  lua_pushnumber(L, HUGE_VAL);
  lua_setfield(L, -2, "huge");
  return 1;
}

