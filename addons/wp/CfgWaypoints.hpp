class CfgWaypoints {
    class LAMBS_DangerAI {
        displayName = "Advanced AI [LAMBS] - DEPRECATED, USE MODULES";
        class EGVAR(danger,Attack) {
            displayName = CSTRING(Waypoint_Deprecated_TaskAssault_displayName);
            displayNameDebug = QEGVAR(danger,Attack);
            file = QPATHTOF(scripts\fnc_wpAssault.sqf);
            icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskAssault_Tooltip);
        };
        class EGVAR(danger,Retreat) {
            displayName = CSTRING(Waypoint_Deprecated_TaskRetreat_displayName);
            displayNameDebug = QEGVAR(danger,Retreat);
            file = QPATHTOF(scripts\fnc_wpRetreat.sqf);
            icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskRetreat_Tooltip);
        };
        class EGVAR(danger,Garrison) {
            displayName = CSTRING(Waypoint_Deprecated_TaskGarrison_displayName);
            displayNameDebug = QEGVAR(danger,Garrison);
            file = QPATHTOF(scripts\fnc_wpGarrison.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskGarrison_Tooltip);
        };
        class EGVAR(danger,Patrol) {
            displayName = CSTRING(Waypoint_Deprecated_TaskPatrol_displayName);
            displayNameDebug = QEGVAR(danger,Patrol);
            file = QPATHTOF(scripts\fnc_wpPatrol.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
            ToolTip = CSTRING(Waypoint_Deprecated_TaskPatrol_Tooltip);
        };
        class EGVAR(danger,Rush) {
            displayName = CSTRING(Waypoint_Deprecated_TaskRush_displayName);
            displayNameDebug = QEGVAR(danger,Rush);
            file = QPATHTOF(scripts\fnc_wpRush.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskRush_Tooltip);
        };
        class EGVAR(danger,Hunt) {
            displayName = CSTRING(Waypoint_Deprecated_TaskHunt_displayName);
            displayNameDebug = QEGVAR(danger,Hunt);
            file = QPATHTOF(scripts\fnc_wpHunt.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskHunt_Tooltip);
        };
        class EGVAR(danger,Creep) {
            displayName = CSTRING(Waypoint_Deprecated_TaskCreep_displayName);
            displayNameDebug = QEGVAR(danger,Creep);
            file = QPATHTOF(scripts\fnc_wpCreep.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskCreep_Tooltip);
        };
        class EGVAR(danger,CQB) {
            displayName = CSTRING(Waypoint_Deprecated_TaskCQB_displayName);
            displayNameDebug = QEGVAR(danger,CQB);
            file = QPATHTOF(scripts\fnc_wpCQB.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_TaskCQB_Tooltip);
        };
        class EGVAR(danger,Artillery) {
            displayName = CSTRING(Waypoint_Deprecated_RegisterArtillery_displayName);
            displayNameDebug = "LAMBS_Register_Artillery";
            file = QPATHTOF(functions\fnc_taskArtilleryRegister.sqf);
            icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
            tooltip = CSTRING(Waypoint_Deprecated_RegisterArtillery_Tooltip);
        };
    };
};
