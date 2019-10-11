#include "script_component.hpp"
    class CfgPatches {
        class ADDON {
            name = COMPONENT_NAME;
            units[] = {};
            weapons[] = {};
            requiredVersion = REQUIRED_VERSION;
            requiredAddons[] = {"lambs_danger"};
            author = "LAMBS Dev Team";
            VERSION_CONFIG;
        };
    };

#include "CfgEventHandlers.hpp"

// Eventhandlers
class Extended_Explosion_Eventhandlers {
	class CAManBase {
        class LAMBS_CAManBase_Explosion {
            Explosion = "_this call lambs_eventhandlers_fnc_explosionEH;";  // can this be compiled as FUNC() even within quotes? -nk
        };
    };
};