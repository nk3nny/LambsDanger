#include "script_component.hpp"
// Do Gesture
// version 1.41
// by nkenny

// init
params ["_unit", ["_gesture", ["gestureFreeze"]]];

// do it
_unit playActionNow selectRandom _gesture;

// end
true
