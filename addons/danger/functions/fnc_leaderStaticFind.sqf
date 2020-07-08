#include "script_component.hpp"
/*
 * Author: nkenny
 * Find and man nearby static weapons
 *
 * Arguments:
 * 0: Units <ARRAY>
 * 1: Unit leader <OBJECT>
 *
 * Return Value:
 * units in array
 *
 * Example:
 * [units bob, bob] call lambs_danger_fnc_leaderStaticFind;
 *
 * Public: No
*/

params ["_units", "_unit"];

// sort units
switch (typeName _units) do {
    case ("OBJECT"): {
        _units = [_units] call EFUNC(main,findReadyUnits);
    };
    case ("GROUP"): {
        _units = [leader _units] call EFUNC(main,findReadyUnits);
    };
};

// never leader
_units = _units - [_unit];

// prevent deployment of static weapons
if (_units isEqualTo []) exitWith { _units };

// man empty statics
private _weapons = nearestObjects [_unit, ["StaticWeapon"], 75, true];
_weapons = _weapons select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// orders
if !((_weapons isEqualTo []) || (_units isEqualTo [])) then { // De Morgan's laws FTW

    // pick a random unit
    _weapons = selectRandom _weapons;
    _units = [_units, [], { _weapons distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    _units = _units select 0;

    // asign no target
    _units doWatch ObjNull;
    _units setVariable [QGVAR(forceMOVE), true];

    // order to man the vehicle
    _units assignAsGunner _weapons;
    [_units] orderGetIn true;
    (group _unit) addVehicle _weapons;
};

// return
_units
