#include "script_component.hpp"
/*
 * Author: nkenny
 * Adds debug and unique behaviour on unit fleeing
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_fleeing;
 *
 * Public: No
*/
params ["_unit", ["_distance", 55]];

// check disabled
if (
    _unit getVariable [QGVAR(disableAI), false]
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
) exitWith {false};

// variable
_unit setVariable [QGVAR(currentTask), "Fleeing"];
// this could have an event attached to it too - nkenny

// play gesture
if (RND(0.85)) then {[_unit, ["gestureHi", "gestureHiB", "gestureHiC"]] call FUNC(gesture);};
// ideally find better gestures or animations to represent things. But. It is what it is. - nkenny

// enemy near -- abandon vehicles
if (RND(0.5) && {!isNull objectParent _unit} && {canUnloadInCombat vehicle _unit} && {speed vehicle _unit < 5}) exitWith {
    [_unit] orderGetIn false;
};

// indoor just hide
if (getSuppression _unit < 0.8 && {isNull objectParent _unit} && {_unit call FUNC(indoor)}) exitWith {

    // halt unit
    doStop _unit;

    // behaviour
    _unit setBehaviour "STEALTH";

    // stance
    //_unit setUnitPosWeak selectRandom ["DOWN","DOWN","MIDDLE"]; <-- Seems to have little effect
    [_unit, ["AdjustB"], true] call FUNC(gesture);
};

// nearBuildings
private _buildings = [_unit, 12, true, true] call FUNC(findBuildings);
if !(_buildings isEqualTo []) exitWith {

    // pick a random building spot and move!
    _unit doMove ((selectRandom _buildings) vectorAdd [-1 + random 2, -1 + random 2, 0]);
};

// update path
private _enemy = _unit findNearestEnemy _unit;
if (_unit distance2d _enemy < 550) then {

    // newpos
    private _pos = (_unit getPos [(_distance * 0.33) + random (_distance * 0.66), (_enemy getDir _unit) - 35 + random 70]);

    // check for water
    if (surfaceIsWater _pos) then {_pos = getposASL _unit};

    // concealment + pick bushes and rocks if possible
    private _objs = nearestTerrainObjects [_pos, ["BUSH", "TREE", "SMALL TREE", "HIDE", "WALL", "FENCE"], 15, false, true];
    if !(_objs isEqualTo []) then {
        _pos = getPos (selectRandom _objs);
    };

    // stance based on distance
    if (_unit distance _enemy < 50) then {_unit setUnitPosWeak "MIDDLE";};
    if (_unit distance _enemy > 200) then {_unit setUnitPosWeak "DOWN";};

    // move away
    _unit doMove _pos;

};

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 Fleeing! (%2m)", side _unit,round (_unit distance (expectedDestination _unit select 0))];};

// end
true
