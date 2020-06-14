#include "script_component.hpp"
/*
 * Author: nkenny
 * Rotate tank to face enemy
 *
 * Remarks:
 * Inspiration by the work of alarm9k @ https://forums.bohemia.net/forums/topic/172270-smarter-tanks-script/
 * Also thanks to Natalie
 *
 * Arguments:
 * 0: Vehicle rotating <OBJECT>
 * 1: Direction which to turn towards, default is nearest enemy, position <ARRAY>
 * 2: Acceptible threshold in degrees, default 18 <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, 100] call lambs_danger_fnc_vehicleRotate;
 *
 * Public: No
*/
params ["_unit", ["_target", []], ["_threshold", 18]];

if (_target isEqualTo []) then {
    _target = _unit findNearestEnemy _unit;
};

// cannot move or moving
if (!canMove _unit || {currentCommand _unit isEqualTo "MOVE"}) exitWith {true};

// CQB tweak <-- disabled! more dynamic vehicles is better!!
if (_unit distance _target < GVAR(CQB_range)) exitWith {true};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Rotate", EGVAR(main,debug_functions)];

// within acceptble limits -- suppress instead
if (_unit getRelDir _target < _threshold || {_unit getRelDir _target > (360-_threshold)}) exitWith {
    [_unit, _target call cba_fnc_getPos] call FUNC(vehicleSuppress);
    true
};

// settings
private _pos = [];
private _min = 20;      // Minimum range
private _i = 0;         // iterations

while {_pos isEqualTo []} do {
    _pos = (_unit getPos [_min, _unit getDir _target]) findEmptyPosition [0, 2.2, typeOf _unit];

    // water
    if !(_pos isEqualTo []) then {if (surfaceIsWater _pos) then {_pos = []};};

    // update
    _min = _min + 15;
    _i = _i + 1;
    if (_i > 6) exitWith {_pos = _unit modelToWorldVisual [0, -100, 0]};
};

// move
_unit doMove _pos;

// waitUntil
[
    {
        params ["_unit", "_target", "_threshold"];
        ((_unit getRelDir _target) < _threshold || {(_unit getRelDir _target) > (360 - _threshold)})
    }, {
        params ["_unit", "_target"];
        // check vehicle
        if (canMove _unit && {!((crew _unit) isEqualTo [])}) then {
            // refresh ready (For HC apparently)
            (effectiveCommander _unit) doMove (getPosASL _unit);

            // refresh formation
            (group _unit) setFormDir (_unit getDir _target);
        };
    }, [_unit, _target, _threshold], (4 + random 6)
] call CBA_fnc_waitUntilAndExecute;

// end
true
