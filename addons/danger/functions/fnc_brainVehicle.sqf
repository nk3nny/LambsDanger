#include "script_component.hpp"
/*
 * Author: nkenny
 * handles vehicle brain
 *
 * Arguments:
 * 0: unit doing the evaluation <OBJECT>
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
} forEach _queue;

// select cause
private _causeArray = _queue select _index;
_causeArray params ["_cause", "_dangerPos", "", "_dangerCausedBy"]; // "_dangerUntil" may be re-implemented in the future ~ nkenny

// debug variable
_unit setVariable [QEGVAR(main,FSMDangerCauseData), _causeArray, EGVAR(main,debug_functions)];

// is it an attack?
private _attack = _cause in [DANGER_ENEMYDETECTED, DANGER_ENEMYNEAR, DANGER_HIT, DANGER_CANFIRE, DANGER_BULLETCLOSE] && {(side _dangerCausedBy) isNotEqualTo (side _unit)} && {!isNull _dangerCausedBy} && {(behaviour _unit) isEqualTo "COMBAT"};

// update dangerPos if attacking. Check that the position is not too far above, or below ground.
if (_attack) then {
    _dangerPos = _unit getHideFrom _dangerCausedBy;
    if (_dangerPos isEqualTo [0, 0, 0]) exitWith {_attack = false;};
    _dangerPos = ASLToAGL (ATLToASL _dangerPos);
    if ((_dangerPos select 2) > 6 || {(_dangerPos select 2) < 2}) then {_dangerPos set [2, 1]};
};

// vehicle type ~ Artillery
private _artillery = _vehicle getVariable [QEGVAR(main,isArtillery), getNumber (configOf _vehicle >> "artilleryScanner") > 0];
if (_artillery) exitWith {
    _vehicle setVariable [QEGVAR(main,isArtillery), true];

    // enemies within 12-30m may cause crew to disembark!
    if (
        _attack
        && {_dangerCausedBy distance _vehicle < (12 + random 18)}
        && {currentCommand _unit isEqualTo ""}
        && {!(_vehicle isKindOf "Tank" && {count (allTurrets [_vehicle, false]) > 1})}
    ) then {
        private _vehicleCrew = crew _vehicle;
        _vehicleCrew orderGetIn false;
        {
            _x setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
        } forEach _vehicleCrew; // There may be more than one unit in vehicle
        [_unit, "Combat", "Eject", 125] call EFUNC(main,doCallout);
    };

    // mortars fire rounds
    private _mortarTime = _vehicle getVariable [QEGVAR(main,mortarTime), 0];
    if (_attack && {_vehicle isKindOf "StaticMortar"} && {unitReady _vehicle} && {_mortarTime < time} && {isTouchingGround _dangerCausedBy}) then {

        // delay
        _timeout = _timeout + 2;
        _vehicle doWatch _dangerPos;

        // check ammo & range
        private _ammo = getArtilleryAmmo [_vehicle];
        private _shell = _ammo param [0, ""];
        if (_shell isEqualTo "") exitWith {};
        private _flareIndex = _ammo findIf {"flare" in (toLowerANSI _x)};
        private _smokeIndex = _ammo findIf {"smoke" in (toLowerANSI _x)};

        // check friendlies
        private _dangerRound = false;
        private _repeatRounds = true;
        if ( RND(0.8) || { ([_unit, _dangerPos, 150] call EFUNC(main,findNearbyFriendlies)) isNotEqualTo [] } ) then {
             if (_smokeIndex isEqualTo -1) then {
                _dangerRound = true;
             } else {
                _shell = _ammo select _smokeIndex;
                _repeatRounds = RND(0.5);
             };
        };

        // check night
        if ( RND(0.2) && { _unit call EFUNC(main,isNight) } && { _flareIndex isNotEqualTo -1 } ) then {
            _dangerPos = _dangerPos getPos [-50 + random 100, (_vehicle getDir _dangerPos) - 45 + random 90];
            _shell = _ammo select _flareIndex;
            _dangerRound = false;
            _repeatRounds = false;
        };

        // check for issues
        if ( _dangerRound || { !(_dangerPos inRangeOfArtillery [[_vehicle], _shell]) } ) exitWith {};

        // execute fire command
        _vehicle commandArtilleryFire [_dangerPos getPos [30 + random 80, (_dangerPos getDir _vehicle) - 10 + random 20], _shell, 1 + random 2];
        _vehicle setVariable [QEGVAR(main,mortarTime), time + 24 + random 66];
        _unit setVariable [QEGVAR(main,currentTask), "Mortar Fire", EGVAR(main,debug_functions)];
        if (_repeatRounds) then {
            [
                {
                    params [["_vehicle", objNull], ["_dangerPos", [0, 0, 0]], ["_shell", ""]];
                    if ( canFire _vehicle && { unitReady _vehicle } ) then {
                        _vehicle commandArtilleryFire [_dangerPos, _shell, ( 2 + random 1 ) min ((gunner _vehicle) ammo (currentMuzzle (gunner _vehicle)))];
                    };
                },
                [_vehicle, _dangerPos, _shell],
                18 + random 6
            ] call CBA_fnc_waitAndExecute;
        };
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
if (_vehicle isKindOf "StaticWeapon") exitWith {

    // get out if enemy near OR out of ammunition
    if ((count (magazines _vehicle)) isEqualTo 0 || {(_unit findNearestEnemy _dangerPos) distance _vehicle < (6 + random 15)}) then {
        private _vehicleCrew = crew _vehicle;
        _vehicleCrew orderGetIn false;
        [_unit, "Combat", "Eject"] call EFUNC(main,doCallout);
        {
            _x setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
        } forEach _vehicleCrew; // There may be more than one unit in vehicle
    } else {
        // suppression
        if (_attack) then {
            [_unit, _dangerPos] call EFUNC(main,doVehicleSuppress);
            [{_this call EFUNC(main,doVehicleSuppress)}, [_unit, _dangerPos], 3] call CBA_fnc_waitAndExecute;
        };
    };

    // end
    [_timeout + random 4] + _causeArray
};

// Make leadership assessment as infantry
private _leader = leader _unit;
if (((vehicle _leader) isEqualTo _vehicle) && {_leader call FUNC(isLeader)}) then {
    [_leader, _dangerCausedBy] call FUNC(tactics);
};

// update information
if (_cause in [DANGER_ENEMYNEAR, DANGER_SCREAM]) then {[_unit, _dangerCausedBy] call EFUNC(main,doShareInformation);};

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

    // keep cargo aboard!
    _vehicle setUnloadInCombat [false, false];

    // foot infantry support ~ unload
    private _group = group _vehicle;
    private _cargo =  ((fullCrew [_vehicle, "cargo"]) apply {_x select 0});
    _cargo append ((fullCrew [_vehicle, "turret"] select {_x select 4}) apply {_x select 0});
    if (
        _validTarget
        && {_cargo isNotEqualTo []}
        && {speed _vehicle < 10}
        && {_distance < 350}
        && {_unit knowsAbout _dangerCausedBy > 2 || {_distance < 220}}
        && {!(terrainIntersectASL [eyePos _vehicle, (eyePos _dangerCausedBy) vectorAdd [0, 0, 2]]) || {_distance < 200}}
    ) exitWith {

        // use smoke if available
        private _time = _vehicle getVariable [QEGVAR(main,smokescreenTime), 0];
        if (RND(0.6) && {_time < time}) then {
            (commander _vehicle) forceWeaponFire ["SmokeLauncher", "SmokeLauncher"];
            _vehicle setVariable [QEGVAR(main,smokescreenTime), time + 30 + random 20];
        };

        // define enemy direction
        _group setFormDir (_vehicle getDir _dangerCausedBy);

        // delayed unload
        _unit setVariable [QEGVAR(main,currentTask), "Dismounting troops", EGVAR(main,debug_functions)];
        [
            {
                params [["_cargo", []], ["_side", east], ["_vehicle", objNull]];
                {_x action ["Eject", _vehicle];} forEach _cargo;
                [selectRandom _cargo, "Combat", "Dismount"] call EFUNC(main,doCallout);
                _cargo allowGetIn false;
                if (EGVAR(main,debug_functions)) then {["%1 %2 unloading %3 carried troops", _side, getText (configOf _vehicle >> "displayName"), count _cargo] call EFUNC(main,debugLog);};
                _vehicle doMove (getPosASL _vehicle);
            },
            [_cargo, side _group, _vehicle],
            0.1
        ] call CBA_fnc_waitAndExecute;

        // exit
        [_timeout + _delay + 1] + _causeArray
    };

    // move into gunners seat ~ Enemy Detected, commander alive but gunner dead
    private _slow = speed _vehicle < 20;
    if (
        RND(0.4)
        && _slow
        && {someAmmo _vehicle}
        && {_cause isEqualTo DANGER_ENEMYDETECTED}
        && {!alive (gunner _vehicle)}
        && {(commander _vehicle) call EFUNC(main,isAlive)}
    ) exitWith {
        (commander _vehicle) assignAsGunner _vehicle;
        [_timeout + 3] + _causeArray
    };

    // vehicle jink
    private _oldDamage = _vehicle getVariable [QGVAR(vehicleDamage), 0];
    if (_slow && _validTarget && {_distance < (12 + random 15) || {damage _vehicle > _oldDamage}} && {(driver _vehicle) call EFUNC(main,isAlive)}) exitWith {
        _vehicle setVariable [QGVAR(vehicleDamage), damage _vehicle];
        [_unit] call EFUNC(main,doVehicleJink);
        [_timeout + _delay] + _causeArray
    };

    // tank assault
    if (_attack && _slow && {(getUnitState _unit) in ["OK", "DELAY"]}) then {

        // rotate
        private _rotate = [_unit, _dangerPos] call EFUNC(main,doVehicleRotate);

        // assault + vehicle assault
        if (!_rotate && {_distance < 750} && {(gunner _vehicle) call EFUNC(main,isAlive)}) then {

            // infantry
            if ( _dangerCausedBy isKindOf "CAManBase" && { !( terrainIntersectASL [ eyePos _vehicle, eyePos _dangerCausedBy ] ) } ) exitWith {
                [
                    {_this call EFUNC(main,doVehicleAssault)},
                    [_unit, _dangerPos, _dangerCausedBy],
                    _delay - 1.5
                ] call CBA_fnc_waitAndExecute;
            };

            // everything else -- assault!
            if (
                isTouchingGround _dangerCausedBy
                && { unitReady _vehicle }
                && { (driver _vehicle) call EFUNC(main,isAlive) }
                && { [_vehicle, "VIEW", vehicle _dangerCausedBy] checkVisibility [eyePos _vehicle, eyePos _dangerCausedBy] < 0.5 }
            ) then {
                [_unit, _dangerPos, _dangerCausedBy, _distance] call EFUNC(main,doVehicleAssaultMove);
            };
        };
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

    // move into gunners seat ~ 30-90 meters and Enemy Detected
    if (
        _slow
        && {canUnloadInCombat _vehicle}
        && {someAmmo _vehicle}
        && {_cause isEqualTo DANGER_ENEMYDETECTED}
        && {_vehicle distanceSqr _dangerPos < (900 + random 3600)}
        && {!alive (gunner _vehicle)}
    ) exitWith {
        _unit action ["Eject", _vehicle];
        _unit assignAsGunner _vehicle;
        [
            {
                params ["_unit", "_vehicle"];
                if (_unit call EFUNC(main,isAlive)) then {
                    [_unit, "Stealth", "Eject"] call EFUNC(main,doCallout);
                    _unit setDir (_unit getDir _vehicle);
                    _unit action ["getInGunner", _vehicle];
                };
            }, [_unit, _vehicle], 0.9
        ] call CBA_fnc_waitAndExecute;
        [_timeout + 3] + _causeArray
    };

    // escape ~ if enemy within 15-50 meters or explosions are nearby!
    if (
        _slow
        && {(side _dangerCausedBy) isNotEqualTo (side _unit)}
        && {_cause isEqualTo DANGER_EXPLOSION || {_vehicle distanceSqr _dangerCausedBy < (225 + random 1225)}}
        && {(driver _vehicle) call EFUNC(main,isAlive)}
    ) exitWith {
        [_unit] call EFUNC(main,doVehicleJink);
        [_timeout + 3] + _causeArray
    };

    // look toward danger
    if (
        _attack
        && {_vehicle knowsAbout _dangerCausedBy > 3}
        && {(gunner _vehicle) call EFUNC(main,isAlive)}
    ) then {_vehicle doWatch (AGLToASL _dangerPos);};

    // suppression
    if (_attack && {_slow}) then {
        [_unit, _dangerPos vectorAdd [0, 0, random 1]] call EFUNC(main,doVehicleSuppress);
        [{_this call EFUNC(main,doVehicleSuppress)}, [_unit, _dangerPos vectorAdd [0, 0, random 2]], 3] call CBA_fnc_waitAndExecute;
        _delay = random 4;
    };

    // end
    [_timeout + _delay] + _causeArray
};

// vehicle type ~ Unarmed car
if (_vehicle isKindOf "Car_F" && {!someAmmo _vehicle}) then {

    // speed
    private _stopped = speed _vehicle < 2;

    // is static and a driver and enemy near and a threat - enemy within 10-35 meters
    if (
        _stopped
        && {!isNull (driver _vehicle)}
        && {canUnloadInCombat _vehicle}
        && {_cause isEqualTo DANGER_ENEMYDETECTED}
        && {_vehicle distanceSqr _dangerCausedBy < (100 + random 225)}
    ) then {
        private _driver = driver _vehicle;
        _driver action ["Eject", _vehicle];
        _driver setSuppression 0.94; // to prevent instant laser aim on exiting vehicle
        [_driver, "Combat", "Eject"] call EFUNC(main,doCallout);
    };
};

// end
[_timeout] + _causeArray
