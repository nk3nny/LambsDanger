#include "script_component.hpp"
/*
 * Author: LAMBS + Codex
 * Enables dynamic reinforcement for newly initialized units per side based on CBA settings.
 *
 * Arguments:
 * 0: unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]]];

if (
    isNull _unit
    || {!alive _unit}
    || {!(_unit isKindOf "CAManBase")}
) exitWith {};

private _enabled = switch (side group _unit) do {
    case west: {GVAR(dynamicReinforcementWest)};
    case east: {GVAR(dynamicReinforcementEast)};
    case independent: {GVAR(dynamicReinforcementIndependent)};
    default {false};
};

if (_enabled) then {
    (group _unit) setVariable [QGVAR(enableGroupReinforce), true, true];
};
