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
params ["_unit","_pos",["_radius",0]];

// get radius
_radius = waypointCompletionRadius [group _unit, currentwaypoint group _unit];
if (_radius isEqualTo 0) then {_radius = 1000;};

// get other settings

// prepare troops ~ pre-set for raid!
[_unit,99,999999] call lambs_danger_fnc_leaderModeUpdate;       // diwako/jok: Could this be 'FUNC(leaderModeUpdate)'; being from different packages? -nkenny
group _unit setVariable ["lambs_danger_dangerAI","disabled"];   // same

// execute script
[_unit,_radius] spawn FUNC(taskRush);

// low level move order
group _unit move _pos;

// end
true
