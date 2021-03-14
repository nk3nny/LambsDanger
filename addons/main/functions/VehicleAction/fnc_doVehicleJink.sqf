#include "script_component.hpp"
/*
 * Author: nkenny
 * Jink vehicle shifts the vehicle 50-150 meters left or right or rear, in response to danger
 *
 * Arguments:
 * 0: vehicle moving <OBJECT>
 * 1: max range to move <NUMBER>
 *
 * Return Value:
 * destination to move
 *
 * Example:
 * [bob, 100] call lambs_main_fnc_doVehicleJink;
 *
 * Public: No
*/
params ["_unit", ["_range", 50 + random [0, 0, 100]]];

// settings
private _vehicle = vehicle _unit;

// cannot move or moving
if (
    !canMove _vehicle
    || {currentCommand _vehicle isEqualTo "MOVE"
    || currentCommand _vehicle isEqualTo "ATTACK"}
    ) exitWith {
    getPosASL _unit
};

// variables
_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Jink Vehicle", GVAR(debug_functions)];

// Find positions
private _destination = [];
_destination pushBack (_vehicle modelToWorldVisual [_range, -5, 0]);
_destination pushBack (_vehicle modelToWorldVisual [-_range, -5, 0]);
//_destination pushBack (_vehicle modelToWorldVisual [0, -50, 0]);  <-- rear movement just confuses AI - nkenny

// near enemy?
private _enemy = _unit findNearestEnemy _unit;
if (!isNull _enemy) then {
    //_destination pushBack ([getPos _enemy, 120 + _range, _range, 8, getPos _vehicle] call FUNC(findOverwatch));

    // Share information!
    [_unit, _enemy, GVAR(radioShout), true] call FUNC(doShareInformation);
};

// tweak
_destination = _destination apply {_x findEmptyPosition [0, 25, typeOf _vehicle];};

// actual position and no water
_destination = _destination select {!(_x isEqualTo []) && {!(surfaceIsWater _x)}};

// check -- no location -- exit
if (_destination isEqualTo []) exitWith { getPosASL _unit };
_destination = selectRandom _destination;

// make tanks pop smoke when moving
// _vehicle forceweaponfire ["SmokeLauncher", "SmokeLauncher"];     <-- not working! Will revist at a later date - nkenny

// execute
_vehicle doMove _destination;

// debug
if (GVAR(debug_functions)) then {
    [
        "%1 jink (%2 moves %3m)",
        side _unit, getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"),
        round (_unit distance _destination)
    ] call FUNC(debugLog);
};

// end
_destination
