#include "script_component.hpp"
GVAR(TargetIndex) = 0;
GVAR(ModuleTargets) = [];
[QGVAR(taskPatrol), {_this call FUNC(taskPatrol)}] call CBA_fnc_addEventHandler;
