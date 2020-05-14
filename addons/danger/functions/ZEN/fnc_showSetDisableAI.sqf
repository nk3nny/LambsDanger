#include "script_component.hpp"

if (true) exitWith {true};
params ["_objects", "_groups", "_args"];

private _set = _args isEqualTo 1;

private _targets = [];
_targets append _objects;
{
    _targets append (units _x);
} forEach _groups;

_targets = _targets arrayIntersect _targets;

_targets findIf { _x getVariable [QGVAR(disableAI), !_set] != _set } != -1;
