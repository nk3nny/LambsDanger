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
_unit setVariable [QGVAR(currentTask), "Dodge!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
// prone override
if (_stance isEqualTo "PRONE" && {!(_unit call FUNC(indoor))}) exitWith {
    [_unit, [["EvasiveLeft"], ["EvasiveRight"]] select (_dir > 330), true] call FUNC(gesture);
    _stance
};

// ACE3 captive exit
if (
    GVAR(disableAIImediateAction)
    || {!(_unit checkAIFeature "MOVE")} // not stopping with PATH for gameplay reasons -nkenny
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {_stance};

// callout
if (RND(0.6)) then {
    [_unit, "Combat", "UnderFireE", 125] call FUNC(doCallout);
};

// reset speed
_unit forceSpeed -1;

private _suppression = getSuppression _unit > 0.55;
private _anim = [];

// move right
if (_dir > 250 && { RND(0.1) }) then {

    if (_suppression) then {
        _anim append ["FastL", "FastLB"];
        _unit setUnitPosWeak "DOWN";
    } else {
        _anim append ["TactL", "TactLB", "WalkL"];
    };
};

// move left
if (_dir < 80 && { RND(0.1) }) then {

    if (_suppression) then {
        _anim append ["FastR", "FastRB"];
        _unit setUnitPosWeak "DOWN";
    } else {
        _anim append ["TactR", "TactRB", "WalkR"];
    };
};

// move back
if ((_dir > 320 || _dir < 40) && {speed _unit < 8} && {_unit distance2d _pos < 20}) then {

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
