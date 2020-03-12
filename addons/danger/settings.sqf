private _curCat = "Settings";
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    ["Disable danger.fsm for player group", "Toggle advanced danger.fsm features on player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0         // players may configure their own preferences
] call CBA_fnc_addSetting;

// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupSuppression),
    "CHECKBOX",
    ["Disable suppression from player group", "Toggle autonomous suppression for units in player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggle reaction state danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupReaction),
    "CHECKBOX",
    ["Disable reaction state on player group", "Toggle Reaction phase on units in player group"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles group manoevure phase initiated by AI squad leader
[
    QGVAR(disableAIAutonomousManoeuvres),
    "CHECKBOX",
    ["Disable autonomous group manoevures", "Toggles group manoevure phase initiated by AI squad leader. Disabling this will prevent AI group leader from adding manoevure orders to flank and suppress buildings."],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;


// Toggles the concealment AI for units not equipped to damage tanks and aircraft
[
    QGVAR(disableAIHideFromTanksAndAircraft),
    "CHECKBOX",
    ["Disable units hiding", "Toggles the concealment move by AI for units not equipped to damage tanks and aircraft. Disabling this setting will make groups more responsive"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Unit Gestures
[
    QGVAR(disableAIGestures),
    "CHECKBOX",
    ["Disable unit hand gestures", "Toggles unit gestures and hand signals when reacting to danger or executing planned manoevures"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Immediate (re)Actions
[
    QGVAR(disableAIImediateAction),
    "CHECKBOX",
    ["Disable unit immediate actions", "Toggles unit quickly dodging or changing stance in response to being hit.\nImmediate reactions force an animation to run. Disabling will make for a more static AI"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Enhanced fleeing
[
    QGVAR(disableAIFleeing),
    "CHECKBOX",
    ["Disable enhanced unit fleeing", "Toggles enhanced fleeing function for units."],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Unit Callouts
[
    QGVAR(disableAICallouts),
    "CHECKBOX",
    ["Disable unit callouts", "Toggles extra unit callouts based on situations"],
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
    [1, 500, 20, 0],
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


// Enable automatic artillery registration
if (GVAR(Loaded_WP)) then {
    GVAR(autoArtilleryRunning) = false;
    [
        QGVAR(autoAddArtillery),
        "CHECKBOX",
        ["Enable automatic artillery registration", "Automatically adds artillery already present in the mission to Side"],
        [COMPONENT_NAME, _curCat],
        false,
        true, {
            params ["_value"];
            if (!_value) exitWith {};
            DFUNC(ArtilleryScan) = {
                if (!GVAR(autoAddArtillery)) exitWith {};
                {
                    if (getNumber (configFile >> "CfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0) then {
                        _x call EFUNC(WP,taskArtilleryRegister);
                    };
                } foreach vehicles;
                GVAR(autoArtilleryRunning) = true;
                [{call FUNC(ArtilleryScan);}, [], 120] call CBA_fnc_waitAndExecute;
            };

            if (_value && !GVAR(autoArtilleryRunning)) then {
                call FUNC(ArtilleryScan);
            };
        }
    ] call CBA_fnc_addSetting;
};
private _curCat = "Settings Share information";

// Toggle communication for all units
[
    QGVAR(radio_disabled),
    "CHECKBOX",
    ["Disable information sharing", "Toggle information sharing betweem units"],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

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

// Configures CQC formations
_curCat = "Settings CQB Formations";
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
        [_x, _x + " Units set to CQB formations will methodically clear buildings when an enemy is encountered"],
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
    ["Debug FSM", "Shows FSM debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// Function level debug messages
[
    QGVAR(debug_functions),
    "CHECKBOX",
    ["Debug Functions", "Shows Function debug messages"],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// FSM level debug messages for civilian fsm
[
    QGVAR(debug_FSM_civ),
    "CHECKBOX",
    ["Debug Civ", "Shows FSM debug messages for civilians"],
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
        } count GVAR(drawRectCacheGame) + GVAR(drawRectInUseGame)           // this is only called once
        + GVAR(drawRectCacheEGSpectator) + GVAR(drawRectInUseEGSpectator)   // when the setting is changed
        + GVAR(drawRectCacheCurator) + GVAR(drawRectInUseCurator);          // we can use the + operator here

        GVAR(drawRectCacheGame) = [];
        GVAR(drawRectInUseGame) = [];

        GVAR(drawRectCacheEGSpectator) = [];
        GVAR(drawRectInUseEGSpectator) = [];

        GVAR(drawRectCacheCurator) = [];
        GVAR(drawRectInUseCurator) = [];
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
