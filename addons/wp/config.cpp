#include "script_component.hpp"
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {
            QGVAR(Target),
            QGVAR(ZeusTaskArtillery),
            QGVAR(ZeusTaskArtilleryRegister),
            QGVAR(ZeusTaskAssault),
            QGVAR(ZeusTaskHunt),
            QGVAR(ZeusTaskCamp),
            QGVAR(ZeusTaskCQB),
            QGVAR(ZeusTaskCreep),
            QGVAR(ZeusTaskGarrison),
            QGVAR(ZeusTaskPatrol),
            QGVAR(ZeusTaskRush),
            QGVAR(ZeusTaskReset),
            QGVAR(TaskArtillery),
            QGVAR(TaskArtilleryRegister),
            QGVAR(TaskAssault),
            QGVAR(TaskHunt),
            QGVAR(TaskCamp),
            QGVAR(TaskCQB),
            QGVAR(TaskCreep),
            QGVAR(TaskGarrison),
            QGVAR(TaskPatrol),
            QGVAR(TaskRush),
            QGVAR(TaskReset)
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"lambs_danger"};
        author = "LAMBS Dev Team";
        VERSION_CONFIG;
    };
};
#include "Cfg3DEN.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgWaypoints.hpp"
#include "CfgWaypointTypes.hpp"
#include "CfgVehicles.hpp"
