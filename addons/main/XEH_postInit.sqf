#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

{
    private _controls = uiNamespace getVariable [_x, []];
    if !(_controls isEqualTo []) then {
        {
            if !(isNull _x) then {
                ctrlDelete _x
            };
        } forEach _controls;
    };
    uiNamespace setVariable [_x, []];
} foreach [
    QGVAR(debug_drawRectCacheGame),
    QGVAR(debug_drawRectInUseGame),
    QGVAR(debug_drawRectCacheEGSpectator),
    QGVAR(debug_drawRectInUseEGSpectator),
    QGVAR(debug_drawRectCacheCurator),
    QGVAR(debug_drawRectInUseCurator)
];

addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];

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
