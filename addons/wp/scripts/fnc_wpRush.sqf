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
params ["_group", "_pos", ["_radius",0]];

// get radius
_radius = waypointCompletionRadius [_group, currentWaypoint _group];
if (_radius isEqualTo 0) then { _radius = TASK_RUSH_SIZE; };

// low level move order
_group move _pos;

// group
_group setVariable [QEGVAR(danger,disableGroupAI), true];
_group setVariable [QEGVAR(danger,tactics), true];

// execute script
[_group, _radius] call FUNC(taskRush);

// end
true
