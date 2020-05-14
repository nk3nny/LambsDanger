#include "script_component.hpp"

params ["_objects", "_groups", "_args"];

private _set = _args isEqualTo 1;

private _targets = [];
_targets append _objects;
{
    _targets append (units _x);
} forEach _groups;

_targets = _targets arrayIntersect _targets;
{
    _x setVariable [QGVAR(disableAI), _set, true];
} forEach _targets;
