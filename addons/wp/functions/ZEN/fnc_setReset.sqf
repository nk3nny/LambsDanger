#include "\z\lambs\addons\wp\script_component.hpp"

params ["_groups", "_objects"];

private _targets = [];
GET_GROUPS_CONTEXT(_targets,_groups,_objects);

{
    [_x] remoteExecCall [QFUNC(taskReset), leader _x];
} forEach _targets;
