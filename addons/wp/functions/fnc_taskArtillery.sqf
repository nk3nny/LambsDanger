#include "script_component.hpp"
// Dynamic artillery attack 
// version 1.0 
// by nkenny 

/*
	Performs artillery strike at location 
	Artillery strike has a cone-like 'beaten zone' 

	Arguments 
	0, Which weapon is used 	[Object]
	1, Position targeted		[Array]
	2, Caller					[Object]
	3, Rounds fired 			[Number] (default: 3 - 7)
	4, Dispersion 				[Number] (default: 100m)

*/

// init 
private _gun = param [0];
private _pos = param [1];
private _caller = param [2];
private _rounds = param [3,floor (3 + (random 4))]; 
private _accuracy = param [4,75];

// Gun and caller must be alive 
if (!canFire _gun || {!alive _caller}) exitWith {false};

// settings
_direction = _gun getDir _pos;
_center = _pos getpos [(_accuracy/3) * -1,_direction];
_offset = 0;

// higher class artillery fire more rounds? Less accurate? 
if !(vehicle _gun isKindOf "StaticMortar") then {
	_rounds = _rounds * 2; 
	_accuracy = _accuracy + random 100; 
};

// remove from list
_artillery = missionNamespace getVariable ["lambs_artillery_" + str (side _gun),[]];
_artillery = _artillery - [_gun];
missionNamespace setVariable ["lambs_artillery_" + str (side _gun),_artillery,false];

// delay 
sleep (((_gun distance _pos)/8) min 90);

// initate attack (gun and caller must be alive)
if (canFire _gun && {alive _caller}) then {

	// debug marker list 
	_mlist = [];

	// check rounds 
	for "_check" from 1 to (1 + random 2) do {

		// check rounds barrage 
		for "_i" from 1 to (1 + random 1) do {

			// Randomize target location
			_target = _center getPos [(450 + (random _accuracy * 2)) / _check,_direction + 50 - random 100];

			// Fire round
			_gun commandArtilleryFire [_target,getArtilleryAmmo [_gun] select 0,1];

			// debug 
			if (EGVAR(danger,debug_functions)) then {
				_m = [_target,format ["%1 (Check round %2)",getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"),_i],"colorIndependent","hd_destroy"] call EFUNC(danger,dotMarker);
				_mlist pushBack _m;
			}; 
			
			// waituntil
			waitUntil {unitReady _gun};  
		}; 

		// delay 
		sleep (35 + random 35); 

	}; 

	// step for main barrage  
	if !(canFire _gun && {alive _caller}) exitWith {false}; 

	// Main Barrage 
	for "_i" from 1 to _rounds do {

		// Randomize target location
		_target = _center getPos [_offset + random _accuracy,_direction + 50 - random 100];
		_offset = _offset + _accuracy/3; 

		// Fire round
		_gun commandArtilleryFire [_target,getArtilleryAmmo [_gun] select 0,1];

		// debug 
		if (EGVAR(danger,debug_functions)) then {
			_m = [_target,format ["%1 (Round %2)",getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"),_i],"colorIndependent","hd_destroy"] call EFUNC(danger,dotMarker);
			_mlist pushBack _m;
		}; 
		
		// waituntil
		waitUntil {unitReady _gun};  
	}; 

	// debug 
	if (EGVAR(danger,debug_functions)) then {
		systemchat format ["danger.wp Artillery strike complete: %1 fired %2 shots at %3m",getText (configFile >> "CfgVehicles" >> (typeOf _gun) >> "displayName"),_rounds,round (_gun distance _pos)];
	}; 

	// clean markers! 
	if (count _mlist > 0) then {_mlist spawn {sleep 60;{deleteMarker _x;true} count _this};};
};

// delay 
sleep (10 + random [10,40,180]); 

// re-add to list 
if (!canFire _gun) exitWith {false};

// Ready up again 
_gun doMove getposASL _gun; 

// register gun 
_artillery = missionNamespace getVariable ["lambs_artillery_" + str (side _gun),[]];
_artillery pushBackUnique _gun;
missionNamespace setVariable ["lambs_artillery_" + str (side _gun),_artillery,false];

// end 
true 
