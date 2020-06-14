#include "script_component.hpp"
/*
 * Author: nkenny
 * Panic soldier
 *
 * Arguments:
 * 0: Unit in panic <OBJECT>
 *
 * Return Value:
 * delay in seconds
 *
 * Example:
 * [bob] call lambs_danger_fnc_panic;
 *
 * Public: No
*/
params ["_unit"];

// near enemy + ace check
if (_unit distance (_unit findNearestEnemy _unit) < 35) exitWith {3};
if ((_unit getVariable ["ace_captives_isHandcuffed", false]) || {_unit getVariable ["ace_captives_issurrendering", false]}) exitWith {22};
//if (!(_unit checkAIFeature "PATH") || {!(_unit checkAIFeature "MOVE")}) exitWith {};
[QGVAR(OnPanic), [_unit, group _unit]] call EFUNC(main,eventCallback);

// settings
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Panic", EGVAR(main,debug_functions)];

// debug
if (EGVAR(main,debug_functions)) then {format ["%1 panic! (%2)", side _unit, name _unit] call EFUNC(main,debugLog);};

// callout
if (RND(0.4)) then {
    [_unit, "Stealth", "panic", 55] call EFUNC(main,doCallout);
};

// indoor -- gesture
if (RND(0.8) || {_unit call EFUNC(main,isIndoor)}) exitWith {

    // action
    _unit forceSpeed 0;
    _unit switchMove (["AmovPercMstpSnonWnonDnon", "AmovPpneMstpSnonWnonDnon"] select (stance _unit isEqualTo "PRONE"));
     // set civilian animation - nkenny
    _unit playMoveNow selectRandom ["AmovPercMstpSnonWnonDnon_Scared", "AmovPercMstpSnonWnonDnon_Scared2"];

    // chance action
    _unit setUnitPos selectRandom ["MIDDLE", "MIDDLE", "DOWN"];

    // return
    6 + random 4;
};

// outdoor -- crawl
if (RND(0.5)) exitWith {

    // action
    _unit doWatch objNull;
    _unit setUnitPos "DOWN";
    [_unit, ["FastB", "FastLB", "FastRB"], true] call EFUNC(main,doGesture);

    // return
    6 + random 6;
};

// outdoor -- hide

// action
_unit doWatch objNull;
[_unit, _unit getPos [100, getDir _unit], 55] call FUNC(doHide);

// chance action
_unit setUnitPos selectRandom ["MIDDLE", "MIDDLE", "DOWN"];

// chance to randomly fire weapon
if ((RND(0.4)) && {!(primaryWeapon _unit isEqualTo "")}) then {
    _unit forceWeaponFire [primaryWeapon _unit, selectRandom (getArray (configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "modes"))];
};

// chance to randomly wave
if (RND(0.4)) then {
    [_unit, ["GestureCover"]] call EFUNC(main,doGesture);
};

// return
12 + random 12
