class CfgVehicles {
    class Module_F;

    class GVAR(Waypoint_Target) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(Waypoint_Target);
        scope = 1;
        scopeCurator = 2;
        displayName = "Waypoint Target";
        category = "Lambs_Danger_Cat";
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa"; // TODO: find Better Icon
        isGlobal = 0;
    };
    class GVAR(TaskRush_Waypoint) : Module_F {
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(TaskRush_Waypoint);
        scope = 1;
        scopeCurator = 2;
        displayName = "Task Rush Waypoint";
        category = "Lambs_Danger_WP_Cat";
        function = QFUNC(moduleTaskRush);
        functionPriority = 1;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa"; // TODO: find Better Icon
        isGlobal = 0;
    };
};
