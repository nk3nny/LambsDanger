#include "script_component.hpp"

params ["_objects", "_args"];

private _set = _args isEqualTo 1;

{
    _x setVariable [QGVAR(disableAI), _set, true];
} forEach _objects;
