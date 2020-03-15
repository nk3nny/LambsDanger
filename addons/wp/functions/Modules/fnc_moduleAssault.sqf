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

                ["Task Assault",
                    [
                        ["Groups", "DROPDOWN", "Select which unit script applies to.\nList is sorted by distance", _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        ["Unit is fleeing", "BOOLEAN", "Enable this to make the unit retreat and ignore enemies", false],
                        ["Completion Threshold", "NUMBER", "Units within this many meters will revert to regular behaviour", 15],
                        ["Script interval", "NUMBER", "The cycle time of the script", 3],
                        ["Remove module after start", "BOOLEAN", "Check this to remove module after script initiates\n If module is present it can be moved to dynamically alter destination", false]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_retreat", "_threshold", "_cycle", "_deleteAfterStartup"];
                        [_groups select _groupIndex, [_logic, getPos _logic] select _deleteAfterStartup, _retreat, _threshold, _cycle, false] spawn FUNC(taskAssault);
                        if (_deleteAfterStartup) then {
                            deleteVehicle _logic;
                        };
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_groups, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                private _targets = GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                ["Task Assault",
                    [
                        ["Center", "DROPDOWN", "Sets center for the script execution. This can be self or a LAMBS Dynamic Target selected from the list", _targets apply { format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        ["Is Retreating", "BOOLEAN", "Enable this to make the unit retreat and ignore enemies", false],
                        ["Completion Threshold", "NUMBER", "Units within this many meters will revert to regular behaviour", 15],
                        ["Script interval", "NUMBER", "The cycle time of the script", 3]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_retreat", "_threshold", "_cycle"];
                        private _target = _targets select _targetIndex;
                        [_group, _target, _retreat, _threshold, _cycle, false] spawn FUNC(taskAssault);
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

            private _retreat = _logic getVariable [QGVAR(IsRetreat), false];
            private _deleteAfterStartup = _logic getVariable [QGVAR(DeleteOnStartUp), false];
            private _threshold = _logic getVariable [QGVAR(DistanceThreshold), 15];
            private _cycle = _logic getVariable [QGVAR(CycleTime), 3];
            {
                [_x, _logic, _retreat, _threshold, _cycle, false] spawn FUNC(taskAssault);
            } forEach _groups;
            if (_deleteAfterStartup) then {
                deleteVehicle _logic;
            };
        };
    };
};
true
