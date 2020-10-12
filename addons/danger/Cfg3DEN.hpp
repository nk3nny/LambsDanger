class Cfg3DEN {
    class Group {
        class AttributeCategories {
            class GVAR(groupAttributes) {
                collapsed = 1;
                displayName = "LAMBS Danger.fsm";
                class Attributes {
                    class GVAR(disableGroupAI) {
                        property = QGVAR(disableGroupAI);
                        control = "Checkbox";
                        displayName = CSTRING(Module_DisableGroupAI_SettingName);
                        tooltip = CSTRING(Module_DisableGroupAI_SettingToolTip);
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        defaultValue = "(false)";
                    };
                    class GVAR(enableGroupReinforce) {
                        property = QGVAR(enableGroupReinforce);
                        control = "Checkbox";
                        displayName = CSTRING(Module_EnableGroupReinforce_SettingName);
                        tooltip = CSTRING(Module_EnableGroupReinforce_SettingToolTip);
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        defaultValue = "(false)";
                    };
                };
            };
        };
    };
    class Object {
        class AttributeCategories {
            class GVAR(attributes) {
                collapsed = 1;
                displayName = "LAMBS Danger.fsm";
                class Attributes {
                    class GVAR(disableAI) {
                        property = QGVAR(disableAI);
                        control = "Checkbox";
                        displayName = CSTRING(3DEN_Attributes_DisableAI_DisplayName);
                        tooltip = CSTRING(3DEN_Attributes_DisableAI_ToolTip);
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        condition = "objectBrain";
                        defaultValue = "(false)";
                    };
                    class GVAR(dangerRadio) {
                        property = QGVAR(dangerRadio);
                        control = "Checkbox";
                        displayName = CSTRING(3DEN_Attributes_HasRadio_DisplayName);
                        tooltip = CSTRING(3DEN_Attributes_HasRadio_ToolTip);
                        expression = "if (_value) then { _this setVariable ['%s', _value, true]; }";
                        typeName = "BOOL";
                        condition = "objectBrain";
                        defaultValue = "(false)";
                    };
                };
            };
        };
    };
};
