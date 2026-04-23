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

addMissionEventHandler ["GroupCreated", {
    params ["_group"];

    [
        {
            params ["_group"];
            !isNull _group && {local _group}
        },
        {
            params ["_group"];
            [_group] call FUNC(applySideReinforcementSetting);
        },
        [_group],
        5
    ] call CBA_fnc_waitUntilAndExecute;
}];

{
    [_x] call FUNC(applySideReinforcementSetting);
} forEach allGroups;

