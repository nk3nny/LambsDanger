#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, 1000, 4] remoteExec [QFUNC(taskCreep), leader _x];
} forEach _targets;
