#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays an immediate reaction unit getting hit (internal to FSM)
 *
 * Arguments:
 * 0: unit hit <OBJECT>
 * 1: position of danger <ARRAY> or <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, angryJoe] call lambs_main_fnc_doDodge;
 *
 * Public: No
*/

params ["_unit", ["_pos", [0, 0, 0]]];

// ACE3 captive exit
if (
    GVAR(disableAIDodge)
    || {!(_unit checkAIFeature "MOVE")}
) exitWith {false};

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// settings
private _stance = stance _unit;
private _dir = _unit getRelDir _pos;
private _still = (speed _unit) isEqualTo 0;
private _allowMove = _unit checkAIFeature "PATH";

// callout
if (RND(0.85)) then {
    [_unit, "Combat", selectRandom ["UnderFireE", "EndangeredE"]] call FUNC(doCallout);
};

// prone override
if (_stance isEqualTo "PRONE") exitWith {

    // over open sky -- roll left or right
    if (_still && _allowMove && {!(lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 7]])}) exitWith {
        [_unit, [["EvasiveLeft", "FastL"], ["EvasiveRight", "FastR"]] select (_dir > 180), true] call FUNC(doGesture);
        true
    };

    // enemy forward - chance to do a peek
    if (RND(0.7) && ( getSuppression _unit < 0.5 ) && { _dir > 320 ||  _dir < 40 }) then {
        [_unit, "Up", false] call FUNC(doGesture);
    };

    // otherwise just exit
    true
};

// settings
private _distanceSqr = _unit distanceSqr _pos;

// Reset stance hard stance changes
[_unit, true] call FUNC(doStanceReset);

// chose anim
private _anim = call {

    // hard dodge ~ 300m
    if (_still && _allowMove && _distanceSqr > 90000) exitWith {
        _unit setUnitPos "DOWN";
        [["FastL", "FastR"] select (_dir > 180), ["FastB", "FastF"] select (_dir > 90 && _dir < 270)]
    };

    // drop stance
    if (_stance isEqualTo "STAND") exitWith {
        _unit setUnitPos "MIDDLE";
        ["Crouch", "Lying"] select (_dir > 110 && _dir < 250)
    };

    // drop down ~ 22m
    if (_distanceSqr > 484 || isHidden _unit) exitWith {
        _unit setUnitPos "DOWN";
        "Lying"
    };

    // default - forced paths peek up ~ 25m
    [["FastF", "Down"] select (_distanceSqr < 25), "Up"] select ((insideBuilding _unit) isEqualTo 1 || !_allowMove)
};

// execute dodge
[_unit, _anim, true] call FUNC(doGesture);

// end
true
