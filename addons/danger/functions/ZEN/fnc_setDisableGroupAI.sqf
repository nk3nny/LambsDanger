#include "script_component.hpp"

params ["_objects", "_groups", "_args"];

private _set = _args isEqualTo 1;

private _targets = [];
_targets append _groups;
{
    _targets pushBackUnique (group _x);
} forEach _objects;

{
    _x setVariable [QGVAR(disableGroupAI), _set, true];
} forEach _targets;
