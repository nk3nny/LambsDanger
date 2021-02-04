class CBA_Extended_EventHandlers_base;
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
        author = "LAMBS Dev Team";
        _generalMacro = QGVAR(BaseModule);
        scope = 0;
        scopeCurator = 0;
        is3DEN = 1;
        isGlobal = 0;
        isTriggerActivated = 1;
        curatorCanAttach = 1;
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
            description = "";
            sync[] = {"AnyBrain", "Condition"};
            class Condition: EmptyDetector {
                optional = 1;
            };
        };
    };
    #include "modules.hpp"
    #include "zeusModules.hpp"
};
