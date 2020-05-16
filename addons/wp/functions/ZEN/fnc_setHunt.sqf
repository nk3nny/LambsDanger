#include "\z\lambs\addons\wp\script_component.hpp"

params ["_groups", "_objects"];

private _targets = [];
GET_GROUPS_CONTEXT(_targets,_groups,_objects);

{
    [_x, 1000, 70] remoteExec [QFUNC(taskHunt), leader _x];
} forEach _targets;
