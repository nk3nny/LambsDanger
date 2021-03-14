#include "script_component.hpp"

params ["_groups", "_args"];

private _set = _args isEqualTo 1;

_groups findIf { _x getVariable [QGVAR(disableGroupAI), false] isNotEqualTo _set } != -1;
