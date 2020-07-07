#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit considers if it is night and therefore necessary to provide light
 *
 * Arguments:
 * 0: Unit  <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_isNight;
 *
 * Public: No
*/

params ["_unit"];

// stealth mode or has nightvision
if (behaviour _unit isEqualTo "STEALTH" 
    || { !( (hmd _unit) isEqualTo "" )}
) exitWith {false};

// night check
private _shift = date call BIS_fnc_sunriseSunsetTime;
(date select 3) < _shift select 0 || {(date select 3) > _shift select 1}