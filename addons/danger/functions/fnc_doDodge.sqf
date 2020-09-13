#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays an immediate reaction unit getting hit (Internal to FSM)
 *
 * Arguments:
 * 0: Unit hit <OBJECT>
 * 1: Position of dange <ARRAY>
 *
 * Return Value:
 * stance
 *
 * Example:
 * [bob] call lambs_danger_fnc_doDodge;
 *
 * Public: No
*/
params ["_unit", ["_pos", [0, 0, 0]]];

// settings
private _stance = stance _unit;
private _dir = 360 - (_unit getRelDir _pos);

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!", EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];

// prone override
if (_stance isEqualTo "PRONE" && {!(_unit call EFUNC(main,isIndoor))}) exitWith {
    [_unit, ["EvasiveLeft", "EvasiveRight"] select (_dir > 330), true] call EFUNC(main,doGesture);
    _unit setDestination [[_unit getRelPos [3, -60], _unit getRelPos [3, 60]] select (_dir > 330), "FORMATION PLANNED", false];
    _stance
};

// ACE3 captive exit
if (
    GVAR(disableAIImediateAction)
    || {!(_unit checkAIFeature "MOVE")}
    || {!(_unit checkAIFeature "PATH")}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {_stance};

// callout
if (RND(0.6)) then {
    [_unit, "Combat", "UnderFireE", 125] call EFUNC(main,doCallout);
};

// settings
private _suppression = (getSuppression _unit > 0.05) && {_unit distance2D _pos < 45};
private _relPos = getpos _unit;
private _anim = [];

// move left
if (_dir > 250 && { random 1 > 0.1 }) then {
    _relPos = _unit getRelPos [2, -60];
    _anim append ([["WalkL", "WalkLB"], ["FastL", "FastLB"]] select _suppression);
};

// move right
if (_dir < 80 && { random 1 > 0.1 }) then {
    _relPos = _unit getRelPos [2, 60];
    _anim append ([["WalkR", "WalkRB"], ["FastR", "FastRB"]] select _suppression);
};

// move back
if ((_dir > 320 || { _dir < 40 }) && { speed _unit < 2 } && { _unit distance2D _pos < 20 }) then {
    _relPos = _unit getRelPos [1, 180];
    _anim pushBack (["WalkB", "FastB"] select _suppression);
};

// check
if (_anim isEqualTo []) then {
    _relPos = _unit getRelPos [3, 0];
    _anim pushBack (["WalkF", "WalkF"] select _suppression); //FastF
};

// otherwise rush left or right
_unit setDestination [_relPos, "FORMATION PLANNED", false];    // <-- check to see if this fixes running in place bug. - nk
[_unit, _anim, true] call EFUNC(main,doGesture);

// end
_stance
