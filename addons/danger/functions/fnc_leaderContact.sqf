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
 * [bob, getPos angryJoe] call lambs_danger_fnc_leaderAssess;
 *
 * Public: No
*/
params ["_unit", "_target"];

// share information
[_unit, _target] call FUNC(shareInformation);

// gather the stray flock
{
    _x doFollow _unit;
    _x setVariable [QGVAR(forceMOVE), true];
} forEach (( units _unit ) select { _x call FUNC(isAlive) && {_x distance _unit > 45} });

// change formation
(group _unit) setFormation (group _unit getVariable [QGVAR(dangerFormation), formation _unit]);

// call event system
[QGVAR(onContact), [_unit, group _unit, _target]] call FUNC(eventCallback);

// end
true
