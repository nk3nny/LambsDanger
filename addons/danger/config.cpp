#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {QGVAR(SetRadio), QGVAR(DisableAI), QGVAR(DisableGroupAI)};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"lambs_main"};
        author = "LAMBS Dev Team";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "CfgFSMs.hpp"
#include "Cfg3DEN.hpp"
