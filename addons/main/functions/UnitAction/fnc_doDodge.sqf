#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays an immediate reaction unit getting hit (Internal to FSM)
 *
 * Arguments:
 * 0: unit hit <OBJECT>
 * 1: position of dange <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_main_fnc_doDodge;
 *
 * Public: No
*/
#define DODGE_DISTANCE 3
#define NEAR_DISTANCE 22

params ["_unit", ["_pos", [0, 0, 0]]];

// settings
private _stance = stance _unit;
private _dir = _unit getRelDir _pos;
private _still = (speed _unit) isEqualTo 0;

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// prone override
if (_still && {_stance isEqualTo "PRONE"} && {!(lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 7]])}) exitWith {
    [_unit, ["EvasiveLeft", "EvasiveRight"] select (_dir > 180), true] call FUNC(doGesture);
    _unit setDestination [[_unit getRelPos [DODGE_DISTANCE, -90], _unit getRelPos [DODGE_DISTANCE, 90]] select (_dir > 180), "FORMATION PLANNED", false];
    true
};

// ACE3 captive exit
if (
    GVAR(disableAIDodge)
    || {!(_unit checkAIFeature "MOVE")}
    || {!(_unit checkAIFeature "PATH")}
) exitWith {false};

// callout
if (RND(0.8)) then {
    [_unit, "Combat", "UnderFireE", 125] call FUNC(doCallout);
};

// settings
private _nearDistance = (_unit distance2D _pos) < NEAR_DISTANCE;
private _suppression = _nearDistance && {getSuppression _unit > 0.1};
private _relPos = [];
private _anim = [];

// drop stance
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (_stance isEqualTo "CROUCH" && { _nearDistance }) then {_unit setUnitPosWeak "DOWN";};

// move left
if (RND(0.1) && { _dir < 80 }) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, -60];
    _anim = ([["FastL", "FastLF"], ["TactL", "TactLF"]] select _suppression);
};

// move right
if (RND(0.1) && { _dir > 250 }) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 60];
    _anim = ([["FastR", "FastRF"], ["TactR", "TactRF"]] select _suppression);
};

// move back ~ more checks because sometimes we want the AI to move forward in CQB - nkenny
if (_still  && { !_nearDistance } && {_dir > 320 || { _dir < 40 }}) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 180];
    _anim = ([["FastB", "FastLB", "FastRB"], ["TactB", "TactLB","TactRB"]] select _suppression);
};

// check
if (_anim isEqualTo []) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 0];
    _anim = (["FastF", "TactF"] select _suppression);
};

// tweak dodge
_unit moveto _relPos;
_unit setDestination [_relPos, "FORMATION PLANNED", true];

// execute dodge
[_unit, _anim, true] call FUNC(doGesture);

// watch distant shots
if (!_nearDistance) then {_unit doWatch _pos;};

// end
true
