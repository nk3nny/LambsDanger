#include "script_component.hpp"
/*
 * Author: jokoho482, dedmen
 * Find Closest Target to Group
 *
 * Arguments:
 * 0: Group to check <GROUP>
 * 1: Radius <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [group bob, 500] call lambs_wp_fnc_findClosestTarget;
 *
 * Public: No
*/

params ["_group", ["_radius", 500]];

private _groupLeader = leader _group;
private _sideExclusion = [side _group, civilian, sideUnknown, sideEmpty, sideLogic];

private _players = switchableUnits + playableUnits;
_players = _players select {!(side _x in _sideExclusion) && { _x distance _groupLeader < _radius } && { (getPosATL _x) select 2 < 200 }};
if (_players isEqualTo []) exitWith {ObjNull};

private _playerDistances = _players apply {[_groupLeader distance2d _x, _x]};
_playerDistances sort true;

(_playerDistances param [0, [0, objNull]]) param [1, objNull]
