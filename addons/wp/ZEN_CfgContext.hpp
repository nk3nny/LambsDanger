 class ZEN_context_menu_actions {
    class ADDON {
        displayName = "LAMBS Danger Waypoints";
        priority = 3;
        class CreateTarget {
            displayName = CSTRING(Context_CreateTarget);
            statement = QUOTE([ARR_2(_objects, _position)] call FUNC(setTarget));
            icon = "\a3\3den\Data\CfgWaypoints\destroy_ca.paa";
        };
        class TaskArtilleryRegister {
            displayName = CSTRING(Module_TaskArtilleryRegister_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setArtilleryRegister));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskCamp {
            displayName = CSTRING(Module_TaskCamp_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCamp));
            icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
        };
        class TaskCQB {
            displayName = CSTRING(Module_TaskCQB_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCQB));
            icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
        };

        class TaskGarrison {
            displayName = CSTRING(Module_TaskGarrison_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setGarrison));
            icon = "\a3\3DEN\Data\CfgWaypoints\Guard_ca.paa";
        };
        class TaskPatrol {
            displayName = CSTRING(Module_TaskPatrol_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setPatrol));
            icon = "\A3\3DEN\Data\CfgWaypoints\Loiter_ca.paa";
        };
        class TaskReset {
            displayName = CSTRING(Module_TaskReset_DisplayName);
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setReset));
            icon = "\a3\3DEN\Data\CfgWaypoints\cycle_ca.paa";
        };
    };
    class DOUBLE(ADDON,Search) {
        displayName = "LAMBS Danger Search Waypoints";
        condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
        priority = 4;
        class TaskCreep {
            displayName = CSTRING(Module_TaskCreep_DisplayName);
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCreep));
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        };
        class TaskHunt {
            displayName = CSTRING(Module_TaskHunt_DisplayName);
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setHunt));
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        };
        class TaskRush {
            displayName = CSTRING(Module_TaskRush_DisplayName);
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setRush));
            icon = "\a3\3DEN\Data\CfgWaypoints\Sentry_ca.paa";
        };
    };
};
