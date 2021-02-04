class ZEN_WaypointTypes {
    class EGVAR(danger,Attack) {
        displayName = "TASK ASSAULT";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpAssault.sqf);
    };
    class EGVAR(danger,Retreat) {
        displayName = "TASK FORCED RETREAT";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpRetreat.sqf);
    };
    class EGVAR(danger,Garrison) {
        displayName = "TASK GARRISON";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpGarrison.sqf);
    };
    class EGVAR(danger,Patrol) {
        displayName = "TASK PATROL";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpPatrol.sqf);
    };
    class EGVAR(danger,Rush) {
        displayName = "TASK RUSH (Rush nearest)";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpRush.sqf);
    };
    class EGVAR(danger,Hunt) {
        displayName = "TASK HUNT (Find nearest)";
        tooltip = "test";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpHunt.sqf);
    };
    class EGVAR(danger,Creep) {
        displayName = "TASK CREEP (Stalk nearest)";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCreep.sqf);
    };
    class EGVAR(danger,CQB) {
        displayName = "TASK CQB [Experimental]";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCQB.sqf);
    };
    class EGVAR(danger,Artillery) {
        displayName = "REGISTER ARTILLERY";
        type = "SCRIPTED";
        script = QPATHTOF(functions\fnc_taskArtilleryRegister.sqf);
    };
};
