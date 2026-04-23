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
params ["_group", grpNull, [grpNull]];
if (isNull _group || {!local _group}) exitWith {};

switch (side _group) do {
    case west: {
        if (GVAR(enableReinforceWest)) then {
            _group setVariable [QGVAR(enableGroupReinforce), true, true];
        };
    };
    case east: {
        if (GVAR(enableReinforceEast)) then {
            _group setVariable [QGVAR(enableGroupReinforce), true, true];
        };
    };
    case independent: {
        if (GVAR(enableReinforceIndependent)) then {
            _group setVariable [QGVAR(enableGroupReinforce), true, true];
        };
    };
};
