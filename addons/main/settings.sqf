private _curCat = LSTRING(Settings_MainCat);

// Toggles AI Unit Gestures
[
    QGVAR(disableAIGestures),
    "CHECKBOX",
    [LSTRING(Settings_DisableHandGestures), LSTRING(Settings_DisableHandGestures_Tooltip)],
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

// Toggles AI Dodging
[
    QGVAR(disableAIDodge),
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

// indoor movement while assessing chance as a percentage
[
    QGVAR(indoorMove),
    "SLIDER",
    [LSTRING(Settings_IndoorMove), LSTRING(Settings_IndoorMove_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 1, 0.1, 2, true],
    1
] call CBA_fnc_addSetting;

// Toggles AI vehicle autonomous munition switching
[
    QGVAR(disableAutonomousMunitionSwitching),
    "CHECKBOX",
    [LSTRING(Settings_disableAutonomousMunitionSwitching), LSTRING(Settings_disableAutonomousMunitionSwitching_Tooltip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

private _profiles = [getMissionConfigValue [QGVAR(AIProfiles), HASH_NULL] call CBA_fnc_hashKeys, "Scenario" get3DENMissionAttribute QGVAR(AIProfiles)] select is3DEN;

if (isNil "_profiles" || {_profiles isEqualType []}) then {
    _profiles = [];
};

{
    {
        _profiles pushBackUnique toLower(configName _x);
    } forEach configProperties [_x >> "LAMBS_CfgAIProfiles", "isClass _x", true];
} forEach [configFile, missionConfigFile];

// Default AI Profiles
[
    QGVAR(defaultAIProfile),
    "LIST",
    [LSTRING(Settings_DefaultAIProfile), LSTRING(Settings_DefaultAIProfile_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [_profiles, _profiles, _profiles find "default"],
    0
] call CBA_fnc_addSetting;

// debug
_curCat = LSTRING(Settings_SuppressionCat);

// Toggle advanced danger.fsm features on player group
[
    QGVAR(disablePlayerGroupSuppression),
    "CHECKBOX",
    [LSTRING(Settings_DisableSuppressionPlayerGroup), LSTRING(Settings_DisableSuppressionPlayerGroup_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Minimum range for suppression
[
    QGVAR(minSuppressionRange),
    "SLIDER",
    [LSTRING(Settings_MinSuppressDistance), LSTRING(Settings_MinSuppressDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [1, 500, 50, 0],
    1
] call CBA_fnc_addSetting;

// 'Danger close' distance for suppression
[
    QGVAR(minFriendlySuppressionDistance),
    "SLIDER",
    [LSTRING(Settings_minFriendlySuppressionDistance), LSTRING(Settings_minFriendlySuppressionDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 50, 5, 0],
    1
] call CBA_fnc_addSetting;

// share information categories
_curCat = LSTRING(Settings_ShareInformationCat);

// Toggle communication for all units
[
    QGVAR(radioDisabled),
    "CHECKBOX",
    [LSTRING(Settings_DisableInformationSharing), LSTRING(Settings_DisableInformationSharing_Tooltip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Maximum Reveal Value -- Accuracy of shared information
[
    QGVAR(maxRevealValue),
    "SLIDER",
    [ LSTRING(Settings_maxRevealValue),  LSTRING(Settings_maxRevealValue_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 4, 1, 2],
    1
] call CBA_fnc_addSetting;

// Combat share range
[
    QGVAR(combatShareRange),
    "SLIDER",
    [ LSTRING(Settings_combatShareRange),  LSTRING(Settings_combatShareRange_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 1000, 200, 0],
    1
] call CBA_fnc_addSetting;

// Ranges at which groups share information
[
    QGVAR(radioShout),
    "SLIDER",
    [LSTRING(Settings_Shout), LSTRING(Settings_Shout_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 200, 100, 0],
    1
] call CBA_fnc_addSetting;

// Base range of WEST side
[
    QGVAR(radioWest),
    "SLIDER",
    [LSTRING(Settings_BaseWest), LSTRING(Settings_BaseWest_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of EAST side
[
    QGVAR(radioEast),
    "SLIDER",
    [LSTRING(Settings_BaseEast), LSTRING(Settings_BaseEast_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of INDEPENDENT side
[
    QGVAR(radioGuer),
    "SLIDER",
    [LSTRING(Settings_BaseIndependent), LSTRING(Settings_BaseIndependent_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of RadioBackpack
[
    QGVAR(radioBackpack),
    "SLIDER",
    [LSTRING(Settings_BackpackRadios), LSTRING(Settings_BackpackRadios_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [500, 6000, 2000, 0],
    1
] call CBA_fnc_addSetting;

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
        params ["_value"];
        {
            private _controls = uiNamespace getVariable [_x, []];
            if (_controls isNotEqualTo []) then {
                {
                    if !(isNull _x) then {
                        ctrlDelete _x
                    };
                } forEach _controls;
            };
            uiNamespace setVariable [_x, []];
        } foreach [
            QGVAR(debug_drawRectCacheGame),
            QGVAR(debug_drawRectCacheEGSpectator),
            QGVAR(debug_drawRectCacheCurator)
        ];
        if (_value) then {
            if (GVAR(debug_DrawID) == -1) then {
                GVAR(debug_DrawID) = addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
            };
        } else {
            if (GVAR(debug_DrawID) != -1) then {
                removeMissionEventHandler ["Draw3D", GVAR(debug_DrawID)];
                GVAR(debug_DrawID) = -1;
            };
        };
    }
] call CBA_fnc_addSetting;

// Debug Renderer for Expected Destination
[
    QGVAR(debug_RenderExpectedDestination),
    "CHECKBOX",
    [LSTRING(Settings_DebugDrawExpDest), LSTRING(Settings_DebugDrawExpDest_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;

// Debug Renderer all Units
[
    QGVAR(debug_drawAllUnitsInVehicles),
    "CHECKBOX",
    [LSTRING(debug_drawAllUnitsInVehicles), LSTRING(debug_drawAllUnitsInVehicles_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    1
] call CBA_fnc_addSetting;
