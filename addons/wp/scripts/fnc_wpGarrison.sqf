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
_radius = waypointCompletionRadius [_group, currentwaypoint _group];
if (_radius isEqualTo 0) then { _radius = TASK_GARRISON_SIZE; };

// get other settings

// execute script
[_group, _pos, _radius] spawn FUNC(taskGarrison);

// end
true
