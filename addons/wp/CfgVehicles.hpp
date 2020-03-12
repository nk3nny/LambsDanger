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
            class EmptyDetector;
        };
    };

    class GVAR(BaseModule): Module_F {
        _generalMacro = QGVAR(BaseModule);
        scope = 0;
        scopeCurator = 0;
        class AttributesBase: AttributesBase {
            class EditShort {
                control = "EditShort";
                expression = "_this setVariable ['%s', _value, true];";
                defaultValue = "15";
            };
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 0;
            position = 1;
            direction = 0;
            description = "TODO";
            sync[] = {"AnyBrain", "Condition"};
            class Condition: EmptyDetector {
                optional = 1;
            };
        };
    };

    // Zeus Modules
    class GVAR(Target) : GVAR(BaseModule) {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(Target);
        scope = 1;
        scopeCurator = 2;
        displayName = "Dynamic Target";
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
            description = "The LAMBS dynamic target creates a point of reference for scripts. The module can be dynamically moved and can be attached to units.";
        };
    };

    // Zeus and Editor Modules
    class GVAR(TaskArtillery) : GVAR(BaseModule) {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskArtillery);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Artillery";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleArtillery);
        functionPriority = 1;
        icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
        portrait = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
        isGlobal = 0;
        isTriggerActivated = 1;
        class Attributes: AttributesBase {
            class GVAR(Side) {
                displayName = "Side";
                tooltip = "Which side is calling for artillery";
                property = QGVAR(Side);
                defaultValue = "0";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
                control = QGVAR(Side);
                expression = "_this setVariable ['%s', _value, true];";
            };
            class GVAR(MainSalvo): EditShort {
                displayName = "Main Salvo";
                tooltip = "Number of rounds in main salvo";
                property = QGVAR(MainSalvo);
                defaultValue = "6";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class GVAR(Spread): EditShort {
                displayName = "Spread";
                tooltip = "Default dispersion of main salvo";
                property = QGVAR(Spread);
                defaultValue = "75";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class GVAR(SkipCheckRounds): Checkbox {
                displayName = "Skip adjusting rounds";
                tooltip = "Check this to disable initial rounds used by the fire controller to adjust rounds on target.\nSkipping this will make the barrage immediately hit on target.";
                property = QGVAR(SkipCheckRounds);
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 0;
            position = 1;
            direction = 0;
            description = "This location is targeted by the first available artillery unit of a given side. The artillery unit must be registered to the side and be within striking distance.";
        };
    };

    class GVAR(TaskArtilleryRegister) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
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
            description = "Register units to that sides artillery pool.";
        };
    };

    class GVAR(TaskAssault) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
        class Attributes: AttributesBase {
            class GVAR(IsRetreat): Checkbox {
                displayName = "Unit is fleeing";
                tooltip = "Enable this to make the unit retreat and ignore enemies";
                property = QGVAR(IsRetreat);
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class GVAR(DeleteOnStartUp): Checkbox {
                displayName = "Remove module on Start Up";
                tooltip = "Deletes module on start up\nIf unchecked it is possible to move module to change destination dynamically.";
                property = QGVAR(DeleteOnStartUp);
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "BOOL";
            };
            class GVAR(DistanceThreshold): EditShort {
                displayName = "Completion Threshold";
                tooltip = "Units within this many meters will revert to regular behaviour";
                property = QGVAR(DistanceThreshold);
                defaultValue = "15";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class GVAR(CycleTime): EditShort {
                displayName = "Script interval";
                tooltip = "The cycle time of the script";
                property = QGVAR(CycleTime);
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
            description = "Task Assault/Retreat is a multi-purpose module. It makes linked unit rush or retreat madly towards the module destination. The module can be moved to dynamically alter final destination.";
        };
    };

    class GVAR(TaskCQB) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {50, 50, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class GVAR(CycleTime): EditShort {
                displayName = "Script interval";
                tooltip = "The cycle time for the script in seconds. Higher numbers make units search buildings more carefully.\nDefault 21 seconds";
                property = QGVAR(CycleTime);
                defaultValue = "21";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class GVAR(DeleteOnStartUp): Checkbox {
                displayName = "Remove Dynamic center";
                tooltip = "With the dynamic center present it is possible to move the central point of the building search pattern";
                property = QGVAR(DeleteOnStartUp);
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
            description = "Task CQB makes the unit search buildings with the area. Set the module size in 3DEN to configured searched area. The module can be moved to dynamically shift the searched area.<br/><br/>In general the module works best with a smaller AOE. Better to string multiple modules or waypoints together than have one massive one. Groups of the same side will share which buildings have been cleared and which still need searching.";
        };
    };

    class GVAR(TaskGarrison) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {50, 50, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "Task Garrison makes the unit take up positions in buildings and man available turrets and static weapons within an area defined by 3DEN attributes.";
        };
    };

    class GVAR(TaskPatrol) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {200, 200, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class GVAR(WaypointCount): EditShort {
                displayName = "Waypoints";
                tooltip = "Number of waypoints created";
                property = QGVAR(WaypointCount);
                defaultValue = "4";
                unique = 0;
                validate = "none";
                condition = "0";
                typeName = "NUMBER";
            };
            class GVAR(MoveWaypoints): Checkbox {
                displayName = "Dynamic patrol pattern";
                tooltip = "Unit will generate a new patrol pattern once one patrol cycle is complete";
                property = QGVAR(moveWaypoints);
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
            description = "Task Patrol makes the unit patrol within the area set by 3DEN attributes.";
        };
    };

    // Search Modules
    class GVAR(TaskCreep) : GVAR(BaseModule) {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskCreep);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Creep";
        category = "Lambs_Danger_WP_Search_Cat";
        function = QFUNC(moduleCreep);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {1000, 1000, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class GVAR(CycleTime): EditShort {
                displayName = "Script interval";
                tooltip = "The cycle time for the script in seconds. Higher numbers can be used to make the creeping group less accurate\nDefault 15 seconds";
                property = QGVAR(CycleTime);
                defaultValue = "15";
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
            description = "Task Creep makes the unit attempt to ambush enemies within the area set by 3DEN attributes. The group will use available cover and keep a low stance to remain undiscovered.<br/><br/>Search modules only target hostile players.";
        };
    };

    class GVAR(TaskHunt) : GVAR(BaseModule) {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskHunt);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Hunt";
        category = "Lambs_Danger_WP_Search_Cat";
        function = QFUNC(moduleHunt);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {1000, 1000, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class GVAR(CycleTime): EditShort {
                displayName = "Script interval";
                tooltip = "The cycle time for the script in seconds. Higher numbers can be used to make the hunting group less accurate\nDefault 70 seconds";
                property = QGVAR(CycleTime);
                defaultValue = "70";
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
            description = "Task Hunt makes the unit patrol the area within the area set by 3DEN attributes. The group will move casually in a search pattern gradually spiralling closer to the target. The unit will enable flashlights if available.<br/><br/>Search modules only target hostile players.";
        };
    };

    class GVAR(TaskRush) : GVAR(BaseModule) {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskRush);
        scope = 2;
        is3DEN = 1;
        scopeCurator = 2;
        displayName = "Task Rush";
        category = "Lambs_Danger_WP_Search_Cat";
        function = QFUNC(moduleRush);
        functionPriority = 1;
        icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        isGlobal = 0;
        isTriggerActivated = 1;
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {1000, 1000, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            class GVAR(CycleTime): EditShort {
                displayName = "Script interval";
                tooltip = "The cycle time for the script in seconds. Higher numbers can be used to make rushers less accurate\nDefault 4 seconds";
                property = QGVAR(CycleTime);
                defaultValue = "4";
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
            description = "Task Rush makes the unit attempt run aggressively towards enemies within the area set by 3DEN attributes. The unit will move extremely aggressively, often ignoring cover and suppression.<br/><br/>Search modules only target hostile players. Disable unit FSM for a truly terrifying enemy.";
        };
    };

    // Disabled
    class GVAR(TaskCamp) : GVAR(BaseModule) {
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
        isTriggerActivated = 1;
        class Attributes: AttributesBase {
            class ModuleDescription: ModuleDescription {};
        };

        class ModuleDescription: ModuleDescription {
            duplicate = 1;
            position = 1;
            direction = 1;
            description = "Task Camp makes the unit appear to gather around a single point, typically a camp site. Some units will peel off to man static weapons, garrison buildings and patrol the area.";
        };
    };

};
