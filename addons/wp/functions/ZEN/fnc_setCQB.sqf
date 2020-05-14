#include "\z\lambs\addons\wp\script_component.hpp"

params ["_groups"];

private _targets = [];
_targets append _groups;
{
    if (_x isKindOf "CAManBase") then {
        _targets pushBackUnique (group _x);
    } else {
        _targets append ((crew _x) apply {group _x});
    };
} forEach _objects;
_targets = _targets arrayIntersect _targets;

{
    [_x, leader _x, 50, 4] remoteExec [QFUNC(taskCQB), leader _x];
} forEach _targets;
