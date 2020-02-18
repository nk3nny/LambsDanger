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
        displayName = "Give unit long range Radio";
        category = "Lambs_Danger_Cat";
        function = QFUNC(moduleSetRadio);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
    };

    class GVAR(DisableAI) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(DisableAI);
        scope = 1;
        scopeCurator = 2;
        displayName = "Disable Unit AI";
        category = "Lambs_Danger_Cat";
        function = QFUNC(moduleDisableAI);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
    };

    class GVAR(DisableGroupAI) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(DisableGroupAI);
        scope = 1;
        scopeCurator = 2;
        displayName = "Configure Group AI";
        category = "Lambs_Danger_Cat";
        function = QFUNC(moduleDisableGroupAI);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 0;
    };
};
