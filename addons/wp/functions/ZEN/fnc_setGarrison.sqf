#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, getPos (leader _x)] remoteExec [QFUNC(taskGarrison), leader _x];
} forEach _targets;
