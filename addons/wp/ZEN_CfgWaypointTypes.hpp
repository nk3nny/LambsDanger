class ZEN_WaypointTypes {
    class EGVAR(danger,Attack) {
        displayName = CSTRING(Waypoint_TaskAssault_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpAssault.sqf);
    };
    class EGVAR(danger,Retreat) {
        displayName = CSTRING(Waypoint_TaskRetreat_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpRetreat.sqf);
    };
    class EGVAR(danger,Garrison) {
        displayName = CSTRING(Waypoint_TaskGarrison_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpGarrison.sqf);
    };
    class EGVAR(danger,Patrol) {
        displayName = CSTRING(Waypoint_TaskPatrol_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpPatrol.sqf);
    };
    class EGVAR(danger,Rush) {
        displayName = CSTRING(Waypoint_TaskRush_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpRush.sqf);
    };
    class EGVAR(danger,Hunt) {
        displayName = CSTRING(Waypoint_TaskHunt_displayName);
        tooltip = "test";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpHunt.sqf);
    };
    class EGVAR(danger,Creep) {
        displayName = CSTRING(Waypoint_TaskCreep_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCreep.sqf);
    };
    class EGVAR(danger,CQB) {
        displayName = CSTRING(Waypoint_TaskCQB_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCQB.sqf);
    };
    class EGVAR(danger,RegisterArtillery) {
        displayName = CSTRING(Waypoint_RegisterArtillery_displayName);
        type = "SCRIPTED";
        script = QPATHTOF(functions\fnc_taskArtilleryRegister.sqf);
    };
};
