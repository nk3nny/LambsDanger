#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, 1000, 4] remoteExec [QFUNC(taskRush), leader _x];
} forEach _targets;
