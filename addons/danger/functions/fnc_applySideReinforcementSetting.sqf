#include "script_component.hpp"
/*
 * Author: InfernoMDF
 * Applies side reinforcement settings to a group without overwriting mission-level disables.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * None
 *
 * Example:
 * [group player] call FUNC(applySideReinforcementSetting)
 *
 * Public: No
 */
params [["_group", grpNull, [grpNull]]];
if (isNull _group || {!local _group}) exitWith {};

private _sideSettingEnabled = switch (side _group) do {
    case west: {GVAR(enableReinforceWest)};
    case east: {GVAR(enableReinforceEast)};
    case independent: {GVAR(enableReinforceIndependent)};
    default {false};
};

if (_sideSettingEnabled) then {
    _group setVariable [QGVAR(enableGroupReinforce), true, true];
};
