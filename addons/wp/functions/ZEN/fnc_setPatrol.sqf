#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x, getPos leader _x] remoteExecCall [QFUNC(taskPatrol), leader _x];
} forEach _targets;
