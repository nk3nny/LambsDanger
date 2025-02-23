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
 * 2: Acceptable threshold in degrees <NUMBER>
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
_target = _target call CBA_fnc_getPos;

// cannot move or moving
private _vehicle = vehicle _unit;
if (
    !canMove _vehicle
    || {(currentCommand _vehicle) isEqualTo "MOVE"}
    || {!((driver _vehicle) call FUNC(isAlive))}
    || {((vehicleMoveInfo _vehicle) select 1) in ["LEFT", "RIGHT"]}
) exitWith {
    false
};

// CQB tweak -- target within 35m - look instead
if (_unit distanceSqr _target < 1225) exitWith {
    _vehicle doWatch (ATLToASL _target);
    false
};

// within acceptable limits
if (_vehicle getRelDir _target < _threshold || {_vehicle getRelDir _target > (360-_threshold)}) exitWith {
    false
};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Rotate", GVAR(debug_functions)];

// move
_unit setFormDir (_unit getDir _target);
if (_vehicle isKindOf "Tank") then {

    // turn vehicle
    _vehicle sendSimpleCommand (["LEFT", "RIGHT"] select (_unit getRelDir _target < 180));

} else {

    // settings
    private _pos = [];
    private _min = 20;      // Minimum range

    for "_i" from 0 to 5 do {
        _pos = (_vehicle getPos [_min, _vehicle getDir _target]) findEmptyPosition [0, precision _vehicle, typeOf _vehicle];

        // water or exit
        if !(_pos isEqualTo [] || {surfaceIsWater _pos}) exitWith {};

        // update
        _min = _min + 15;
    };
    if (_pos isEqualTo []) then {_pos = _vehicle modelToWorldVisual [0, -100, 0]};
    _vehicle doMove _pos;
};


// waitUntil
[
    {
        params ["_vehicle", "_target", "_threshold"];
        ((_vehicle getRelDir _target) < _threshold || {(_vehicle getRelDir _target) > (360 - _threshold)})
    }, {
        params ["_vehicle", "_target"];
        // refresh ready
        _vehicle sendSimpleCommand "STOPTURNING";
        _vehicle sendSimpleCommand "STOP";
        _vehicle doMove (_vehicle getPos [precision _vehicle, _vehicle getDir _target]);

        // refresh formation
        (group _vehicle) setFormDir (_vehicle getDir _target);
    }, [_vehicle, _target, _threshold * 3], 4 + random 3,
    {
        params ["_vehicle", "_target"];
        _vehicle doWatch (ATLToASL _target);
        _vehicle sendSimpleCommand "STOPTURNING";
        _vehicle doMove (getPosASL _vehicle);
    }
] call CBA_fnc_waitUntilAndExecute;

// end
true
