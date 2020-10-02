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
private _trace = lineIntersectsSurfaces [eyePos _unit, eyePos _unit vectorAdd [0, 0, 10], _unit, objNull, true, -1, "GEOM", "NONE", true];
if (_trace isEqualTo []) exitWith {false};
_trace findIf {_x select 3 isKindOf "Building"} != -1