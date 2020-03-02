class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase;
    };

    // Zeus Modules
    class GVAR(Target) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(Target);
        scope = 1;
        scopeCurator = 2;
        displayName = "Target for Lambs Danger Zeus Modules";
        category = "Lambs_Danger_WP_Cat";
        function = "";
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
    };

    // Editor Modules
    class GVAR(TaskArtillery) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskArtillery);
        scope = 0;
        is3DEN = 1;
        scopeCurator = 0;
        displayName = "Task Artillery";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleArtillery);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
        isGlobal = 0;
    };

    class GVAR(TaskArtilleryRegister) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskArtilleryRegister);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Artillery Register";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleArtilleryRegister);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
    };

    class GVAR(TaskAssault) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskAssault);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Assault/Retreat";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleAssault);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\SeekAndDestroy_ca.paa";
        isGlobal = 0;
        class Attributes: AttributesBase {
            class IsRetreat {
                displayName = "Is Retreat";
                tooltip = "Is Retreating";
                property = "IsRetreat";
                control = "Checkbox";
                expression = "_this setVariable ['%s',_value];";
                defaultValue = "false";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class DistanceThreshold {
                displayName = "Distance Threshold";
                tooltip = "The Distance the Task Terminates";
                property = "DistanceThreshold";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "15";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class CycleTime {
                displayName = "Cycle Time";
                tooltip = "The Cycle Time";
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "3";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
        };
    };

    class GVAR(TaskCamp) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskCamp);
        scope = 0;
        is3DEN = 1;
        scopeCurator = 0;
        displayName = "Task Camp";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleCamp);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
    };

    class GVAR(TaskCQB) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskCQB);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task CQB";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleCQB);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class CycleTime {
                displayName = "Cycle Time";
                tooltip = "The Cycle Time";
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
        };
    };

    class GVAR(TaskCreep) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskCreep);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Creep";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleCreep);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
    };

    class GVAR(TaskGarrison) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskGarrison);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Garrison";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleGarrison);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
        isGlobal = 0;
    };

    class GVAR(TaskHunt) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskHunt);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Hunt";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleHunt);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
    };

    class GVAR(TaskPatrol) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskPatrol);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Patrol";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(modulePatrol);
        functionPriority = 1;
        icon = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class WaypointCount {
                displayName = "Waypoint Count";
                tooltip = "The Amount of Waypoits the Module Creates";
                property = "WaypointCount";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "4";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
        };
    };

    class GVAR(TaskRush) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskRush);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Rush";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleRush);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
    };
};
