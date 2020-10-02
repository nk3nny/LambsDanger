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
