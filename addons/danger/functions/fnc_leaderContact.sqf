#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader Declares Contact!
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Dangerous target <OBJECT>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_leaderAssess;
 *
 * Public: No
*/
params ["_unit", "_target"];

if (isPlayer _unit) exitWith {false};

// share information
[_unit, _target] call FUNC(shareInformation);

// gather the stray flock
{
    _x doFollow _unit;
} forEach (( units _unit ) select { _x distance _unit > 45 && {!(isPlayer _x)}});

// change formation
(group _unit) setFormation (group _unit getVariable [QGVAR(dangerFormation),formation _unit]);

// call event system
[QGVAR(onContact), [_unit, group _unit, units _unit]] call FUNC(eventCallback);

// end
true
