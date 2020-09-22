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
 * number - timeout for FSM
 *
 * Example:
 * [bob, angryBob] call lambs_danger_fnc_brainReact;
 *
 * Public: No
*/
params ["_unit", ["_queue", []], ["_timeout", 5]];

// commander
if !(effectiveCommander vehicle _unit isEqualTo _unit) exitWith {_timeout};
if (_queue isEqualTo []) exitWith {_timeout};

// modify priorities ~ consider adding vehicle specific changes!
private _priorities = _unit call FUNC(brainAdjust);

// pick the most relevant danger cause
private _priority = -1;
private _index = -1;
{
    private _cause = _x select 0;
    if ((_priorities select _cause) > _priority) then {
        _index = _forEachIndex;
    };
} foreach _queue;

// select cause
private _causeArray = _queue select _index;
_causeArray params ["_cause", "_dangerPos", "_dangerUntil", "_dangerCausedBy"];

// is it an attack?
private _vehicle = vehicle _unit;
private _attack = _cause in [0, 2, 8, 9] && {!(side _dangerCausedBy isEqualTo side _unit)};

// update information
if (_attack && {RND(0.4)}) then {[_unit, _dangerCausedBy] call FUNC(shareInformation);};

// vehicle type ~ Artillery
private _artillery = _vehicle getVariable [QGVAR(isArtillery), getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "artilleryScanner") > 0];
if (_artillery) exitWith {
    _vehicle setVariable [QGVAR(isArtillery), true];
    _timeout + 20
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
    _timeout + 15
};

// vehicle type ~ Armoured vehicle
private _armored = _vehicle isKindOf "Tank" || {_vehicle isKindOf "Wheeled_APC_F"};
if (_armored && {_attack}) exitWith {
    // tank assault
    if (speed _vehicle < 8) then {
        // rotate + suppression (internal to vehicle rotate)
        [{_this call FUNC(vehicleRotate)}, [_vehicle, getPosATL _dangerCausedBy], 0] call CBA_fnc_waitAndExecute;

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
                params ["_vehicle", "_dangerCausedBy", "_health"];
                _vehicle distance2D _vehicle < 20
                || {_health > damage _vehicle}
            },
            {
                params ["_vehicle"];
                _vehicle call FUNC(vehicleJink);
                if (alive _dangerCausedBy) then {_vehicle doWatch _dangerCausedBy;};
            },
            [_vehicle, _dangerCausedBy, damage _vehicle + 0.1],
            10
        ] call CBA_fnc_waitUntilAndExecute;
    };

    // timeout
    _timeout + 2 + random 9
};

// vehicle type ~ Armed Car
private _car = _vehicle isKindOf "Car_F" && {!(([typeOf _vehicle, false] call BIS_fnc_allTurrets) isEqualTo [])};
if (_car && {_attack}) exitWith {

    // suppression
    if (speed _vehicle < 8) then {
        [{_this call FUNC(vehicleSuppress)}, [_unit, ASLtoAGL eyePos _dangerCausedBy], random 1] call CBA_fnc_waitAndExecute;
    };

    // end
    _timeout + 8
};

// end
_timeout
