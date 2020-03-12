#include "script_component.hpp"
/*
 * Author: nkenny
 * Performs artillery strike at location. Artillery strike has a cone-like 'beaten zone'
 *
 * Arguments:
 * 0: Artillery unit <OBJECT>
 * 1: Position targeted <ARRAY>
 * 2: Caller of strike <OBJECT>
 * 3: Rounds fired, default 3 - 7 <NUMBER>
 * 4: Dispersion accuracy, default 100 <NUMBER>
 *
 * Return Value:
 * none
 *
 * Example:
 * [cannonbob, getpos angryJoe, bob] call lambs_wp_fnc_taskArtillery;
 *
 * Public: No
*/

// init
params ["_gun", "_pos", "_caller", ["_rounds", floor (3 + random 4)], ["_accuracy", 75]];

// Gun and caller must be alive
if (!canFire _gun || {!(_caller call EFUNC(danger,isAlive))}) exitWith {false};

// settings
private _direction = _gun getDir _pos;
private _center = _pos getPos [(_accuracy / 3) * -1, _direction];
private _offset = 0;

// higher class artillery fire more rounds? Less accurate?
if !((vehicle _gun) isKindOf "StaticMortar") then {
    _rounds = _rounds * 2;
    _accuracy = _accuracy / 2;
};

// remove from list
private _artillery = missionNamespace getVariable [QEGVAR(danger,artillery_) + str (side _gun), []];
_artillery = _artillery - [_gun];
missionNamespace setVariable [QEGVAR(danger,artillery_) + str (side _gun), _artillery, false];

// delay
private _mainStrike = linearConversion [100, 2000, (_gun distance2d _pos), 30, 90, true];
private _checkRounds = (25 + random 35);

// delay
sleep _mainStrike;

// initate attack (gun and caller must be alive)
if (canFire _gun && {_caller call EFUNC(danger,isAlive)}) then {

    // debug marker list
    private _mlist = [];

    // check rounds
    for "_check" from 1 to (1 + random 2) do {

        // check rounds barrage
        for "_i" from 1 to (1 + random 1) do {

            // Randomize target location
            private _target = _center getPos [(100 + (random _accuracy * 2)) / _check, _direction + 50 - random 100];

            private _ammo = getArtilleryAmmo [_gun] select 0;
            if (_ammo isEqualTo []) exitWith {};

            if (_target inRangeOfArtillery [[_gun], _ammo]) then {
                // Fire round
                _gun commandArtilleryFire [_target, _ammo, 1];

                // debug
                if (EGVAR(danger,debug_functions)) then {
                    private _m = [_target, format ["%1 (Check round %2)", getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"), _i], "Color4_FD_F", "hd_destroy"] call EFUNC(danger,dotMarker);
                    _mlist pushBack _m;
                };
                // waituntil
                waitUntil {unitReady _gun};
            } else {
                if (EGVAR(danger,debug_functions)) then {
                    (format ["Error Artillery Position is not Reachable with Artillery"]) call EFUNC(danger,debugLog);
                };
            };
        };

        // delay
        sleep _checkRounds;

    };

    // step for main barrage
    if !(canFire _gun && {_caller call EFUNC(danger,isAlive)}) exitWith {false};

    // Main Barrage
    for "_i" from 1 to _rounds do {

        // Randomize target location
        private _target = _center getPos [_offset + random _accuracy, _direction + 50 - random 100];
        _offset = _offset + _accuracy / 3;

        private _ammo = getArtilleryAmmo [_gun] select 0;
        if (_ammo isEqualTo []) exitWith {};

        if (_target inRangeOfArtillery [[_gun], _ammo]) then {

            // Fire round
            _gun commandArtilleryFire [_target, _ammo, 1];

            // debug
            if (EGVAR(danger,debug_functions)) then {
                private _m = [_target, format ["%1 (Round %2)", getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"), _i], "colorIndependent", "hd_destroy"] call EFUNC(danger,dotMarker);
                _mlist pushBack _m;
            };

            // waituntil
            waitUntil {unitReady _gun};
        } else {
            if (EGVAR(danger,debug_functions)) then {
                (format ["Error Artillery Position is not Reachable with Artillery"]) call EFUNC(danger,debugLog);
            };
        };
    };

    // debug
    if (EGVAR(danger,debug_functions)) then {
        format ["%1 Artillery strike complete: %2 fired %3 shots at %4m", side _gun, getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"), _rounds, round (_gun distance _pos)] call EFUNC(danger,debugLog);
    };

    // clean markers!
    if (count _mlist > 0) then {
        [
            {
                {deleteMarker _x; true} count _this
            }, _mList, 60
        ] call cba_fnc_waitAndExecute;
    };
};

// delay
sleep _checkRounds;

// re-add to list
if (!canFire _gun) exitWith {false};

// Ready up again
_gun doMove getposASL _gun;

// register gun
_artillery = missionNamespace getVariable [QEGVAR(danger,artillery_) + str (side _gun), []];
_artillery pushBackUnique _gun;
missionNamespace setVariable [QEGVAR(danger,artillery_) + str (side _gun), _artillery, false];

// end
true
