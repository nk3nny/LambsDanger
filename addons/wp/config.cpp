#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {QGVAR(TaskRush_Waypoint), QGVAR(Waypoint_Target)};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"lambs_danger"};
        author = "LAMBS Dev Team";
        VERSION_CONFIG;
    };
};


#include "CfgEventHandlers.hpp"
#include "CfgWaypoints.hpp"
#include "CfgWaypointTypes.hpp"
#include "CfgVehicles.hpp"
