#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

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
GVAR(debug_DrawID) = -1;

GVAR(debug_DrawID) = -1;

GVAR(debug_TextFactor) = linearConversion [0.55, 0.7, getResolution select 5, 1, 0.85, false];

[QGVAR(OnCheckBody), {
    [_this select 0, QGVAR(OnCheckBody), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnCheckBody), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnPanic), {
    [_this select 0, QGVAR(OnPanic), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnPanic), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnInformationShared), {
    [_this select 0, QGVAR(OnInformationShared), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnInformationShared), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnFleeing), {
    [_this select 0, QGVAR(OnFleeing), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnFleeing), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

/*
    Moved Event Wrappers
    Moved in v2.5.0
    Removed with v2.6.0???
*/
[QGVAR(OnCheckBody), {
    [_this select 0, QEGVAR(danger,OnCheckBody), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QEGVAR(danger,OnCheckBody), _this] call BIS_fnc_callScriptedEventHandler;
    [QEGVAR(danger,OnCheckBody), _this] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnPanic), {
    [_this select 0, QEGVAR(danger,OnPanic), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QEGVAR(danger,OnPanic), _this] call BIS_fnc_callScriptedEventHandler;
    [QEGVAR(danger,OnPanic), _this] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnInformationShared), {
    [_this select 0, QEGVAR(danger,OnInformationShared), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QEGVAR(danger,OnInformationShared), _this] call BIS_fnc_callScriptedEventHandler;
    [QEGVAR(danger,OnInformationShared), _this] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnFleeing), {
    [_this select 0, QEGVAR(danger,OnFleeing), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QEGVAR(danger,OnFleeing), _this] call BIS_fnc_callScriptedEventHandler;
    [QEGVAR(danger,OnFleeing), _this] call CBA_fnc_localEvent;
}] call CBA_fnc_addEventHandler;
