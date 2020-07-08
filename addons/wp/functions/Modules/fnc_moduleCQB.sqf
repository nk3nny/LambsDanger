#include "script_component.hpp"
/*
 * Author: jokoho482
 * Makes the unit clear buildings room by room in AOE
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

                [LSTRING(Module_TaskCQB_DisplayName),
                    [
                        [LSTRING(Groups_DisplayName), "DROPDOWN", LSTRING(Groups_ToolTip), _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        [LSTRING(Module_TaskCQB_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskCQB_Radius_ToolTip), [10, 500], [2, 1], TASK_CQB_SIZE, 2],
                        [LSTRING(Module_TaskCQB_CycleTime_DisplayName), "SLIDER", LSTRING(Module_TaskCQB_CycleTime_Tooltip), [1, 300], [1, 0.5], TASK_CQB_CYCLETIME, 2],
                        [LSTRING(Module_TaskCQB_DeleteOnStartUp_DisplayName), "BOOLEAN", LSTRING(Module_TaskCQB_DeleteOnStartUp_Tooltip), TASK_CQB_DELETEONSTARTUP]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_radius", "_cycle", "_deleteAfterStartup"];
                        private _group = _groups select _groupIndex;
                        if !((local _group) || _deleteAfterStartup) then {
                            _deleteAfterStartup = true;
                            [objNull, format [LLSTRING(SettingIsOnlyForLocalGroups), LLSTRING(Module_TaskCQB_DeleteOnStartUp_DisplayName)]] call BIS_fnc_showCuratorFeedbackMessage;
                        };
                        [_group, [_logic, getPos _logic] select _deleteAfterStartup, _radius, _cycle, nil, false] remoteExec [QFUNC(taskCQB), leader _group];
                        if (_deleteAfterStartup) then {
                            deleteVehicle _logic;
                        };
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        //params ["", "_logic"];
                        //deleteVehicle _logic;
                    }, [_groups, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                _logic setVehicleVarName LLSTRING(Self);
                private _targets = [_logic];
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                _targets append GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;

                [LSTRING(Module_TaskCQB_DisplayName),
                    [
                        [LSTRING(Centers_DisplayName), "DROPDOWN", LSTRING(Centers_ToolTip), _targets apply {  format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        [LSTRING(Module_TaskCQB_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskCQB_Radius_ToolTip), [10, 500], [2, 1], TASK_CQB_SIZE],
                        [LSTRING(Module_TaskCQB_CycleTime_DisplayName), "SLIDER", LSTRING(Module_TaskCQB_CycleTime_Tooltip), [1, 300], [1, 0.5], TASK_CQB_CYCLETIME]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_radius", "_cycle"];
                        private _target = _targets select _targetIndex;
                        if !(local _group) then {
                            _target = getPos _target;
                        };
                        [_group, _target, _radius, _cycle, nil, false] remoteExec [QFUNC(taskCQB), leader _group];
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

            private _area = _logic getVariable ["objectarea", [TASK_CQB_SIZE, TASK_CQB_SIZE]];
            private _radius = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable [QGVAR(CycleTime), TASK_CQB_CYCLETIME];
            private _deleteAfterStartup = _logic getVariable [QGVAR(DeleteOnStartUp), TASK_CQB_DELETEONSTARTUP];

            {
                private _target = _logic;
                if !(local _x) then {
                    _target = getPos _target;
                };
                [_x, _target, _radius, _cycle, _area, false] remoteExec [QFUNC(taskCQB), leader _x];
            } forEach _groups;
            if (_deleteAfterStartup) then {
                deleteVehicle _logic;
            };
        };
    };
};
true
