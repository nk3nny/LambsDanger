#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays an immediate reaction unit getting hit (Internal to FSM)
 *
 * Arguments:
 * 0: Unit hit <OBJECT>
 * 1: Current stance of unit, default none <STRING>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_immediateAction;
 *
 * Public: No
*/
params ["_unit", ["_stance", ""],"_anim"];

if (_stance isEqualTo "") then {
    _stance = stance _unit;
};

// prone -- exit quickly
if (_stance isEqualTo "PRONE") exitWith {
    [_unit, ["EvasiveLeft", "EvasiveRight"], true] call FUNC(gesture);
    true
};

// Not standing -- No weapon --  ACE3 captive exit
if (
    !(_stance isEqualTo "STAND")
    || {primaryWeapon _unit isEqualTo ""}
    || {!(primaryWeapon _unit isEqualTo currentWeapon _unit)}
    || {!canMove _unit}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// stopped or path/move disabled
//if (stopped _unit) exitWith {false};

// standing to rush
if (RND(0.5)) exitWith {
    _anim = selectRandom [
        "AmovPercMrunSrasWrflDfl_AmovPercMrunSrasWrflDf",
        "AmovPercMrunSrasWrflDfl_AmovPercMrunSrasWrflDfr",
        "AmovPercMrunSrasWrflDfr_AmovPercMrunSrasWrflDf",
        "AmovPercMrunSrasWrflDfr_AmovPercMrunSrasWrflDfl"
    ];
    _unit switchMove _anim;
    true
};

// standing to crouched
_unit setUnitPos "MIDDLE";
_anim = selectRandom [
    "AmovPercMevaSrasWrflDf_AmovPknlMstpSrasWrflDnon",
    "AmovPercMevaSrasWrflDfl_AmovPknlMstpSrasWrflDnon",
    "AmovPercMevaSrasWrflDfr_AmovPknlMstpSrasWrflDnon"
];
_unit switchMove _anim;

// end
true
