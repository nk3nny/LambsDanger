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
 * [bob, angryJoe] call lambs_danger_fnc_assaultSpeed;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull]];


// speed
if ((behaviour _unit) isEqualTo "STEALTH") exitWith {_unit forceSpeed 1; 1};
private _distance = _unit distance2D _target;
if ((speedMode _unit) isEqualTo "FULL") exitWith {private _speed = [24, 3] select (_distance < 12); _unit forceSpeed _speed; _speed};
if (_distance > (GVAR(cqbRange) + 20)) exitWith {_unit forceSpeed -1; -1};
if (_distance > 6) exitWith {_unit forceSpeed 3; 3};
if (_distance > 3) exitWith {_unit forceSpeed 2; 2};
_unit forceSpeed 1;
1
