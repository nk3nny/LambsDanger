// Zeus Modules
class GVAR(Target) : Module_F {
    _generalMacro = QGVAR(Target);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    displayName = CSTRING(Module_Target_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
    portrait = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
    function = QFUNC(moduleTarget);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskArtillery) : Module_F {
    _generalMacro = QGVAR(ZeusTaskArtillery);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskArtillery_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    portrait = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    function = QFUNC(moduleArtillery);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskArtilleryRegister) : Module_F {
    _generalMacro = QGVAR(ZeusTaskArtilleryRegister);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskArtilleryRegister_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
    portrait = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
    function = QFUNC(moduleArtilleryRegister);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskAssault) : Module_F {
    _generalMacro = QGVAR(ZeusTaskAssault);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskAssault_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    portrait = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    function = QFUNC(moduleAssault);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskCamp) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCamp);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskCamp_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    function = QFUNC(moduleCamp);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskCQB) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCQB);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskCQB_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    function = QFUNC(moduleCQB);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskGarrison) : Module_F {
    _generalMacro = QGVAR(ZeusTaskGarrison);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskGarrison_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    function = QFUNC(moduleGarrison);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskPatrol) : Module_F {
    _generalMacro = QGVAR(ZeusTaskPatrol);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskPatrol_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    portrait = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    function = QFUNC(modulePatrol);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskReset) : Module_F {
    _generalMacro = QGVAR(ZeusTaskReset);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskReset_DisplayName);
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    function = QFUNC(moduleReset);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

// Search Modules
class GVAR(ZeusTaskCreep) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCreep);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskCreep_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    function = QFUNC(moduleCreep);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskHunt) : Module_F {
    _generalMacro = QGVAR(ZeusTaskHunt);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskHunt_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    function = QFUNC(moduleHunt);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};

class GVAR(ZeusTaskRush) : Module_F {
    _generalMacro = QGVAR(ZeusTaskRush);
    scope = 1;
    scopeCurator = 2;
    isGlobal = 0;
    is3DEN = 1;
    displayName = CSTRING(Module_TaskRush_DisplayName);
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    function = QFUNC(moduleRush);
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE(_this call EFUNC(main,initModules));
        };
    };
};
