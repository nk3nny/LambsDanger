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
params ["_group", "_pos", ["_radius", 0]];

// get radius
_radius = waypointCompletionRadius [_group, currentWaypoint _group];
if (_radius isEqualTo 0) then { _radius = TASK_HUNT_SIZE; };

// get other settings

// low level move order
_group move _pos;

// execute script
[_group, _radius] call FUNC(taskHunt);

// end
true
