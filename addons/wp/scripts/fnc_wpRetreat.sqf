#include "script_component.hpp"
/*
 * Author: nkenny
 * Creates a Forced retreat WP on target location
 *
 * Arguments:
 * 0: Unit
 * 1: Unit position
 *
 * Return Value:
 * none
 *
*/

// init
params ["_group", "_pos"];

// group
_group setVariable [QEGVAR(danger,tactics), true];
_group setVariable [QEGVAR(danger,disableGroupAI), true];
_group setSpeedMode "FULL";

// individual units
{
    _x enableAI "MOVE";
    _x enableAI "PATH";
} foreach units _group;

// low level move order
_group move _pos;

// execute script
[_group, _pos, true, TASK_ASSAULT_DISTANCETHRESHOLD, TASK_ASSAULT_CYCLETIME, true] call FUNC(taskAssault);

// end
true
