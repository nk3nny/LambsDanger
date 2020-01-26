#include "script_component.hpp"
/*
 * Author: nkenny
 * Add to group leader modes
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Setting <NUMBER>
 * 2: Target information, unit <OBJECT> or position <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, 0, angryJoe] call lambs_danger_fnc_leaderMode;
 *
 * Public: No
*/
params ["_unit", ["_setting", 0], ["_target", objNull]];
if (isPlayer _unit)  exitWith {false};
// get variable
private _dangerMode = (group _unit) getVariable [QGVAR(dangerMode), [[], [], true, time]];

// old dangers discarded
if ((_dangerMode select 3) < time) then {_dangerMode = [[], [], true, 0]};

// Update danger type and target/position
(_dangerMode select 0) pushBackUnique _setting;
(_dangerMode select 1) set [_setting, _target];
_dangerMode set [2, false];
_dangerMode set [3, time + 360];

// update variable
(group _unit) setVariable [QGVAR(dangerMode), _dangerMode, false];

// end
true
