#include "script_component.hpp"
/*
 * Author: nkenny
 * Jink vehicle shifts the vehicle 25-150 meters left or right or rear, in response to danger
 *
 * Arguments:
 * 0: Vehicle moving <OBJECT>
 * 1: Max range to move, default is 25 to 150 meters <NUMBER>
 *
 * Return Value:
 * destination to move
 *
 * Example:
 * [bob, 100] call lambs_danger_fnc_vehicleJink;
 *
 * Public: No
*/
params ["_unit", ["_range", 25 + random [0, 25, 125]]];

// settings
private _vehicle = vehicle _unit;

// cannot move or moving
if (!canMove _vehicle || {currentCommand _vehicle isEqualTo "MOVE" || currentCommand _vehicle isEqualTo "ATTACK"}) exitWith {getPosASL _unit};

// variables
_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Jink Vehicle"];

// Find positions
private _destination = [];
_destination pushBack (_vehicle modelToWorldVisual [_range, -(random 10), 0]);
_destination pushBack (_vehicle modelToWorldVisual [_range * -1, -(random 10), 0]);
//_destination pushBack (_vehicle modelToWorldVisual [0, (20 + random 50) * -1, 0]);  <-- rear movement just confuses AI

// near enemy?
if (!isNull (_unit findNearestEnemy _unit)) then {
    _destination pushBack ([getPos (_unit findNearestEnemy _unit), 120 + _range, _range, 8, getPos _vehicle] call FUNC(findOverwatch));
};

// tweak
_destination apply {_x findEmptyPosition [0, 25, typeOf _vehicle];};

// actual position and no water
_destination = _destination select {count _x > 0 && {!(surfaceIsWater _x)}};

// check -- no location -- exit
if (_destination isEqualTo []) exitWith { _vehicle modelToWorldVisual [0, -(random 30), 0] };
_destination = selectRandom _destination;

// refresh ready
(effectiveCommander _unit) doMove (getPosASL _unit);

// execute
_vehicle doMove _destination;

// debug
if (GVAR(debug_functions)) then {format ["%1 jink (%2 moves %3m)", side _unit, getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"), round (_unit distance _destination)] call FUNC(debugLog);};

// end
_destination
