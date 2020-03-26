private _curCat = LSTRING(Settings_MainCat);
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    [LSTRING(Settings_DisableDangerFSM), LSTRING(Settings_DisableDangerFSM_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0         // players may configure their own preferences
] call CBA_fnc_addSetting;

// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupSuppression),
    "CHECKBOX",
    [LSTRING(Settings_DisableSuppressionPlayerGroup), LSTRING(Settings_DisableSuppressionPlayerGroup_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggle reaction state danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupReaction),
    "CHECKBOX",
    [LSTRING(Settings_DisableReactPlayerGroup), LSTRING(Settings_DisableReactPlayerGroup_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles group manoevure phase initiated by AI squad leader
[
    QGVAR(disableAIAutonomousManoeuvres),
    "CHECKBOX",
    [LSTRING(Settings_DisableGroupManoevures), LSTRING(Settings_DisableGroupManoevures_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;


// Toggles the concealment AI for units not equipped to damage tanks and aircraft
[
    QGVAR(disableAIHideFromTanksAndAircraft),
    "CHECKBOX",
    [LSTRING(Settings_DisableUnitsHiding), LSTRING(Settings_DisableUnitsHiding_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Unit Gestures
[
    QGVAR(disableAIGestures),
    "CHECKBOX",
    [LSTRING(Settings_DisableHandGestures), LSTRING(Settings_DisableHandGestures_Tooltip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Immediate (re)Actions
[
    QGVAR(disableAIImediateAction),
    "CHECKBOX",
    [LSTRING(Settings_DisableImmediateActions), LSTRING(Settings_DisableImmediateActions_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Enhanced fleeing
[
    QGVAR(disableAIFleeing),
    "CHECKBOX",
    [LSTRING(Settings_DisableEnhancedFleeing), LSTRING(Settings_DisableEnhancedFleeing_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Unit Callouts
[
    QGVAR(disableAICallouts),
    "CHECKBOX",
    [LSTRING(Settings_DisableCallouts), LSTRING(Settings_DisableCallouts_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

private _curCat = LSTRING(Settings_GeneralCat);
// Range at which units consider themselves in CQB
[
    QGVAR(CQB_range),
    "SLIDER",
    [LSTRING(Settings_CQBRange), LSTRING(Settings_CQBRange_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [25, 150, 50, 0],
    1
] call CBA_fnc_addSetting;

// Minimum range for suppression
[
    QGVAR(minSuppression_range),
    "SLIDER",
    [LSTRING(Settings_MinSuppressDistance), LSTRING(Settings_MinSuppressDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [1, 500, 20, 0],
    1
] call CBA_fnc_addSetting;

// 'Danger close' distance for suppression
[
    QGVAR(minFriendlySuppressionDistance),
    "SLIDER",
    [LSTRING(Settings_minFriendlySuppressionDistance), LSTRING(Settings_minFriendlySuppressionDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 200, 15, 0],
    1
] call CBA_fnc_addSetting;

// Chance of panic expressed as percentage
[
    QGVAR(panic_chance),
    "SLIDER",
    [LSTRING(Settings_PanicChance), LSTRING(Settings_PanicChance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [1, 100, 10, 0],
    1
] call CBA_fnc_addSetting;

private _curCat = LSTRING(Settings_ShareInformationCat);

// Toggle communication for all units
[
    QGVAR(radio_disabled),
    "CHECKBOX",
    [LSTRING(Settings_DisableInformationSharing), LSTRING(Settings_DisableInformationSharing_Tooltip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Ranges at which groups share information
[
    QGVAR(radio_shout),
    "SLIDER",
    [LSTRING(Settings_Shout), LSTRING(Settings_Shout_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 200, 100, 0],
    1
] call CBA_fnc_addSetting;

// Base range of WEST side
[
    QGVAR(radio_WEST),
    "SLIDER",
    [LSTRING(Settings_BaseWest), LSTRING(Settings_BaseWest_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of EAST side
[
    QGVAR(radio_EAST),
    "SLIDER",
    [LSTRING(Settings_BaseEast), LSTRING(Settings_BaseEast_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of INDEPENDENT side
[
    QGVAR(radio_GUER),
    "SLIDER",
    [LSTRING(Settings_BaseIndependent), LSTRING(Settings_BaseIndependent_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [200, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of RadioBackpack
[
    QGVAR(radio_backpack),
    "SLIDER",
    [LSTRING(Settings_BackpackRadios), LSTRING(Settings_BackpackRadios_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [500, 6000, 2000, 0],
    1
] call CBA_fnc_addSetting;

// Configures CQC formations
_curCat = LSTRING(Settings_CQBFormationsCat);
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
        [_x, format ["%1 %2", _x, localize LSTRING(Settings_CQBFormation)]],
        [COMPONENT_NAME, _curCat],
        _x in GVAR(CQB_formations),
        1, _code
    ] call CBA_fnc_addSetting;
} forEach GVAR(allPossibleFormations);

// debug
_curCat = LSTRING(Settings_Debug);
// FSM level debug messages
[
    QGVAR(debug_FSM),
    "CHECKBOX",
    [LSTRING(Settings_DebugFSM), LSTRING(Settings_DebugFSM_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// Function level debug messages
[
    QGVAR(debug_functions),
    "CHECKBOX",
    [LSTRING(Settings_DebugFunctions), LSTRING(Settings_DebugFunctions_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// FSM level debug messages for civilian fsm
[
    QGVAR(debug_FSM_civ),
    "CHECKBOX",
    [LSTRING(Settings_DebugCiv), LSTRING(Settings_DebugCiv_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;


// Debug Renderer
[
    QGVAR(debug_Drawing),
    "CHECKBOX",
    [LSTRING(Settings_DebugDraw), LSTRING(Settings_DebugDraw_ToolTip)],
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
    [LSTRING(Settings_DebugDrawExpDest), LSTRING(Settings_DebugDrawExpDest_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;
