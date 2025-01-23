#include "script_component.hpp"
/*
 * Author: nkenny
 * Defend
 *      The group defends a position from buildings and selected cover positions.
 *      The group will not leave the area.
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Position to defend, default group location <ARRAY or OBJECT>
 * 2: Range the group defends, default is 75 meters <NUMBER>
 * 3: Area the group defends, default [] <ARRAY>
 * 4: Teleport Units to Position <BOOL>
 * 5: Use trees and stones as additional defensive positions, default is TRUE <BOOL>
 * 6: Unit is waiting in ambush, default is TRUE <BOOL>
 * 7: Group sets a sub-unit to Patrol the area <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, bob, 50] spawn lambs_wp_fnc_taskDefend;
 *
 * Public: Yes
*/

if !(canSuspend) exitWith {
    _this spawn FUNC(taskDefend);
};

params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_pos", [], [objNull, []]],
    ["_radius", TASK_DEFEND_SIZE, [0]],
    ["_area", [], [[]]],
    ["_teleport", TASK_DEFEND_TELEPORT, [false]],
    ["_useCover", TASK_DEFEND_USECOVER, [0]],
    ["_stealth", TASK_DEFEND_STEALTH, [false]],
    ["_patrol", TASK_DEFEND_PATROL, [false]]
];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// sort pos
if (_pos isEqualTo []) then {_pos = leader _group;};
_pos = _pos call CBA_fnc_getPos;

// orders
_group enableAttack false;
_group setFormation (["DIAMOND", "LINE"] select _stealth);
_group setVariable [QEGVAR(danger,disableGroupAI), true, true];
if (_stealth || _teleport) then {_group setBehaviour (["COMBAT", "STEALTH"] select _stealth);};

// set group task
_group setVariable [QEGVAR(main,currentTactic), "taskDefend", EGVAR(main,debug_functions)];
[_group] call CBA_fnc_clearWaypoints;

// orders
private _wp = _group addWaypoint [_pos, 0, 0];
_wp setWaypointType "HOLD";

// find defensive spots
private _defensivePos = [];
private _leaderASL = [ ( ( AGLToASL _pos ) select 2 ) - 5 , ( ( getPosASL ( leader _group ) ) select 2 ) - 5 ] select ( ( leader _group ) distance2D _pos < _radius );

/*
    Cover types
    0, All
    1, Buildings
    2, Walls
    3, Vegetation
    4, Buildings and Vegetation
    5, Buildings and Walls
    6, Walls and Vegetation
*/

// find buildings
if (_useCover in [0, 1, 4, 5]) then {
    private _houses = nearestObjects [_pos, ["house", "building", "strategic"], _radius];
    {
        private _buildingPos = _x buildingPos -1;

        // reduce building positions
        if ( _useCover isNotEqualTo 2 && { _radius > 25 } ) then {
            [_buildingPos, true] call CBA_fnc_shuffle;
            _buildingPos resize ((count _buildingPos) min 2);
        };

        _defensivePos append _buildingPos;
    } forEach _houses;
};

// add walls and fortifications
if (_useCover in [0, 2, 5, 6]) then {
    private _fortifications = (nearestObjects [_pos, ["strategic"], _radius]) select {(_x buildingPos -1) isEqualTo []};
    _fortifications = _fortifications apply {_x getPos [1.5, _x getDir _pos]};
    _defensivePos append _fortifications;

    // add configured hides
    private _hide = nearestTerrainObjects [_pos, ["HIDE"], _radius, false, true];
    _hide = _hide select {((getPosASL _x) select 2) > _leaderASL && {(str _x) find "mound" > 0}};
    _hide append (nearestTerrainObjects [_pos, ["WALL", "BUNKER"], _radius, false, true]);
    _hide = _hide apply {_x getPos [1.5, _x getDir _pos]};
    _defensivePos append _hide;
};

// find vegetation (or if no spots are found)
if (_useCover in [0, 3, 4, 6] || {_defensivePos isEqualTo []}) then {
    private _cover = nearestTerrainObjects [_pos, ["BUSH", "TREE", "SMALL TREE"], _radius, false, true];
    _cover = _cover select {((getPosASL _x) select 2) > _leaderASL};
    _cover = _cover apply {_x getPos [1.5, _x getDir _pos]};
    _defensivePos append _cover;
};

// get area
if (_area isNotEqualTo []) then {
    _area params ["_a", "_b", "_angle", "_isRectangle", ["_c", -1]];
    _defensivePos = _defensivePos select { _x inArea [_pos, _a, _b, _angle, _isRectangle, _c] };
};

// exit if no positions are found
if (_defensivePos isEqualTo []) exitWith {false};

// patrol
if (_patrol) then {
    private _units = (units _group) select {isNull (objectParent _x)};
    reverse _units;
    private _patrolGroup = createGroup [(side _group), true];
    [_units deleteAt 0] join _patrolGroup;
    if (count _units > 4)  then { [_units deleteAt 0] join _patrolGroup; };

    // performance
    if (dynamicSimulationEnabled _group) then {
        [_patrolGroup, true] remoteExec ["enableDynamicSimulation", 2];
    };

    // id
    _patrolGroup setGroupIdGlobal [format ["Patrol (%1)", groupId _patrolGroup]];

    // orders
    if (_area isEqualTo []) then {
        [_patrolGroup, _pos, _radius, 4, nil, true, false] call FUNC(taskPatrol);
    } else {
        private _area2 = +_area;
        _area2 set [0, (_area2 select 0) * 2];
        _area2 set [1, (_area2 select 1) * 2];
        [_patrolGroup, _pos, _radius, 4, _area2, true, false] call FUNC(taskPatrol);
    };

    // eventhandler
    _group setVariable [QGVAR(baseGroup), _patrolGroup];
    _group addEventHandler ["CombatModeChanged", {
        params ["_group"];
        private _patrolGroup = _group getVariable [QGVAR(baseGroup), grpNull];
        (units _patrolGroup) joinSilent _group;
        _group removeEventHandler [_thisEvent, _thisEventHandler];
    }];

    // stealth patrol
    if (_stealth) then {
        _patrolGroup setBehaviour "AWARE";
        _patrolGroup setCombatMode "GREEN";
    };
};

// stealth
if (_stealth) then {
    _group setCombatMode "WHITE";
};

// teleport
if (_teleport) then {

    private _units = (units _group) select { !(_x getVariable [QEGVAR(danger,forceMove), false ]) && { (vehicle _x) isKindOf "CAManBase" } };
    if (count _units > count _defensivePos) then {_units resize (count _defensivePos)};
    [_defensivePos, true] call CBA_fnc_shuffle;
    {
        _x setVehiclePosition [_defensivePos select _forEachIndex, [], precision _x, "CAN_COLLIDE"];
        if (!_stealth) then {_x setUnitPosWeak selectRandom ["MIDDLE", "MIDDLE", "UP"];};
        doStop _x;
    } forEach _units;
};

// update group settings
_group setVariable [QGVAR(defendUpdate), time];

private _handle = [
    {
        params ["_args"];
        _args params ["_group", "_pos", "_radius", "_defensivePos"];

        // get variables
        private _defendUpdate = _group getVariable [QGVAR(defendUpdate), time];

        // find enemy
        private _target = (leader _group) findNearestEnemy _pos;
        private _getHideFrom = (leader _group) getHideFrom _target;
        private _distance2D = _pos distance2D _target;

        // sort units
        private _units = (units _group) select {
            simulationEnabled _x
            && { isNull ( objectParent _x ) }
            && { ! ( _x getVariable [QEGVAR(danger,forceMove), false] ) }
            && { ! ( currentCommand _x in ["GET IN", "ACTION", "HEAL"] ) }
        };

        {
            private _unit = _x;
            // unit is outside zone -- return to zone or stacked
            private _nearby = _x nearEntities ["CAManBase", 1];
            if (_unit distance2D _pos > _radius || { count _nearby > 1 }) then {
                // systemChat format ["%1 %2 %3!", side _unit, ["outside", "stacked"] select (count _nearby > 1), name _unit];
                _unit doMove (_pos getPos [_radius * 0.9, _pos getDir _unit]);
                _units deleteAt _forEachIndex;
            };
        } forEach _units;

        // exit in no targets
        if (isNull _target || { _getHideFrom distance2D [0, 0, 0] < 1 } ) exitWith {false};

        // advanced combat moves

        // deploy flares
        private _leader = leader _group;
        if (_leader call EFUNC(main,isNight)) then {
            _units = [_units] call EFUNC(main,doUGL);
        };

        // man empty static weapons
        _units = [_units, _leader] call EFUNC(main,doGroupStaticFind);

        // give orders
        if (!isNull _target && _defendUpdate < time) then {

            // debug
            // systemChat format ["%1 Defend - %2 @ %3m - %4 units - hide %5", side _group, name _target, round _distance2D, count _units, count _defensivePos];

            // if enemy within range
            if (_distance2D < _radius) exitWith {
                {
                    _x doMove (getPosATL _target);
                } forEach (units _group);
            };

            // if enemy outside range
            if (_distance2D > _radius) then {

                // share info and check for artillery
                if (_leader call EFUNC(main,isAlive) && {getSuppression _leader < 0.5}) then {

                    // share info
                    [_leader] call EFUNC(main,doShareInformation);

                    // call arty
                    if ([side _group] call FUNC(sideHasArtillery) && {([_leader, _getHideFrom, 200] call EFUNC(main,findNearbyFriendlies)) isEqualTo []}) then {
                        [_leader, _getHideFrom] call EFUNC(main,doCallArtillery);
                    };
                };

                // set group dir
                _group setFormDir (_pos getDir _getHideFrom);

                // sort hides
                _defensivePos = _defensivePos apply {[_getHideFrom distanceSqr _x, _x]};
                _defensivePos sort true;
                _defensivePos = _defensivePos apply {_x select 1};

                // check available cover
                if (count _units > count _defensivePos) then {_units resize (count _defensivePos)};

                // debug
                // systemChat format ["%1 units vs hides - ready units %2  - hides %3  - time %4", side _group, count _units, count _defensivePos, time];

                // units move
                {
                    private _unit = _x;
                    private _movePos = (_defensivePos select _forEachIndex);
                    private _moveDistance2D = _unit distance2D _movePos;


                    // debug
                    // systemChat format ["%1 unitMove %2 - %3m - %4", side _unit, name _unit, round _moveDistance2D, currentCommand _unit];

                    if (_moveDistance2D > 3 && {unitReady _unit || (currentCommand _unit) isEqualTo "STOP"}) then {
                        _unit doMove _movePos;
                        [
                            {
                                params ["_unit"];
                                unitReady _unit
                            },
                            {
                                params ["_unit"];
                                doStop _unit
                            },
                            [_unit]
                        ] call CBA_fnc_waitUntilAndExecute;
                    };

                    // nearby? Just hold
                    if (_moveDistance2D < 3 && {(currentCommand _unit) isNotEqualTo "STOP"}) then {
                        doStop _unit;
                    };

                    // not useful?
                    if (_moveDistance2D > _radius && {(getSuppression _unit) isEqualTo 0} && {(currentCommand _unit) isEqualTo "STOP"}) then {
                        _unit doFollow (leader _unit);
                    };

                } forEach _units;
            };
            _group setVariable [QGVAR(defendUpdate), time + 23];
        };
    },
    8,
    [_group, _pos, _radius, _defensivePos]
] call CBA_fnc_addPerFrameHandler;

// cover debug
if (EGVAR(main,debug_functions)) then {
    private _marker = [_pos, format ["Defend (%1x @ %2m)", count _defensivePos, round _radius], "Color1_FD_F"] call EFUNC(main,dotMarker);
    private _mList = [_marker];
    {
        private _marker = [_x, "", "Color1_FD_F", "loc_Tree"] call EFUNC(main,dotMarker);
        _mList pushBack _marker;
    } forEach _defensivePos;
    [{[{deleteMarker _x} forEach _this]}, _mList, 60] call CBA_fnc_waitAndExecute;
};

// count waypoints
private _waypointCount = count (waypoints _group);

// waypoint loop
waitUntil {

    // performance
    waitUntil { sleep 2; simulationEnabled (leader _group) };

    // alive or waypoints changed
    (units _group) findIf {_x call EFUNC(main,isAlive)} == -1
    || {count (waypoints _group) isNotEqualTo _waypointCount}
};

// remove handler
[_handle] call CBA_fnc_removePerFrameHandler;

// reset
if (!isNull _group) then {

    // reset
    {[_x] call FUNC(doAssaultUnitReset)} forEach (units _group);

};

// end
true
