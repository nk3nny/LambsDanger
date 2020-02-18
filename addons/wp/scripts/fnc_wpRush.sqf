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
_radius = waypointCompletionRadius [_group, currentwaypoint _group];
if (_radius isEqualTo 0) then { _radius = 1000; };

// get other settings

// prepare troops ~ pre-set for raid!
[leader _group, 99, 999999] call EFUNC(danger,leaderModeUpdate);

// group
_group setVariable [QEGVAR(danger,disableGroupAI), true];

// execute script
[_group, _radius] spawn FUNC(taskRush);

// end
true
