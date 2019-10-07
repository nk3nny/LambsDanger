#include "script_component.hpp"
// Do Gesture
// version 1.5
// by nkenny

// init
params ["_unit", ["_gesture", ["gestureFreeze"]]];

// not for players 
if (isPlayer _unit) exitWith {false};

// do it
_unit playActionNow selectRandom _gesture;

// end
true
