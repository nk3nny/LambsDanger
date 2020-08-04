#include "script_component.hpp"
GVAR(TargetIndex) = 0;
GVAR(ModuleTargets) = [];
[QGVAR(taskAssault), {_this call FUNC(taskAssault)}] call CBA_fnc_addEventHandler;
[QGVAR(taskCQB), {_this call FUNC(taskCQB)}] call CBA_fnc_addEventHandler;
[QGVAR(taskCamp), {_this call FUNC(taskCamp)}] call CBA_fnc_addEventHandler;
[QGVAR(taskCreep), {_this call FUNC(taskCreep)}] call CBA_fnc_addEventHandler;
[QGVAR(taskGarrison), {_this call FUNC(taskGarrison)}] call CBA_fnc_addEventHandler;
[QGVAR(taskHunt), {_this call FUNC(taskHunt)}] call CBA_fnc_addEventHandler;
[QGVAR(taskPatrol), {_this call FUNC(taskPatrol)}] call CBA_fnc_addEventHandler;
[QGVAR(taskReset), {_this call FUNC(taskReset)}] call CBA_fnc_addEventHandler;
[QGVAR(taskRush), {_this call FUNC(taskRush)}] call CBA_fnc_addEventHandler;
