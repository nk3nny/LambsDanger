// Editor Modules
class GVAR(TaskArtillery) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskArtillery);
    scope = 2;
    displayName = CSTRING(Module_TaskArtillery_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleArtillery);
    icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    portrait = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    class Attributes: AttributesBase {
        class GVAR(Side) {
            displayName = CSTRING(Module_TaskArtillery_Side_DisplayName);
            tooltip = CSTRING(Module_TaskArtillery_Side_Tooltip);
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
            displayName = CSTRING(Module_TaskArtillery_MainSalvo_DisplayName);
            tooltip = CSTRING(Module_TaskArtillery_MainSalvo_Tooltip);
            property = QGVAR(MainSalvo);
            defaultValue = "6";
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "NUMBER";
        };
        class GVAR(Spread): EditShort {
            displayName = CSTRING(Module_TaskArtillery_Spread_DisplayName);
            tooltip = CSTRING(Module_TaskArtillery_Spread_Tooltip);
            property = QGVAR(Spread);
            defaultValue = "75";
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "NUMBER";
        };
        class GVAR(SkipCheckRounds): Checkbox {
            displayName = CSTRING(Module_TaskArtillery_SkipCheckrounds_DisplayName);
            tooltip = CSTRING(Module_TaskArtillery_SkipCheckrounds_Tooltip);
            property = QGVAR(SkipCheckRounds);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
        };
        class ModuleDescription: ModuleDescription {};
    };
    class ModuleDescription: ModuleDescription {
        description = CSTRING(Module_TaskArtillery_ModuleDescription);
    };
};

class GVAR(TaskArtilleryRegister) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskArtilleryRegister);
    scope = 2;
    displayName = CSTRING(Module_TaskArtilleryRegister_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleArtilleryRegister);
    icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
    portrait = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
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
        direction = 1;
        description = CSTRING(Module_TaskArtilleryRegister_ModuleDescription);
    };
};

class GVAR(TaskAssault) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskAssault);
    scope = 2;
    displayName = CSTRING(Module_TaskAssault_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleAssault);
    icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    portrait = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    class Attributes: AttributesBase {
        class GVAR(IsRetreat): Checkbox {
            displayName = CSTRING(Module_TaskAssault_Retreating_DisplayName);
            tooltip = CSTRING(Module_TaskAssault_Retreating_Tooltip);
            property = QGVAR(IsRetreat);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
        };
        class GVAR(DeleteOnStartUp): Checkbox {
            displayName = CSTRING(Module_TaskAssault_DeleteOnStartup_DisplayName);
            tooltip = CSTRING(Module_TaskAssault_DeleteOnStartup_Tooltip);
            property = QGVAR(DeleteOnStartUp);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
        };
        class GVAR(DistanceThreshold): EditShort {
            displayName = CSTRING(Module_TaskAssault_DistanceThreshold_DisplayName);
            tooltip = CSTRING(Module_TaskAssault_DistanceThreshold_Tooltip);
            property = QGVAR(DistanceThreshold);
            defaultValue = "15";
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "NUMBER";
        };
        class GVAR(CycleTime): EditShort {
            displayName = CSTRING(Module_TaskAssault_CycleTime_DisplayName);
            tooltip = CSTRING(Module_TaskAssault_CycleTime_Tooltip);
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
        description = CSTRING(Module_TaskAssault_ModuleDescription);
    };
};

class GVAR(TaskCamp) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskCamp);
    scope = 2;
    displayName = CSTRING(Module_TaskCamp_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleCamp);
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
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
        description = CSTRING(Module_TaskCamp_ModuleDescription);
    };
};

class GVAR(TaskCQB) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskCQB);
    scope = 2;
    displayName = CSTRING(Module_TaskCQB_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleCQB);
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    canSetArea = 1;
    canSetAreaShape = 1;
    class AttributeValues {
        size3[] = {50, 50, -1};
        isRectangle = 0;
    };
    class Attributes: AttributesBase {
        class GVAR(CycleTime): EditShort {
            displayName = CSTRING(Module_TaskCQB_CycleTime_DisplayName);
            tooltip = CSTRING(Module_TaskCQB_CycleTime_Tooltip);
            property = QGVAR(CycleTime);
            defaultValue = "21";
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "NUMBER";
        };
        class GVAR(DeleteOnStartUp): Checkbox {
            displayName = CSTRING(Module_TaskCQB_DeleteOnStartUp_DisplayName);
            tooltip = CSTRING(Module_TaskCQB_DeleteOnStartUp_Tooltip);
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
        direction = 1;
        description = CSTRING(Module_TaskCQB_ModuleDescription);
    };
};

class GVAR(TaskGarrison) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskGarrison);
    scope = 2;
    displayName = CSTRING(Module_TaskGarrison_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleGarrison);
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
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
        direction = 1;
        description = CSTRING(Module_TaskGarrison_ModuleDescription);
    };
};

class GVAR(TaskPatrol) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskPatrol);
    scope = 2;
    displayName = CSTRING(Module_TaskPatrol_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(modulePatrol);
    icon = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    portrait = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    canSetArea = 1;
    canSetAreaShape = 1;
    class AttributeValues {
        size3[] = {200, 200, -1};
        isRectangle = 0;
    };
    class Attributes: AttributesBase {
        class GVAR(WaypointCount): EditShort {
            displayName = CSTRING(Module_TaskPatrol_Waypoints_DisplayName);
            tooltip = CSTRING(Module_TaskPatrol_Waypoints_Tooltip);
            property = QGVAR(WaypointCount);
            defaultValue = "4";
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "NUMBER";
        };
        class GVAR(MoveWaypoints): Checkbox {
            displayName = CSTRING(Module_TaskPatrol_MoveWaypoints_DisplayName);
            tooltip = CSTRING(Module_TaskPatrol_MoveWaypoints_Tooltip);
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
        direction = 1;
        description = CSTRING(Module_TaskPatrol_ModuleDescription);
    };
};

class GVAR(TaskReset) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskReset);
    scope = 2;
    displayName = CSTRING(Module_TaskReset_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    function = QFUNC(moduleReset);
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    class ModuleDescription: ModuleDescription {
        description = CSTRING(Module_TaskReset_ModuleDescription);
    };
};

// Search Modules
class GVAR(TaskCreep) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskCreep);
    scope = 2;
    displayName = CSTRING(Module_TaskCreep_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    function = QFUNC(moduleCreep);
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    canSetArea = 1;
    canSetAreaShape = 1;
    class AttributeValues {
        size3[] = {1000, 1000, -1};
        isRectangle = 0;
    };
    class Attributes: AttributesBase {
        class GVAR(MovingCenter): Checkbox {
            displayName = CSTRING(Module_TaskCreep_MovingCenter_DisplayName);
            tooltip = CSTRING(Module_TaskCreep_MovingCenter_Tooltip);
            property = QGVAR(MovingCenter);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
            defaultValue = "(true)";
        };
        class GVAR(CycleTime): EditShort {
            displayName = CSTRING(Module_TaskCreep_CycleTime_DisplayName);
            tooltip = CSTRING(Module_TaskCreep_CycleTime_Tooltip);
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
        direction = 1;
        description = CSTRINGModule_TaskCreep_ModuleDescription);
    };
};

class GVAR(TaskHunt) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskHunt);
    scope = 2;
    displayName = CSTRING(Module_TaskHunt_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    function = QFUNC(moduleHunt);
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    canSetArea = 1;
    canSetAreaShape = 1;
    class AttributeValues {
        size3[] = {1000, 1000, -1};
        isRectangle = 0;
    };
    class Attributes: AttributesBase {
        class GVAR(MovingCenter): Checkbox {
            displayName = CSTRINGModule_TaskHunt_MovingCenter_DisplayName);
            tooltip = CSTRINGModule_TaskHunt_MovingCenter_ToolTip);
            property = QGVAR(MovingCenter);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
            defaultValue = "(true)";
        };
        class GVAR(CycleTime): EditShort {
            displayName = CSTRINGModule_TaskHunt_CycleTime_DisplayName);
            tooltip = CSTRINGModule_TaskHunt_CycleTime_ToolTip);
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
        direction = 1;
        description = CSTRINGModule_TaskHunt_ModuleDescription);
    };
};

class GVAR(TaskRush) : GVAR(BaseModule) {
    _generalMacro = QGVAR(TaskRush);
    scope = 2;
    displayName = CSTRING(Module_TaskRush_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    function = QFUNC(moduleRush);
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    canSetArea = 1;
    canSetAreaShape = 1;
    class AttributeValues {
        size3[] = {1000, 1000, -1};
        isRectangle = 0;
    };
    class Attributes: AttributesBase {
        class GVAR(MovingCenter): Checkbox {
            displayName = CSTRINGModule_TaskRush_MovingCenter_DisplayName);
            tooltip = CSTRINGModule_TaskRush_MovingCenter_ToolTip);
            property = QGVAR(MovingCenter);
            unique = 0;
            validate = "none";
            condition = "0";
            typeName = "BOOL";
            defaultValue = "(true)";
        };
        class GVAR(CycleTime): EditShort {
            displayName = CSTRINGModule_TaskRush_CycleTime_DisplayName);
            tooltip = CSTRINGModule_TaskRush_CycleTime_ToolTip);
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
        direction = 1;
        description = CSTRINGModule_TaskRush_ModuleDescription);
    };
};
