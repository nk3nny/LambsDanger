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
 * Public: Yes
*/
params ["_unit", ["_range", 25 + random [0, 25, 125]]];

// settings
private _veh = vehicle _unit;

// cannot move or moving
if (!canMove _veh || {currentCommand _veh isEqualTo "MOVE" || currentCommand _veh isEqualTo "ATTACK"}) exitWith {getPosASL _unit};

// variables
_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Jink Vehicle"];

// Find positions
private _destination = [];
_destination pushBack (_veh modelToWorldVisual [_range, -(random 10), 0]);
_destination pushBack (_veh modelToWorldVisual [_range * -1, -(random 10), 0]);
//_destination pushBack (_veh modelToWorldVisual [0, (20 + random 50) * -1, 0]);  <-- rear movement just confuses AI

// near enemy?
if (!isNull (_unit findNearestEnemy _unit)) then {
    _destination pushBack ([getpos (_unit findNearestEnemy _unit), 120 + _range, _range, 8, getpos _veh] call FUNC(findOverwatch));
};

// tweak
_destination apply {_x findEmptyPosition [0, 25, typeOf _veh];};

// actual position and no water
_destination = _destination select {count _x > 0 && {!(surfaceIsWater _x)}};

// check -- no location -- exit
if (count _destination < 1) exitWith { _veh modelToWorldVisual [0, -(random 30), 0] };
_destination = selectRandom _destination;

// refresh ready
(effectiveCommander _unit) doMove (getPosASL _unit);

// execute
_veh doMove _destination;

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 jink (%2 moves %3m)", side _unit, getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName"), round (_unit distance _destination)];};

// end
_destination
