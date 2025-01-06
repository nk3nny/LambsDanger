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
 * bool
 *
 * Example:
 * [bob] call lambs_main_fnc_doCover;
 *
 * Public: No
*/

params ["_unit", ["_pos", [], [[]]]];

// stance change
_unit setUnitPosWeak "DOWN";

// check if stopped or inside a building
if (!(_unit checkAIFeature "PATH") || {(insideBuilding _unit) isEqualTo 1}) exitWith {false};

// find cover
if (_pos isEqualTo []) then {
    _pos = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE"], 6, true, true];
    _pos = if (_pos isEqualTo []) then {
        getPosASL _unit
    } else {
        (_pos select 0) getPos [-1.2, _unit getDir (_pos select 0)]
    };
};

// force anim
if (_unit distance2D _pos < 0.6) exitWith {false};
private _direction = _unit getRelDir _pos;
private _anim = call {
    if (_direction > 315) exitWith {["WalkF", "WalkLF"]};
    if (_direction > 225) exitWith {["WalkL", "WalkLF"]};
    if (_direction > 135) exitWith {["WalkB"]};
    if (_direction > 45) exitWith {["WalkR", "WalRF"]};
    ["WalkF", "WalkRF"]
};

// prevent run in place
_unit moveTo _pos;
_unit setDestination [_pos, "FORMATION PLANNED", true];

// do anim
[_unit, _anim, false] call FUNC(doGesture);       // gesture is not forced to allow cover movement to appear smoother - nkenny

// end
true
