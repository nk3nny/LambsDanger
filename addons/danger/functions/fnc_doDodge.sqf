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
 * stance <STRING>
 *
 * Example:
 * [bob] call lambs_danger_fnc_doDodge;
 *
 * Public: No
*/
#define DODGE_DISTANCE 3
#define NEAR_DISTANCE 22

params ["_unit", ["_pos", [0, 0, 0]]];

// settings
private _stance = stance _unit;
private _dir = _unit getRelDir _pos;

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!", EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];

// prone override
if (_stance isEqualTo "PRONE" && {!(_unit call EFUNC(main,isIndoor))}) exitWith {
    [_unit, ["EvasiveLeft", "EvasiveRight"] select (_dir > 180), true] call EFUNC(main,doGesture);
    _unit setDestination [[_unit getRelPos [DODGE_DISTANCE, -90], _unit getRelPos [DODGE_DISTANCE, 90]] select (_dir > 180), "FORMATION PLANNED", false];
    _stance
};

// ACE3 captive exit
if (
    GVAR(disableAIDodge)
    || {isForcedWalk _unit}
    || {!(_unit checkAIFeature "MOVE")}
    || {!(_unit checkAIFeature "PATH")}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_isSurrendering", false]}
    || {_unit distance2D (_unit findNearestEnemy _unit) < (5 + random 15)}
) exitWith {_stance};

// callout
if (RND(0.6)) then {
    [_unit, "Combat", "UnderFireE", 125] call EFUNC(main,doCallout);
};

// settings
private _nearDistance = (_unit distance2D _pos) < NEAR_DISTANCE;
private _suppression = _nearDistance && {getSuppression _unit > 0.1};
private _relPos = [];
private _anim = [];

// move left
if (_dir < 250 && { RND(0.1) }) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, -120];
    _anim = ([["FastL", "FastLB"], ["TactL", "TactLB"]] select _suppression);
};

// move right
if (_dir > 80 && { RND(0.1) }) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 120];
    _anim = ([["FastR", "FastRB"], ["TactR", "TactRB"]] select _suppression);
};

// move back ~ more checks because sometimes we want the AI to move forward in CQB - nkenny
if ((_dir < 320 || { _dir > 40 }) && { speed _unit < 2 } && { !_nearDistance }) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 180];
    _anim = (["FastB", "TactB"] select _suppression);
};

// check
if (_anim isEqualTo []) then {
    _relPos = _unit getRelPos [DODGE_DISTANCE, 0];
    _anim = (["FastF", "TactF"] select _suppression);
};

// tweak dodge (in case unit is standing still!)
_relPos set [2, (getPosATL _unit) select 2];
if (((expectedDestination _unit) select 1) isEqualTo "DoNotPlan") then {_unit moveTo _relPos;};

// execute dodge
_unit setDestination [_relPos, ["doNotPlanFormation", "FORMATION PLANNED"] select (_unit call EFUNC(main,isIndoor)), true];
[_unit, _anim, true] call EFUNC(main,doGesture);

// drop stance
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (_stance isEqualTo "CROUCH" && { _nearDistance }) then {_unit setUnitPosWeak "DOWN";};

// watch distant shots
if (!_nearDistance) then {_unit doWatch _pos;};

// end
_stance
