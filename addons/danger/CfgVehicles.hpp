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

    class Logic;
    class Module_F: Logic {};
    class Lambs_Danger_SetRadio : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = "Lambs_Danger_SetRadio";
        scope = 1;
        scopeCurator = 2;
        displayName = "Set Radio";
        category = "Lambs_Danger_Cat";
        function = QFUNC(moduleSetRadio);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        isGlobal = 1;
    };
};
