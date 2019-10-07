class CfgWaypoints {
    class LAMBS_DangerAI {
        displayName = "Advanced AI [LAMBS]";
        class EGVAR(danger,Attack) {
            displayName = "0 TASK ATTACK [Enters buildings]";
            displayNameDebug = QEGVAR(danger,Attack);
            file = QPATHTOF(functions\fnc_taskAttack.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\SeekAndDestroy_ca.paa";
            tooltip = "Units assault position and check buildings around waypoint out to WP completion radius (default 25m)";
        };
        class EGVAR(danger,Garrison) {
            displayName = "1 TASK GARRISON";
            displayNameDebug = QEGVAR(danger,Garrison);
            file = QPATHTOF(scripts\fnc_wpGarrison.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
            tooltip = "Garrisons units in buildings around waypoint out to WP completion radius (default 50m)";
        };
        class EGVAR(danger,Patrol) {
            displayName = "2 TASK PATROL";
            displayNameDebug = QEGVAR(danger,Patrol);
            file = QPATHTOF(scripts\fnc_wpPatrol.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
            tooltip = "Randomised patrol within WP completion radius (Default 200m)";
        };
        class EGVAR(danger,Rush) {
            displayName = "3 TASK RUSH";
            displayNameDebug = QEGVAR(danger,Rush);
            file = QPATHTOF(scripts\fnc_wpRush.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Rushes towards enemy with WP completion radius (Default 1000m)";
        };
        class EGVAR(danger,Hunt) {
            displayName = "4 TASK HUNT";
            displayNameDebug = QEGVAR(danger,Hunt);
            file = QPATHTOF(scripts\fnc_wpHunt.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Hunts the AI around group leader out to WP completion radius (Default 1000m)";
        };
        class EGVAR(danger,Creep) {
            displayName = "5 TASK CREEP";
            displayNameDebug = QEGVAR(danger,Creep);
            file = QPATHTOF(scripts\fnc_wpCreep.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Stalks the AI around group leader out to WP completion radius (Default 1000m)";
        };
        class EGVAR(danger,CQB) {
            displayName = "6 TASK CQB [Experimental]";
            displayNameDebug = QEGVAR(danger,CQB);
            file = QPATHTOF(scripts\fnc_wpCQB.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\SeekAndDestroy_ca.paa";
            tooltip = "Clears buildings around the waypoint out to WP completion radius (Default 50m)";
        };
        class EGVAR(danger,Artillery) {
            displayName = "9 REGISTER ARTILLERY";
            displayNameDebug = "LAMBS_Register_Artillery";
            file = QPATHTOF(functions\fnc_taskArtilleryRegister.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
            tooltip = "Registers artillery for dynamic use";
        };
    };
};
