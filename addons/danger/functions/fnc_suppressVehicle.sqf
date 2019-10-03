#include "script_component.hpp"
// Suppression Vehicle
// version 1.2
// by nkenny

/*
    Vehicle suppression
*/

// init
private _unit = param [0];
private _target = param [1];
private _vehicle = vehicle _unit;
// only gunners
if (gunner _vehicle != _unit) exitWith {false};

// artillery (no tactical options)
if (_vehicle getVariable [QGVAR(isArtillery), getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "artilleryScanner") > 0]) exitWith {
        _vehicle setVariable [QGVAR(lastAction), time + 999];
        _vehicle setVariable [QGVAR(isArtillery), true];
        false
};

// high speed?
if (speed _vehicle > 10) exitWith {false};

// Target dead? A little random to keep things interesting
if (!alive _target && {random 1 > 0.8}) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Suppress Vehicle"];

// settings
_vehicle setVariable [QGVAR(lastAction), time + 9 + random 16];

// find
_tpos = (ATLtoASL (_unit getHideFrom _target)) vectorAdd [0.5 - random 1, 0.5 - random 1, random 1.3];

// do it
_unit doSuppressiveFire _tPos;

// debug
if (GVAR(debug_functions)) then {systemchat format ["Danger.fnc %1 suppression (%2s)", getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"), round (time - (_vehicle getVariable [QGVAR(lastAction), 0]))];};

// end
true
