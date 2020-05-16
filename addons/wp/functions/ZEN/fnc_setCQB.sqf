#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, leader _x, 50, 4] remoteExec [QFUNC(taskCQB), leader _x];
} forEach _targets;
