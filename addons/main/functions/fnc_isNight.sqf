#include "script_component.hpp"
/*
 * Author: nkenny, RCA3
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
    || {((hmd _unit) isNotEqualTo "")}
) exitWith {false};

// night check
// ~65 is the light level where vanilla AI puts nightvision goggles on
(getLighting # 1) < 65
