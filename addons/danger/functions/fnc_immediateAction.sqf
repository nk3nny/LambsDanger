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
 * [bob] call lambs_danger_fnc_immediateAction;
 *
 * Public: No
*/
params ["_unit", ["_pos", [0, 0, 0]]];

// settings
private _stance = stance _unit;
private _dir = 360 - (_unit getRelDir _pos);

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!"];

// prone override
if (_stance isEqualTo "PRONE") exitWith {
    _unit playActionNow (["EvasiveLeft", "EvasiveRight"] select (_dir > 330));
    _stance
};

// ACE3 captive exit
if (
    GVAR(disableAIImediateAction)
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// callout
if (RND(0.6)) then {
    [_unit, "Combat", "UnderFireE", 125] call FUNC(doCallout);
};

private _suppression = getSuppression _unit > 0.1;
private _anim = [];

// move right
if (_dir > 250 && { random 1 > 0.1 }) then {

    if (_suppression) then {
        _anim append ["FastL", "FastLB"];
        _unit setUnitPosWeak "DOWN";
    } else {
        _anim append ["TactL", "TactLB", "WalkL"];
    };
};

// move left
if (_dir < 80 && { random 1 > 0.1 }) then {

    if (_suppression) then {
        _anim append ["FastR", "FastRB"];
        _unit setUnitPosWeak "DOWN";
    } else {
        _anim append ["TactR", "TactRB", "WalkR"];
    };
};

// move back 
if ((_dir > 320 || _dir < 40) && {_unit distance2d _pos < 20}) then {
  
  if (_suppression) then {
        _anim pushBack "FastB";
    } else {
        _anim append ["TactB", "WalkB"];
    };
};


// check
if (_anim isEqualTo []) then {
    _anim pushBack "FastF";
    _unit setUnitPosWeak "DOWN";
};

// otherwise rush left or right
[_unit, _anim, true] call FUNC(gesture);

// end
_stance