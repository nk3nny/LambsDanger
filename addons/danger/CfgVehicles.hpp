class CBA_Extended_EventHandlers_base;
class CfgVehicles {
    class CAManBase;
    class Civilian;
    class SoldierWB: CAManBase {
        fsmDanger = QUOTE(PATHTOF2_SYS(PREFIX,COMPONENT,scripts\lambs_danger.fsm));
    };
    class SoldierEB: CAManBase {
        fsmDanger = QUOTE(PATHTOF2_SYS(PREFIX,COMPONENT,scripts\lambs_danger.fsm));
    };
    class SoldierGB: CAManBase {
        fsmDanger = QUOTE(PATHTOF2_SYS(PREFIX,COMPONENT,scripts\lambs_danger.fsm));
    };
    class Civilian_F: Civilian {
        fsmDanger = QUOTE(PATHTOF2_SYS(PREFIX,COMPONENT,scripts\lambs_dangerCivilian.fsm));
    };

    class Module_F;

    class GVAR(SetRadio) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(SetRadio);
        scope = 1;
        scopeCurator = 2;
        displayName = CSTRING(Module_SetRadio_DisplayName);
        isGlobal = 0;
        category = "Lambs_Danger_Cat";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        function = QFUNC(moduleSetRadio);
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
            class ADDON {
                init = QUOTE(_this call EFUNC(main,initModules));
            };
        };
    };

    class GVAR(DisableAI) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(DisableAI);
        scope = 1;
        scopeCurator = 2;
        displayName = CSTRING(Module_DisableAI_DisplayName);
        isGlobal = 0;
        category = "Lambs_Danger_Cat";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        function = QFUNC(moduleDisableAI);
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
            class ADDON {
                init = QUOTE(_this call EFUNC(main,initModules));
            };
        };
    };

    class GVAR(DisableGroupAI) : Module_F {
        _generalMacro = QGVAR(DisableGroupAI);
        scope = 1;
        scopeCurator = 2;
        displayName = CSTRING(Module_DisableGroupAI_DisplayName);
        isGlobal = 0;
        category = "Lambs_Danger_Cat";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        function = QFUNC(moduleDisableGroupAI);
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
            class ADDON {
                init = QUOTE(_this call EFUNC(main,initModules));
            };
        };
    };
};
