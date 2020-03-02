#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main"};
        author = "LAMBS Dev Team";
        VERSION_CONFIG;
    };
};
#include "CfgFactionClasses.hpp"
#include "CfgEventHandlers.hpp"

class GVAR(Display) {
    idd = -1;
    movingEnable = 1;
    enableSimulation = 1;
    onLoad = QUOTE(with uiNamespace do {GVAR(display) = _this select 0});
};
