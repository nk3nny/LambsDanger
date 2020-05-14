class ZEN_context_menu_actions {
    class ADDON {
        displayName = COMPONENT_NAME;
        condition = QUOTE(!(_groups isEqualTo []) && !(_objects isEqualTo []));
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        class EnableAI {
            displayName = "Enable AI";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setDisableAI));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showDisableAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 1;
        };
        class DisableAI {
            displayName = "Disable AI";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setDisableAI));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showDisableAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 0;
        };
        class EnableGroupAI {
            displayName = "Disable Group AI";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setDisableGroupAI));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showDisableGroupAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 1;
        };
        class DisableGroupAI {
            displayName = "Disable Group AI";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setDisableGroupAI));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showDisableGroupAI));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 0;
        };
        class HasRadio {
            displayName = "Has Radio";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setHasRadio));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showHasRadio));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 1;
        };
        class HasNoRadio {
            displayName = "Has No Radio";
            condition = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(setHasRadio));
            statement = QUOTE([ARR_3(_objects,_groups,_args)] call FUNC(showHasRadio));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
            args = 0;
        };
    };
};
