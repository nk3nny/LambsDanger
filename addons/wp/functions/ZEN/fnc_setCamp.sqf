#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, getPos (leader _x), 50] remoteExecCall [QFUNC(taskCamp), leader _x];
} forEach _targets;
