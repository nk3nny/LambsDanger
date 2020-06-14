#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended suppressive fire towards buildings or location
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderSuppress;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []]];

// find target
_target = _target call CBA_fnc_getPos;

// stopped or static
if (!(attackEnabled _unit) || {stopped _unit}) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = [_unit] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// find vehicles
private _vehicles = [];
{
    if (!(isNull objectParent _x) && { isTouchingGround vehicle _x } && { canFire vehicle _x }) then {
        _vehicles pushBackUnique vehicle _x;
    };
} foreach (units _unit select { _unit distance2D _x < 350 && { canFire _x }});

// sort building locations
private _pos = [_target, 20, true, true] call EFUNC(main,findBuildings);
_pos append ((nearestTerrainObjects [ _target, ["HIDE", "TREE", "BUSH", "SMALL TREE"], 8, false, true ]) apply {getPos _x});
_pos pushBack _target;

// sort cycles
private _cycle = selectRandom [3, 3, 4, 5];

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Suppress", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gesturePoint"]] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "SuppressiveFire", 125] call EFUNC(main,doCallout);

// ready group
(group _unit) setFormDir (_unit getDir _target);

// manoeuvre function
private _fnc_suppress = {
    params ["_cycle", "_units", "_vehicles", "_pos", "_fnc_suppress"];

    // update
    _units = _units select {_x call EFUNC(main,isAlive) && { !isPlayer _x }};
    _vehicles = _vehicles select { canFire _x };
    _cycle = _cycle - 1;

    // infantry
    {
        // ready
        private _posAGL = selectRandom _pos;

        // suppressive fire
        _x forceSpeed 1;
        _x setUnitPosWeak "MIDDLE";
        _x doWatch _posAGL;
        private _suppress = [_x, AGLtoASL _posAGL, true] call FUNC(suppress);
        _x setVariable [QGVAR(currentTask), "Group Suppress", EGVAR(main,debug_functions)];

        // no LOS
        if !(_suppress) then {
            // move forward
            _x forceSpeed 3;
            _x doMove (_x getPos [8 + random 6, _x getdir _posAGL]);
            _x setVariable [QGVAR(currentTask), "Group Suppress (Move)", EGVAR(main,debug_functions)];
        };
    } foreach _units;

    // vehicles
    {
        private _posAGL = selectRandom _pos;
        _x doWatch _posAGL;
        [_x, _posAGL] call FUNC(vehicleSuppress);
    } foreach _vehicles;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])}) then {
        [
            _fnc_suppress,
            [_cycle, _units, _vehicles, _pos, _fnc_suppress],
            3 + random 10
        ] call CBA_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _vehicles, _pos, _fnc_suppress] call _fnc_suppress;

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 group SUPPRESS (%2 with %3 units and %6 vehicles @ %4m with %5 positions for %7 cycles)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _pos, count _vehicles, _cycle] call EFUNC(main,debugLog);
};

// end
true
