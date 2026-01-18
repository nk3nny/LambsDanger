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
private _speed = [3, 4] select (getSuppression _unit isEqualTo 0);
if ((leader _unit) isEqualTo _unit || (morale _unit) < 0) then {_speed = _speed - 1;};
if (_unit distance2D _target < 5) then {_speed = _speed - 1;};
_unit forceSpeed _speed;
_speed

