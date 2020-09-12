#include "script_component.hpp"
/*
 * Author: nkenny
 * moved the unit into cover
 *
 * Arguments:
 * 0: unit doing the flight <OBJECT>
 * 1: position of cover <ARRAY>
 *
 * Return Value:
 * _unit
 *
 * Example:
 * [bob] call lambs_danger_fnc_doCover;
 *
 * Public: No
*/
params ["_unit", ["_pos", [], [[]]]];

// find cover
if (_pos isEqualTo []) then {
    _pos = nearestTerrainObjects [_unit, [], GVAR(searchForHide), true, true]; //"BUSH", "TREE", "HIDE", "WALL", "FENCE"
    _pos = [(_pos select 0) getPos [-1, _unit getDir (_pos select 0)], getpos _unit] select (_pos isEqualTo []);
};

// force anim
if (_unit distance2D _pos < 0.8) exitWith {_unit};
private _direction = _unit getRelDir _pos;
private _anim = call {
    if (_direction > 315) exitWith {["WalkF", "WalkLF"]};
    if (_direction > 225) exitWith {["WalkL", "WalkLF"]};
    if (_direction > 135) exitWith {["WalkB"]};
    if (_direction > 45) exitWith {["WalkR", "WalRF"]};
    ["WalkF", "WalkRF"]
};
[_unit, selectRandom _anim, true] call EFUNC(main,doGesture);
_unit setDestination [_pos, "FORMATION PLANNED", false];

// DEBUG BRUTE
//systemchat format ["%1 ## SEEKS COVER ## %2 (%3m)", side _unit, name _unit, round (_unit distance _pos)];
//[_pos, "", "ColorWhite"] call EFUNC(main,dotMarker);

// end
_unit