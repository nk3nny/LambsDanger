private _curCat = "General";
// Range at which units consider themselves in CQB
[
    QGVAR(CQB_range),
    "SLIDER",
    ["CQB Range", "Range at which units consider themselves in CQB"],
    [COMPONENT_NAME, _curCat],
    [25, 100, 50, 0],
    true
] call CBA_Settings_fnc_init;

// you cannot do arrays in cba settings, only select one entry from an array
GVAR(CQB_formations) = ["FILE","DIAMOND"];     // Special CQB Formations )

// Minimum range for suppression
[
    QGVAR(minSuppression_range),
    "SLIDER",
    ["Minimum Suppression Range", "Minimum range for suppression"],
    [COMPONENT_NAME, _curCat],
    [1, 500, 25, 0],
    true
] call CBA_Settings_fnc_init;

// Chance of panic  1 out of this number.  (i.e., 1 out of 20 is 5%)
[
    QGVAR(panic_chance),
    "SLIDER",
    ["Panic Chance", "Chance of panic 1 out of this number.  (i.e., 1 out of 20 is 5%)"],
    [COMPONENT_NAME, _curCat],
    [0, 20, 15, 0],
    true
] call CBA_Settings_fnc_init;

// debug
_curCat = "Debug";
// FSM level debug messages
[
    QGVAR(debug_FSM),
    "CHECKBOX",
    ["Debug", "FSM level debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_Settings_fnc_init;

// Function level debug messages
[
    QGVAR(debug_functions),
    "CHECKBOX",
    ["Debug Functions", "Function level debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_Settings_fnc_init;

// FSM level debug messages for civilian fsm
[
    QGVAR(debug_FSM_civ),
    "CHECKBOX",
    ["Debug Civ", "FSM level debug messages for civilian fsm"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_Settings_fnc_init;


// FSM level debug messages for civilian fsm
[
    QGVAR(debug_Drawing),
    "CHECKBOX",
    ["Debug Draw", "Draws 3d Text over Units with AI Informations"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_Settings_fnc_init;
