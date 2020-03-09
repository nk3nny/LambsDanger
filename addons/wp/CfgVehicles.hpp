class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Default;
            class Edit;
            class Combo;
            class Checkbox;
            class CheckboxNumber;
            class ModuleDescription;
            class Units;
        };
        class ModuleDescription {
            class AnyBrain;
        };
    };

    // Zeus Modules
    class GVAR(Target) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(Target);
        scope = 1;
        scopeCurator = 2;
        displayName = "Lambs Target"; // TODO
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleTarget);
        functionPriority = 1;
        icon = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
        portrait = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
        isGlobal = 0;
        class ModuleDescription: ModuleDescription {
            duplicate = 0;
            position = 1;
            direction = 0;
            description = "TODO";
        };
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
        isGlobal = 0;
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 0;
            description = "TODO";
        };
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
        portrait = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
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
        icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
        portrait = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
        isGlobal = 0;
        class Attributes: AttributesBase {
            class IsRetreat: Checkbox {
                displayName = "Is Retreat"; // TODO
                tooltip = "Is Retreating"; // TODO
                property = "IsRetreat";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class DeleteOnStartUp: Checkbox {
                displayName = "Delete On Start Up"; // TODO
                tooltip = "Delete On Start Up"; // TODO
                property = "DeleteOnStartUp";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class DistanceThreshold {
                displayName = "Distance Threshold"; // TODO
                tooltip = "The Distance the Task Terminates"; // TODO
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
                displayName = "Cycle Time"; // TODO
                tooltip = "The Cycle Time"; // TODO
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "3";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 0;
            description = "TODO";
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
        portrait = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
        class Attributes: AttributesBase {
            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
        };
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class CycleTime {
                displayName = "Cycle Time"; // TODO
                tooltip = "The Cycle Time"; // TODO
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class DeleteOnStartUp: Checkbox {
                displayName = "Delete On Start Up"; // TODO
                tooltip = "Delete On Start Up"; // TODO
                property = "DeleteOnStartUp";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class CycleTime {
                displayName = "Cycle Time"; // TODO
                tooltip = "The Cycle Time"; // TODO
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
        };
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
        };
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class CycleTime {
                displayName = "Cycle Time"; // TODO
                tooltip = "The Cycle Time"; // TODO
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
        };
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
        portrait = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class WaypointCount {
                displayName = "Waypoint Count"; // TODO
                tooltip = "The Amount of Waypoits the Module Creates"; // TODO
                property = "WaypointCount";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "4";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class MoveWaypoints: Checkbox {
                displayName = "Move Waypoints After Completion"; // TODO
                tooltip = "Move Waypoints After Completion"; // TODO
                property = "moveWaypoints";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
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
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {100, 100, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class CycleTime {
                displayName = "Cycle Time"; // TODO
                tooltip = "The Cycle Time"; // TODO
                property = "CycleTime";
                control = "EditShort";
                expression = "_this setVariable ['%s', _value];";
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "TODO";
        };
    };
};
