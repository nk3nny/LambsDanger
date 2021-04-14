#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    [QGVAR(taskCreep), [_x], leader _x] call CBA_fnc_targetEvent;
} forEach _targets;
