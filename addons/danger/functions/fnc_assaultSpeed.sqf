#include "script_component.hpp"
/*
 * Author: nkenny
 * Determines appropriate CQC speed based on distance
 *
 * Arguments:
 * 0: Unit assaulting <OBJECT> or <ARRAY>
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

params ["_unit", ["_target",ObjNull]];

// distance
private _distance = _unit distance2d _target;

// speed
if (behaviour _unit isEqualTo "STEALTH") exitWith {1};
if (speedMode _unit isEqualTo "FULL") exitWith {[24, 3] select (_distance < (8 + random 4))};
if (_distance > (GVAR(CQB_range) + 10)) exitWith {-1};
if (_distance > 15) exitWith {3};
if (_distance > 4) exitWith {2};
1