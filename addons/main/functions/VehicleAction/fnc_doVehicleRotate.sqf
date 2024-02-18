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
 * 1: Direction which to turn towards <ARRAY>
 * 2: Acceptible threshold in degrees <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doVehicleRotate;
 *
 * Public: No
*/
params ["_unit", ["_target", []], ["_threshold", 18]];

if (_target isEqualTo []) then {
    _target = _unit getHideFrom (_unit findNearestEnemy _unit);
};
if (_target isEqualTo [0, 0, 0] || {_unit distanceSqr _target < 2}) exitWith {false};

// cannot move or moving
if (!canMove _unit || {currentCommand _unit isEqualTo "MOVE"}) exitWith {false};

// CQB tweak -- target within 75m - look instead
if (_unit distanceSqr _target < 5625) exitWith {
    (vehicle _unit) doWatch (ATLtoASL _target);
    false
};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Rotate", GVAR(debug_functions)];

// within acceptble limits
if (_unit getRelDir _target < _threshold || {_unit getRelDir _target > (360-_threshold)}) exitWith {
    false
};

// settings
private _pos = [];
private _min = 20;      // Minimum range

for "_i" from 0 to 5 do {
    _pos = (_unit getPos [_min, _unit getDir _target]) findEmptyPosition [0, 2.2, typeOf _unit];

    // water or exit
    if !(_pos isEqualTo [] || {surfaceIsWater _pos}) exitWith {};

    // update
    _min = _min + 15;
};
if (_pos isEqualTo []) then {_pos = _unit modelToWorldVisual [0, -100, 0]};

// move
_unit doMove _pos;
_unit setFormDir (_unit getDir _pos);

// waitUntil
[
    {
        params ["_unit", "_target", "_threshold"];
        ((_unit getRelDir _target) < _threshold || {(_unit getRelDir _target) > (360 - _threshold)})
    }, {
        params ["_unit", "_target"];
        // check vehicle
        if (canMove _unit && {(crew _unit) isNotEqualTo []}) then {

            // refresh ready
            (effectiveCommander _unit) doMove (getPosASL _unit);

            // refresh formation
            (group _unit) setFormDir (_unit getDir _target);
        };
    }, [_unit, _target, _threshold], (4 + random 6)
] call CBA_fnc_waitUntilAndExecute;

// end
true
