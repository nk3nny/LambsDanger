#include "script_component.hpp"
// Creep up close
// version 4.1
// by nkenny

/*
  ** WAYPOINT EDITION ** 

  Simple garrison script for Arma3
  Each garrisoned solider has one movement trigger (hit, fired, or fired Near)
  
    Would like arguments for: 
        only indoors

  Arguments
    1, Group or object            [Object or Group]
    2, Range to find buildings    [Number]            <-- not for this version 
    3, Group set to patrol        [Boolean]            <-- not implemented -- always true 
*/


// init 
private _grp = param [0];
private _pos = param [1];
private _patrol = false; 
private _statics = 0.2; 
private _range = waypointCompletionRadius [_grp,currentwaypoint _grp];

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix 
if (_range isEqualTo 0) then {_range = 50;};

// find buildings // remove half outdoor spots // shuffle array 
_houses = [_pos,_range,true,false] call EFUNC(danger,nearBuildings);
_houses = _houses select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0,0,6]] || {random 1 > 0.5}}; 
_houses = _houses call BIS_fnc_arrayShuffle; 

// find guns 
_weapons = nearestobjects [_pos,["Landvehicle"],_range,true];
_weapons = _weapons select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// orders 
_grp enableAttack false; 

// declare units + tweak count 
_units = units _grp;
_units = _units select {isNull objectParent _x}; 
if (count _units > count _houses) then {_units resize (count _houses);};

// Large groups man guns and patrol! 
if (count _units > 4) then {

    // consider patrol 
    if (_patrol) then {
    while {count _units > 5 && {random 1 > 0.8}} do {_units deleteAt 0}; 
    }; 

    // last man mans guns 
    for "_i" from 0 to (count _weapons - 1) do {
        if (random 1 > _statics) then {
            _gunner = (_units deleteAt (count _units - 1)); 
            _gunner assignAsGunner (_weapons deleteAt _i); 
            [_gunner] orderGetIn true;
        }; 
    }; 
}; 

// spread out 
{
    // prepare 
    doStop _x; 

    // move and delay stopping + stance 
    [_x,(_houses select 0)] spawn {
        params ["_unit","_pos"];
        _unit doMove (_pos vectorAdd [0.25 - random 0.5,0.25 - random 0.5,0]); 
        waitUntil {unitReady _unit && {canMove _unit}}; 
        if (!alive _unit) exitWith {};                                                    // dead? exit 
        if (surfaceIsWater getpos _unit) exitWith {_unit doFollow leader group _unit};    // surface is water? rejoin formation 
        _unit disableAI "PATH";
        _unit setUnitPos selectRandom ["UP","UP","MIDDLE"]; 
    }; 

    // add handlers 
    _type = selectRandom [1,2,3,1,2,3]; 
    switch (_type) do {
        case 1: {
            _x addEventHandler ["Fired", {
            params ["_unit"]; 
            _unit enableAI "PATH"; 
            _unit setCombatMode "RED";
            _unit removeEventHandler ["Fired",_thisEventHandler]; 
            }];
        };
        case 2: {
            _x addEventHandler ["FiredNear", {
            params ["_unit","_shooter","_distance"]; 
            if (side _unit != side _shooter && {_distance < 10 + random 10}) then {
                _unit enableAI "PATH"; 
                _unit doMove getposATL _shooter; 
                _unit setCombatMode "RED";
                _unit removeEventHandler ["FiredNear",_thisEventHandler];                 
                }; 
            }];            
        };
        default {
            _x addEventHandler ["Hit", {
            params ["_unit"]; 
            _unit enableAI "PATH"; 
            _unit setCombatMode "RED";
            _unit removeEventHandler ["Hit",_thisEventHandler]; 
            }];            
        };
    };

    // refresh 
    _houses deleteAt 0; 

    // end 
    true 
} count _units; 

// end with patrol 

// orders
_grp setBehaviour "SAFE";

// waypoint 
_wp = _grp addWaypoint [_pos,_range/5];
_wp setWaypointType "SENTRY"; 
_wp setWaypointCompletionRadius _range; 

// debug 
if (EGVAR(danger,debug_functions)) then {
  systemchat format ["danger.wp taskGarrison: %1 garrisoned",groupID _grp];
}; 


// end 
true 