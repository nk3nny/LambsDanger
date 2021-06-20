#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"lambs_main"};
        author = ECSTRING(main,Team);
        VERSION_CONFIG;
    };
};

class DummyClass {
    #if __has_include("\userconfig\lambs_danger\range.hpp")
        #include "\userconfig\lambs_danger\range.hpp";
    #endif

    #ifndef LAMBS_RANGE_SENSITIVITY_MAN
        #define LAMBS_RANGE_SENSITIVITY_MAN 6
    #endif
};

#include "CfgVehicles.hpp"
