#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader finds and declares nearest building as assault position
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group target <OBJECT>
 * 1: range to check buildings, default is CQB range <NUMBER>
 *
 * Return Value:
 * buildings found
 *
 * Example:
 * [bob, getPos angryJoe] call lambs_danger_fnc_tacticsCQB;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", GVAR(cqbRange)], ["_delay", 180]];

// update tactics and contact state
private _group = group _unit;
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(tacticsTask), "CQB clearing", EGVAR(main,debug_functions)];
_group setVariable [QGVAR(contact), time + 300];

// reset tactics state
[
    {
        params [["_group", grpNull, [grpNull]], ["_attackEnabled", false]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QGVAR(tacticsTask), nil];
            _group enableAttack _attackEnabled;
        };
    },
    [_group, attackEnabled _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// disable attack!
_group enableAttack false;

// new variable + distance check + exit if none
private _inCQB = _group getVariable [QGVAR(inCQB), []];
_inCQB = _inCQB select {_x distance2D _unit < _range + 25};
if (_inCQB isEqualTo []) exitWith {[]};

// check target
if (isNull _target) then {_target = _unit findNearestEnemy _unit;};

// update
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics CQB", EGVAR(main,debug_functions)];

// define buildings
private _buildings = [_unit, _range] call EFUNC(main,findBuildings);

// sort buildings near targets
private _distance = _unit distance2D _target;
_buildings = _buildings select {
    _x distance2D _target < (_distance + 8)
    && !((_x getVariable [QGVAR(CQB_cleared_) + str (side _unit), [0, 0]]) isEqualTo [])
};

_inCQB append _buildings;
_inCQB = _inCQB arrayIntersect _inCQB;
_group setVariable [QGVAR(inCQB), _inCQB];

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS CQB (%2 with %3 units @ assaults %4 buildings)", side _unit, name _unit, count units _unit, count _inCQB] call EFUNC(main,debugLog);
};

// end
_buildings
