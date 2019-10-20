#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays a gesture picked from an array
 *
 * Arguments:
 * 0: Unit doing gesture <OBJECT>
 * 1: Array of possible gestures, default freeze gesture <ARRAY>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_gesture;
 *
 * Public: No
*/
params ["_unit", ["_gesture", ["gestureFreeze"]]];

// not for players
if (isPlayer _unit) exitWith {false};

// do it
_unit playActionNow (selectRandom _gesture);

// end
true
