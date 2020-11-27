#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x] remoteExec [QFUNC(taskHunt), leader _x];
} forEach _targets;
