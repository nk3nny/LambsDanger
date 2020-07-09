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

params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_radius", 500, [0]],
    ["_area", [], [[]]],
    ["_pos", [], [[]]],
    ["_onlyPlayers", true, [false]]
];

private _groupLeader = leader _group;
private _sideExclusion = [side _group, civilian, sideUnknown, sideEmpty, sideLogic];
if (_pos isEqualTo []) then {
    _pos = _groupLeader;
};
_pos = _pos call CBA_fnc_getPos;
private _units = [allUnits ,switchableUnits + playableUnits] select _onlyPlayers;

_units = _units select {
    !(side _x in _sideExclusion)
    && { _x distance2D _pos < _radius }
    && { (getPosATL _x) select 2 < 200 }
};
if !(_area isEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle", ["_c", -1]];
    _units = _units select { (getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle, _c] };
};
if (_units isEqualTo []) exitWith {ObjNull};

private _unitDistances = _units apply {[_groupLeader distance2D _x, _x]};
_unitDistances sort true;

(_unitDistances param [0, [0, objNull]]) param [1, objNull]
