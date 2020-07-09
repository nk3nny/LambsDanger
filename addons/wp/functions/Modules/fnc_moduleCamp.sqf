#include "script_component.hpp"
/*
 * Author: jokoho482
 * Makes the unit appear to camp or wait around target location
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

                [LSTRING(Module_TaskCamp_DisplayName),
                    [
                        [LSTRING(Groups_DisplayName), "DROPDOWN", LSTRING(Groups_ToolTip), _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        [LSTRING(Module_TaskCamp_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskCamp_Radius_ToolTip), [10, 400], [2, 1], TASK_CAMP_SIZE, 2],
                        [LSTRING(Module_TaskCamp_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskCamp_Teleport_Tooltip), falTASK_CAMP_TELEPORTse],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_CAMP_PATROL]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_range", "_teleport", "_patrol"];
                        private _group = _groups select _groupIndex;
                        [_group, getPos _logic, _range, nil, _teleport, _patrol] remoteExecCall [QFUNC(taskCamp), leader _group];
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

                [LSTRING(Module_TaskCamp_DisplayName),
                    [
                        [LSTRING(Centers_DisplayName), "DROPDOWN", LSTRING(Centers_ToolTip), _targets apply {  format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        [LSTRING(Module_TaskCamp_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskCamp_Radius_ToolTip), [10, 400], [2, 1], TASK_CAMP_SIZE, 2],
                        [LSTRING(Module_TaskGarrison_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Teleport_Tooltip), TASK_CAMP_TELEPORT],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_CAMP_PATROL]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic", "_targets"];
                        _data params ["_targetIndex", "_range", "_teleport", "_patrol"];
                        [_group, getPos (_targets select _targetIndex), _range, nil, _teleport, _patrol] remoteExecCall [QFUNC(taskCamp), leader _group];
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
            private _groups = (synchronizedObjects _logic) apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea", [TASK_CAMP_SIZE, TASK_CAMP_SIZE, 0, false, -1]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _teleport = _logic getVariable [QGVAR(Teleport), TASK_CAMP_TELEPORT];
            private _patrol = _logic getVariable [QGVAR(Patrol), TASK_CAMP_PATROL];

            {
                [_x, getPos _logic, _range, _area, _teleport, _patrol] remoteExecCall [QFUNC(taskCamp), leader _x];
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
