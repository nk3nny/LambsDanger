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
params ["_unit", "_target", ["_units", []], ["_cycle", 3]];

// find target
_target = _target call cba_fnc_getPos;

// stopped or static
if (!(attackEnabled _unit) || {stopped _unit}) exitWith {false};

// check CQC ~ exit if in close combat other functions will do the work - nkenny
if (_unit distance2D _target < GVAR(CQB_range)) exitWith {

    // set tasks + rally unit
    _unit setVariable [QGVAR(currentTask), "Leader Rally"];
    {
        _x doFollow (leader _x);
        _x forceSpeed selectRandom [24, 3];
        _x setVariable [QGVAR(forceMOVE), true];
        true
    } count (( units _unit ) select { _x distance _unit > 45 });
    false
};

// find units
if (_units isEqualTo []) then {
    _units = (units _unit) select {!isPlayer _x};
};

// find overwatch position
private _overwatch = [getpos _unit, ((_unit distance2d _target) / 2) min 300, 100, 8, _target] call FUNC(findOverwatch);

// sort building locations
private _pos = ([_target, 12, true, false] call FUNC(findBuildings));
[_pos, true] call cba_fnc_shuffle;
_pos pushBack (_target call CBA_fnc_getPos);

// set tasks
_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Leader Manoeuvre"];

// gesture
[_unit, ["gestureGo"]] call FUNC(gesture);
[selectRandom _units, ["gestureGoB"]] call FUNC(gesture);

// ready group
(group _unit) setFormDir (_unit getDir _target);
if (_overwatch isEqualto []) then {(group _unit) move _target} else {(group _unit) move _overwatch;};

// manoeuvre function
private _fnc_manoeuvre = {
    params ["_cycle", "_units", "_pos", "_fnc_manoeuvre"];

    // update
    _units = _units select {alive _x && {!isPlayer _x}};
    _cycle = _cycle - 1;

    {
        // Half suppress -- Half manoeuvre
        if (RND(0.4) && {count _pos > 0}) then {
            _x doWatch (_pos select 0);
            _x suppressFor 12;
            [_x, AGLtoASL (_pos select 0)] call FUNC(suppress);
            _pos deleteAt 0;
        } else {
            // manoeuvre
            _x forceSpeed selectRandom [24, 3, 3];
            _x setUnitPosWeak selectRandom ["UP", "MIDDLE"];
            _x setVariable [QGVAR(currentTask), "Manoeuvre"];
            _x setVariable [QGVAR(forceMOVE), true];

            // force movement
            [_x, ["FastF", "FastF", "FastLF", "FastRF"]] call FUNC(gesture);
        };
    } foreach _units;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])} && {!(_pos isEqualTo [])}) then {
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
