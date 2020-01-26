#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader finds and declares nearest building as assault position
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Range to check buildings, default is CQB range <NUMBER>
 *
 * Return Value:
 * buildings found
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_leaderCQC;
 *
 * Public: No
*/
params ["_unit", ["_range", GVAR(CQB_range)]];

if (isPlayer _unit) exitWith {false};
// new variable + distance check
private _inCQC = group _unit getVariable [QGVAR(inCQC), []];
_inCQC = _inCQC select {_x distance2d _unit < 250};

// buildings present? ignore
if (count _inCQC > 0) exitWith {};

_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Leader CQC"];

// define buildings
private _buildings = [_unit, _range] call FUNC(findBuildings);
_buildings = _buildings select {count (_x getVariable [QGVAR(CQB_cleared_) + str (side _unit), [0, 0]]) > 0};

// update variable
{
    _inCQC pushBackUnique _x;
    true
} count _buildings;
(group _unit) setVariable [QGVAR(inCQC), _inCQC];

// end
_buildings
