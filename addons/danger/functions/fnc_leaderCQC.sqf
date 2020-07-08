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
 * [bob, getPos angryJoe] call lambs_danger_fnc_leaderCQC;
 *
 * Public: No
*/
params ["_unit", "_target", ["_range", GVAR(CQB_range)]];

// new variable + distance check
private _inCQC = group _unit getVariable [QGVAR(inCQC), []];
_inCQC = _inCQC select {_x distance2d _unit < _range + 25};

// buildings present? ignore
if (count _inCQC > 0) exitWith {};
if (!(_target call EFUNC(main,isAlive))) then {_target = _unit findNearestEnemy _unit;};

// update
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader CQB", EGVAR(main,debug_functions)];

// define buildings
private _buildings = [_unit, _range] call EFUNC(main,findBuildings);

// sort buildings near targets
private _distance = _unit distance2d _target;
_buildings = _buildings select {
    _x distance2d _target < (_distance + 8)
    && !((_x getVariable [QGVAR(CQB_cleared_) + str (side _unit), [0, 0]]) isEqualTo [])
};

// update variable
{
    _inCQC pushBackUnique _x;
    true
} count _buildings;
(group _unit) setVariable [QGVAR(inCQC), _inCQC];

// end
_buildings
