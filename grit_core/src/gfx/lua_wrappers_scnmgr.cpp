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

#include <OgreSceneManager.h>
#include <OgreSceneNode.h>
#include <OgreEntity.h>
#include <OgreManualObject.h>
#include <OgreShadowCameraSetup.h>
#include <OgreShadowCameraSetupFocused.h>
#include <OgreShadowCameraSetupLiSPSM.h>
#include <OgreShadowCameraSetupPSSM.h>

#include "../main.h"
#include "gfx.h"
#include "lua_wrappers_scnmgr.h"
#include "lua_wrappers_mobj.h"
#include "../lua_wrappers_primitives.h"
#include "lua_wrappers_material.h"
#include "lua_wrappers_tex.h"

#include "lua_userdata_dependency_tracker_funcs.h"

// SCENE NODE ============================================================== {{{

void push_node (lua_State *L, Ogre::SceneNode *n)
{
        if (!n) {
                lua_pushnil(L);
                return;
        }
        void **ud = static_cast<void**>(lua_newuserdata(L, sizeof(*ud)));
        ud[0] = static_cast<void*> (n);
        Ogre::SceneManager *scnmgr = n->getCreator();
        luaL_getmetatable(L, NODE_TAG);
        lua_setmetatable(L, -2);
        APP_ASSERT(scnmgr!=NULL);
        APP_ASSERT(n!=NULL);
        APP_ASSERT(ud!=NULL);
        user_data_tables.scnmgrs[scnmgr].sceneNodes[n].push_back(ud);
}

static int node_child_node (lua_State *L)
{
TRY_START
        std::string name;
        if (lua_gettop(L)!=1)
                check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        if (lua_gettop(L)==1) {
                push_node(L,self.createChildSceneNode());
        } else {
                std::string name = luaL_checkstring(L,2);
                push_node(L,self.createChildSceneNode(name));
        }
        return 1;
TRY_END
}

static int node_translate (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Vector3 p = check_v3(L, 2);
        self.translate(to_ogre(p));
        return 0;
TRY_END
}

static int node_get_world_position (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        push_v3(L, from_ogre(self._getDerivedPosition()));
        return 1;
TRY_END
}

static int node_get_world_orientation (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        push_quat(L, from_ogre(self._getDerivedOrientation()));
        return 1;
TRY_END
}

static int node_get_local_position (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        push_v3(L,from_ogre(self.getPosition()));
        return 1;
TRY_END
}

static int node_get_local_orientation (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        push_quat(L, from_ogre(self.getOrientation()));
        return 1;
TRY_END
}

static int node_rotate_to_parent (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Vector3 p = check_v3(L, 2);
        push_v3(L,from_ogre(self.getOrientation()) * p);
        return 1;
TRY_END
}

static int node_rotate_to_world (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Vector3 p = check_v3(L, 2);
        push_v3(L,from_ogre(self._getDerivedOrientation()) * p);
        return 1;
TRY_END
}

static int node_set_position (lua_State *L)
{
TRY_START
        check_args(L,4);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        float px = luaL_checknumber(L,2);
        float py = luaL_checknumber(L,3);
        float pz = luaL_checknumber(L,4);
        self.setPosition(px,py,pz);
        return 0;
TRY_END
}

static int node_set_orientation (lua_State *L)
{
TRY_START
        check_args(L,5);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        float qw = luaL_checknumber(L,2);
        float qx = luaL_checknumber(L,3);
        float qy = luaL_checknumber(L,4);
        float qz = luaL_checknumber(L,5);
        self.setOrientation(qw,qx,qy,qz);
        return 0;
TRY_END
}

static int node_set_orientation_angle (lua_State *L)
{
TRY_START
        check_args(L,5);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        float angle = luaL_checknumber(L,2);
        float qx = luaL_checknumber(L,3);
        float qy = luaL_checknumber(L,4);
        float qz = luaL_checknumber(L,5);
        self.setOrientation(Ogre::Quaternion(Ogre::Degree(angle),
                            Ogre::Vector3(qx,qy,qz).normalisedCopy()));
        return 0;
TRY_END
}


static int node_detach_all_objects (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        self.detachAllObjects();
        return 0;
TRY_END
}

static int node_add_child (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        GET_UD_MACRO(Ogre::SceneNode,child,2,NODE_TAG);
        self.addChild(&child);
        return 0;
TRY_END
}

static int node_remove_child (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        GET_UD_MACRO(Ogre::SceneNode,child,2,NODE_TAG);
        self.removeChild(&child);
        return 0;
TRY_END
}

static int node_remove_all_children (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        self.removeAllChildren();
        return 0;
TRY_END
}

static int node_detach_object (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Ogre::MovableObject *mobj = check_mobj(L,2);
        self.detachObject(mobj);
        return 0;
TRY_END
}

static int node_attach_object (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Ogre::MovableObject *mobj = check_mobj(L,2);
        Ogre::SceneNode::ObjectIterator i =
                self.getAttachedObjectIterator();
        while (i.hasMoreElements()) {
                Ogre::MovableObject *o = i.getNext();
                if (o->getName()==mobj->getName()) {
                        my_lua_error(L,"Object of this name already attached "
                                       "to SceneNode: "+o->getName());
                }
        }
        self.attachObject(mobj);
        return 0;
TRY_END
}

static int node_destroy (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        Ogre::SceneManager *scnmgr = self.getCreator();
        scnmgr->destroySceneNode(self.getName());
        map_nullify_remove(
                          user_data_tables.scnmgrs[scnmgr].sceneNodes,
                           &self);
        return 0;
TRY_END
}


TOSTRING_GETNAME_MACRO(node,Ogre::SceneNode,.getName(),NODE_TAG)


static int node_gc(lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO_OFFSET(Ogre::SceneNode,self,1,NODE_TAG,0);
        if (self==NULL) return 0;
        Ogre::SceneManager *scnmgr = self->getCreator();
        vec_nullify_remove(
                user_data_tables.scnmgrs[scnmgr].sceneNodes[self],
                &self);
        return 0;
TRY_END
}

static int node_index(lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        std::string key  = luaL_checkstring(L,2);
        if (key=="createChild") {
                push_cfunction(L,node_child_node);
        } else if (key=="position") {
                push_v3(L, from_ogre(self.getPosition()));
        } else if (key=="orientation") {
                push_quat(L, from_ogre(self.getOrientation()));
        } else if (key=="scale") {
                push_v3(L, from_ogre(self.getScale()));
        } else if (key=="derivedPosition") {
                push_v3(L, from_ogre(self._getDerivedPosition()));
        } else if (key=="derivedScale") {
                push_v3(L, from_ogre(self._getDerivedScale()));
        } else if (key=="derivedOrientation") {
                push_quat(L, from_ogre(self._getDerivedOrientation()));
        } else if (key=="inheritOrientation") {
                lua_pushboolean(L,self.getInheritOrientation());
        } else if (key=="inheritScale") {
                lua_pushboolean(L,self.getInheritScale());
        } else if (key=="getLocalOrientation") {
                push_cfunction(L,node_get_local_orientation);
        } else if (key=="getWorldOrientation") {
                push_cfunction(L,node_get_world_orientation);
        } else if (key=="getLocalPosition") {
                push_cfunction(L,node_get_local_position);
        } else if (key=="getWorldPosition") {
                push_cfunction(L,node_get_world_position);
        } else if (key=="translate") {
                push_cfunction(L,node_translate);
        } else if (key=="rotateToParent") {
                push_cfunction(L,node_rotate_to_parent);
        } else if (key=="rotateToWorld") {
                push_cfunction(L,node_rotate_to_world);
        } else if (key=="setPosition") {
                push_cfunction(L,node_set_position);
        } else if (key=="setOrientation") {
                push_cfunction(L,node_set_orientation);
        } else if (key=="setOrientationAngle") {
                push_cfunction(L,node_set_orientation_angle);
        } else if (key=="attachObject") {
                push_cfunction(L,node_attach_object);
        } else if (key=="detachObject") {
                push_cfunction(L,node_detach_object);
        } else if (key=="detachAllObjects") {
                push_cfunction(L,node_detach_all_objects);
        } else if (key=="addChild") {
                push_cfunction(L,node_add_child);
        } else if (key=="removeChild") {
                push_cfunction(L,node_remove_child);
        } else if (key=="removeAllChildren") {
                push_cfunction(L,node_remove_all_children);
        } else if (key=="objects") {
                lua_newtable(L);
                int counter = 0;
                Ogre::SceneNode::ObjectIterator i =
                        self.getAttachedObjectIterator();
                while (i.hasMoreElements()) {
                        Ogre::MovableObject *o = i.getNext();
                        if (push_mobj(L,o)) {
                                lua_rawseti(L,-2,counter+LUA_ARRAY_BASE);
                                counter++;
                        }
                }
        } else if (key=="children") {
                lua_newtable(L);
                int counter = 0;
                Ogre::SceneNode::ChildNodeIterator j =
                        self.getChildIterator();
                while (j.hasMoreElements()) {
                        Ogre::Node *o = j.getNext();
                        if (dynamic_cast<Ogre::SceneNode*>(o)) {
                                push_node(L, static_cast<Ogre::SceneNode*>(o));
                                lua_rawseti(L,-2,counter+LUA_ARRAY_BASE);
                                counter++;
                        }
                }
        } else if (key == "parentSceneNode") {
                push_node(L,self.getParentSceneNode());
        } else if (key=="destroy") {
                push_cfunction(L,node_destroy);
        } else {
                my_lua_error(L,"Not a valid SceneNode member: "+key);
        }
        return 1;
TRY_END
}

static int node_newindex(lua_State *L)
{
TRY_START
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneNode,self,1,NODE_TAG);
        std::string key  = luaL_checkstring(L,2);
        if (key=="position") {
                Vector3 v = check_v3(L,3);
                self.setPosition(to_ogre(v));
        } else if (key=="orientation") {
                Quaternion q = check_quat(L,3);
                self.setOrientation(to_ogre(q));
        } else if (key=="scale") {
                Vector3 v = check_v3(L,3);
                self.setScale(to_ogre(v));
        } else if (key=="inheritOrientation") {
                bool v = check_bool(L,3);
                self.setInheritOrientation(v);
        } else if (key=="inheritScale") {
                bool v = check_bool(L,3);
                self.setInheritScale(v);
        } else {
                my_lua_error(L,"Not a valid SceneNode member: "+key);
        }
        return 0;
TRY_END
}

EQ_PTR_MACRO(Ogre::SceneNode,node,NODE_TAG)

MT_MACRO_NEWINDEX(node);

//}}}



// SCENE MANAGER =========================================================== {{{

void push_scnmgr (lua_State *L, Ogre::SceneManager *scnmgr)
{
        if (!scnmgr) {
                lua_pushnil(L);
                return;
        }
        void **ud = static_cast<void**>(lua_newuserdata(L, sizeof(*ud)));
        ud[0] = static_cast<void*> (scnmgr);
        luaL_getmetatable(L, SCNMGR_TAG);
        lua_setmetatable(L, -2);
        user_data_tables.scnmgrs[scnmgr].userData.push_back(ud);
}

static int scnmgr_set_skybox (lua_State *L)
{
TRY_START

        int num_args = lua_gettop(L);
        if (num_args<3 || num_args>6)
                my_lua_error(L,"Incorrect number of arguments");

        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        bool enable = check_bool(L,2);
        std::string mat_name(luaL_checkstring(L,3));
        float dist = 100;
        bool draw_first = true;
        Ogre::Quaternion orientation=Ogre::Quaternion::IDENTITY;

        switch (num_args) {
                case 6: 
                orientation = to_ogre(check_quat(L,6));
                case 5:
                draw_first = check_bool(L,5);
                case 4:
                dist = luaL_checknumber(L,4);
                case 3:
                break;
        }

        self.setSkyBox(enable,mat_name,dist,draw_first,orientation,"GRIT");
        return 0;
TRY_END
}


static int scnmgr_create_light (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        Ogre::Light *light = self.createLight(name);
        push_light(L,light);
        return 1;
TRY_END
}

static int scnmgr_get_light (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        if (!self.hasLight(name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::Light *light = self.getLight(name);
        push_light(L,light);
        return 1;
TRY_END
}


static int scnmgr_create_cam (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        Ogre::Camera *cam = self.createCamera(name);
        push_cam(L,cam);
        return 1;
TRY_END
}

static int scnmgr_get_cam (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        if (!self.hasCamera(name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::Camera *cam = self.getCamera(name);
        push_cam(L,cam);
        return 1;
TRY_END
}


static int scnmgr_get_manobj (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        if (!self.hasManualObject(name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::ManualObject *o = self.getManualObject(name);
        push_manobj(L,o);
        return 1;
TRY_END
}


static int scnmgr_create_node (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        Ogre::SceneNode *node = self.createSceneNode();
        push_node(L,node);
        return 1;
TRY_END
}

static int scnmgr_get_node (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        if (!self.hasSceneNode(name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::SceneNode *node = self.getSceneNode(name);
        push_node(L,node);
        return 1;
TRY_END
}


static int scnmgr_create_instgeo (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        Ogre::InstancedGeometry *g = self.createInstancedGeometry(name);
        push_instgeo(L,&self,g);
        return 1;
TRY_END
}

static int scnmgr_get_instgeo (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        //if (!self.hasInstancedGeometry(name)) {
        //        lua_pushnil(L);
        //        return 1;
        //}
        Ogre::InstancedGeometry *instgeo = self.getInstancedGeometry(name);
        push_instgeo(L,&self,instgeo);
        return 1;
TRY_END
}

static int scnmgr_create_statgeo (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        Ogre::StaticGeometry *g = self.createStaticGeometry(name);
        push_statgeo(L,&self,g);
        return 1;
TRY_END
}

static int scnmgr_get_statgeo (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        if (!self.hasStaticGeometry(name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::StaticGeometry *statgeo = self.getStaticGeometry(name);
        push_statgeo(L,&self,statgeo);
        return 1;
TRY_END
}

static int scnmgr_get_entity (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *ent_name = luaL_checkstring(L,2);
        if (!self.hasEntity(ent_name)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::Entity *ent = self.getEntity(ent_name);
        push_entity(L,ent);
        return 1;
TRY_END
}

static int scnmgr_create_entity (lua_State *L)
{
TRY_START
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *ent_name = luaL_checkstring(L,2);
        const char *mesh_name = luaL_checkstring(L,3);
        push_entity(L,self.createEntity(ent_name,mesh_name));
        return 1;
TRY_END
}

static int scnmgr_has_mobj (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        const char *type = luaL_checkstring(L,3);
        lua_pushboolean(L,self.hasMovableObject(name,type));
        return 1;
TRY_END
}

static int scnmgr_get_mobj (lua_State *L)
{
TRY_START
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        const char *type = luaL_checkstring(L,3);
        if (!self.hasMovableObject(name,type)) {
                lua_pushnil(L);
                return 1;
        }
        Ogre::MovableObject *mobj = self.getMovableObject(name,type);
        if (!push_mobj(L,mobj))
                lua_pushnil(L);
        return 1;
TRY_END
}

static int scnmgr_create_mobj (lua_State *L)
{
TRY_START
        check_args(L,4);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const char *name = luaL_checkstring(L,2);
        const char *type = luaL_checkstring(L,3);
        if (!lua_istable(L,4))
                my_lua_error(L,"Last parameter should be a table");

        Ogre::NameValuePairList params;
        // scan through table adding k/v pairs to params
        for (lua_pushnil(L) ; lua_next(L,4)!=0 ; lua_pop(L,1)) {
                std::string value = luaL_checkstring(L,-1);
                std::string key = luaL_checkstring(L,-2);
                params[key] = value;
        }

        Ogre::MovableObject *mobj = self.createMovableObject(name,type,&params);
        if (!push_mobj(L,mobj))
                lua_pushnil(L);
        return 1;
TRY_END
}

static int scnmgr_get_fog (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        lua_pushstring(L,fog_mode_to_string(L,self.getFogMode()));
        const Ogre::ColourValue &cv = self.getFogColour();
        lua_pushnumber(L,cv.r);
        lua_pushnumber(L,cv.g);
        lua_pushnumber(L,cv.b);
        lua_pushnumber(L,self.getFogDensity());
        lua_pushnumber(L,self.getFogStart());
        lua_pushnumber(L,self.getFogEnd());
        return 7;
TRY_END
}

static int scnmgr_set_fog (lua_State *L)
{
TRY_START
        check_args(L,8);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        Ogre::FogMode fm = fog_mode_from_string(L,luaL_checkstring(L,2));
        float r = luaL_checknumber(L,3);
        float g = luaL_checknumber(L,4);
        float b = luaL_checknumber(L,5);
        float density = luaL_checknumber(L,6);
        float start = luaL_checknumber(L,7);
        float end = luaL_checknumber(L,8);
        self.setFog(fm,Ogre::ColourValue(r,g,b),density,start,end);
        return 0;
TRY_END
}

static int scnmgr_get_ambient (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const Ogre::ColourValue &cv = self.getAmbientLight();
        lua_pushnumber(L,cv.r);
        lua_pushnumber(L,cv.g);
        lua_pushnumber(L,cv.b);
        return 3;
TRY_END
}

static int scnmgr_set_ambient (lua_State *L)
{
TRY_START
        check_args(L,4);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        float r = luaL_checknumber(L,2);
        float g = luaL_checknumber(L,3);
        float b = luaL_checknumber(L,4);
        self.setAmbientLight(Ogre::ColourValue(r,g,b));
        return 0;
TRY_END
}

static int scnmgr_get_shadow_colour (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        const Ogre::ColourValue &cv = self.getShadowColour();
        lua_pushnumber(L,cv.r);
        lua_pushnumber(L,cv.g);
        lua_pushnumber(L,cv.b);
        return 3;
TRY_END
}

static int scnmgr_set_shadow_colour (lua_State *L)
{
TRY_START
        check_args(L,4);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        float r = luaL_checknumber(L,2);
        float g = luaL_checknumber(L,3);
        float b = luaL_checknumber(L,4);
        self.setShadowColour(Ogre::ColourValue(r,g,b));
        return 0;
TRY_END
}

const char *pixel_format_to_string (lua_State *L, Ogre::PixelFormat pf)
{
        // use if statements because some of these enum values are actually duplicates
        if (pf == Ogre::PF_UNKNOWN) return "PF_UNKNOWN"; 
        else if (pf == Ogre::PF_L8) return "PF_L8"; 
        else if (pf == Ogre::PF_BYTE_L) return "PF_BYTE_L"; 
        else if (pf == Ogre::PF_L16) return "PF_L16"; 
        else if (pf == Ogre::PF_SHORT_L) return "PF_SHORT_L"; 
        else if (pf == Ogre::PF_A8) return "PF_A8"; 
        else if (pf == Ogre::PF_BYTE_A) return "PF_BYTE_A"; 
        else if (pf == Ogre::PF_A4L4) return "PF_A4L4"; 
        else if (pf == Ogre::PF_BYTE_LA) return "PF_BYTE_LA"; 
        else if (pf == Ogre::PF_R5G6B5) return "PF_R5G6B5"; 
        else if (pf == Ogre::PF_B5G6R5) return "PF_B5G6R5"; 
        else if (pf == Ogre::PF_R3G3B2) return "PF_R3G3B2"; 
        else if (pf == Ogre::PF_A4R4G4B4) return "PF_A4R4G4B4"; 
        else if (pf == Ogre::PF_A1R5G5B5) return "PF_A1R5G5B5"; 
        else if (pf == Ogre::PF_R8G8B8) return "PF_R8G8B8"; 
        else if (pf == Ogre::PF_B8G8R8) return "PF_B8G8R8"; 
        else if (pf == Ogre::PF_A8R8G8B8) return "PF_A8R8G8B8"; 
        else if (pf == Ogre::PF_A8B8G8R8) return "PF_A8B8G8R8"; 
        else if (pf == Ogre::PF_B8G8R8A8) return "PF_B8G8R8A8"; 
        else if (pf == Ogre::PF_R8G8B8A8) return "PF_R8G8B8A8"; 
        else if (pf == Ogre::PF_X8R8G8B8) return "PF_X8R8G8B8"; 
        else if (pf == Ogre::PF_X8B8G8R8) return "PF_X8B8G8R8"; 
        else if (pf == Ogre::PF_BYTE_RGB) return "PF_BYTE_RGB"; 
        else if (pf == Ogre::PF_BYTE_BGR) return "PF_BYTE_BGR"; 
        else if (pf == Ogre::PF_BYTE_BGRA) return "PF_BYTE_BGRA"; 
        else if (pf == Ogre::PF_BYTE_RGBA) return "PF_BYTE_RGBA"; 
        else if (pf == Ogre::PF_A2R10G10B10) return "PF_A2R10G10B10"; 
        else if (pf == Ogre::PF_A2B10G10R10) return "PF_A2B10G10R10"; 
        else if (pf == Ogre::PF_DXT1) return "PF_DXT1"; 
        else if (pf == Ogre::PF_DXT2) return "PF_DXT2"; 
        else if (pf == Ogre::PF_DXT3) return "PF_DXT3"; 
        else if (pf == Ogre::PF_DXT4) return "PF_DXT4"; 
        else if (pf == Ogre::PF_DXT5) return "PF_DXT5"; 
        else if (pf == Ogre::PF_FLOAT16_R) return "PF_FLOAT16_R"; 
        else if (pf == Ogre::PF_FLOAT16_RGB) return "PF_FLOAT16_RGB"; 
        else if (pf == Ogre::PF_FLOAT16_RGBA) return "PF_FLOAT16_RGBA"; 
        else if (pf == Ogre::PF_FLOAT32_R) return "PF_FLOAT32_R"; 
        else if (pf == Ogre::PF_FLOAT32_RGB) return "PF_FLOAT32_RGB"; 
        else if (pf == Ogre::PF_FLOAT32_RGBA) return "PF_FLOAT32_RGBA"; 
        else if (pf == Ogre::PF_FLOAT16_GR) return "PF_FLOAT16_GR"; 
        else if (pf == Ogre::PF_FLOAT32_GR) return "PF_FLOAT32_GR"; 
        else if (pf == Ogre::PF_DEPTH) return "PF_DEPTH"; 
        else if (pf == Ogre::PF_SHORT_RGBA) return "PF_SHORT_RGBA"; 
        else if (pf == Ogre::PF_SHORT_GR) return "PF_SHORT_GR"; 
        else if (pf == Ogre::PF_SHORT_RGB) return "PF_SHORT_RGB"; 
        else if (pf == Ogre::PF_PVRTC_RGB2) return "PF_PVRTC_RGB2"; 
        else if (pf == Ogre::PF_PVRTC_RGBA2) return "PF_PVRTC_RGBA2"; 
        else if (pf == Ogre::PF_PVRTC_RGB4) return "PF_PVRTC_RGB4"; 
        else if (pf == Ogre::PF_PVRTC_RGBA4) return "PF_PVRTC_RGBA4"; 
        else if (pf == Ogre::PF_COUNT) return "PF_COUNT"; 
        else my_lua_error(L, "Unrecognised Ogre::PixelFormat");
        return "Never happens";
}

Ogre::PixelFormat pixel_format_from_string (lua_State *L, const std::string& s)
{
        if (s=="PF_UNKNOWN") return Ogre::PF_UNKNOWN; 
        else if (s=="PF_L8") return Ogre::PF_L8; 
        else if (s=="PF_BYTE_L") return Ogre::PF_BYTE_L; 
        else if (s=="PF_L16") return Ogre::PF_L16; 
        else if (s=="PF_SHORT_L") return Ogre::PF_SHORT_L; 
        else if (s=="PF_A8") return Ogre::PF_A8; 
        else if (s=="PF_BYTE_A") return Ogre::PF_BYTE_A; 
        else if (s=="PF_A4L4") return Ogre::PF_A4L4; 
        else if (s=="PF_BYTE_LA") return Ogre::PF_BYTE_LA; 
        else if (s=="PF_R5G6B5") return Ogre::PF_R5G6B5; 
        else if (s=="PF_B5G6R5") return Ogre::PF_B5G6R5; 
        else if (s=="PF_R3G3B2") return Ogre::PF_R3G3B2; 
        else if (s=="PF_A4R4G4B4") return Ogre::PF_A4R4G4B4; 
        else if (s=="PF_A1R5G5B5") return Ogre::PF_A1R5G5B5; 
        else if (s=="PF_R8G8B8") return Ogre::PF_R8G8B8; 
        else if (s=="PF_B8G8R8") return Ogre::PF_B8G8R8; 
        else if (s=="PF_A8R8G8B8") return Ogre::PF_A8R8G8B8; 
        else if (s=="PF_A8B8G8R8") return Ogre::PF_A8B8G8R8; 
        else if (s=="PF_B8G8R8A8") return Ogre::PF_B8G8R8A8; 
        else if (s=="PF_R8G8B8A8") return Ogre::PF_R8G8B8A8; 
        else if (s=="PF_X8R8G8B8") return Ogre::PF_X8R8G8B8; 
        else if (s=="PF_X8B8G8R8") return Ogre::PF_X8B8G8R8; 
        else if (s=="PF_BYTE_RGB") return Ogre::PF_BYTE_RGB; 
        else if (s=="PF_BYTE_BGR") return Ogre::PF_BYTE_BGR; 
        else if (s=="PF_BYTE_BGRA") return Ogre::PF_BYTE_BGRA; 
        else if (s=="PF_BYTE_RGBA") return Ogre::PF_BYTE_RGBA; 
        else if (s=="PF_A2R10G10B10") return Ogre::PF_A2R10G10B10; 
        else if (s=="PF_A2B10G10R10") return Ogre::PF_A2B10G10R10; 
        else if (s=="PF_DXT1") return Ogre::PF_DXT1; 
        else if (s=="PF_DXT2") return Ogre::PF_DXT2; 
        else if (s=="PF_DXT3") return Ogre::PF_DXT3; 
        else if (s=="PF_DXT4") return Ogre::PF_DXT4; 
        else if (s=="PF_DXT5") return Ogre::PF_DXT5; 
        else if (s=="PF_FLOAT16_R") return Ogre::PF_FLOAT16_R; 
        else if (s=="PF_FLOAT16_RGB") return Ogre::PF_FLOAT16_RGB; 
        else if (s=="PF_FLOAT16_RGBA") return Ogre::PF_FLOAT16_RGBA; 
        else if (s=="PF_FLOAT32_R") return Ogre::PF_FLOAT32_R; 
        else if (s=="PF_FLOAT32_RGB") return Ogre::PF_FLOAT32_RGB; 
        else if (s=="PF_FLOAT32_RGBA") return Ogre::PF_FLOAT32_RGBA; 
        else if (s=="PF_FLOAT16_GR") return Ogre::PF_FLOAT16_GR; 
        else if (s=="PF_FLOAT32_GR") return Ogre::PF_FLOAT32_GR; 
        else if (s=="PF_DEPTH") return Ogre::PF_DEPTH; 
        else if (s=="PF_SHORT_RGBA") return Ogre::PF_SHORT_RGBA; 
        else if (s=="PF_SHORT_GR") return Ogre::PF_SHORT_GR; 
        else if (s=="PF_SHORT_RGB") return Ogre::PF_SHORT_RGB; 
        else if (s=="PF_PVRTC_RGB2") return Ogre::PF_PVRTC_RGB2; 
        else if (s=="PF_PVRTC_RGBA2") return Ogre::PF_PVRTC_RGBA2; 
        else if (s=="PF_PVRTC_RGB4") return Ogre::PF_PVRTC_RGB4; 
        else if (s=="PF_PVRTC_RGBA4") return Ogre::PF_PVRTC_RGBA4; 
        else if (s=="PF_COUNT") return Ogre::PF_COUNT; 
        else {
                my_lua_error(L,"Unrecognised pixel format: "+s);
                return Ogre::PF_UNKNOWN; //never happens
        }
}

static int scnmgr_set_shadow_texture_settings (lua_State *L)
{
TRY_START
        check_args(L,4);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        size_t size = check_t<size_t>(L,2);
        size_t count = check_t<size_t>(L,3);
        std::string pf_ = luaL_checkstring(L,4);
        Ogre::PixelFormat pf = pixel_format_from_string(L,pf_);
        self.setShadowTextureSettings(size,count,pf);
        return 0;
TRY_END
}

static int scnmgr_get_shadow_texture (lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        size_t index = check_t<size_t>(L,2);
        push(L, new Ogre::TexturePtr(self.getShadowTexture(index)),TEX_TAG);
        return 1;
TRY_END
}

static const char *
shadow_type_to_string (lua_State *L, Ogre::ShadowTechnique st)
{
        switch (st) {
        case Ogre::SHADOWTYPE_NONE: return "NONE";
        case Ogre::SHADOWTYPE_STENCIL_MODULATIVE: return "STENCIL_MODULATIVE";
        case Ogre::SHADOWTYPE_STENCIL_ADDITIVE: return "STENCIL_ADDITIVE";
        case Ogre::SHADOWTYPE_TEXTURE_MODULATIVE: return "TEXTURE_MODULATIVE";
        case Ogre::SHADOWTYPE_TEXTURE_ADDITIVE: return "TEXTURE_ADDITIVE";
        case Ogre::SHADOWTYPE_TEXTURE_MODULATIVE_INTEGRATED:
                return "TEXTURE_MODULATIVE_INTEGRATED";
        case Ogre::SHADOWTYPE_TEXTURE_ADDITIVE_INTEGRATED:
                return "TEXTURE_ADDITIVE_INTEGRATED";
        default:
                my_lua_error(L,"Unrecognised shadow type.");
                return "never happens";
        }
}
static Ogre::ShadowTechnique
shadow_type_from_string (lua_State *L, const std::string& t)
{
        if (t=="NONE") {
                return Ogre::SHADOWTYPE_NONE;
        } else if (t=="STENCIL_MODULATIVE") {
                return Ogre::SHADOWTYPE_STENCIL_MODULATIVE;
        } else if (t=="STENCIL_ADDITIVE") {
                return Ogre::SHADOWTYPE_STENCIL_ADDITIVE;
        } else if (t=="TEXTURE_MODULATIVE") {
                return Ogre::SHADOWTYPE_TEXTURE_MODULATIVE;
        } else if (t=="TEXTURE_ADDITIVE") {
                return Ogre::SHADOWTYPE_TEXTURE_ADDITIVE;
        } else if (t=="TEXTURE_MODULATIVE_INTEGRATED") {
                return Ogre::SHADOWTYPE_TEXTURE_MODULATIVE_INTEGRATED;
        } else if (t=="TEXTURE_ADDITIVE_INTEGRATED") {
                return Ogre::SHADOWTYPE_TEXTURE_ADDITIVE_INTEGRATED;
        } else {
                my_lua_error(L,"Unrecognised shadow type: "+t);
                return Ogre::SHADOWTYPE_NONE;//never happens
        }
}


static int scnmgr_update_scene_graph (lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        self.getRootSceneNode()->_update(true,false);
        return 0;
TRY_END
}

static int scnmgr_set_shadow_texture_count_per_light_type (lua_State *L)
{
TRY_START
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        Ogre::Light::LightTypes type =
                light_type_from_string(L,luaL_checkstring(L,2));
        size_t v = check_t<size_t>(L,3);
        self.setShadowTextureCountPerLightType(type, v);
        return 0;
TRY_END
}

static int scnmgr_set_shadow_camera_setup (lua_State *L)
{
TRY_START
        if (lua_gettop(L)==2) {
                lua_newtable(L);
        }
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        std::string type = luaL_checkstring(L,2);
        if (!lua_istable(L,3))
                my_lua_error(L,"Second parameter should be a table");

        bool aggressive = table_fetch_bool(L, "aggressiveFocusRegion", true);
        float threshold = table_fetch_real(L, "threshold", 35);
        float opt = table_fetch_real(L, "optimalAdjustFactor", 0.1);
        bool simple = table_fetch_bool(L, "simpleOptimalAdjust", true);

        int splits = table_fetch_num<int>(L, "splits", 3);
        float padding = table_fetch_real(L, "padding", 3);
        
        std::vector<float> adjustFactors;
        for (int i=0 ; i<splits ; ++i) {
                std::stringstream ss;
                ss << "optimalAdjustFactor" << i;
                float f = table_fetch_real(L, ss.str().c_str(), opt);
                adjustFactors.push_back(f);
        }

        Ogre::ShadowCameraSetup *p;
        if (type=="DEFAULT") {
                p = new Ogre::DefaultShadowCameraSetup();
        } else if (type=="FOCUSED") {
                Ogre::FocusedShadowCameraSetup *p2 =
                        new Ogre::FocusedShadowCameraSetup();
                p2->setUseAggressiveFocusRegion(aggressive);
                p = p2;
        } else if (type=="LISPSM") {
                Ogre::LiSPSMShadowCameraSetup *p2 =
                        new Ogre::LiSPSMShadowCameraSetup();
                p2->setUseAggressiveFocusRegion(aggressive);

                p2->setCameraLightDirectionThreshold(Ogre::Degree(threshold));
                p2->setOptimalAdjustFactor(opt);
                p2->setUseSimpleOptimalAdjust(simple);
                p = p2;
        } else if (type=="PSSM") {
                Ogre::PSSMShadowCameraSetup::SplitPointList boundaries;
                for (int i=0 ; i<=splits ; ++i) {
                        std::stringstream ss;
                        ss << "boundary" << i;
                        float f = table_fetch_real(L, ss.str().c_str(), -1);
                        if (f<=0) {
                                my_lua_error(L,"Expected a positive value: "+
                                               ss.str()+".");
                        }
                        boundaries.push_back(f);
                }
                Ogre::PSSMShadowCameraSetup *p2 =
                        new Ogre::PSSMShadowCameraSetup();
                p2->setUseAggressiveFocusRegion(aggressive);

                p2->setCameraLightDirectionThreshold(Ogre::Degree(threshold));
                p2->setUseSimpleOptimalAdjust(simple);

                p2->setSplitPoints(boundaries);
                p2->setSplitPadding(padding);
                for (int i=0 ; i<splits ; ++i) {
                        p2->setOptimalAdjustFactor(i, adjustFactors[i]);
                }
                p = p2;
        } else {
                my_lua_error(L,"Unrecognised shadow camera setup: "+type);
        }

        self.setShadowCameraSetup(Ogre::ShadowCameraSetupPtr(p));

        return 0;
TRY_END
}


static int scnmgr_destroy(lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        ogre_root->destroySceneManager(&self);
        struct scnmgr_maps& maps = user_data_tables.scnmgrs[&self];
        vec_nullify_remove_all(maps.userData);
        map_nullify_remove_all(maps.sceneNodes);
        map_nullify_remove_all(maps.cameras);
        map_nullify_remove_all(maps.entities);
        map_nullify_remove_all(maps.lights);
        map_nullify_remove_all(maps.manobjs);
        map_nullify_remove_all(maps.statgeoms);
        map_nullify_remove_all(maps.instgeoms);
        map_remove_only(user_data_tables.scnmgrs,&self);
        return 0;
TRY_END
}


TOSTRING_ADDR_MACRO(scnmgr,Ogre::SceneManager,SCNMGR_TAG)


static int scnmgr_gc(lua_State *L)
{
TRY_START
        check_args(L,1);
        GET_UD_MACRO_OFFSET(Ogre::SceneManager,self,1,SCNMGR_TAG,0);
        if (self==NULL) return 0;
        vec_nullify_remove(user_data_tables.scnmgrs[self].userData,
                           &self);
        return 0;
TRY_END
}

static int scnmgr_index(lua_State *L)
{
TRY_START
        check_args(L,2);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        std::string key  = luaL_checkstring(L,2);

        if (key=="setSkyBox") {
                push_cfunction(L,scnmgr_set_skybox);

        } else if (key=="shadowTechnique") {
                lua_pushstring(L,
                        shadow_type_to_string(L,self.getShadowTechnique()));
        } else if (key=="setShadowCameraSetup") {
                push_cfunction(L, scnmgr_set_shadow_camera_setup);
        } else if (key=="setShadowTextureCountPerLightType") {
               push_cfunction(L,scnmgr_set_shadow_texture_count_per_light_type);
        } else if (key=="shadowDirectionalLightExtrusionDistance") {
                lua_pushnumber(L,
                        self.getShadowDirectionalLightExtrusionDistance());
        } else if (key=="shadowFarDistance") {
                lua_pushnumber(L,self.getShadowFarDistance());
        } else if (key=="shadowIndexBufferSize") {
                lua_pushnumber(L,self.getShadowIndexBufferSize());
        } else if (key=="shadowTextureCount") {
                lua_pushnumber(L,self.getShadowTextureCount());
        } else if (key=="getShadowTexture") {
                push_cfunction(L,scnmgr_get_shadow_texture);
        } else if (key=="shadowDirLightTextureOffset") {
                lua_pushnumber(L,self.getShadowDirLightTextureOffset());
/* GETTERS NOT IMPLEMENTED?!
        } else if (key=="shadowTextureFadeStart") {
                lua_pushnumber(L,self.getShadowTextureFadeStart());
        } else if (key=="shadowTextureFadeEnd") {
                lua_pushnumber(L,self.getShadowTextureFadeEnd());
*/
        } else if (key=="shadowTextureSelfShadow") {
                lua_pushboolean(L,self.getShadowTextureSelfShadow());
        } else if (key=="shadowCasterRenderBackFaces") {
                lua_pushboolean(L,self.getShadowCasterRenderBackFaces());
/* GETTER NOT IMPLEMENTED?!
        } else if (key=="shadowUseInfiniteFarPlane") {
                lua_pushboolean(L,self.getShadowUseInfiniteFarPlane());
*/

        } else if (key=="setShadowTextureSettings") {
                push_cfunction(L,scnmgr_set_shadow_texture_settings);
/* GETTER NOT IMPLEMENTED?!
        } else if (key=="shadowTextureCasterMaterial") {
                mat_push(L,self.getShadowTextureCasterMaterial());
*/

        } else if (key=="setShadowColour") {
                push_cfunction(L,scnmgr_set_shadow_colour);
        } else if (key=="getShadowColour") {
                push_cfunction(L,scnmgr_get_shadow_colour);

        } else if (key=="setAmbientLight") {
                push_cfunction(L,scnmgr_set_ambient);
        } else if (key=="getAmbientLight") {
                push_cfunction(L,scnmgr_get_ambient);
        } else if (key=="setFog") {
                push_cfunction(L,scnmgr_set_fog);
        } else if (key=="getFog") {
                push_cfunction(L,scnmgr_get_fog);

        } else if (key=="createLight") {
                push_cfunction(L,scnmgr_create_light);
        } else if (key=="getLight") {
                push_cfunction(L,scnmgr_get_light);

        } else if (key=="createCamera") {
                push_cfunction(L,scnmgr_create_cam);
        } else if (key=="getCamera") {
                push_cfunction(L,scnmgr_get_cam);

        } else if (key=="createNode") {
                push_cfunction(L,scnmgr_create_node);
        } else if (key=="getNode") {
                push_cfunction(L,scnmgr_get_node);

        } else if (key=="getManualObject") {
                push_cfunction(L,scnmgr_get_manobj);

        } else if (key=="entities") {
                lua_newtable(L);
                unsigned int c = 0;
                {
                        Ogre::SceneManager::MovableObjectIterator i =
                                self.getMovableObjectIterator("Entity");
                        while (i.hasMoreElements()) {
                                Ogre::Entity *ent = static_cast<Ogre::Entity*>
                                                                (i.getNext());
                                push_entity(L,ent);
                                lua_rawseti(L,-2,c+LUA_ARRAY_BASE);
                                c++;
                        }
                }
                {
                        Ogre::SceneManager::MovableObjectIterator i =
                                self.getMovableObjectIterator("FPEntity");
                        while (i.hasMoreElements()) {
                                Ogre::Entity *ent = static_cast<Ogre::Entity*>
                                                                (i.getNext());
                                push_entity(L,ent);
                                lua_rawseti(L,-2,c+LUA_ARRAY_BASE);
                                c++;
                        }
                }

        } else if (key=="manualObjects") {
                lua_newtable(L);
                unsigned int c = 0;
                Ogre::SceneManager::MovableObjectIterator j =
                        self.getMovableObjectIterator("ManualObject");
                while (j.hasMoreElements()) {
                        Ogre::ManualObject *o =
                                static_cast<Ogre::ManualObject*>(j.getNext());
                        push_manobj(L,o);
                        lua_rawseti(L,-2,c+LUA_ARRAY_BASE);
                        c++;
                }

        } else if (key=="cameras") {
                lua_newtable(L);
                unsigned int c = 0;
                Ogre::SceneManager::MovableObjectIterator j =
                        self.getMovableObjectIterator("Camera");
                while (j.hasMoreElements()) {
                        Ogre::Camera *cam = static_cast<Ogre::Camera*>
                                                        (j.getNext());
                        push_cam(L,cam);
                        lua_rawseti(L,-2,c+LUA_ARRAY_BASE);
                        c++;
                }

        } else if (key=="createInstancedGeometry") {
                push_cfunction(L,scnmgr_create_instgeo);
        } else if (key=="getInstancedGeometry") {
                push_cfunction(L,scnmgr_get_instgeo);

        } else if (key=="createStaticGeometry") {
                push_cfunction(L,scnmgr_create_statgeo);
        } else if (key=="getStaticGeometry") {
                push_cfunction(L,scnmgr_get_statgeo);

        } else if (key=="createEntity") {
                push_cfunction(L,scnmgr_create_entity);
        } else if (key=="getEntity") {
                push_cfunction(L,scnmgr_get_entity);

        } else if (key=="createMovableObject") {
                push_cfunction(L,scnmgr_create_mobj);
        } else if (key=="getMovableObject") {
                push_cfunction(L,scnmgr_get_mobj);
        } else if (key=="hasMovableObject") {
                push_cfunction(L,scnmgr_has_mobj);

        } else if (key=="destroy") {
                push_cfunction(L,scnmgr_destroy);

        } else if (key=="showSceneNodes") {
                lua_pushboolean(L,self.getDisplaySceneNodes());
        } else if (key=="showBoundingBoxes") {
                lua_pushboolean(L,self.getShowBoundingBoxes());
        } else if (key=="showDebugShadows") {
                lua_pushboolean(L,self.getShowDebugShadows());

        } else if (key=="skyBoxNode") {
                push_node(L,self.getSkyBoxNode());
        } else if (key=="root") {
                push_node(L,self.getRootSceneNode());

        } else if (key=="updateSceneGraph") {
                push_cfunction(L, scnmgr_update_scene_graph);

        } else {
                my_lua_error(L,"Not a valid SceneManager member: "+key);
        }
        return 1;
TRY_END
}

static int scnmgr_newindex(lua_State *L)
{
TRY_START
        check_args(L,3);
        GET_UD_MACRO(Ogre::SceneManager,self,1,SCNMGR_TAG);
        std::string key  = luaL_checkstring(L,2);

        if (key=="showSceneNodes") {
                self.setDisplaySceneNodes(check_bool(L,3));
        } else if (key=="showBoundingBoxes") {
                self.showBoundingBoxes(check_bool(L,3));
        } else if (key=="showDebugShadows") {
                self.setShowDebugShadows(check_bool(L,3));

        } else if (key=="shadowTechnique") {
                const char* st = luaL_checkstring(L,3);
                self.setShadowTechnique(shadow_type_from_string(L,st));
        } else if (key=="shadowDirectionalLightExtrusionDistance") {
                float v = luaL_checknumber(L,3);
                self.setShadowDirectionalLightExtrusionDistance(v);
        } else if (key=="shadowFarDistance") {
                float v = luaL_checknumber(L,3);
                self.setShadowFarDistance(v);
        } else if (key=="shadowIndexBufferSize") {
                size_t v = check_t<size_t>(L,3);
                self.setShadowIndexBufferSize(v);
        } else if (key=="shadowDirLightTextureOffset") {
                float v = luaL_checknumber(L,3);
                self.setShadowDirLightTextureOffset(v);
        } else if (key=="shadowTextureFadeStart") {
                float v = luaL_checknumber(L,3);
                self.setShadowTextureFadeStart(v);
        } else if (key=="shadowTextureFadeEnd") {
                float v = luaL_checknumber(L,3);
                self.setShadowTextureFadeEnd(v);
        } else if (key=="shadowTextureSelfShadow") {
                bool v = check_bool(L,3);
                self.setShadowTextureSelfShadow(v);
        } else if (key=="shadowCasterRenderBackFaces") {
                bool v = check_bool(L,3);
                self.setShadowCasterRenderBackFaces(v);
        } else if (key=="shadowTextureCasterMaterial") {
                if (lua_type(L,3)==LUA_TSTRING) {
                        std::string v = luaL_checkstring(L,3);
                        self.setShadowTextureCasterMaterial(v);
                } else {
                        GET_UD_MACRO(Ogre::MaterialPtr,v,3,MAT_TAG);
                        self.setShadowTextureCasterMaterial(v->getName());
                }
        } else if (key=="shadowUseInfiniteFarPlane") {
                bool v = check_bool(L,3);
                self.setShadowUseInfiniteFarPlane(v);

        } else {
                my_lua_error(L,"Not a valid SceneManager member: "+key);
        }
        return 1;
TRY_END
}

EQ_PTR_MACRO(Ogre::SceneManager,scnmgr,SCNMGR_TAG)

MT_MACRO_NEWINDEX(scnmgr);

//}}}


// vim: shiftwidth=8:tabstop=8:expandtab
