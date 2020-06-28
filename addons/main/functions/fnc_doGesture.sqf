#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays a gesture picked from an array
 *
 * Arguments:
 * 0: Unit doing gesture <OBJECT>
 * 1: Array of possible gestures, default freeze gesture <ARRAY>
 * 2: Force Gesture <BOOL> (Default: false)
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_doGesture;
 *
 * Public: Yes
*/
params [
    ["_unit", objNull, [objNull]],
    ["_gesture", ["gestureFreeze"], [[]]],
    ["_force", false, [false]]
];

// check global settings
if (GVAR(disableAIGestures) && {!_force}) exitWith {false};

// not for players
if (isPlayer _unit) exitWith {false};

// do it
_unit playActionNow (selectRandom _gesture);

// end
true
