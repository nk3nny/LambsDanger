class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class GVAR(attributes) {
                collapsed = 1;
                displayName = "LAMBS Danger Settings";
                class Attributes {
                    class GVAR(dangerRadio) {
                        property = QGVAR(dangerRadio);
                        control = "Checkbox";
                        displayName = "Has Radio";
                        tooltip = "Unit counts as carrying backpack radio for information sharing\nWARNING checking this will add mod dependency";
                        expression = "if (_value) then {_this setVariable ['%s', _value, true]}";
                        typeName = "BOOL";
                        condition = "objectBrain";
                        defaultValue = "(false)";
                    };
                };
            };
        };
    };
};
