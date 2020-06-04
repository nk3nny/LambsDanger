#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x] remoteExec [QFUNC(taskRush), leader _x];
} forEach _targets;
