#include "script_component.hpp"
/*
 * Author: nkenny
 * Adds debug and unique behaviour on unit fleeing
 *
 * Arguments:
 * 0: unit fleeing <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_fleeing;
 *
 * Public: No
*/
#define FLEE_DISTANCE 10

params ["_unit"];

// check disabled
if (
    _unit getVariable [QGVAR(disableAI), false]
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {currentCommand _unit in ["GET IN", "ACTION"]}
    || {GVAR(disableAIFleeing)}
) exitWith {false};

// check for vehicle
private _onFoot = isNull (objectParent _unit);

// variable
_unit setVariable [QGVAR(currentTask), ["Fleeing (vehicle)", "Fleeing"] select _onFoot, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];

// eventhandler
[QGVAR(OnFleeing), [_unit, group _unit]] call EFUNC(main,eventCallback);

// Abandon vehicles in need!
if (
    RND(0.5)
    && {!_onFoot}
    && {canUnloadInCombat (vehicle _unit)}
    && {(speed (vehicle _unit)) < 3}
    && {isTouchingGround vehicle _unit}
) exitWith {
    [_unit] orderGetIn false;
    _unit setSuppression 1;  // prevents instant laser aim - nkenny
    false
};

// no further action in vehicle
if (!_onFoot) exitWith {false};

// enemy
private _enemy = _unit findNearestEnemy _unit;

// get destination
private _pos = (expectedDestination _unit) select 0;
private _eyePos = eyePos _unit;

// on foot and seen by enemy
private _onFootAndSeen = (_unit distance2D _enemy) < 100 || {getSuppression _unit > 0.9} || {!(terrainIntersectASL [_eyePos, eyePos _enemy])};
if (_onFootAndSeen) then {

    // variable
    _unit setVariable [QGVAR(currentTask), "Fleeing (enemy near)", EGVAR(main,debug_functions)];

    // callout
    if (RND(0.4) && {getSuppression _unit > 0.5}) then {
        [_unit, "Stealth", "panic", 55] call EFUNC(main,doCallout);
    };

    // inside or under cover!
    if ((getSuppression _unit < 0.2) && {lineIntersects [_eyePos, _eyePos vectorAdd [0, 0, 10], _unit] || {_unit distance2D _pos < 1}}) exitWith {
        if (RND(0.9)) then {[_unit, "treated", true] call EFUNC(main,doGesture);};
        doStop _unit;
    };

    // speed
    _unit forceSpeed -1;

    // update pos
    private _cover = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE", "ROCK", "WALL", "FENCE"], GVAR(searchForHide), false, true];

    // force anim
    if (_cover isEqualTo [] || {getSuppression _unit > 0.8}) exitWith {
        private _direction = _unit getRelDir _pos;
        private _relPos = [];
        private _anim = call {
            if (_direction > 315) exitWith {_relPos = _unit getRelPos [FLEE_DISTANCE, -15];["SlowF", "SlowLF"]};
            if (_direction > 225) exitWith {_relPos = _unit getRelPos [FLEE_DISTANCE, -60];["SlowL", "SlowLF"]};
            if (_direction > 135) exitWith {_relPos = _unit getRelPos [FLEE_DISTANCE, 180];["SlowB"]};
            if (_direction > 45) exitWith {_relPos = _unit getRelPos [FLEE_DISTANCE, 60];["SlowR", "SlowRF"]};
            _relPos = _unit getRelPos [FLEE_DISTANCE, 15];
            ["SlowF", "SlowRF"]
        };

        // dodge
        if (((expectedDestination _unit) select 1) isEqualTo "DoNotPlan") then {_unit doMove _relPos;};

        // force anim
        [_unit, _anim, true] call EFUNC(main,doGesture);
        _unit setDestination [_relPos, ["DoNotPlanFormation", "FORMATION PLANNED"] select (_unit call EFUNC(main,isIndoor)), false];
    };

    // hide
    private _buildings = [_unit, GVAR(searchForHide) * 2, true, true] call EFUNC(main,findBuildings);
    _buildings append (_cover apply {getPosATL _x});
    if !(_buildings isEqualTo []) then {
        _unit doMove (_buildings select 0);
    };
} else {
    // follow self! ~ bugfix which prevents untis from getting stuck in fleeing loop inside fsm. - nkenny
    _unit doFollow (leader _unit);
};

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 Fleeing! %2 (%3m)", side _unit, name _unit, round (_unit distance (expectedDestination _unit select 0))] call EFUNC(main,debugLog);
};

// end
true
