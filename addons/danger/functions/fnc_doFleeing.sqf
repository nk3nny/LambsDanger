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
params ["_unit"];

// check disabled
if (
    _unit getVariable [QGVAR(disableAI), false]
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {currentCommand _unit in ["GET IN", "ACTION", "REARM", "HEAL"]}
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
private _distance2D = _unit distance2D _enemy;

// get destination
private _pos = (expectedDestination _unit) select 0;
private _eyePos = eyePos _unit;
private _suppression = getSuppression _unit;

// on foot and seen by enemy
private _onFootAndSeen = _distance2D < 75 || {_suppression > 0.9} || {([objNull, "VIEW", objNull] checkVisibility [_eyePos, eyePos _enemy]) > 0};
if (_onFootAndSeen) then {

    // variable
    _unit setVariable [QGVAR(currentTask), "Fleeing (enemy near)", EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTarget), _enemy, EGVAR(main,debug_functions)];

    // ACE3 ~ prevents stopping to heal!
    _unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];

    // callout
    if (RND(0.4) && {_suppression > 0.5}) then {
        [_unit, "Stealth", "panic", 55] call EFUNC(main,doCallout);
    };

    // calm and inside or under cover!
    if ((_suppression < 0.2) && {lineIntersects [_eyePos, _eyePos vectorAdd [0, 0, 10], _unit] || {_distance2D < random 5}}) exitWith {
        _unit setUnitPos "DOWN";// ~ this forces unit stance which may override mission maker. The effect is good however - nkenny
        doStop _unit;
    };

    // find nearby cover
    private _cover = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE", "ROCK", "WALL", "FENCE"], GVAR(searchForHide), false, true];

    // speed and stance (based on cover)
    _unit forceSpeed -1;
    _unit setUnitPos (["MIDDLE", "DOWN"] select (_suppression > 0 || {!(_cover isEqualTo [])})); // test nkenny

    // find buildings to hide
    private _buildings = [_unit, GVAR(searchForHide) * 2, true, true] call EFUNC(main,findBuildings);
    if (!(_buildings isEqualTo []) && {_distance2D > random 5}) then {
        _unit doMove selectRandom _buildings;
    };

} else {
    // follow self! ~ bugfix which prevents untis from getting stuck in fleeing loop inside fsm. - nkenny
    _unit doFollow (leader _unit);

    // reset
    _unit setUnitPos "AUTO";
};

// debug
if (EGVAR(main,debug_functions)) then {
    [
        "%1 Fleeing! %2 (%3m %4%5%6)",
        side _unit,
        name _unit,
        [format ["Enemy @ %1", round _distance2D], format ["Destination @ %1", round (_unit distance2D _pos)]] select (isNull _enemy),
        ["", "- suppressed "] select (_suppression > 0),
        ["", "- inside "] select (lineIntersects [_eyePos, _eyePos vectorAdd [0, 0, 10], _unit]),
        ["", "- spotted "] select (([objNull, "VIEW", objNull] checkVisibility [_eyePos, eyePos _enemy]) > 0)
    ] call EFUNC(main,debugLog);
};

// end
true
