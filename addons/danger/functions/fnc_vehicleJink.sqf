#include "script_component.hpp"
// Jink vehicle shifts the vehicle 50-150 meters left or right or rear
// version 1.41
// by nkenny

// init
params ["_unit",["_range",25 + random [0,25,150]]];

// settings
private _veh = vehicle _unit;

// refresh ready
effectiveCommander _unit doMove getPosASL _unit;

// fnc find good spot
private _destination = selectBestPlaces [_veh getRelPos [_range, selectRandom [90,90,270,270,180]], 50,"(1 + hills) * (1 + meadow) *  (1 - sea)",100,2] apply {_x select 0};

// flat
//_destination = _destination apply {_p2 = [_x,0,100,3,0,0.12,0,[],[_x,_x]] call BIS_fnc_findSafePos;_p2};

// always getPos
_destination pushBack (_veh modelToWorldVisual [_range,0,0]);
_destination pushBack (_veh modelToWorldVisual [_range * -1,0,0]);

// no water
_destination = _destination select {!(surfaceIsWater _x)};

// check -- no location -- exit
if (count _destination < 1) exitWith {getPosASL _veh};
_destination = selectRandom _destination;

// execute
_veh doMove _destination;

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 jink (%2 moves %3m)",side _unit,getText (configFile >> "CfgVehicles" >> (typeOf vehicle _unit) >> "displayName"),round (_unit distance _destination)];};

// end
_destination