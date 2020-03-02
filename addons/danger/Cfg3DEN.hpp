class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class GVAR(attributes) {
                collapsed = 1;
                displayName = "LAMBS Danger.fsm";
                class Attributes {
                    class GVAR(disableAI) {
                        property = QGVAR(disableAI);
                        control = "Checkbox";
                        displayName = "AI Disabled";
                        tooltip = "Unit has advanced danger.fsm features disabled\n\nWARNING checking this will add mod dependency";
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        condition = "objectBrain";
                        defaultValue = "(false)";
                    };
                    class GVAR(dangerRadio) {
                        property = QGVAR(dangerRadio);
                        control = "Checkbox";
                        displayName = "Has Radio";
                        tooltip = "Unit counts as carrying backpack radio for information sharing\n\nWARNING checking this will add mod dependency";
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        condition = "objectBrain";
                        defaultValue = "(false)";
                    };
                    class EGVAR(WP,Editor_IsArtillery) {
                        property = QEGVAR(WP,Editor_IsArtillery);
                        control = "Checkbox";
                        displayName = "Is Artillery";
                        tooltip = "Unit counts as carrying backpack radio for information sharing\n\nWARNING checking this will add mod dependency";
                        expression = QUOTE(if (_value && GVAR(Loaded_WP)) then {[gunner _this] call EFUNC(wp,taskArtilleryRegister); });
                        typeName = "BOOL";
                        condition = "objectVehicle";
                        defaultValue = "(false)";
                    };
                };
            };
        };
    };
};
