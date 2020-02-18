#include "script_component.hpp"
/*
 * Author: jokoho482
 * Find Closed Target to Group
 *
 * Arguments:
 * 0: Group to check <GROUP>
 * 1: Radius <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [group bob, 500] call lambs_wp_fnc_findClosedTarget;
 *
 * Public: Yes
*/

params ["_group", ["_radius", 500]];
private _newdist = _radius;
private _players = (switchableUnits + playableUnits - entities "HeadlessClient_F");
_players = _players select {side _x != side _group && {side _x != civilian}};
private _target = objNull;
{
    private _dist = (leader _group) distance2d _x;
    if (_dist < _newdist && {(getPosATL _x) select 2 < 200}) then { _target = _x; _newdist = _dist; };
    true
} count _players;
_target
