#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, getPos (leader _x), 50] remoteExec [QFUNC(taskGarrison), leader _x];
} forEach _targets;
