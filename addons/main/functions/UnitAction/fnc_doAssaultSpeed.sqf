#include "script_component.hpp"
/*
 * Author: nkenny
 * Sets and reports appropriate CQB speed based on distance
 *
 * Arguments:
 * 0: Unit assaulting <OBJECT>
 * 1: Destination <OBJECT> or <ARRAY>
 *
 * Return Value:
 * appropriate speed
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doAssaultSpeed;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull]];

// speed
if ((behaviour _unit) isEqualTo "STEALTH") exitWith {_unit forceSpeed 1; 1};
private _distanceSqr = _unit distanceSqr _target;
if ((speedMode _unit) isEqualTo "FULL") exitWith {private _speed = [24, 3] select (_distanceSqr < 144); _unit forceSpeed _speed; _speed};
if (_distanceSqr > 6400) exitWith {_unit forceSpeed -1; -1};
if (_distanceSqr > 36) exitWith {_unit forceSpeed 3; 3};
if (_distanceSqr > 9) exitWith {_unit forceSpeed 2; 2};
_unit forceSpeed 1;
1
