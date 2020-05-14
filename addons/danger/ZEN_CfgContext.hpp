class ZEN_context_menu_actions {
    class ADDON {
        displayName = COMPONENT_NAME;
        condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        priority = 5;
        class EnableAI {
            displayName = "Enable AI";
            statement = QUOTE([ARR_2(_objects,_args)] call FUNC(setDisableAI));
            condition = QUOTE([ARR_2(_objects,_args)] call FUNC(showSetDisableAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 0;
        };
        class DisableAI: EnableAI {
            displayName = "Disable AI";
            args = 1;
        };
        class EnableGroupAI {
            displayName = "Disable Group AI";
            statement = QUOTE([ARR_2(_groups,_args)] call FUNC(setDisableGroupAI));
            condition = QUOTE([ARR_2(_groups,_args)] call FUNC(showSetDisableGroupAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 0;
        };
        class DisableGroupAI: EnableGroupAI {
            displayName = "Disable Group AI";
            args = 1;
        };
        class HasRadio {
            displayName = "Has Radio";
            statement = QUOTE([ARR_2(_objects,_args)] call FUNC(setHasRadio));
            condition = QUOTE([ARR_2(_objects,_args)] call FUNC(showHasRadio));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 1;
        };
        class HasNoRadio: HasRadio {
            displayName = "Has No Radio";
            args = 0;
        };
    };
};
