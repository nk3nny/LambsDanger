#include "script_component.hpp"
/*
 * Author: jokoho482
 * Makes the unit take up defense building positions around target center
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

            //--- Check if the unit is suitable
            if (isNull _group) then {
                private _groups = allGroups;
                _groups = _groups select { ((units _x) findIf { alive _x }) != -1; };
                _groups = [_groups, [], {_logic distance (leader _x) }, "ASCEND"] call BIS_fnc_sortBy;
                [LSTRING(Module_TaskGarrison_DisplayName),
                    [
                        [LSTRING(Groups_DisplayName), "DROPDOWN", LSTRING(Groups_ToolTip), _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        [LSTRING(Module_TaskGarrison_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskGarrison_Radius_ToolTip), [10, 500], [2, 1], TASK_GARRISON_SIZE, 2],
                        [LSTRING(Module_TaskGarrison_ExitCondition_DisplayName), "DROPDOWN", LSTRING(Module_TaskGarrison_ExitCondition_Tooltip), [LSTRING(Random), LSTRING(All), LSTRING(FiredNear), LSTRING(Fired), LSTRING(Hit), LSTRING(None)], TASK_GARRISON_EXITCONDITIONS],
                        [LSTRING(Module_TaskGarrison_SortByHeight_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_SortByHeight_Tooltip), TASK_GARRISON_SORTBYHEIGHT],
                        [LSTRING(Module_TaskGarrison_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Teleport_Tooltip), TASK_GARRISON_TELEPORT],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_GARRISON_PATROL]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_range", "_exitCondition", "_sortByHeight", "_teleport", "_patrol"];
                        private _group = _groups select _groupIndex;
                        [_group, getPos _logic, _range, nil, _teleport, _sortByHeight, _exitCondition - 2, _patrol] remoteExec [QFUNC(taskGarrison), leader _group];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_groups, _logic]] call EFUNC(main,showDialog);
            } else {
                _logic setVehicleVarName LLSTRING(Self);
                private _targets = [_logic];
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                _targets append GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;

                [LSTRING(Module_TaskGarrison_DisplayName),
                    [
                        [LSTRING(Centers_DisplayName), "DROPDOWN", LSTRING(Centers_ToolTip), _targets apply {  format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        [LSTRING(Module_TaskGarrison_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskGarrison_Radius_ToolTip), [10, 500], [2, 1], TASK_GARRISON_SIZE, 2],
                        [LSTRING(Module_TaskGarrison_ExitCondition_DisplayName), "DROPDOWN", LSTRING(Module_TaskGarrison_ExitCondition_Tooltip), [LSTRING(Random), LSTRING(All), LSTRING(FiredNear), LSTRING(Fired), LSTRING(Hit), LSTRING(None)], TASK_GARRISON_EXITCONDITIONS],
                        [LSTRING(Module_TaskGarrison_SortByHeight_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_SortByHeight_Tooltip), TASK_GARRISON_SORTBYHEIGHT],
                        [LSTRING(Module_TaskGarrison_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Teleport_Tooltip), TASK_GARRISON_TELEPORT],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_GARRISON_PATROL]

                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic", "_targets"];
                        _data params ["_targetIndex", "_range", "_exitCondition", "_sortByHeight", "_teleport", "_patrol"];
                        private _target = _targets select _targetIndex;
                        [_group, getPos _target, _range, nil, _teleport, _sortByHeight, _exitCondition - 2, _patrol] remoteExec [QFUNC(taskGarrison), leader _group];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_group, _logic, _targets]
                ] call EFUNC(main,showDialog);
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea", [TASK_GARRISON_SIZE, TASK_GARRISON_SIZE, 0, false, -1]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _sortByHeight = _logic getVariable [QGVAR(SortByHeight), TASK_GARRISON_SORTBYHEIGHT];
            private _teleport = _logic getVariable [QGVAR(Teleport), TASK_GARRISON_TELEPORT];
            private _exitCondition = _logic getVariable [QGVAR(ExitConditions), TASK_GARRISON_EXITCONDITIONS];
            private _patrol = _logic getVariable [QGVAR(Patrol), TASK_GARRISON_PATROL];
            {
                [_x, getPos _logic, _range, _area, _teleport, _sortByHeight, _exitCondition - 2, _patrol] remoteExec [QFUNC(taskGarrison), leader _x];
            } forEach _groups;

            deleteVehicle _logic;
        };
    };
};
true
