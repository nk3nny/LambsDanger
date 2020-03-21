// Zeus Modules
class GVAR(Target) : Module_F {
    _generalMacro = QGVAR(Target);
    is3DEN = 0;
    scope = 1;
    scopeCurator = 2;
    displayName = "Dynamic Target";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
    portrait = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([ARR_3(_this select 0,true,true)] call FUNC(moduleTarget));
        };
    };
};

class GVAR(ZeusTaskArtillery) : Module_F {
    _generalMacro = QGVAR(ZeusTaskArtillery);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Artillery";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    portrait = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleArtillery));
        };
    };
};

class GVAR(ZeusTaskArtilleryRegister) : Module_F {
    _generalMacro = QGVAR(ZeusTaskArtilleryRegister);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Artillery Register";
    category = "Lambs_Danger_WP_Cat";
    icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
    portrait = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleArtilleryRegister));
        };
    };
};

class GVAR(ZeusTaskAssault) : Module_F {
    _generalMacro = QGVAR(ZeusTaskAssault);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Assault/Retreat";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    portrait = "\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleAssault));
        };
    };
};

class GVAR(ZeusTaskCamp) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCamp);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Camp";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleCamp));
        };
    };
};

class GVAR(ZeusTaskCQB) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCQB);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task CQB";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleCQB));
        };
    };
};

class GVAR(ZeusTaskGarrison) : Module_F {
    _generalMacro = QGVAR(ZeusTaskGarrison);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Garrison";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleGarrison));
        };
    };
};

class GVAR(ZeusTaskPatrol) : Module_F {
    _generalMacro = QGVAR(ZeusTaskPatrol);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Patrol";
    category = "Lambs_Danger_WP_Cat";
    icon = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    portrait = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(modulePatrol));
        };
    };
};

class GVAR(ZeusTaskReset) : Module_F {
    _generalMacro = QGVAR(ZeusTaskReset);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Reset";
    category = "Lambs_Danger_WP_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleReset));
        };
    };
};

// Search Modules
class GVAR(ZeusTaskCreep) : Module_F {
    _generalMacro = QGVAR(ZeusTaskCreep);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Creep";
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleCreep));
        };
    };
};

class GVAR(ZeusTaskHunt) : Module_F {
    _generalMacro = QGVAR(ZeusTaskHunt);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Hunt";
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleHunt));
        };
    };
};

class GVAR(ZeusTaskRush) : Module_F {
    _generalMacro = QGVAR(ZeusTaskRush);
    scope = 1;
    scopeCurator = 2;
    displayName = "Task Rush";
    category = "Lambs_Danger_WP_Search_Cat";
    icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    portrait = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
    class EventHandlers {
        class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        class ADDON {
            init = QUOTE([[ARR_2("init",[ARR_3(_this select 0,true,true)])]] call FUNC(moduleRush));
        };
    };
};
