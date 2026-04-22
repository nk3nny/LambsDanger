#include "script_component.hpp"

[QGVAR(OnArtilleryCalled), {
    [_this select 0, QGVAR(OnArtilleryCalled), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnArtilleryCalled), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnAssess), {
    [_this select 0, QGVAR(OnAssess), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnAssess), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnContact), {
    [_this select 0, QGVAR(OnContact), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnContact), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

[QGVAR(OnReinforce), {
    [_this select 0, QGVAR(OnReinforce), _this] call BIS_fnc_callScriptedEventHandler;
    [_this select 1, QGVAR(OnReinforce), _this] call BIS_fnc_callScriptedEventHandler;
}] call CBA_fnc_addEventHandler;

GVAR(applySideReinforcementSetting) = {
    params ["_group"];
    if (isNull _group) exitWith {};

    private _enabled = switch (side _group) do {
        case west: {GVAR(enableReinforceWest)};
        case east: {GVAR(enableReinforceEast)};
        case independent: {GVAR(enableReinforceIndependent)};
        default {false};
    };

    _group setVariable [QGVAR(enableGroupReinforce), _enabled, true];
};

addMissionEventHandler ["GroupCreated", {
    params ["_group"];
    [_group] call GVAR(applySideReinforcementSetting);
}];

