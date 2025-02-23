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
 * [bob] call lambs_main_fnc_fleeing;
 *
 * Public: No
*/
#define SEARCH_FOR_HIDE 12
#define SEARCH_FOR_BUILDING 8

params ["_unit"];

// check disabled
if (
    _unit getVariable [QEGVAR(danger,disableAI), false]
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {GVAR(disableAIFleeing)}
    || {(currentCommand _unit) in ["GET IN", "ACTION", "REARM", "HEAL"]}
) exitWith {false};

// check for vehicle
private _onFoot = isNull (objectParent _unit);

// variable
_unit setVariable [QGVAR(currentTask), ["Fleeing (vehicle)", "Fleeing"] select _onFoot, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];

// eventhandler
[QGVAR(OnFleeing), [_unit, group _unit]] call FUNC(eventCallback);


// Vehicle sub-actions
if (!_onFoot) exitWith {

    // get vehicle
    private _vehicle = vehicle _unit;
    private _changeSeats = (speed _vehicle) < 3 && { isTouchingGround _vehicle };

    // move into gunners seat ~ Enemy Detected, commander alive but gunner dead
    private _candidate = call {
        if ((commander _vehicle) call EFUNC(main,isAlive)) exitWith {commander _vehicle};
        if ((driver _vehicle) call EFUNC(main,isAlive)) exitWith {driver _vehicle};
        objNull
    };

    if (
        _changeSeats
        && {!isNull _candidate}
        && {someAmmo _vehicle}
        && {!((gunner _vehicle) call EFUNC(main,isAlive))}
    ) exitWith {
        if (_vehicle isKindOf "Tank") then {
            _candidate assignAsGunner _vehicle;
        } else {
            _candidate action ["Eject", _vehicle];
            _candidate assignAsGunner _vehicle;
            [
                {
                    params ["_unit", "_vehicle"];
                    if (_unit call EFUNC(main,isAlive)) then {
                        _unit setDir (_unit getDir _vehicle);
                        _unit action ["getInGunner", _vehicle];
                    };
                }, [_candidate, _vehicle], 0.8
            ] call CBA_fnc_waitAndExecute;
        };
        false
    };

    // Abandon vehicles in need!
    private _abandonChance = ( (1 - damage _vehicle) + (_unit skillFinal "courage") ) * 0.5;
    if (!canMove _vehicle || {fuel _vehicle < 0.1} || {_vehicle isKindOf "StaticWeapon"}) then { _abandonChance = _abandonChance * 0.25 };
    if (someAmmo _vehicle) then { _abandonChance = _abandonChance * 1.3 };
    if (
        RND(_abandonChance)
        && {canUnloadInCombat _vehicle || (damage _vehicle) > 0.9}
        && {_changeSeats}
    ) exitWith {
        if (_abandonChance < 0.5) then {_unit leaveVehicle _vehicle;};
        [_unit] orderGetIn false;
        _unit setSuppression 1;  // prevents instant laser aim - nkenny
        false
    };

    // exit
    false
};


// enemy
private _enemy = _unit findNearestEnemy _unit;
private _distance2D = _unit distance2D _enemy;

// get destination
private _eyePos = eyePos _unit;
private _suppression = getSuppression _unit;

// on foot and seen by enemy
private _onFootAndSeen = _distance2D < 75 || {_suppression > 0.9} || {([objNull, "VIEW", objNull] checkVisibility [_eyePos, eyePos _enemy]) > 0.01};
if (_onFootAndSeen) then {

    // variable
    _unit setVariable [QGVAR(currentTask), "Fleeing (enemy near)", GVAR(debug_functions)];
    _unit setVariable [QGVAR(currentTarget), _enemy, GVAR(debug_functions)];

    // ACE3 ~ prevents stopping to heal!
    _unit setVariable ["ace_medical_ai_lastFired", CBA_missionTime];

    // callout
    if (RND(0.4) && {_suppression > 0.5}) then {
        [_unit, "Stealth", "panic", 55] call FUNC(doCallout);
    };

    // calm and inside or under cover!
    if ((_suppression < 0.2) && {lineIntersects [_eyePos, _eyePos vectorAdd [0, 0, 10], _unit] || {_distance2D < 15}}) exitWith {
        _unit setUnitPos "DOWN";// ~ this forces unit stance which may override mission maker. The effect is good however - nkenny
        doStop _unit;
    };

    // find nearby cover
    private _cover = nearestTerrainObjects [_unit, ["BUSH", "TREE", "HIDE", "ROCK", "WALL", "FENCE"], SEARCH_FOR_HIDE, false, true];

    // speed and stance (based on cover)
    _unit forceSpeed -1;
    _unit setUnitPos (["MIDDLE", "DOWN"] select (_suppression > 0 || {_cover isNotEqualTo []})); // test nkenny

    // update cover
    _cover = _cover apply {_x getPos [1.5, _enemy getDir _x]};

    // find buildings to hide
    if (_distance2D > 30) then {
        private _buildings = [_unit, SEARCH_FOR_BUILDING, true, true] call FUNC(findBuildings);
        _cover append _buildings;
    };

    // execute move
    if (_cover isNotEqualTo [] && {_distance2D > 5}) then {
        _unit doMove selectRandom _cover;
    };

} else {
    // follow self! ~ bugfix which prevents units from getting stuck in fleeing loop inside fsm. - nkenny
    _unit doFollow (leader _unit);

    // reset
    _unit setUnitPos "AUTO";
    _unit setUnitPosWeak "MIDDLE";
};

// debug
if (GVAR(debug_functions)) then {
    [
        "%1 Fleeing! %2 (%3m %4%5%6)",
        side _unit,
        name _unit,
        [format ["Enemy @ %1", round _distance2D], format ["Destination @ %1", round (_unit distance2D ((expectedDestination _unit) select 0))]] select (isNull _enemy),
        ["", "- suppressed "] select (_suppression > 0),
        ["", "- inside "] select (lineIntersects [_eyePos, _eyePos vectorAdd [0, 0, 10], _unit]),
        ["", "- spotted "] select (([objNull, "VIEW", objNull] checkVisibility [_eyePos, eyePos _enemy]) > 0.01)
    ] call FUNC(debugLog);
};

// end
true
