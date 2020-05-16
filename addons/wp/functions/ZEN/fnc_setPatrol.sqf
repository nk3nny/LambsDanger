#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, getPos leader _x, 200] remoteExecCall [QFUNC(taskPatrol), leader _x];
} forEach _targets;
