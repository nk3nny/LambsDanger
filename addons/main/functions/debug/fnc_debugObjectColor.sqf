#include "script_component.hpp"
/*
 * Author: nkenny
 * Returns object colour appropriate to unit
 *
 * Arguments:
 * 0: unit being checked <OBJECT>
  *
 * Return Value:
 * String value with texture colour
 *
 * Example:
 * [_bob] call lambs_main_fnc_debugMarkerColor;
 *
 * Public: No
*/
params ["_unit"];

// return
if (side _unit isEqualTo EAST) exitWith { "#(argb,8,8,3)color(0.5,0,0,0.7,ca)" };
if (side _unit isEqualTo WEST) exitWith { "#(argb,8,8,3)color(0,0.3,0.6,0.7,ca)" };
if (side _unit isEqualTo CIVILIAN) exitWith { "#(argb,8,8,3)color(0.4,0,0.5,0.7,ca)" };
if (side _unit isEqualTo INDEPENDENT) exitWith { "#(argb,8,8,3)color(0,0.5,0,0.7,ca)" };
"#(argb,8,8,3)color(0.7,0.6,0,0.7,ca)"
