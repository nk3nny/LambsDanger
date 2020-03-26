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
    || {GVAR(disableAIFleeing)}
) exitWith {false};

// check for vehicle
private _onFoot = isNull objectParent _unit;

// variable
_unit setVariable [QGVAR(currentTask), ["Fleeing (vehicle)", "Fleeing"] select _onFoot];
// this could have an event attached to it too - nkenny

// Abandon vehicles in need!
if (RND(0.5) && {!_onFoot} && {canUnloadInCombat vehicle _unit} && {speed vehicle _unit < 3} && {isTouchingGround vehicle _unit}) exitWith {
    [_unit] orderGetIn false;
    _unit setSuppression 2;  // prevents instant laser aim - nkenny
};

// no further action in vehicle
if (!_onFoot) exitWith {};

// play gesture
if (RND(0.85)) then {[_unit, ["GestureCover", "GestureCeaseFire"]] call FUNC(gesture);};
// ideally find better gestures or animations to represent things. But. It is what it is. - nkenny

// indoor just hide
if (getSuppression _unit < 0.2 && {_unit call FUNC(indoor)}) exitWith {

    // halt unit
    //doStop _unit;
    _unit forceSpeed 1;

    // behaviour
    //_unit setBehaviour "STEALTH";

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
if (_unit distance2d _enemy < 120) then {

    // newpos
    private _pos = (_unit getPos [(_distance * 0.33) + random (_distance * 0.66), (_enemy getDir _unit) - 35 + random 70]);

    // check for water
    if (surfaceIsWater _pos) then {_pos = getPosASL _unit};

    // concealment + pick bushes and rocks if possible
    private _objs = nearestTerrainObjects [_pos, ["BUSH", "TREE", "SMALL TREE", "HIDE", "WALL", "FENCE"], 15, false, true];
    if !(_objs isEqualTo []) then {
        _pos = getPos (selectRandom _objs);
    };

    // move away
    _unit doMove _pos;

};

// debug
if (GVAR(debug_functions)) then {format ["%1 Fleeing! (%2m)", side _unit,round (_unit distance (expectedDestination _unit select 0))] call FUNC(debugLog);};

// end
true
