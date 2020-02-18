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
hintSilent "Execute Rush Waypoint";
// get radius
_radius = waypointCompletionRadius [_group, currentwaypoint _group];
if (_radius isEqualTo 0) then { _radius = 1000; };

// get other settings

// prepare troops ~ pre-set for raid!
[leader _group, 99, 999999] call EFUNC(danger,leaderModeUpdate);

// group
_group setVariable [QEGVAR(danger,disableGroupAI), true];

// individual units
{
    _x setVariable [QEGVAR(danger,disableAI), true];
    _x disableAI "SUPPRESSION"; // these are here because the script probably works 'best' with some intelligence enabled. That said. Users expect dumb bots. To preserve utility, I disable these here instead of core script.  -nkenny
    _x disableAI "FSM";
    _x forceSpeed 24;
} foreach units _group;

// execute script
[_group, _radius] spawn FUNC(taskRush);

// low level move order
_group move _pos;

// end
true
