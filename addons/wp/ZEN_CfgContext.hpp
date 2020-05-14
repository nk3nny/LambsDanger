class ZEN_context_menu_actions {
    class ADDON {
        displayName = COMPONENT_NAME;
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        priority = 4;
        class CreateTarget {
            displayName = "Create Target";
            statement = QUOTE([ARR_2(_objects, _position)] call FUNC(setTarget));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskArtilleryRegister {
            displayName = "Task Register Artillery";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setArtilleryRegister));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskCamp {
            displayName = "Task Camp";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCamp));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskCQB {
            displayName = "Task CQB";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCQB));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskCreep {
            displayName = "Task Creep";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setCreep));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskGarrison {
            displayName = "Task Garrison";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setGarrison));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskHunt {
            displayName = "Task Hunt";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setHunt));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskPatrol {
            displayName = "Task Patrol";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setPatrol));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskReset {
            displayName = "Task Reset";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setReset));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
        class TaskRush {
            displayName = "Task Rush";
            condition = QUOTE(!((_groups isEqualTo []) && (_objects isEqualTo [])));
            statement = QUOTE([ARR_2(_groups, _objects)] call FUNC(setRush));
            icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa";
        };
    };
};
