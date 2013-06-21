#include <cstdlib>

#include <Ogre.h>
#include <OgreFontManager.h>
#include <OgreMeshManager.h>
#include <OgreOverlayElementFactory.h>
#include <OgreVector3.h>
#include <OgreQuaternion.h>
#include <OgreCustomCompositionPass.h>
#include <OgreCompositor.h>
#ifdef NO_PLUGINS
#  include <OgreOctreeSceneManager.h>
#  include "OgreOctreePlugin.h"
#  include "OgreGLPlugin.h"
#  include "OgreCgPlugin.h"
#  ifdef WIN32
#    include "OgreD3D9Plugin.h"
#  endif
#endif

bool use_hwgamma = false; //getenv("GRIT_NOHWGAMMA")==NULL;

Ogre::Root *ogre_root;
Ogre::SceneManager *ogre_sm;
Ogre::SceneNode *ogre_root_node;
Ogre::Camera *left_eye;
Ogre::Camera *right_eye;
Ogre::Light *ogre_sun;
Ogre::SceneNode *ogre_celestial;
Ogre::SceneNode *ogre_sky_node;
Ogre::Entity *ogre_sky_ent;
Ogre::Viewport *overlay_vp;
Ogre::Viewport *left_vp;
Ogre::Viewport *right_vp;
Ogre::TexturePtr anaglyph_fb;
Ogre::RenderWindow *ogre_win;
#ifdef NO_PLUGINS
    Ogre::GLPlugin *gl;
    Ogre::OctreePlugin *octree;
    //Ogre::ParticleFXPlugin *pfx;
    Ogre::CgPlugin *cg;
    #ifdef WIN32
        Ogre::D3D9Plugin *d3d9;
    #endif
#endif

int main(int argc, char **argv)
{
    if (argc!=2) {
        fprintf(stderr, "Usage: %s blah.mesh\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    std::string mesh_name = argv[1];
    try {

        #ifdef WIN32
        bool use_d3d9 = getenv("GRIT_GL")==NULL;
        #else
        bool use_d3d9 = false;
        #endif

        #ifdef NO_PLUGINS
            ogre_root = OGRE_NEW Ogre::Root("","","");

            gl = OGRE_NEW Ogre::GLPlugin();
            ogre_root->installPlugin(gl);

            octree = OGRE_NEW Ogre::OctreePlugin();
            ogre_root->installPlugin(octree);

            cg = OGRE_NEW Ogre::CgPlugin();
            ogre_root->installPlugin(cg);

            #ifdef WIN32
            if (use_d3d9) {
                Ogre::D3D9Plugin *d3d9 = OGRE_NEW Ogre::D3D9Plugin();
                ogre_root->installPlugin(d3d9);
            }
            #endif
        #else
            ogre_root = OGRE_NEW Ogre::Root("plugins.cfg","","");
        #endif


        Ogre::RenderSystem *rs;
        if (use_d3d9) {
            rs = ogre_root->getRenderSystemByName("Direct3D9 Rendering Subsystem");
            rs->setConfigOption("Allow NVPerfHUD","Yes");
            rs->setConfigOption("Floating-point mode","Consistent");
            rs->setConfigOption("Video Mode","800 x 600 @ 32-bit colour");
        } else {
            rs = ogre_root->getRenderSystemByName("OpenGL Rendering Subsystem");
            rs->setConfigOption("RTT Preferred Mode","FBO");
            rs->setConfigOption("Video Mode","800 x 600");
        }
        rs->setConfigOption("sRGB Gamma Conversion",use_hwgamma?"Yes":"No");
        rs->setConfigOption("Full Screen","No");
        rs->setConfigOption("VSync","Yes");
        ogre_root->setRenderSystem(rs);

        ogre_root->initialise(true,"Grit Game Window");

        ogre_win = ogre_root->getAutoCreatedWindow();



        Ogre::ResourceGroupManager::getSingleton().addResourceLocation(".","FileSystem","General",false);
        Ogre::ResourceGroupManager::getSingleton().initialiseAllResourceGroups();
        Ogre::MeshManager::getSingleton().load(mesh_name,"General");



        if (ogre_sm && ogre_root) ogre_root->destroySceneManager(ogre_sm);
        if (ogre_root) OGRE_DELETE ogre_root;
        #ifdef NO_PLUGINS
            OGRE_DELETE gl;
            OGRE_DELETE octree;
            OGRE_DELETE cg;
            #ifdef WIN32
                OGRE_DELETE d3d9;
            #endif
        #endif


        return EXIT_SUCCESS;

    } catch( Ogre::Exception& e ) {
            std::cerr << "An exception has occured: " << e.getFullDescription().c_str() << std::endl;
    }

}
