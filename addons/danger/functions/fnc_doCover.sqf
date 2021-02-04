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

// check if stopped
if (!(_unit checkAIFeature "PATH") || {isForcedWalk _unit}) exitWith {_unit};

// find cover
if (_pos isEqualTo []) then {
    _pos = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE"], GVAR(searchForHide), true, true];
    _pos = if (_pos isEqualTo []) then {
        getPosASL _unit
    } else {
        (_pos select 0) getPos [-1.2, _unit getDir (_pos select 0)]
    };
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

// prevent run in place
if (((expectedDestination _unit) select 1) isEqualTo "DoNotPlan") then {_unit moveTo _pos;};

// do anim
[_unit, _anim, false] call EFUNC(main,doGesture);       // gesture is not forced to allow cover movement to appear smoother - nkenny
_unit setDestination [_pos, "FORMATION PLANNED", false];

// end
_unit
