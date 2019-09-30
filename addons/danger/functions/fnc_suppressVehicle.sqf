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

// only gunners
if (gunner vehicle _unit != _unit) exitWith {false};

// artillery (no tactical options)
if (vehicle _unit getVariable ["isArtillery",getNumber (configFile >> "CfgVehicles" >> (typeOf (vehicle _unit)) >> "artilleryScanner") > 0]) exitWith {
        vehicle _unit setVariable ["lastAction",time + 999];
        vehicle _unit setVariable ["isArtillery",true];
        false
};

// high speed?
if (speed vehicle _unit > 10) exitWith {false};

// Target dead? A little random to keep things interesting
if (!alive _target && {random 1 > 0.8}) exitWith {false};

// settings
vehicle _unit setVariable ["lastAction",time + 9 + random 16];

// find
_tpos = (ATLtoASL (_unit getHideFrom _target)) vectorAdd [0.5 - random 1,0.5 - random 1,random 1.3];

// do it
_unit doSuppressiveFire _tPos;

// debug
if (GVAR(debug_functions)) then {systemchat format ["Danger.fnc %1 suppression (%2s)",getText (configFile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "displayName"),round (time - (vehicle _unit getVariable ["lastAction",0]))];};

// end
true
