#include "script_component.hpp"
/*
 * Author: nkenny
 * Garrison
 *        Simple garrison script for Arma3
 *        Units may use static weapons
 *        Each garrisoned solider has one movement trigger (hit, fired, or fired Near)
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Position to occupy, default group location <ARRAY or OBJECT>
 * 2: Range of tracking, default is 50 meters <NUMBER>
 * 3: Area the AI Camps in, default [] <ARRAY>
 * 4: Exit Conditions that breaks a Unit free (-2 Random, -1 All, 0 Hit, 1 Fired, 2 FiredNear), default -2 <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, bob, 50] call lambs_wp_fnc_taskGarrison;
 *
 * Public: No
*/
if (canSuspend) exitWith { [FUNC(taskGarrison), _this] call CBA_fnc_directCall; };

// init
params ["_group", ["_pos", []], ["_radius", 50], ["_area", [], [[]]], ["_teleport", false], ["_sortBasedOnHeight", false], ["_exitCondition", -2]];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// sort pos
if (_pos isEqualTo []) then {_pos = _group;};
_pos = _pos call CBA_fnc_getPos;

// remove all waypoints
//[_group] call CBA_fnc_clearWaypoints;

// settings
private _patrol = false;    // disabled for now
private _statics = 0.8;

// find buildings // remove half outdoor spots // shuffle array
private _houses = [_pos, _radius, true, false] call EFUNC(danger,findBuildings);
_houses = _houses select { RND(0.5) || {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 6]]}};
if !(_area isEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle"];
    _houses = _houses select { _x inArea [_pos, _a, _b, _angle, _isRectangle] };
};
[_houses, true] call CBA_fnc_Shuffle;

if (_sortBasedOnHeight) then {
    _houses = [_houses, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;
};

// find guns
private _weapons = nearestObjects [_pos, ["Landvehicle"], _radius, true];
_weapons = _weapons select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// orders
_group setBehaviour "SAFE";
_group enableAttack false;

// declare units + sort vehicles + tweak count to match house positions
private _units = units _group;
_units = _units select {isNull objectParent _x};

// Large groups man guns and patrol!
if (count _units > 4) then {

    // consider patrol
    if (_patrol) then {
        while {RND(0.8) && {count _units > 5}} do { _units deleteAt 0 };
    };

    // last man mans guns
    for "_i" from 0 to (count _weapons - 1) do {
        if (random 1 > _statics) then {
            private _gunner = (_units deleteAt (count _units - 1));
            _gunner assignAsGunner (_weapons deleteAt _i);
            [_gunner] orderGetIn true;
        };
    };
};

if (count _units > count _houses) then {_units resize (count _houses);};
private _fnc_addEventHandler = {
    params ["_type"];
    if (_type == -2) then {
        _type = floor (random 3);
    };
    // add handlers
    switch (_type) do {
        case 0: {
            _x addEventHandler ["Hit", {
                params ["_unit"];
                [_unit, "PATH"] remoteExec ["enableAI", _unit];
                _unit setCombatMode "RED";
                _unit removeEventHandler ["Hit", _thisEventHandler];
            }];
        };
        case 1: {
            _x addEventHandler ["Fired", {
                params ["_unit"];
                [_unit, "PATH"] remoteExec ["enableAI", _unit];
                _unit setCombatMode "RED";
                _unit removeEventHandler ["Fired", _thisEventHandler];
            }];
        };
        case 2: {
            _x addEventHandler ["FiredNear", {
                params ["_unit", "_shooter", "_distance"];
                if (side _unit != side _shooter && {_distance < (10 + random 10)}) then {
                    [_unit, "PATH"] remoteExec ["enableAI", _unit];
                    _unit doMove (getPosATL _shooter);
                    _unit setCombatMode "RED";
                    _unit removeEventHandler ["FiredNear", _thisEventHandler];
                };
            }];
        };
    };
};
// spread out
{
    // prepare
    doStop _x;
    private _house = _houses deleteAt 0;
    // move and delay stopping + stance
    if (_teleport) then {
        if (surfaceIsWater _house) then {
            _x doFollow (leader _x);
        } else {
            _x setPos _house;
            _x disableAI "PATH";
            _x setUnitPos selectRandom ["UP", "UP", "MIDDLE"];
        };
    } else {
        if (surfaceIsWater _house) exitWith {
            _x doFollow (leader _x);
        };
        _x doMove _house;
        [
            {
                params ["_unit", ""];
                unitReady _unit
            }, {
                params ["_unit", "_target"];
                if (surfaceIsWater (getPos _unit) || (_unit distance _target > 1.5)) exitWith { _unit doFollow (leader _unit); };
                _unit disableAI "PATH";
                _unit setUnitPos selectRandom ["UP", "UP", "MIDDLE"];
            }, [_x, _house]
        ] call CBA_fnc_waitUntilAndExecute;
    };

    if (_exitCondition == -1) then {
        for "_i" from 0 to 2 do {
            _i call _fnc_addEventHandler;
        };
    } else {
        _exitCondition call _fnc_addEventHandler;
    };
    // end
    true
} count _units;

// end with patrol
// disabled!

// waypoint
_pos set [2, 0]; // Stop Waypoints from Flying
private _wp = _group addWaypoint [_pos, _radius / 5];
_wp setWaypointType "HOLD";
_wp setWaypointCompletionRadius _radius;

// debug
if (EGVAR(danger,debug_functions)) then {
    format ["%1 taskGarrison: %2 garrisoned", side _group, groupID _group] call EFUNC(danger,debugLog);
};


// end
true
