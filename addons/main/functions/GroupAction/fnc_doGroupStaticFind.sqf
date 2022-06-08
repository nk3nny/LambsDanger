#include "script_component.hpp"
/*
 * Author: nkenny
 * Find and man nearby static weapons
 *
 * Arguments:
 * 0: units <ARRAY>
 * 1: unit leader <OBJECT>
 *
 * Return Value:
 * units in array
 *
 * Example:
 * [units bob, bob] call lambs_main_fnc_doGroupStaticFind;
 *
 * Public: No
*/
params ["_units", ["_unit", objNull]];

// sort units
switch (typeName _units) do {
    case ("OBJECT"): {
        _units = [_units] call FUNC(findReadyUnits);
    };
    case ("GROUP"): {
        _units = [leader _units] call FUNC(findReadyUnits);
    };
};

// never leader
_units = _units - [_unit];

// prevent deployment of static weapons
if (_units isEqualTo []) exitWith { _units };

// man empty statics
private _weapons = nearestObjects [_unit, ["StaticWeapon"], 75, true];
_weapons = _weapons select { simulationEnabled _x && { !isObjectHidden _x } && { locked _x != 2 } && { (_x emptyPositions "Gunner") > 0 } };

// orders
if !((_weapons isEqualTo []) || (_units isEqualTo [])) then { // De Morgan's laws FTW

    // pick a random unit
    _weapons = selectRandom _weapons;
    _units = [_units, [], { _weapons distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    private _unit = _units select 0;

    // asign no target
    _unit doWatch ObjNull;

    // order to man the vehicle
    _unit assignAsGunner _weapons;
    [_unit] orderGetIn true;
    (group _unit) addVehicle _weapons;
};

// reinsert leader
_units pushBack _unit;

// return
_units
