#include "script_component.hpp"

params ["_groups", "_args"];

private _set = _args isEqualTo 1;

{
    _x setVariable [QGVAR(disableGroupAI), _set, true];
} forEach _groups;
