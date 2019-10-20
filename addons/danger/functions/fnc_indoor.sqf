#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if unit is indoors
 *
 * Arguments:
 * 0: Unit checked <OBJECT>
 *
 * Return Value:
 * unit indoor or not
 *
 * Example:
 * [bob] call lambs_danger_fnc_inside;
 *
 * Public: No
*/
params ["_unit"];
lineIntersects [eyePos _unit, eyePos _unit vectorAdd [0, 0, 4]]
