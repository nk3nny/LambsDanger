private _curCat = "Settings";
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    ["Danger.fsm for player group", "Toggle advanced danger.fsm features on player group"],
    [COMPONENT_NAME, _curCat],
    false,
    nil         // players may configure their own preferences
] call CBA_fnc_addSetting;

private _curCat = "General";
// Range at which units consider themselves in CQB
[
    QGVAR(CQB_range),
    "SLIDER",
    ["CQB Range", "Range at which units consider themselves in assault range"],
    [COMPONENT_NAME, _curCat],
    [25, 150, 50, 0],
    true
] call CBA_fnc_addSetting;

// you cannot do arrays in cba settings, only select one entry from an array
GVAR(CQB_formations)= ["FILE", "DIAMOND"];     // Special CQB Formations )

// Minimum range for suppression
[
    QGVAR(minSuppression_range),
    "SLIDER",
    ["Minimum Suppression Range", "Within this range AI will not perform suppression fire"],
    [COMPONENT_NAME, _curCat],
    [1, 500, 25, 0],
    true
] call CBA_fnc_addSetting;

// Chance of panic  1 out of this number.  (i.e., 1 out of 20 is 5%)
[
    QGVAR(panic_chance),
    "SLIDER",
    ["Panic Chance", "Chance of panic 1 out of this number.  (i.e., 1 out of 20 is 5%)"],
    [COMPONENT_NAME, _curCat],
    [0, 20, 15, 0],
    true
] call CBA_fnc_addSetting;

private _curCat = "Share information";
// Ranges at which groups share information
[
    QGVAR(radio_shout),
    "SLIDER",
    ["Shout", "Range AI units share information without radios"],
    [COMPONENT_NAME, _curCat],
    [20, 150, 50, 0],
    true
] call CBA_fnc_addSetting;

// Base range of WEST side
[
    QGVAR(radio_WEST),
    "SLIDER",
    ["Base West", "Base range side WEST share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 1000, 0],
    true
] call CBA_fnc_addSetting;

// Base range of EAST side
[
    QGVAR(radio_EAST),
    "SLIDER",
    ["Base East", "Base range side EAST share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 1000, 0],
    true
] call CBA_fnc_addSetting;

// Base range of INDEPENDENT side
[
    QGVAR(radio_GUER),
    "SLIDER",
    ["Base East", "Base range independent and civilian sides share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 1000, 0],
    true
] call CBA_fnc_addSetting;

// Base range of RadioBackpack
[
    QGVAR(radio_backpack),
    "SLIDER",
    ["Backpack radios", "Range added to units wearing backpack radios (Vanilla, TFAR, or configured by variable)"],
    [COMPONENT_NAME, _curCat],
    [500, 6000, 2000, 0],
    true
] call CBA_fnc_addSetting;

// debug
_curCat = "Debug";
// FSM level debug messages
[
    QGVAR(debug_FSM),
    "CHECKBOX",
    ["Debug", "FSM debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_fnc_addSetting;

// Function level debug messages
[
    QGVAR(debug_functions),
    "CHECKBOX",
    ["Debug Functions", "Function debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_fnc_addSetting;

// FSM level debug messages for civilian fsm
[
    QGVAR(debug_FSM_civ),
    "CHECKBOX",
    ["Debug Civ", "FSM debug messages for civilian fsm"],
    [COMPONENT_NAME, _curCat],
    false,
    true
] call CBA_fnc_addSetting;


// Debug Renderer
[
    QGVAR(debug_Drawing),
    "CHECKBOX",
    ["Debug Draw", "Draws 3d Text over Units with AI Informations"],
    [COMPONENT_NAME, _curCat],
    false,
    true,
    {
        {
            ctrlDelete _x;
        } count GVAR(drawRectCacheGame);
        {
            ctrlDelete _x;
        } count GVAR(drawRectCacheEGSpectator);
        GVAR(drawRectCacheEGSpectator) = [];
        GVAR(drawRectCacheGame) = [];
    }
] call CBA_fnc_addSetting;

// Debug Renderer for Expected Destination
[
    QGVAR(RenderExpectedDestination),
    "CHECKBOX",
    ["Debug Draw Expected Destination", "Draws Expected Destinations of AI Units"],
    [COMPONENT_NAME, _curCat],
    false,
    true, {
        //GVAR(debug_Drawing) = true; // Force on Debug Renderer
    }
] call CBA_fnc_addSetting;
