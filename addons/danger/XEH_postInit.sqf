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