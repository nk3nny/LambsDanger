#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit tries to move into cover from danger
 * Cover that is towards the enemy is prioritised,-
 * so the unit will slowly advance if cover allows
 *
 * Arguments:
 * 0: unit doing the flight <OBJECT>
 * 1: position of danger <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, getPosATL badguy] call lambs_main_fnc_doCover;
 *
 * Public: No
*/
#define SEARCH_FOR_HIDE 6.5

params [
    ["_unit", objNull, [objNull]],
    ["_dangerPos", [0,0,0], [[]]]
];

if (isNull _unit || _dangerPos isEqualTo [0,0,0]) exitWith {false};
if ((_unit distance2D _dangerPos) < 20) exitWith {false};
if (!(_unit checkAIFeature "MOVE")) exitWith {false};
if (!(_unit checkAIFeature "PATH")) exitWith {false};

// Take cover
_unit setVariable [QGVAR(currentTask), "Take Cover!", GVAR(debug_functions)];

// Drop stance
if ((stance _unit) isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE"};

// find cover, preferably towards the opponent
private _coverPositions = nearestTerrainObjects [_unit getPos [1.5, _unit getDir _dangerPos], ["BUSH", "TREE", "HIDE"], SEARCH_FOR_HIDE, true, true];

private _pos = if (_coverPositions isEqualTo []) then {
    getPosATL _unit
} else {
    private _cover = _coverPositions select 0;
    _cover getPos [2, _dangerPos getDir _cover]
};

// Sanity checks to try prevent constant moving between cover positions -
// and units wandering away from the formation
if (_unit distance2D _pos < 0.6) exitWith {false};
if (_pos distance2D (leader _unit) > 20) exitWith {false};

// Force anim
private _direction = _unit getRelDir _pos;
private _anim = call {
    if (_direction > 315) exitWith {["FastF", "FastLF"]};
    if (_direction > 225) exitWith {["FastL", "FastLF"]};
    if (_direction > 135) exitWith {["FastB"]};
    if (_direction > 45) exitWith {["FastR", "FastRF"]};
    ["FastF", "FastRF"]
};

// prevent run in place
_unit doMove _pos;
_unit setDestination [_pos, "FORMATION PLANNED", true];

// do anim
[_unit, _anim, false] call FUNC(doGesture);       // gesture is not forced to allow cover movement to appear smoother - nkenny

// end
true
