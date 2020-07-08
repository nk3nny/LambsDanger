#include "script_component.hpp"
/*
 * Author: nkenny
 * Creates taskAssault WP at target location and prepares units
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

// prepare troops ~ pre-set for raid!
[leader _group, 99, 170] call EFUNC(danger,leaderModeUpdate);

// group
_group setVariable [QEGVAR(danger,disableGroupAI), true];

// individual units
{
    _x enableAI "MOVE";
    _x enableAI "PATH";
} foreach units _group;

// low level move order
_group move _pos;

// execute script
[_group, _pos, TASK_ASSAULT_ISRETREAT, TASK_ASSAULT_DISTANCETHRESHOLD, TASK_ASSAULT_CYCLETIME, true] call FUNC(taskAssault);

// end
true
