#include "script_component.hpp"

private _targets = [];
GET_GROUPS_CONTEXT(_targets);

{
    private _leader = leader _x;
    [QGVAR(taskCamp), [_x, POSITIONAGL(_leader)], _leader] call CBA_fnc_targetEvent;
} forEach _targets;
