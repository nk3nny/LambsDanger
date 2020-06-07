#include "script_component.hpp"
/*
 * Author: jokoho482
 * Makes the unit randomly patrol a given area
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
            private _group = GET_CURATOR_GRP_UNDER_CURSOR;

            if (isNull _group) then {
                private _groups = allGroups;
                _groups = _groups select { ((units _x) findIf { alive _x }) != -1; };
                _groups = [_groups, [], {_logic distance (leader _x) }, "ASCEND"] call BIS_fnc_sortBy;

                [LSTRING(Module_TaskPatrol_DisplayName),
                    [
                        [LSTRING(Groups_DisplayName), "DROPDOWN", LSTRING(Groups_ToolTip), _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        [LSTRING(Module_TaskPatrol_Range_DisplayName), "SLIDER", LSTRING(Module_TaskPatrol_Range_ToolTip), [20, 2000], [1, 0.5], TASK_PATROL_SIZE, 1],
                        [LSTRING(Module_TaskPatrol_Waypoints_DisplayName), "SLIDER", LSTRING(Module_TaskPatrol_Waypoints_ToolTip), [2, 15], [2, 1], TASK_PATROL_WAYPOINTCOUNT, 0],
                        [LSTRING(Module_TaskPatrol_MoveWaypoints_DisplayName), "BOOLEAN", LSTRING(Module_TaskPatrol_MoveWaypoints_ToolTip), TASK_PATROL_MOVEWAYPOINTS]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_range", "_waypointCount", "_moveWaypoint"];
                        private _group = _groups select _groupIndex;
                        [_group, getPos _logic, _range, _waypointCount, [], _moveWaypoint] remoteExecCall [QFUNC(taskPatrol), leader _group];
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
                _logic setVehicleVarName LLSTRING(Self);
                private _targets = [_logic];
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                _targets append GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;

                [LSTRING(Module_TaskPatrol_DisplayName),
                    [
                        [LSTRING(Centers_DisplayName), "DROPDOWN", LSTRING(Centers_ToolTip), _targets apply { format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        [LSTRING(Module_TaskPatrol_Range_DisplayName), "SLIDER", LSTRING(Module_TaskPatrol_Range_ToolTip), [20, 2000], [1, 0.5], TASK_PATROL_SIZE, 1],
                        [LSTRING(Module_TaskPatrol_Waypoints_DisplayName), "SLIDER", LSTRING(Module_TaskPatrol_Waypoints_ToolTip), [2, 15], [2, 1], TASK_PATROL_WAYPOINTCOUNT, 0],
                        [LSTRING(Module_TaskPatrol_MoveWaypoints_DisplayName), "BOOLEAN", LSTRING(Module_TaskPatrol_MoveWaypoints_ToolTip), TASK_PATROL_MOVEWAYPOINTS]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_range", "_waypointCount", "_moveWaypoint"];
                        private _target = _targets select _targetIndex;
                        if !(local _group) then {
                            _target = getPos _target;
                        };
                        [_group, _target, _range, _waypointCount, [], _moveWaypoint] remoteExecCall [QFUNC(taskPatrol), leader _group];
                        if !(_logic isEqualTo _target) then {
                            deleteVehicle _logic;
                        };
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

            private _area = _logic getVariable ["objectarea", [TASK_PATROL_SIZE, TASK_PATROL_SIZE]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _moveWaypoint = _logic getVariable [QGVAR(moveWaypoints), TASK_PATROL_MOVEWAYPOINTS];
            private _waypointCount =_logic getVariable [QGVAR(WaypointCount), TASK_PATROL_WAYPOINTCOUNT];
            {
                [_x, getPos _logic, _range, _waypointCount, _area, _moveWaypoint] remoteExecCall [QFUNC(taskPatrol), leader _x];
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
