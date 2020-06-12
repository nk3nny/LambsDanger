#include "script_component.hpp"
/*
 * Author: jokoho482
 * Forces unit to assault or flee towards target location
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

                [LSTRING(Module_TaskAssault_DisplayName),
                    [
                        [LSTRING(Groups_DisplayName), "DROPDOWN", LSTRING(Groups_ToolTip), _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        [LSTRING(Module_TaskAssault_Retreating_DisplayName), "BOOLEAN", LSTRING(Module_TaskAssault_Retreating_Tooltip), TASK_ASSAULT_ISRETREAT],
                        [LSTRING(Module_TaskAssault_DistanceThreshold_DisplayName), "SLIDER", LSTRING(Module_TaskAssault_DistanceThreshold_Tooltip), [1, 100], [2, 1], TASK_ASSAULT_DISTANCETHRESHOLD, 2],
                        [LSTRING(Module_TaskAssault_CycleTime_DisplayName), "SLIDER", LSTRING(Module_TaskAssault_CycleTime_Tooltip), [1, 300], [1, 0.5], TASK_ASSAULT_CYCLETIME, 2],
                        [LSTRING(Module_TaskAssault_DeleteOnStartup_DisplayName), "BOOLEAN", LSTRING(Module_TaskAssault_DeleteOnStartup_Tooltip), TASK_ASSAULT_DELETEONSTARTUP]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_retreat", "_threshold", "_cycle", "_deleteAfterStartup"];
                        private _group = _groups select _groupIndex;
                        if !((local _group) || _deleteAfterStartup) then {
                            _deleteAfterStartup = true;
                            [objNull, format [LLSTRING(SettingIsOnlyForLocalGroups), LLSTRING(Module_TaskAssault_DeleteOnStartup_DisplayName)]] call BIS_fnc_showCuratorFeedbackMessage;
                        };
                        [_group, [_logic, getPos _logic] select _deleteAfterStartup, _retreat, _threshold, _cycle, false] remoteExec [QFUNC(taskAssault), leader _group];

                        if (_deleteAfterStartup) then {
                            deleteVehicle _logic;
                        };
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        //params ["", "_logic"]; <-- uncommented for now. 'Unload phase' would always delete logic even when _deleteAfterStartUp was set to false. - nkenny
                        //deleteVehicle _logic;
                    }, [_groups, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                private _targets = GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                [LSTRING(Module_TaskAssault_DisplayName),
                    [
                        [LSTRING(Centers_DisplayName), "DROPDOWN", LSTRING(Centers_ToolTip), _targets apply { format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        [LSTRING(Module_TaskAssault_Retreating_DisplayName), "BOOLEAN", LSTRING(Module_TaskAssault_Retreating_Tooltip), TASK_ASSAULT_ISRETREAT],
                        [LSTRING(Module_TaskAssault_DistanceThreshold_DisplayName), "SLIDER", LSTRING(Module_TaskAssault_DistanceThreshold_Tooltip), [1, 100], [2, 1], TASK_ASSAULT_DISTANCETHRESHOLD, 2],
                        [LSTRING(Module_TaskAssault_CycleTime_DisplayName), "SLIDER", LSTRING(Module_TaskAssault_CycleTime_Tooltip), [1, 300], [1, 0.5], TASK_ASSAULT_CYCLETIME, 2]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_retreat", "_threshold", "_cycle"];
                        private _target = _targets select _targetIndex;
                        if !(local _group) then {
                            _target = getPos _target;
                        };
                        [_group, _target, _retreat, _threshold, _cycle, false] remoteExec [QFUNC(taskAssault), leader _group];
                        if !(_target isEqualTo _logic) then {
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
            private _groups = (synchronizedObjects _logic) apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _retreat = _logic getVariable [QGVAR(IsRetreat), TASK_ASSAULT_ISRETREAT];
            private _deleteAfterStartup = _logic getVariable [QGVAR(DeleteOnStartUp), TASK_ASSAULT_DELETEONSTARTUP];
            private _threshold = _logic getVariable [QGVAR(DistanceThreshold), TASK_ASSAULT_DISTANCETHRESHOLD];
            private _cycle = _logic getVariable [QGVAR(CycleTime), TASK_ASSAULT_CYCLETIME];
            {
                [_x, [_logic, getPos _logic] select _deleteAfterStartup, _retreat, _threshold, _cycle, false] remoteExec [QFUNC(taskAssault), leader _x];
            } forEach _groups;
            if (_deleteAfterStartup) then {
                deleteVehicle _logic;
            };
        };
    };
};
true
