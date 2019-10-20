#include "script_component.hpp"
/*
 * Author: nkenny
 * Remove from group leader modes
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Setting <NUMBER>
 * 2: New delay until leaderAssessment can be made, default 1 <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, 0, 33] call lambs_danger_fnc_leaderMode;
 *
 * Public: No
*/
params ["_unit", ["_setting", 0], ["_delay", 1]];

// get variable
private _dangerMode = (group _unit) getVariable [QGVAR(dangerMode), [[], [], true, time]];

// Update danger type and target/position
_dangerMode set [0, (_dangerMode select 0) - [_setting]];
_dangerMode set [3, time + 360 + (_delay/2) + random (_delay/2)];

// update variable
(group _unit) setVariable [QGVAR(dangerMode), _dangerMode, false];

// return
true
