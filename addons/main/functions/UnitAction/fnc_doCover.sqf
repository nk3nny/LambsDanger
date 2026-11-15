#include "script_component.hpp"
/*
 * Author: nkenny
 * moved the unit into cover
 *
 * Arguments:
 * 0: unit doing the flight <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_main_fnc_doCover;
 *
 * Public: No
*/

params ["_unit"];

// stance change (one step lower)
_unit setUnitPosWeak (["DOWN", "MIDDLE"] select ((stance _unit) isEqualTo "STAND"));

// exit if stopped or inside a building
if (!(_unit checkAIFeature "PATH") || {(insideBuilding _unit) isEqualTo 1}) exitWith {false};

// find cover - exit on no cover
private _pos = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE", "WALL"], 4, true, true];
if (_pos isEqualTo []) exitWith {false};

// adjust pos - exit if close
_pos =_pos select 0;
_pos = _pos getPos [-1.2, _unit getDir _pos];
if (_unit distance2D _pos < 0.6) exitWith {false};

// force anim
private _direction = _unit getRelDir _pos;
private _anim = call {
    if (_direction > 315) exitWith {["WalkF", "WalkLF"]};
    if (_direction > 225) exitWith {["WalkL", "WalkLF"]};
    if (_direction > 135) exitWith {["WalkB"]};
    if (_direction > 45) exitWith {["WalkR", "WalRF"]};
    ["WalkF", "WalkRF"]
};

// seek cover
_unit setVariable [QGVAR(currentTask), "Seek cover!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// prevent run in place
_unit moveTo _pos;
_unit setDestination [_pos, "FORMATION PLANNED", true];

// do anim
[_unit, _anim, false] call FUNC(doGesture);       // gesture is not forced to allow cover movement to appear smoother - nkenny

// end
true
