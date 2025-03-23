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
 * 5: Skip check rounds and skip shooting delay, default false <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [cannonbob, getPos angryJoe, bob] spawn lambs_wp_fnc_doArtillery;
 *
 * Public: No
*/

if !(canSuspend) exitWith { _this spawn FUNC(doArtillery); };

// init
params [["_gun", objNull], ["_pos", []], ["_caller", objNull], ["_rounds", TASK_ARTILLERY_ROUNDS], ["_accuracy", TASK_ARTILLERY_SPREAD], ["_skipCheckrounds", TASK_ARTILLERY_SKIPCHECKROUNDS]];

if (isNull _gun) exitWith {};
if (_pos isEqualTo []) exitWith {
    [QGVAR(RegisterArtillery), [_gun]] call CBA_fnc_serverEvent;
};

if (isNull _caller) then {
    _caller = _gun;
};

// gun and caller must be alive
if !(canFire _gun && {(_caller call EFUNC(main,isAlive))}) exitWith {
    [QGVAR(RegisterArtillery), [_gun]] call CBA_fnc_serverEvent;
    false
};

[QEGVAR(danger,OnArtilleryCalled), [_caller, group _caller, _gun, _pos]] call EFUNC(main,eventCallback);

// turn gun
_gun doWatch _pos;

// set group task
(group _gun) setVariable [QEGVAR(main,currentTactic), "taskArtillery", EGVAR(main,debug_functions)];

// settings
private _direction = _gun getDir _pos;
private _center = _pos getPos [_accuracy * 0.33, -_direction];
private _offset = 0;
private _salvo = 1;

// heavier artillery fires more rounds, more accurately
if !((vehicle _gun) isKindOf "StaticMortar") then {
    _rounds = _rounds * 2;
    _accuracy = _accuracy * 0.5;
};

// MRLS weapons fire almost entire magazine, but with less accuracy
private _isMLRS = _gun getVariable [QEGVAR(main,isArtilleryMRLS), false];
if (_isMLRS) then {
    _skipCheckrounds = true;
    _salvo = (gunner _gun) ammo (currentMuzzle (gunner _gun));
    _rounds = 1;
    if ((_salvo mod 6) isEqualTo 0) then {
        _rounds = floor (_salvo * 0.334);
        _salvo = 3;
    };
    if ((_salvo mod 10) isEqualTo 0) then {
        if (_salvo > 20) then {_salvo = 20;};
        _rounds = floor (_salvo * 0.2);
        _salvo = 5;
    };
    _accuracy = _accuracy * 1.5;
};

private _ammo = (getArtilleryAmmo [_gun]) param [0, ""];
private _time = _gun getArtilleryETA [_center, _ammo];

// delay ~ no delay if skipping checkRounds nkenny
private _mainStrike = [linearConversion [100, 2000, _gun distance2D _pos, 30, 90, true], 0] select _skipCheckrounds;
private _checkRounds = _time + random 35;

// debug marker list
private _markerList = [];

// caller marker
if (EGVAR(main,debug_functions)) then {
    private _markerCaller = [_caller, ["Spotter (%1M)", round (_caller distance2D _center)], "Color5_FD_F", "mil_arrow"] call EFUNC(main,dotMarker);
    _markerCaller setMarkerDir (_caller getDir _center);
    _markerList pushBack _markerCaller;
};

// delay for main strike
sleep _mainStrike;

// initate attack ~ gun and caller must be alive
if (canFire _gun && {(_caller call EFUNC(main,isAlive))}) then {

    if !(_skipCheckrounds) then {
        // check rounds
        for "_check" from 1 to (round (1 + random 1)) do {

            // randomize target location
            private _target = _center getPos [(100 + (random _accuracy * 2)) / _check, _direction + 45 - random 90];

            private _ammo = (getArtilleryAmmo [_gun]) param [0, ""];
            if (_ammo isEqualTo "") exitWith {};

            if (_target inRangeOfArtillery [[_gun], _ammo]) then {

                // check rounds barrage
                for "_i" from 1 to (round (1 + random 1)) do {
                    _gun commandArtilleryFire [_target, _ammo, 1];
                    waitUntil {unitReady _gun};
                };

                // debug
                if (EGVAR(main,debug_functions)) then {
                    private _marker = [_target, ["%1 %2 (check round barrage %3)", getText (configOf _gun >> "displayName"), groupId (group _gun), _check], "Color4_FD_F", "mil_destroy"] call EFUNC(main,dotMarker);
                    _markerList pushBack _marker;
                };

            } else {
                if (EGVAR(main,debug_functions)) then {
                    ["Error Target position is not reachable with artillery"] call EFUNC(main,debugLog);
                };
            };

            // delay
            sleep _checkRounds;
        };
    };

    // step for main barrage
    if !(canFire _gun && {_caller call EFUNC(main,isAlive)}) exitWith {};

    // caller marker
    if (EGVAR(main,debug_functions)) then {
        (_markerList select 0) setMarkerPos (getPos _caller);
        (_markerList select 0) setMarkerDir (_caller getDir _center);
        (_markerList select 0) setMarkerText format ["Spotter (%1M)", round (_caller distance2D _center)];
    };

    // main barrage
    for "_i" from 1 to _rounds do {

        // randomize target location
        private _target = _center getPos [_offset + random _accuracy, _direction + 45 - random 90];
        _offset = _offset + (_accuracy * 0.33);

        private _ammo = (getArtilleryAmmo [_gun]) param [0, ""];
        if (_ammo isEqualTo "") exitWith {};

        if (_target inRangeOfArtillery [[_gun], _ammo]) then {

            // fire round
            _gun commandArtilleryFire [_target, _ammo, _salvo];

            // debug
            if (EGVAR(main,debug_functions)) then {
                private _marker = [_target, ["%1 %2 (main salvo %3)", getText (configOf _gun >> "displayName"), groupId (group _gun), _i], "Color5_FD_F", "mil_destroy"] call EFUNC(main,dotMarker);
                _markerList pushBack _marker;
            };

            // waituntil
            if (_isMLRS) then {sleep 1.3;};
            waitUntil {unitReady _gun};

        } else {
            if (EGVAR(main,debug_functions)) then {
                ["Error Target position is not reachable with artillery"] call EFUNC(main,debugLog);
            };
        };
    };

    // debug
    if (EGVAR(main,debug_functions)) then {
        ["%1 Artillery strike complete: %2 fired %3 shots at %4m", side _gun, getText (configOf _gun >> "displayName"), _rounds * _salvo, round (_gun distance2D _pos)] call EFUNC(main,debugLog);
    };
};

// clean markers!
if (_markerList isNotEqualTo []) then {
    [
        {
            {deleteMarker _x;} forEach _this;
        }, _markerList, 60
    ] call CBA_fnc_waitAndExecute;
};

// delay
sleep _checkRounds;

// set group task
(group _gun) setVariable [QEGVAR(main,currentTactic), nil, EGVAR(main,debug_functions)];

// ready up again
[QGVAR(RegisterArtillery), [_gun]] call CBA_fnc_serverEvent;
