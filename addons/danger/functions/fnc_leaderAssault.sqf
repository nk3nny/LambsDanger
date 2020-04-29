#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggresive assault towards buildings or location
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
 * [bob, angryJoe] call lambs_danger_fnc_leaderAssault;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 2]];

// stopped or static
if (!(attackEnabled _unit) || {stopped _unit}) exitWith {false};

// find target
_target = _target call CBA_fnc_getPos;

// check CQB ~ exit if in close combat other functions will do the work - nkenny
if (_unit distance2D _target < GVAR(CQB_range)) exitWith {

    [_unit, _target] call FUNC(leaderGarrison);

    // leader smoke
    [_unit, _target] call FUNC(doSmoke);

    false
};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 250] call FUNC(findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort building locations
private _pos = [_target, 16, true, false] call FUNC(findBuildings);
_pos pushBack _target;

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Assault", GVAR(debug_functions)];

// gesture
[_unit, ["gestureGo"]] call FUNC(gesture);
[_units select (count _units - 1), ["gestureGoB"]] call FUNC(gesture);

// leader callout
[_unit, "combat", "Advance", 125] call FUNC(doCallout);

// leader smoke
[_unit, _target] call FUNC(doSmoke);

// ready group
(group _unit) setFormDir (_unit getDir _target);

// manoeuvre function
private _fnc_assault = {
    params ["_cycle", "_units", "_pos", "_fnc_assault"];

    // update
    _units = _units select {_x call FUNC(isAlive) && {!isPlayer _x}};
    _cycle = _cycle - 1;

    {

        private _targetPos = selectRandom _pos;

        // setpos
        _x doMove _targetPos;

        // brave!
        _x setSuppression 0;

        // manoeuvre
        _x forceSpeed ([2, 3] select (speedMode _x isEqualTo "FULL"));
        _x setUnitPosWeak "UP";
        _x setVariable [QGVAR(currentTask), "Group Assault", GVAR(debug_functions)];
        _x setVariable [QGVAR(forceMove), true];

    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])}) then {
        [
            _fnc_assault,
            [_cycle, _units, _pos, _fnc_assault],
            10
        ] call CBA_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _pos, _fnc_assault] call _fnc_assault;

// debug
if (GVAR(debug_functions)) then {
    format ["%1 group ASSAULT (%2 with %3 units @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _pos] call FUNC(debugLog);
};

// end
true
