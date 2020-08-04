#include "script_component.hpp"
GVAR(TargetIndex) = 0;
GVAR(ModuleTargets) = [];

[QGVAR(taskGarrison), {_this call FUNC(taskGarrison)}] call CBA_fnc_addEventHandler;
[QGVAR(taskPatrol), {_this call FUNC(taskPatrol)}] call CBA_fnc_addEventHandler;

[QGVAR(taskGarrison), {_this call FUNC(taskAssault)}] call CBA_fnc_addEventHandler;

[QGVAR(taskGarrison), {_this call FUNC(taskCQB)}] call CBA_fnc_addEventHandler;

[QGVAR(taskGarrison), {_this call FUNC(taskGarrison)}] call CBA_fnc_addEventHandler;

[QGVAR(taskGarrison), {_this call FUNC(taskGarrison)}] call CBA_fnc_addEventHandler;

[QGVAR(taskGarrison), {_this call FUNC(taskGarrison)}] call CBA_fnc_addEventHandler;
