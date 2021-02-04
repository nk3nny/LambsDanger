#include "script_component.hpp"

params ["_objects", "_args"];

private _set = _args isEqualTo 1;

_objects findIf { !(_x getVariable [QGVAR(dangerRadio), false] isEqualTo _set) } != -1;
