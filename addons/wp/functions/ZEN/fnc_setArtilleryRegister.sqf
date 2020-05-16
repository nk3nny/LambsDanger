#include "\z\lambs\addons\wp\script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets,_groups,_objects);

{
    [_x] call FUNC(taskArtilleryRegister);
} forEach _targets;
