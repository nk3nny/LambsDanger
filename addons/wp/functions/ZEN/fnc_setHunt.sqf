#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, 1000, 70] remoteExec [QFUNC(taskHunt), leader _x];
} forEach _targets;
