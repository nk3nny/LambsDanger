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
_group setVariable [QEGVAR(danger,dangerAI), "disabled"];
_group setSpeedMode "FULL";

// individual units
{
    _x enableAI "MOVE";
	_x enableAI "PATH";
    _x forceSpeed 24;
} foreach units _group;

// execute script
[_group, _pos, false] call FUNC(taskAssault);

// end
true
