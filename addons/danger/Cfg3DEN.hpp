class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class GVAR(attributes) {
                class Attributes {
                    class GVAR(dangerRadio) {
                        property = QGVAR(dangerRadio);
                        control = "Checkbox";
                        displayName = "Has Radio";
                        tooltip = "Unit has Boosted Range for Share Information";
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
