#include "script_component.hpp"
// Checks if unit is indoors
// version 1.01
// by nkenny


// init
params ["_unit"];

// check and Return
lineIntersects [eyePos _unit, eyePos _unit vectorAdd [0, 0, 4]];
