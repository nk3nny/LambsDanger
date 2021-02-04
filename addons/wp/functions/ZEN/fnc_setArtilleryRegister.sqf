#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [_x] call FUNC(taskArtilleryRegister);
} forEach _targets;
