#include "script_component.hpp"

if (true) exitWith {true};
params ["_objects", "_groups", "_args"];

private _set = _args isEqualTo 1;

private _targets = [];
_targets append _groups;
{
    _targets pushBackUnique (group _x);
} forEach _objects;

_targets findIf { _x getVariable [QGVAR(disableGroupAI), !_set] != _set } != -1;
