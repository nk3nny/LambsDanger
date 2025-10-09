#include "script_component.hpp"
/*
 * Author: nkenny
 * Vehicle moves aggressively to superior position
 *
 * Arguments:
 * 0: _unit moving <OBJECT>
 * 1: dangerous position <ARRAY>
 * 2: dangerous object <OBJECT>
 * 3: distance to position and object <NUMBER>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, getPos angryJoe, angryJoe] call lambs_main_fnc_doVehicleAssaultMove;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_target", objNull], ["_distance", -1]];

// settings
private _vehicle = vehicle _unit;

// distance to position
if (_distance < 0) then {_distance = _vehicle distance _pos};
if (isNull _target) then {_target = _vehicle;};

// cannot move or moving or enemy too close or too far away
if (
    !canMove _vehicle
    || { (fuel _vehicle) < 0.1 }
    || { (currentCommand _vehicle) in ["MOVE", "ATTACK"] }
    || {_distance < (precision _vehicle)}
    || {_distance > 200}
    ) exitWith {
        _vehicle doMove (getPosASL _vehicle);
        false
};

private _destination = call {

    // 25 meters ahead
    private _typeOf = typeOf _vehicle;
    private _distance = _vehicle distance _pos;
    private _movePos = _vehicle getPos [50 min _distance, _vehicle getDir _pos];
    _movePos = _movePos findEmptyPosition [0, 15, _typeOf];
    if (_movePos isNotEqualTo [] && {[vehicle _target, "VIEW", objNull] checkVisibility [(AGLToASL _movePos) vectorAdd [0, 0, 3], AGLToASL _pos] > 0}) exitWith {
        _movePos
    };

    // random 200 + road adjustment
    _movePos = (_vehicle getPos [200 min _distance, (_vehicle getDir _pos) - 45 + random 90]) findEmptyPosition [10, 30, _typeOf];
    if (_movePos isNotEqualTo [] && {[vehicle _target, "VIEW", objNull] checkVisibility [(AGLToASL _movePos) vectorAdd [0, 0, 3], AGLToASL _pos] > 0}) exitWith {

        // road adjust
        private _roads = _movePos nearRoads 20;
        if (_roads isNotEqualTo []) then {_movePos = (ASLToAGL (getPosASL (selectRandom _roads)));};

        // return
        _movePos
    };

    // On top of
    _movePos = _pos findEmptyPosition [5, 35, _typeOf];
    if (_movePos isNotEqualTo []) exitWith {
        _movePos
    };

    // none
    []
};

// check it!
if (_destination isEqualTo []) exitWith {
    false
};

// set task
_unit setVariable [QGVAR(currentTarget), _destination, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Vehicle Assault Move", GVAR(debug_functions)];

// execute
_vehicle doMove _destination;

// debug
if (GVAR(debug_functions)) then {
    [
        "%1 assault move (%2 moves %3m | visiblity %4)",
        side _unit, getText (configOf _vehicle >> "displayName"),
        round (_unit distance _destination),
        [vehicle _target, "VIEW", objNull] checkVisibility [(AGLToASL _destination) vectorAdd [0, 0, 5], AGLToASL _pos]
    ] call FUNC(debugLog);
};

// exit
true
