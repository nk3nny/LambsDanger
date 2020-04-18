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

    [_unit, _target] call FUNC(leaderAssaultClose);

    false
};

// find units
if (_units isEqualTo []) then {
    _units = (units _unit) select {_x call FUNC(isAlive) && {!isPlayer _x}};
};

// sort building locations
private _pos = [_target, 16, true, false] call FUNC(findBuildings);
_pos pushBack _target;

// set tasks
_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Assault"];

// gesture
[_unit, ["gestureGo"]] call FUNC(gesture);
[_units select (count _units - 1), ["gestureGoB"]] call FUNC(gesture);

// leader callout
[_unit, "combat", "Advance", 125] call FUNC(doCallout);

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
        _x forceSpeed 3;
        _x setUnitPosWeak "UP";
        _x setVariable [QGVAR(currentTask), "Group Assault"];
        _x setVariable [QGVAR(forceMOVE), true];

        // force movement
        [_x, ["TactF", "TactF", "TactLF", "TactRF"], true] call FUNC(gesture);

    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])}) then {
        [
            _fnc_assault,
            [_cycle, _units, _pos, _fnc_assault],
            8
        ] call CBA_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _pos, _fnc_assault] call _fnc_assault;

// end
true
