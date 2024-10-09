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
 * 3: Area the AI garrisons, default [] <ARRAY>
 * 4: Teleport Units to Position <BOOL>
 * 5: Sort Based on Height <BOOL>
 * 6: Exit Conditions that breaks a Unit free (-2 Random, -1 All, 0 Hit, 1 Fired, 2 FiredNear), default -2 <NUMBER>
 * 7: Patrol <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, bob, 50] call lambs_wp_fnc_taskGarrison;
 *
 * Public: Yes
*/
if (canSuspend) exitWith { [FUNC(taskGarrison), _this] call CBA_fnc_directCall; };

// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_pos", []],
    ["_radius", TASK_GARRISON_SIZE, [0]],
    ["_area", [], [[]]],
    ["_teleport", TASK_GARRISON_TELEPORT, [false]],
    ["_sortBasedOnHeight", TASK_GARRISON_SORTBYHEIGHT, [false]],
    ["_exitCondition", TASK_GARRISON_EXITCONDITIONS - 2, [0]],
    ["_patrol", TASK_GARRISON_PATROL, [false]]
];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// sort pos
if (_pos isEqualTo []) then {_pos = _group;};
_pos = _pos call CBA_fnc_getPos;

// find guns
private _weapons = nearestObjects [_pos, ["Landvehicle"], _radius, true];
_weapons = _weapons select { simulationEnabled _x && { !isObjectHidden _x } && { locked _x != 2 } && { (_x emptyPositions "Gunner") > 0 } };

// find buildings // remove half outdoor spots // shuffle array
private _buildingPos = [_pos, _radius, true, false] call EFUNC(main,findBuildings);

if (_area isNotEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle", ["_c", -1]];
    _buildingPos = _buildingPos select { _x inArea [_pos, _a, _b, _angle, _isRectangle, _c] };
    _weapons = _weapons select {(getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle, _c]};
};

private _outsidePos = [];
{
    if !(lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 6]]) then {
        _outsidePos pushBack _x;
    };
} forEach _buildingPos;
_buildingPos = _buildingPos - _outsidePos;

// declare units
private _units = (units _group) select {!isPlayer _x && {isNull objectParent _x}};

// match inside positions to outside positions if possible.
if (count _units >= count _buildingPos) then {
    _buildingPos append _outsidePos;
} else {
    _buildingPos append ( _outsidePos select { RND(0.5) } );
};

// sort based on height or true random
if (_sortBasedOnHeight) then {
    _buildingPos = [_buildingPos, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;
} else {
    [_buildingPos, true] call CBA_fnc_Shuffle;
};

// orders
_group setBehaviour "SAFE";
_group enableAttack false;

// set group task
_group setVariable [QEGVAR(main,currentTactic), "taskGarrison", EGVAR(main,debug_functions)];

// add sub patrols
reverse _units;
if (_patrol) then {
    private _patrolGroup = createGroup [(side _group), true];
    [_units deleteAt 0] join _patrolGroup;
    if (count _units > 4)  then { [_units deleteAt 0] join _patrolGroup; };

    // performance
    if (dynamicSimulationEnabled _group) then {
        [_patrolGroup, true] remoteExec ["enableDynamicSimulation", 2];
    };

    // id
    _patrolGroup setGroupIDGlobal [format ["Patrol (%1)", groupId _patrolGroup]];

    // orders
    if (_area isEqualTo []) then {
        [_patrolGroup, _pos, _radius, 4, nil, true] call FUNC(taskPatrol);
    } else {
        private _area2 = +_area;
        _area2 set [0, (_area2 select 0) * 2];
        _area2 set [1, (_area2 select 1) * 2];
        [_patrolGroup, _pos, _radius, 4, _area2, true] call FUNC(taskPatrol);
    };

    // eventhandler
    _group setVariable [QGVAR(baseGroup), _patrolGroup];
    _group addEventHandler ["CombatModeChanged", {
        params ["_group"];
        private _patrolGroup = _group getVariable [QGVAR(baseGroup), grpNull];
        (units _patrolGroup) joinSilent _group;
        _group removeEventHandler [_thisEvent, _thisEventHandler];
    }];

};

// man static weapons
{
    // gun
    if (_weapons isNotEqualTo []) then {
        private _staticWeapon = _weapons deleteAt 0;
        if (_teleport) then { _x moveInGunner _staticWeapon; };
        _x assignAsGunner _staticWeapon;
        [_x] orderGetIn true;
        _units set [_foreachIndex, objNull];
    };
} forEach _units;

_units = _units - [objNull];

// enter buildings
if (count _units > count _buildingPos) then {_units resize (count _buildingPos);};
private _fnc_addEventHandler = {
    params ["_unit", "_type"];
    if (_type == 0) exitWith {};
    if (_type == -2) then {
        _type = floor (random 4);
    };

    // variables
    private _ehs = _unit getVariable [QGVAR(eventhandlers), []];

    // add handlers
    switch (_type) do {
        case 1: {
            private _handle = _unit addEventHandler ["Hit", {
                params ["_unit"];
                [_unit, "PATH"] remoteExec ["enableAI", _unit];
                _unit setCombatMode "RED";
                [_unit, _unit getVariable [QGVAR(eventhandlers), []]] call EFUNC(main,removeEventhandlers);
                _unit setVariable [QGVAR(eventhandlers), nil];
            }];
            _ehs pushBack ["Hit", _handle];
        };
        case 2: {
            private _handle = _unit addEventHandler ["Fired", {
                params ["_unit"];
                [_unit, "PATH"] remoteExec ["enableAI", _unit];
                _unit setCombatMode "RED";
                [_unit, _unit getVariable [QGVAR(eventhandlers), []]] call EFUNC(main,removeEventhandlers);
                _unit setVariable [QGVAR(eventhandlers), nil];
            }];
            _ehs pushBack ["Fired", _handle];
        };
        case 3: {
            private _handle = _unit addEventHandler ["FiredNear", {
                params ["_unit", "_shooter", "_distance"];
                if (side _unit != side _shooter && {_distance < (10 + random 10)}) then {
                    [_unit, "PATH"] remoteExec ["enableAI", _unit];
                    _unit doMove (getPosATL _shooter);
                    _unit setCombatMode "RED";
                    [_unit, _unit getVariable [QGVAR(eventhandlers), []]] call EFUNC(main,removeEventhandlers);
                    _unit setVariable [QGVAR(eventhandlers), nil];
                };
            }];
            _ehs pushBack ["FiredNear", _handle];
        };
        case 4: {
            private _handle = _unit addEventHandler ["Suppressed", {
                params ["_unit"];
                [_unit, "PATH"] remoteExec ["enableAI", _unit];
                _unit setCombatMode "RED";
                [_unit, _unit getVariable [QGVAR(eventhandlers), []]] call EFUNC(main,removeEventhandlers);
                _unit setVariable [QGVAR(eventhandlers), nil];
            }];
            _ehs pushBack ["Suppressed", _handle];
        };
    };

    // set EH
    _unit setVariable [QGVAR(eventhandlers), _ehs];
};
// spread out
{
    // prepare
    doStop _x;
    private _house = _buildingPos deleteAt 0;

    // move and delay stopping + stance
    if (_teleport) then {
        if (surfaceIsWater _house) then {
            _x doFollow (leader _x);
        } else {
            _x setVehiclePosition [_house, [], 0, "CAN_COLLIDE"];
            _x disableAI "PATH";
            _x setUnitPos selectRandom ["UP", "UP", "MIDDLE"];

            // look away from nearest building
            if !([_x] call EFUNC(main,isIndoor)) then {
                _x doWatch AGLtoASL (_x getPos [250, (nearestBuilding _house) getDir _house]);
            };
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
                if (surfaceIsWater (getPosASL _unit) || (_unit distance _target > 1.5)) exitWith { _unit doFollow (leader _unit); };
                _unit disableAI "PATH";
                _unit setUnitPos selectRandom ["UP", "UP", "MIDDLE"];
            }, [_x, _house]
        ] call CBA_fnc_waitUntilAndExecute;
    };

    if (_exitCondition == -1) then {
        for "_i" from 0 to 4 do {
            [_x, _i] call _fnc_addEventHandler;
        };
    } else {
        [_x, _exitCondition] call _fnc_addEventHandler;
    };

} forEach _units;

// waypoint
_pos set [2, 0]; // Stop Waypoints from Flying
private _wp = _group addWaypoint [_pos, _radius / 5];
_wp setWaypointType "HOLD";
_wp setWaypointCompletionRadius _radius;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 taskGarrison: %2 garrisoned", side _group, groupID _group] call EFUNC(main,debugLog);
};

// end
true
