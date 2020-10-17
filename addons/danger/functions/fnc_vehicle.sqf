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
private _timeout = time + 5;

// commander
if (_queue isEqualTo []|| {!(effectiveCommander vehicle _unit isEqualTo _unit)}) exitWith {
    [_timeout, 10, getPosASL _unit, time + GVAR(dangerUntil), objNull]
};

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
private _vehicle = vehicle _unit;
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
        [{_this call FUNC(vehicleSuppress)}, [_unit, _dangerPos], random 1] call CBA_fnc_waitAndExecute;
    };

    // get out if enemy near
    if ((_unit findNearestEnemy _dangerPos) distance _unit < (6 + random 15)) then {
        [_unit] orderGetIn false;
        _unit setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
    };

    // end
    [_timeout + 3] + _causeArray
};

// vehicle type ~ Armed Car
private _car = _vehicle isKindOf "Car_F" && {!(([typeOf _vehicle, false] call BIS_fnc_allTurrets) isEqualTo [])};
if (_car && {_attack}) exitWith {

    // suppression
    if (speed _vehicle < 8) then {
        _vehicle doWatch _dangerPos;
        [{_this call FUNC(vehicleSuppress)}, [_unit, (_unit getHideFrom _dangerCausedBy) vectorAdd [0, 0, 1.2]], random 1] call CBA_fnc_waitAndExecute;
    };

    // end
    [_timeout] + _causeArray
};

// update information
if (_attack && {RND(0.6)}) then {[_unit, _dangerCausedBy] call FUNC(shareInformation);};

// vehicle type ~ Armoured vehicle
private _armored = _vehicle isKindOf "Tank" || {_vehicle isKindOf "Wheeled_APC_F"};
if (_armored && {_attack}) exitWith {
    // delay
    private _delay = 2 + random 9;

    // tank assault
    if (speed _vehicle < 8) then {
        // rotate + suppression (internal to vehicle rotate)
        [{_this call FUNC(vehicleRotate)}, [_vehicle, _unit getHideFrom _dangerCausedBy], 0] call CBA_fnc_waitAndExecute;

        // assault
        if (_vehicle distance2D _dangerCausedBy < 550 && {_dangerCausedBy isKindOf "Man"}) then {
            [
                {_this call FUNC(vehicleAssault)},
                [_unit, _dangerPos, _dangerCausedBy],
                3 + random 3
            ] call CBA_fnc_waitAndExecute;
        };
    };

    // vehicle Jink
    if (!isNull _dangerCausedBy) then {
        [
            {
                params ["_vehicle", "_dangerCausedBy", "_damage"];
                _vehicle distance2D _dangerCausedBy < 18
                || {_damage > (damage _vehicle + 0.1)}
            },
            {
                params ["_vehicle", "_dangerCausedBy"];
                [effectiveCommander _vehicle] call FUNC(vehicleJink);
                if (_dangerCausedBy call EFUNC(main,isAlive)) then {_vehicle doWatch _dangerCausedBy;};
            },
            [_vehicle, _dangerCausedBy, damage _vehicle],
            5 +_delay
        ] call CBA_fnc_waitUntilAndExecute;
    };

    // timeout
    [_timeout + _delay] + _causeArray;
};

// end
[_timeout] + _causeArray
