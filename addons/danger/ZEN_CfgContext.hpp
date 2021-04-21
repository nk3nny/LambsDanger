class ZEN_context_menu_actions {
    class ADDON {
        displayName = CSTRING(Context_Main_displayName);
        condition = QUOTE((_groups isNotEqualTo []) || (_objects isNotEqualTo []));
        priority = 5;
        class EnableAI {
            displayName = CSTRING(Context_EnableAI);
            statement = QUOTE([ARR_2(_objects,_args)] call FUNC(setDisableAI));
            condition = QUOTE([ARR_2(_objects,_args)] call FUNC(showSetDisableAI));
            args = 0;
        };
        class DisableAI: EnableAI {
            displayName = CSTRING(Context_DisableAI);
            args = 1;
        };
        class EnableGroupAI {
            displayName = CSTRING(Context_EnableGroupAI);
            statement = QUOTE([ARR_2(_groups,_args)] call FUNC(setDisableGroupAI));
            condition = QUOTE([ARR_2(_groups,_args)] call FUNC(showSetDisableGroupAI));
            args = 0;
        };
        class DisableGroupAI: EnableGroupAI {
            displayName = CSTRING(Context_DisableGroupAI);
            args = 1;
        };
        class HasRadio {
            displayName = CSTRING(Context_HasRadio);
            statement = QUOTE([ARR_2(_objects,_args)] call FUNC(setHasRadio));
            condition = QUOTE([ARR_2(_objects,_args)] call FUNC(showHasRadio));
            icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\radio_ca.paa";
            args = 1;
        };
        class HasNoRadio: HasRadio {
            displayName = CSTRING(Context_HasNoRadio);
            args = 0;
        };

        class EnableReinforcement {
            displayName = CSTRING(Context_EnableReinforcement);
            statement = QUOTE([ARR_2(_objects,_args)] call FUNC(setReinforcement));
            condition = QUOTE([ARR_2(_objects,_args)] call FUNC(showReinforcement));
            args = 1;
        };
        class DisableReinforcement: EnableReinforcement {
            displayName = CSTRING(Context_DisableReinforcement);
            args = 0;
        };
    };
};
