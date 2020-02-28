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
[QGVAR(OnPanic), [_unit, group _unit]] call FUNC(eventCallback);

// settings
_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Panic"];

// debug
if (GVAR(debug_functions)) then {format ["%1 - %2 in panic", side _unit, name _unit] call FUNC(debugLog);};

// indoor -- gesture
if (RND(0.8) || {_unit call FUNC(indoor)}) exitWith {

    // action
    _unit forceSpeed 0;
    _unit switchMove "AmovPercMstpSnonWnonDnon"; // set civilian animation - nkenny
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
    [_unit, ["FastB", "FastLB", "FastRB"], true] call FUNC(gesture);

    // return
    6 + random 6;
};

// outdoor -- hide

// action
_unit doWatch objNull;
[_unit, _unit getPos [100, getDir _unit], 55] call FUNC(hideInside);

// chance action
_unit setUnitPos selectRandom ["MIDDLE", "MIDDLE", "DOWN"];

// chance to randomly fire weapon
if ((RND(0.4)) && {!(primaryWeapon _unit isEqualTo "")}) then {
    _unit forceWeaponFire [(weapons _unit) select 0, selectRandom (getArray (configFile >> "CfgWeapons" >> ((weapons _unit) select 0) >> "modes"))];
};

// chance to randomly wave
if (RND(0.4)) then {
    [_unit, ["GestureCover"]] call FUNC(gesture);
};

// return
12 + random 12
