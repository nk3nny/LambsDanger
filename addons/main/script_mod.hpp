#define MAINPREFIX z
#define PREFIX lambs

#include "script_version.hpp"

#define VERSION         MAJOR.MINOR
#define VERSION_STR     MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR      MAJOR,MINOR,PATCHLVL,BUILD
#define VERSION_PLUGIN  MAJOR.MINOR.PATCHLVL.BUILD

#define REQUIRED_VERSION 2.16

#ifdef COMPONENT_BEAUTIFIED
    #define COMPONENT_NAME QUOTE(LAMBS COMPONENT_BEAUTIFIED)
#else
    #define COMPONENT_NAME QUOTE(LAMBS COMPONENT)
#endif
