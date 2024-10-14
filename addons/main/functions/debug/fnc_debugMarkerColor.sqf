#include "script_component.hpp"
/*
 * Author: nkenny
 * Returns marker colour appropriate to unit
 *
 * Arguments:
 * 0: unit being checked <OBJECT>
 *
 * Return Value:
 * String value with marker colour
 *
 * Example:
 * [_bob] call lambs_main_fnc_debugMarkerColor;
 *
 * Public: No
*/
params ["_unit"];

// return
if (side _unit isEqualTo east) exitWith { "colorEAST" };
if (side _unit isEqualTo west) exitWith { "colorWEST" };
if (side _unit isEqualTo civilian) exitWith { "ColorCIV" };
if (side _unit isEqualTo independent) exitWith { "colorIndependent" };
"ColorUNKNOWN"
