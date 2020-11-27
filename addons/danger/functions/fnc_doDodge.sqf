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
    _unit setDestination [[_unit getRelPos [3, -60], _unit getRelPos [3, 60]] select (_dir > 180), "FORMATION PLANNED", false];
    _stance
};

// ACE3 captive exit
if (
    GVAR(disableAIImediateAction)
    || {isForcedWalk _unit}
    || { !(_unit checkAIFeature "MOVE") }
    || { !(_unit checkAIFeature "PATH") }
    || { _unit getVariable ["ace_captives_isHandcuffed", false] }
    || { _unit getVariable ["ace_captives_isSurrendering", false] }
) exitWith {_stance};

// callout
if (RND(0.6)) then {
    [_unit, "Combat", "UnderFireE", 125] call EFUNC(main,doCallout);
};

// settings
private _suppression = (getSuppression _unit > 0.05) && {_unit distance2D _pos < 45};
private _relPos = getPosASL _unit;
private _anim = [];

// move left
if (_dir < 250 && { RND(0.1) }) then {
    _relPos = _unit getRelPos [3, -60];
    _anim append ([["WalkL", "WalkLB"], ["FastL", "FastLB"]] select _suppression);
};

// move right
if (_dir > 80 && { RND(0.1) }) then {
    _relPos = _unit getRelPos [3, 60];
    _anim append ([["WalkR", "WalkRB"], ["FastR", "FastRB"]] select _suppression);
};

// move back ~ more checks because sometimes we want the AI to move forward in CQB - nkenny
if ((_dir < 320 || { _dir > 40 }) && { speed _unit < 2 } && { _unit distance2D _pos < 3 }) then {
    _relPos = _unit getRelPos [3, 180];
    _anim pushBack (["WalkB", "TactB"] select _suppression); //"FastB"
};

// check
if (_anim isEqualTo []) then {
    _relPos = _unit getRelPos [3, 0];
    _anim pushBack (["WalkF", "TactF"] select _suppression); //FastF
};

// otherwise rush left or right
_unit setDestination [_relPos, "FORMATION PLANNED", false];
[_unit, _anim, true] call EFUNC(main,doGesture);

// drop stance
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};

// end
_stance
