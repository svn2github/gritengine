#define OGRE_STATIC_LIB


#define OGRE_MEMORY_ALLOCATOR 1

#define OGRE_CONFIG_LITTLE_ENDIAN

#define OGRE_DOUBLE_PRECISION 0

#define OGRE_NO_DEVIL 1

#define OGRE_NO_FREEIMAGE 0

#define OGRE_THREAD_PROVIDER 1

#define OGRE_THREAD_SUPPORT 2

#ifdef WIN32
    #define OGRE_GUI_WIN32
#else
    #define OGRE_GUI_GLX
#endif

#define OGRE_NO_ZIP_ARCHIVE 1