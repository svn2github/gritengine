#include <cstdlib>

#include <Ogre.h>


int should_quit = 0;

class OgreWindowEventListener : public Ogre::WindowEventListener
{
        virtual void windowResized(Ogre::RenderWindow* rw)
        { (void) rw; }

        virtual void windowClosed(Ogre::RenderWindow *rw)
        { (void) rw; should_quit = 1; }
};

OgreWindowEventListener ogre_window_event_listener;



int main(int argc, char **argv)
{
        try {


                Ogre::Root* ogre = new Ogre::Root();

                if (!ogre->restoreConfig() && !ogre->showConfigDialog())
                        return EXIT_FAILURE;

                Ogre::RenderWindow* win = ogre->initialise(true,"GLSL segfault");

                Ogre::WindowEventUtilities::
                        addWindowEventListener(win, &ogre_window_event_listener);

                Ogre::SceneManager* scnmgr =
                        ogre->createSceneManager("OctreeSceneManager");

                scnmgr->setAmbientLight(Ogre::ColourValue(1,1,1));


                Ogre::Camera* cam = scnmgr->createCamera("MyCamera");
                // face north by "default"
                cam->setPosition(0,0,100);

                Ogre::Viewport* vp = win->addViewport(cam);

                Ogre::ResourceGroupManager::getSingleton().
                        addResourceLocation(".","FileSystem","General",false);
                Ogre::ResourceGroupManager::getSingleton().
                        initialiseAllResourceGroups();

                vp->setBackgroundColour(Ogre::ColourValue(0,0,0.5));

                Ogre::SceneNode *node = scnmgr->getRootSceneNode();
            
                Ogre::Entity *ent1 = scnmgr->createEntity("ent1",Ogre::SceneManager::PT_SPHERE);
                node->attachObject(ent1);
                ent1->getSubEntity(0)->setMaterialName("Broken1");

                Ogre::Entity *ent2 = scnmgr->createEntity("ent2",Ogre::SceneManager::PT_SPHERE);
                node->attachObject(ent2);
                ent2->getSubEntity(0)->setMaterialName("Broken2");

                Ogre::Entity *ent3 = scnmgr->createEntity("ent3",Ogre::SceneManager::PT_SPHERE);
                node->attachObject(ent3);
                ent3->getSubEntity(0)->setMaterialName("Broken3");


                // RENDER LOOP
                while (!should_quit) {
                        Ogre::WindowEventUtilities::messagePump();
                        ogre->renderOneFrame();
                }

                delete ogre;


                return EXIT_SUCCESS;

        } catch( Ogre::Exception& e ) {
                std::cerr << "An exception has occured: " << e.getFullDescription().c_str() << std::endl;
        }

}
