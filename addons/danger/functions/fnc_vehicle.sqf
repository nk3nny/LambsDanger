#include "script_component.hpp"
/*
 * Author: nkenny
 * handles vehicle brain
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 2: current action queue <ARRAY>
 *
 * Return Value:
 * timeout and danger result for FSM
 *
 * Example:
 * [bob, []] call lambs_danger_fnc_vehicle;
 *
 * Public: No
*/
params ["_unit", ["_queue", []]];

// timeout
private _timeout = time + 1;

// commander
private _vehicle = vehicle _unit;
if !((effectiveCommander _vehicle) isEqualTo _unit) exitWith {
    [_timeout + 1, -2, getPosASL _vehicle, time + GVAR(dangerUntil), objNull]
};

// no queue
if (_queue isEqualTo []) then {_queue pushBack [10, getPosASL _vehicle, time + GVAR(dangerUntil), _unit findNearestEnemy _unit];};

// modify priorities ~ consider adding vehicle specific changes!
private _priorities = _unit call FUNC(brainAdjust);

// pick the most relevant danger cause
private _priority = -1;
private _index = -1;
{
    private _cause = _x select 0;
    if ((_priorities select _cause) > _priority) then {
        _index = _forEachIndex;
        _priority = _priorities select _cause;
    };
} foreach _queue;

// select cause
private _causeArray = _queue select _index;
_causeArray params ["_cause", "_dangerPos", "", "_dangerCausedBy"]; // "_dangerUntil" may be re-implemented in the future ~ nkenny

// debug variable
_unit setVariable [QEGVAR(main,FSMDangerCauseData), _causeArray, EGVAR(main,debug_functions)];

// is it an attack?
private _attack = _cause in [DANGER_ENEMYDETECTED, DANGER_ENEMYNEAR, DANGER_HIT, DANGER_CANFIRE, DANGER_BULLETCLOSE] && {!(side _dangerCausedBy isEqualTo side _unit)};

// vehicle type ~ Artillery
private _artillery = _vehicle getVariable [QGVAR(isArtillery), getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "artilleryScanner") > 0];
if (_artillery) exitWith {
    _vehicle setVariable [QGVAR(isArtillery), true];
    [_timeout + 20] + _causeArray
};

// variable
_vehicle setVariable [QGVAR(isArtillery), false];

// vehicle type ~ Static weapon
private _static = _vehicle isKindOf "StaticWeapon";
if (_static) exitWith {

    // suppression
    if (_attack) then {
        [_unit, _dangerPos] call FUNC(vehicleSuppress);
        [{_this call FUNC(vehicleSuppress)}, [_unit, _dangerPos], 3] call CBA_fnc_waitAndExecute;
    };

    // get out if enemy near
    if ((_unit findNearestEnemy _dangerPos) distance _vehicle < (6 + random 15)) then {
        [_unit] orderGetIn false;
        _unit setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
    };

    // end
    [_timeout + random 4] + _causeArray
};

// vehicle type ~ Armed Car
private _car = _vehicle isKindOf "Car_F" && {!(([typeOf _vehicle, false] call BIS_fnc_allTurrets) isEqualTo [])};
if (_car) exitWith {

    // speed
    private _delay = 0;
    private _slow = speed _vehicle < 8;

    // look to danger
    if (!isNull _dangerCausedBy) then {_vehicle doWatch _dangerCausedBy;};

    // suppression
    if (_attack && {_slow}) then {
        [_unit, (_unit getHideFrom _dangerCausedBy) vectorAdd [0, 0, 1.2]] call FUNC(vehicleSuppress);
        [{_this call FUNC(vehicleSuppress)}, [_unit, _dangerPos], 3] call CBA_fnc_waitAndExecute;
        _delay = random 4;
    };

    // escape
    if (_slow && {_vehicle distance _dangerCausedBy < (3 + random 5)}) then {
        [_unit] call FUNC(vehicleJink);
        _delay = 3;
    };

    // end
    [_timeout + _delay] + _causeArray
};

// update information
if (_attack && {RND(0.6)}) then {[_unit, _dangerCausedBy] call FUNC(shareInformation);};

// vehicle type ~ Armoured vehicle
private _armored = _vehicle isKindOf "Tank" || {_vehicle isKindOf "Wheeled_APC_F"};
if (_armored && {!isNull _dangerCausedBy}) exitWith {

    // delay + info
    private _delay = 2 + random 2;

    // vehicle jink
    private _oldDamage = _vehicle getVariable [QGVAR(vehicleDamage), 0];
    if (_vehicle distance _dangerCausedBy < (12 + random 15) || {damage _vehicle > _oldDamage}) exitWith {
        _vehicle setVariable [QGVAR(vehicleDamage), damage _vehicle];
        _vehicle doWatch _dangerCausedBy;
        [_unit] call FUNC(vehicleJink);
        [_timeout + _delay] + _causeArray
    };

    // tank assault
    if (_attack && {speed _vehicle < 8}) then {
        // rotate + suppression (internal to vehicle rotate)
        [_vehicle, _dangerCausedBy] call FUNC(vehicleRotate);

        // assault
        if (_vehicle distance2D _dangerCausedBy < 750 && {_dangerCausedBy isKindOf "Man"}) then {
            [
                {_this call FUNC(vehicleAssault)},
                [_unit, _dangerPos, _dangerCausedBy],
                _delay - 2
            ] call CBA_fnc_waitAndExecute;
        };
    };

    // foot infantry support
    private _units = [_unit] call EFUNC(main,findReadyUnits);
    if !(_units isEqualTo []) then {[selectRandom _units, _dangerCausedBy, _units] call FUNC(tacticsAttack);};

    // timeout
    [_timeout + _delay] + _causeArray
};

// Make leadership assessment as infantry
if (_unit call FUNC(isLeader)) then {
    [_unit, _dangerCausedBy] call FUNC(tactics);
};

// end
[_timeout] + _causeArray
