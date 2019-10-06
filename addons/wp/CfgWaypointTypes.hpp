class ZEN_WaypointTypes {
    class EGVAR(danger,Attack) {
        displayName = "0 TASK ATTACK [Enters buildings]";
        type = "SCRIPTED";
        script = QPATHTOF(functions\fnc_taskAttack.sqf);
    };
    class EGVAR(danger,Garrison) {
        displayName = "1 TASK GARRISON";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpGarrison.sqf);
    };
    class EGVAR(danger,Patrol) {
        displayName = "2 TASK PATROL";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpPatrol.sqf);
    };
    class EGVAR(danger,Rush) {
        displayName = "3 TASK RUSH";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpRush.sqf);
    };
    class EGVAR(danger,Hunt) {
        displayName = "4 TASK HUNT";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpHunt.sqf);
    };
    class EGVAR(danger,Creep) {
        displayName = "5 TASK CREEP";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCreep.sqf);
    };
    class EGVAR(danger,CQB) {
        displayName = "6 TASK CQB [Experimental]";
        type = "SCRIPTED";
        script = QPATHTOF(scripts\fnc_wpCQB.sqf);
    };
    class EGVAR(danger,Artillery) {
        displayName = "9 REGISTER ARTILLERY";
        type = "SCRIPTED";
        script = QPATHTOF(functions\fnc_taskArtilleryRegister.sqf);
    };
};
