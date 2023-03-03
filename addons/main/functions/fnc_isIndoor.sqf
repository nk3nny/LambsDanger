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
 * [bob] call lambs_main_fnc_inside;
 *
 * Public: No
*/
params ["_unit"];
insideBuilding _unit isEqualTo 1
