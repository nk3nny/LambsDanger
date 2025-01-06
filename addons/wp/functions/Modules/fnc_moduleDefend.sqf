#include "script_component.hpp"
/*
 * Author: jokoho482, nkenny
 * Makes the unit hold and defence a position near the position
 *
 * Arguments:
 * Arma 3 Module Function Parameters
 *
 * Return Value:
 * NONE
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
                        [LSTRING(Module_TaskDefend_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskDefend_Radius_Tooltip), [10, 500], [2, 1], TASK_DEFEND_SIZE, 2],
                        [LSTRING(Module_TaskDefend_UseCover_DisplayName), "DROPDOWN", LSTRING(Module_TaskDefend_UseCover_Tooltip), [LSTRING(All), LSTRING(Buildings), LSTRING(Walls), LSTRING(Vegetation), LSTRING(BuildingsAndVegetation), LSTRING(BuildingsAndWalls), LSTRING(WallsandVegetation)], TASK_DEFEND_USECOVER],
                        [LSTRING(Module_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Teleport_Tooltip), TASK_GARRISON_TELEPORT],
                        [LSTRING(Module_TaskDefend_Stealth_DisplayName), "BOOLEAN", LSTRING(Module_TaskDefend_Stealth_Tooltip), TASK_DEFEND_STEALTH],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_DEFEND_PATROL]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_range", "_useCover", "_teleport", "_stealth", "_patrol"];
                        private _group = _groups select _groupIndex;
                        [QGVAR(taskDefend), [_group, getPos _logic, _range, nil, _teleport, _useCover, _stealth, _patrol], leader _group] call CBA_fnc_targetEvent;
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
                        [LSTRING(Module_TaskDefend_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskDefend_Radius_Tooltip), [10, 500], [2, 1], TASK_DEFEND_SIZE, 2],
                        [LSTRING(Module_TaskDefend_UseCover_DisplayName), "DROPDOWN", LSTRING(Module_TaskDefend_UseCover_Tooltip), [LSTRING(All), LSTRING(Buildings), LSTRING(Walls), LSTRING(Vegetation), LSTRING(BuildingsAndVegetation), LSTRING(BuildingsAndWalls), LSTRING(WallsandVegetation)], TASK_DEFEND_USECOVER],
                        [LSTRING(Module_Teleport_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Teleport_Tooltip), TASK_GARRISON_TELEPORT],
                        [LSTRING(Module_TaskDefend_Stealth_DisplayName), "BOOLEAN", LSTRING(Module_TaskDefend_Stealth_Tooltip), TASK_DEFEND_STEALTH],
                        [LSTRING(Module_TaskGarrison_Patrol_DisplayName), "BOOLEAN", LSTRING(Module_TaskGarrison_Patrol_Tooltip), TASK_DEFEND_PATROL]

                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic", "_targets"];
                        _data params ["_targetIndex", "_range", "_useCover", "_teleport", "_stealth", "_patrol"];
                        private _target = _targets select _targetIndex;
                        [QGVAR(taskDefend), [_group, getPos _target, _range, nil, _teleport, _useCover, _stealth, _patrol], leader _group] call CBA_fnc_targetEvent;
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

            private _area = _logic getVariable ["objectarea", [TASK_DEFEND_SIZE, TASK_DEFEND_SIZE, 0, false, -1]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _teleport = _logic getVariable [QGVAR(Teleport), TASK_DEFEND_TELEPORT];
            private _useCover = _logic getVariable [QGVAR(useCover), TASK_DEFEND_USECOVER];
            private _stealth = _logic getVariable [QGVAR(stealth), TASK_DEFEND_STEALTH];
            private _patrol = _logic getVariable [QGVAR(Patrol), TASK_DEFEND_PATROL];
            {
                [QGVAR(taskDefend), [_x, getPos _logic, _range, _area, _teleport, _useCover, _stealth, _patrol], leader _x] call CBA_fnc_targetEvent;
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
