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
 * [bob, []] call lambs_danger_fnc_brainVehicle;
 *
 * Public: No
*/
params ["_unit", ["_queue", []]];

// timeout
private _timeout = time + 1;

// commander
private _vehicle = vehicle _unit;
if !((effectiveCommander _vehicle) isEqualTo _unit && {_unit call EFUNC(main,isAlive)}) exitWith {
    [_timeout, -2, getPosWorld _vehicle, time + GVAR(dangerUntil), objNull]
};

// no queue
if (_queue isEqualTo []) then {_queue pushBack [10, getPosWorld _vehicle, time + GVAR(dangerUntil), assignedTarget _unit];};

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
private _attack = _cause in [DANGER_ENEMYDETECTED, DANGER_ENEMYNEAR, DANGER_HIT, DANGER_CANFIRE, DANGER_BULLETCLOSE] && {(side _dangerCausedBy) isNotEqualTo (side _unit)};

// vehicle type ~ Artillery
private _artillery = _vehicle getVariable [QEGVAR(main,isArtillery), getNumber (configOf _vehicle >> "artilleryScanner") > 0];
if (_artillery) exitWith {
    _vehicle setVariable [QEGVAR(main,isArtillery), true];

    // enemies within 12-30m may cause crew to disembark!
    if (_attack && {_dangerCausedBy distanceSqr _vehicle < (144 + random 324)} && {currentCommand _unit isEqualTo ""}) then {
        (units _unit) orderGetIn false;
        _unit setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
    };
    [_timeout] + _causeArray
};

// variable
_vehicle setVariable [QEGVAR(main,isArtillery), false];

// vehicle type ~ Air
if (_vehicle isKindOf "Air") exitWith {
    [_timeout + 2 + random 2] + _causeArray
};

// vehicle type ~ Static weapon
private _static = _vehicle isKindOf "StaticWeapon";
if (_static) exitWith {

    // get out if enemy near
    if ((_unit findNearestEnemy _dangerPos) distance _vehicle < (6 + random 15)) then {
        (units _unit) orderGetIn false;
        _unit setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
    };

    // suppression
    if (_attack) then {
        [_unit, _dangerPos] call EFUNC(main,doVehicleSuppress);
        [{_this call EFUNC(main,doVehicleSuppress)}, [_unit, _dangerPos], 3] call CBA_fnc_waitAndExecute;
    };

    // end
    [_timeout + random 4] + _causeArray
};

// update information
if (_cause isEqualTo DANGER_ENEMYNEAR) then {[_unit, _dangerCausedBy] call EFUNC(main,doShareInformation);};

// select turret ammunition
if (_attack && {!EGVAR(main,disableAutonomousMunitionSwitching) && {!(isNull _dangerCausedBy) && {
    (_vehicle getVariable [QGVAR(warheadSwitchTimeout), -1]) < CBA_missionTime}}}) then {
    _vehicle setVariable [QGVAR(warheadSwitchTimeout), CBA_missionTime + 15];
    [{
        params ["_vehicle", "_dangerCausedBy"];
        private _enemyVic = vehicle _dangerCausedBy;
        if (_enemyVic isKindOf "Tank" || {
            _enemyVic isKindOf "Wheeled_APC_F"}) then {
            [_vehicle, ["AP", "TANDEMHEAT"], true] call EFUNC(main,doSelectWarhead);
        } else {
            [_vehicle] call EFUNC(main,doSelectWarhead);
        };
    }, [_vehicle, _dangerCausedBy]] call CBA_fnc_directCall;
};

// vehicle type ~ Armoured vehicle
private _armored = _vehicle isKindOf "Tank" || {_vehicle isKindOf "Wheeled_APC_F"};
if (_armored && {!isNull _dangerCausedBy}) exitWith {

    // delay + info
    private _delay = 2 + random 3;
    private _validTarget = (side _unit) isNotEqualTo (side _dangerCausedBy);
    private _distance = _vehicle distance _dangerCausedBy;

    // vehicle jink
    private _oldDamage = _vehicle getVariable [QGVAR(vehicleDamage), 0];
    if (_validTarget && {_distance < (12 + random 15) || {damage _vehicle > _oldDamage}}) exitWith {
        _vehicle setVariable [QGVAR(vehicleDamage), damage _vehicle];
        [_unit] call EFUNC(main,doVehicleJink);
        [_timeout + _delay] + _causeArray
    };

    // tank assault
    if (_attack && {speed _vehicle < 20}) then {
        // rotate
        [_vehicle, _dangerCausedBy] call EFUNC(main,doVehicleRotate);

        // assault
        if (_distance < 750 && {_dangerCausedBy isKindOf "Man"}) then {
            [
                {_this call EFUNC(main,doVehicleAssault)},
                [_unit, _dangerPos, _dangerCausedBy],
                _delay - 1
            ] call CBA_fnc_waitAndExecute;
        };
    };

    // foot infantry support ~ unload
    private _group = group _vehicle;
    private _cargo =  ((fullCrew [_vehicle, "cargo"]) apply {_x select 0});
    _cargo append ((fullCrew [_vehicle, "turret"]) apply {_x select 0});
    if (
        _validTarget
        && {_cargo isNotEqualTo []}
        && {!(terrainIntersectASL [eyePos _vehicle, (eyePos _dangerCausedBy) vectorAdd [0, 0, 3]]) || {_distance < 300}}
        && {_unit knowsAbout _dangerCausedBy > 1}
    ) then {

        // define enemy direction
        _group setFormDir (_vehicle getDir _dangerCausedBy);

        // delayed unload
        [
            {
                params [["_cargo", []], ["_side", EAST], ["_vehicle", objNull]];
                _cargo orderGetIn false;
                if (EGVAR(main,debug_functions)) then {["%1 %2 unloading %3 carried troops", _side, getText (configOf _vehicle >> "displayName"), count _cargo] call EFUNC(main,debugLog);};
            },
            [_cargo, side _group, _vehicle],
            _delay * 2
        ] call CBA_fnc_waitAndExecute;
    };

    // timeout
    [_timeout + _delay] + _causeArray
};

// vehicle type ~ Armed Car
private _car = _vehicle isKindOf "Car_F" && {([typeOf _vehicle, false] call BIS_fnc_allTurrets) isNotEqualTo []};
if (_car) exitWith {

    // speed
    private _delay = 0;
    private _slow = speed _vehicle < 30;

    // look to danger
    if (!isNull _dangerCausedBy && {_vehicle knowsAbout _dangerCausedBy > 2}) then {_vehicle doWatch ATLtoASL (_vehicle getHideFrom _dangerCausedBy);};

    // escape
    if (_slow && {_vehicle distance _dangerCausedBy < (15 + random 35)}) then {
        [_unit] call EFUNC(main,doVehicleJink);
        _slow = false;
        _delay = 3;
    };

    // suppression
    if (_attack && {_slow}) then {
        [_unit, (_unit getHideFrom _dangerCausedBy) vectorAdd [0, 0, random 1]] call EFUNC(main,doVehicleSuppress);
        [{_this call EFUNC(main,doVehicleSuppress)}, [_unit, _dangerPos], 3] call CBA_fnc_waitAndExecute;
        _delay = random 4;
    };

    // end
    [_timeout + _delay] + _causeArray
};

// Make leadership assessment as infantry
if (_unit call FUNC(isLeader)) then {
    [_unit, _dangerCausedBy] call FUNC(tactics);
};

// end
[_timeout] + _causeArray
