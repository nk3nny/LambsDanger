#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggresive manoeuvres towards buildings or location
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 * 3: How many assault cycles, default four <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderManoeuvre;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []],["_cycle",4]];

// find units
if (_units isEqualTo []) then {
    _units = units _unit;
};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Manoeuvre"];

// sort building locations
private _pos = ([_target, 12, true, true] call FUNC(findBuildings));
_pos pushBack (_target call CBA_fnc_getPos);

// gesture
[_unit, ["gestureGo"]] call FUNC(gesture);
[selectRandom _units, ["gestureGoB"]] call FUNC(gesture);

// ready group
{ _x doFollow (leader _x) } forEach _units;
(group _unit) setFormDir (_unit getDir (_pos select 0));

// manoeuvre function
private _fnc_manoeuvre = {
    params ["_cycle", "_units", "_pos", "_fnc_manoeuvre"];

    // update
    _units = _units select {alive _x && {_x distance (selectRandom _pos) > GVAR(CQB_range)}};
    _cycle = _cycle - 1;

    {
        // Half suppress -- Half manoeuvre
        if (RND(0.6)) then {
            _x forceSpeed 2;
            _x suppressFor 12;
            [_x, selectRandom _pos] call FUNC(Suppress);
        } else {
            // manoeuvre
            _x setUnitPosWeak selectRandom ["UP", "MIDDLE"];
            _x forceSpeed 25;
            _x commandMove selectRandom _pos;
            _x setVariable [QGVAR(currentTask), "Manoeuvre"];
        };
    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])}) then {
        [
            _fnc_manoeuvre,
            [_cycle, _units, _pos, _fnc_manoeuvre],
            12 + random 6
        ] call cba_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _pos, _fnc_manoeuvre] call _fnc_manoeuvre;

// end
true
