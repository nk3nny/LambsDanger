#include "\z\lambs\addons\wp\script_component.hpp"

params ["_groups", "_objects"];

private _targets = [];
GET_GROUPS_CONTEXT(_targets,_groups,_objects);

{
    [_x, getPos (leader _x), 50] remoteExec [QFUNC(taskGarrison), leader _x];
} forEach _targets;
