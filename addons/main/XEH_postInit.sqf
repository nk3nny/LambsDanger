#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

{
    private _string = getText (_x >> "model");
    if (_string isNotEqualTo "") then {
        if ((_string select [0,1]) isEqualTo "\") then {
            _string = [_string, 1] call CBA_fnc_substr;
        };
        if !(".p3d" in _string) then {
            _string = _string + ".p3d";
        };
        GVAR(blockSuppressionModelCache) setVariable [toLower _string, true];
    };
} forEach ("private _name = configName _x; _name isKindof 'building' || {_name isKindOf 'Rocks_base_F'}" configClasses (configFile >> "CfgVehicles"));

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
} forEach [
    QGVAR(debug_drawRectCacheGame),
    QGVAR(debug_drawRectCacheEGSpectator),
    QGVAR(debug_drawRectCacheCurator)
];

GVAR(debug_DrawID) = -1;

GVAR(debug_sideColorLUT) = createHashMap;
{
    _x params ["_name", "_side", "_default"];
    private _r = profileNamespace getVariable [format ["map_%1_r", _name], _default select 0];
    private _g = profileNamespace getVariable [format ["map_%1_g", _name], _default select 1];
    private _b = profileNamespace getVariable [format ["map_%1_b", _name], _default select 2];
    private _color = [_r, _g, _b] call BIS_fnc_colorRGBToHTML;
    GVAR(debug_sideColorLUT) set [_side, _color];
} forEach [
    ["blufor", west, [0, 0.3, 0.6]],
    ["opfor", east, [0.5,0,0]],
    ["independent", independent, [0,0.5,0]],
    ["civilian", civilian, [0.4,0,0.5]],
    ["unknown", sideUnknown, [0.7,0.6,0]]
];

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
    Removed with v2.7.0???
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

[QGVAR(doSwitchMove), {
    params [["_unit", objNull], ["_move", ""]];
    _unit switchMove [_move, 0, 0.5, false];
}] call CBA_fnc_addEventHandler;
