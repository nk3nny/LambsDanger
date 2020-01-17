private _curCat = "Settings";
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    ["Disable Danger.fsm for player group", "Toggle advanced danger.fsm features on player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0         // players may configure their own preferences
] call CBA_fnc_addSetting;

// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupSuppression),
    "CHECKBOX",
    ["Disable Suppression from player group", "Toggle autonomous suppression for units in player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggle reaction state danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupReaction),
    "CHECKBOX",
    ["Disable Reaction state on player group", "Toggle Reaction phase on units in player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

private _curCat = "General";
// Range at which units consider themselves in CQB
[
    QGVAR(CQB_range),
    "SLIDER",
    ["CQB Range", "Range at which units consider themselves in assault range"],
    [COMPONENT_NAME, _curCat],
    [25, 150, 50, 0],
    1
] call CBA_fnc_addSetting;

// Minimum range for suppression
[
    QGVAR(minSuppression_range),
    "SLIDER",
    ["Minimum Distance for Suppression Fire", "Within this distance AI will not perform suppression fire"],
    [COMPONENT_NAME, _curCat],
    [1, 500, 25, 0],
    1
] call CBA_fnc_addSetting;

// Chance of panic expressed as percentage
[
    QGVAR(panic_chance),
    "SLIDER",
    ["Panic Chance", "Chance to panic in percentage"],
    [COMPONENT_NAME, _curCat],
    [1, 100, 10, 0],
    1
] call CBA_fnc_addSetting;

private _curCat = "Share information";
// Ranges at which groups share information
[
    QGVAR(radio_shout),
    "SLIDER",
    ["Shout", "Range AI units share information without radios"],
    [COMPONENT_NAME, _curCat],
    [20, 150, 50, 0],
    1
] call CBA_fnc_addSetting;

// Base range of WEST side
[
    QGVAR(radio_WEST),
    "SLIDER",
    ["Base West", "Base range side WEST share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of EAST side
[
    QGVAR(radio_EAST),
    "SLIDER",
    ["Base East", "Base range side EAST share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of INDEPENDENT side
[
    QGVAR(radio_GUER),
    "SLIDER",
    ["Base Independent", "Base range independent and civilian sides share information"],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of RadioBackpack
[
    QGVAR(radio_backpack),
    "SLIDER",
    ["Backpack radios", "Range added to units wearing backpack radios (Vanilla, TFAR, or configured by variable)"],
    [COMPONENT_NAME, _curCat],
    [500, 6000, 2000, 0],
    1
] call CBA_fnc_addSetting;

_curCat = "CQB Formations";
GVAR(allPossibleFormations) = ["COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"];

GVAR(CQB_formations) = ["FILE", "DIAMOND"];     // Special CQB Formations )

DFUNC(UpdateCQBFormations) = {
    params ["_args", "_formation"];
    _args params ["_value"];
    if (_value) then {
        GVAR(CQB_formations) pushBackUnique _formation;
    } else {
        private _index = GVAR(CQB_formations) find _formation;
        if (_index != -1) then {
            GVAR(CQB_formations) deleteAt _index;
        };
    };
};

{
    private _code = compile format ["
        [_this, %1] call %2;
    ", str _x, QFUNC(UpdateCQBFormations)];
    [
        format [QGVAR(CQB_formations_%1), _x],
        "CHECKBOX",
        [_x, _x + " Formation is Classified as CQB"], // TODO: Better Description? @nKenny
        [COMPONENT_NAME, _curCat],
        _x in GVAR(CQB_formations),
        1, _code
    ] call CBA_fnc_addSetting;
} forEach GVAR(allPossibleFormations);

// debug
_curCat = "Debug";
// FSM level debug messages
[
    QGVAR(debug_FSM),
    "CHECKBOX",
    ["Debug", "FSM debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// Function level debug messages
[
    QGVAR(debug_functions),
    "CHECKBOX",
    ["Debug Functions", "Function debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// FSM level debug messages for civilian fsm
[
    QGVAR(debug_FSM_civ),
    "CHECKBOX",
    ["Debug Civ", "FSM debug messages for civilian fsm"],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;


// Debug Renderer
[
    QGVAR(debug_Drawing),
    "CHECKBOX",
    ["Debug Draw", "Draws 3d Text over Units with AI Informations"],
    [COMPONENT_NAME, _curCat],
    false,
    1,
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
    1
] call CBA_fnc_addSetting;
