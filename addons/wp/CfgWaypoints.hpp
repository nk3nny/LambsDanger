class CfgWaypoints {
    class LAMBS_DangerAI {
        displayName = "Advanced AI [LAMBS]";
        class EGVAR(danger,Attack) {
            displayName = "0 TASK ASSAULT";
            displayNameDebug = QEGVAR(danger,Attack);
            file = QPATHTOF(scripts\fnc_wpAssault.sqf);
            icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
            tooltip = "Rushes to target position with no regard for safety";
        };
        class EGVAR(danger,Retreat) {
            displayName = "0 TASK FORCED RETREAT";
            displayNameDebug = QEGVAR(danger,Retreat);
            file = QPATHTOF(scripts\fnc_wpRetreat.sqf);
            icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
            tooltip = "Retreats to target position while ignoring enemies";
        };
        class EGVAR(danger,Garrison) {
            displayName = "1 TASK GARRISON";
            displayNameDebug = QEGVAR(danger,Garrison);
            file = QPATHTOF(scripts\fnc_wpGarrison.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
            tooltip = "Garrisons in buildings around waypoint out to WP completion radius (default 50m)";
        };
        class EGVAR(danger,Patrol) {
            displayName = "2 TASK PATROL";
            displayNameDebug = QEGVAR(danger,Patrol);
            file = QPATHTOF(scripts\fnc_wpPatrol.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
            tooltip = "Randomised patrol within WP completion radius (Default 200m)\nNB will remove all existing waypoints from group";
        };
        class EGVAR(danger,Rush) {
            displayName = "3 TASK RUSH";
            displayNameDebug = QEGVAR(danger,Rush);
            file = QPATHTOF(scripts\fnc_wpRush.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Rushes players within WP completion radius (Default 1000m)\nOnly targets players!";
        };
        class EGVAR(danger,Hunt) {
            displayName = "4 TASK HUNT";
            displayNameDebug = QEGVAR(danger,Hunt);
            file = QPATHTOF(scripts\fnc_wpHunt.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Hunts players within WP completion radius (Default 1000m)\nOnly targets players!";
        };
        class EGVAR(danger,Creep) {
            displayName = "5 TASK CREEP";
            displayNameDebug = QEGVAR(danger,Creep);
            file = QPATHTOF(scripts\fnc_wpCreep.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = "Stalks players within WP completion radius (Default 1000m)\nOnly targets players!";
        };
        class EGVAR(danger,CQB) {
            displayName = "6 TASK CQB [Experimental]";
            displayNameDebug = QEGVAR(danger,CQB);
            file = QPATHTOF(scripts\fnc_wpCQB.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
            tooltip = "Enters and clears buildings within WP completion radius (Default 50m)";
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
