#include "script_component.hpp"
// Add to group leader modes
// version 1.41
// by nkenny

// init
params ["_unit", ["_setting", 0], ["_target", objNull]];

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
