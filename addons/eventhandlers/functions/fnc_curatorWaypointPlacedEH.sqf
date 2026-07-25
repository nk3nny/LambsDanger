#include "script_component.hpp"
/*
 * Author: nkenny
 * Allows curator commands to cancel group manoeuvres
 *
 * Arguments:
 * BIS curator
 *
 * Return Value:
 * bool
 *
 * Example:
 * [BIS curator] call lambs_eventhandlers_fnc_curatorWaypointPlacedEH;
 *
 * Public: No
*/

params ["", "_group", "_waypointID"];

// update variables
_group setVariable [QEGVAR(danger,isExecutingTactic), false, true];
_group setVariable [QEGVAR(main,groupMemory), [], true];

// clear targets
private _leader = leader _group;
private _waypointPos = getWPPos [_group, _waypointID];

// forget enemies that are distant to waypoint
if (local _leader && {_leader distance2D _waypointPos > 300}) then {

    private _enemies = (_leader targets [true]) select {_x distance2D _wayPointPos > 300};
    {
        _group forgetTarget _x;
    } forEach _enemies;
};

// end
true
