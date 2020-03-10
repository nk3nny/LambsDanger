#include "script_component.hpp"
/*
 * Author: jokoho482
 * TODO
 *
 * Arguments:
 * TODO
 *
 * Return Value:
 * TODO
 *
 * Example:
 * TODO
 *
 * Public: No
*/
params [["_mode", "", [""]], ["_input", [], [[]]]];

switch (_mode) do {
    // Default object init
    case "init": {
        if (is3DEN) exitWith {};
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if !(_isActivated && local _logic) exitWith {};
        if (_isCuratorPlaced) then {
            //--- Get unit under cursor
            GET_CURATOR_GRP_UNDER_CURSOR(_group);

            if (isNull _group) then {
                private _groups = allGroups;
                _groups = _groups select { ((units _x) findIf { alive _x }) != -1; };
                _groups = [_groups, [], {_logic distance (leader _x) }, "ASCEND"] call BIS_fnc_sortBy;

                ["Task Patrol",
                    [
                        ["Groups", "DROPDOWN", "TODO", _groups apply { format ["%1 (%2 m)", groupId _x, (leader _x) distance _logic] }, 0],
                        ["Range", "NUMBER", "TODO", 200],
                        ["Waypoints", "NUMBER", "TODO", 3],
                        ["Move Waypoint After Completion", "BOOLEAN", "TODO", false]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_range", "_waypointCount", "_moveWaypoint"];
                        [_groups select _groupIndex, getPos _logic, _range, _waypointCount, [], _moveWaypoint] call FUNC(taskPatrol);
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_groups, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                _logic setVehicleVarName "Logic";
                private _targets = [_logic];
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                _targets append GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;

                ["Task Patrol",
                    [
                        ["Targets", "DROPDOWN", "TODO", _targets apply { format ["%1 (%2 m)", vehicleVarName _x, _x distance _logic] }, 0],
                        ["Distance Threshold", "NUMBER", "TODO", 200],
                        ["Waypoints", "NUMBER", "TODO", 3],
                        ["Move Waypoint After Completion", "BOOLEAN", "TODO", false]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_range", "_waypointCount", "_moveWaypoint"];
                        [_group, _targets select _targetIndex, _range, _waypointCount, [], _moveWaypoint] call FUNC(taskPatrol);
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_targets, _logic, _group]
                ] call EFUNC(main,showDialog);
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea",[]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _moveWaypoint = _logic getVariable [QGVAR(moveWaypoints), false];
            private _waypointCount =_logic getVariable [QGVAR(WaypointCount), 4];
            {
                [_x, getPos _logic, _range, _waypointCount, _area, _moveWaypoint] call FUNC(taskPatrol);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
