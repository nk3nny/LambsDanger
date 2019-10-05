#include "script_component.hpp"
/*
* Author: nkenny
* Creates taskRush WP at target location and prepares units 
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
params ["_group","_pos",["_radius",0]];

// get radius
_radius = waypointCompletionRadius [_group, currentwaypoint _group];
if (_radius isEqualTo 0) then {_radius = 1000;};

// get other settings

// prepare troops ~ pre-set for raid!
[leader _group,99,999999] call FUNC(danger,leaderModeUpdate);

// group 
_group setVariable [QEGVAR(danger,dangerAI),"disabled"];

// individual units
{_x setVariable [QEGVAR(danger,dangerDisabled), true];} foreach units _group;

// execute script
[_group,_radius] spawn FUNC(taskRush);

// low level move order
_group move _pos;

// end
true
