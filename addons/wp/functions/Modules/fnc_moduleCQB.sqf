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
            private _group = GET_CURATOR_GRP_UNDER_CURSOR;

            if (isNull _group) then {
                private _groups = allGroups;
                _groups = _groups select { ((units _x) findIf { alive _x }) != -1; };
                _groups = [_groups, [], {_logic distance (leader _x) }, "ASCEND"] call BIS_fnc_sortBy;

                ["Task CQB",
                    [
                        ["Groups", "DROPDOWN", "Select which unit script applies to.\nList is sorted by distance.", _groups apply { format ["%1 - %2 (%3 m)", side _x, groupId _x, round ((leader _x) distance _logic)] }, 0],
                        ["Radius", "NUMBER", "Max distance houses will be searched", 50],
                        ["Script interval", "NUMBER", "The cycle time for the script in seconds. Higher numbers make units search buildings more carefully.\nDefault 21 seconds", 21],
                        ["Dynamic center", "BOOLEAN", "Enable this to make it possible to move the center/module of the building search pattern", false]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_radius", "_cycle", "_deleteAfterStartup"];
                        [_groups select _groupIndex, [_logic, getPos _logic] select _deleteAfterStartup, _radius, _cycle, nil, false] spawn FUNC(taskCQB);
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
                _logic setVehicleVarName "Logic";
                private _targets = [_logic];
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                _targets append GVAR(ModuleTargets);
                _targets = [_targets, [], {_logic distance _x }, "ASCEND"] call BIS_fnc_sortBy;

                ["Task CQB",
                    [
                        ["Targets", "DROPDOWN", "TODO", _targets apply {  format ["%1 (%2 m)", vehicleVarName _x, round (_x distance _logic)] }, 0],
                        ["Radius", "NUMBER", "Max distance houses will be searched", 50],
                        ["Script interval", "NUMBER", "The cycle time for the script in seconds. Higher numbers make units search buildings more carefully.\nDefault 21 seconds", 21]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_radius", "_cycle"];
                        private _target = _targets select _targetIndex;
                        [_group, _target, _radius, _cycle, nil, false] spawn FUNC(taskCQB);
                        if !(_logic isEqualTo _target) then {
                            deleteVehicle _logic;
                        };                    }, {
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
            private _radius = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable [QGVAR(CycleTime), 4];
            private _deleteAfterStartup = _logic getVariable [QGVAR(DeleteOnStartUp), false];

            {
                [_x, _logic, _radius, _cycle, _area, false] spawn FUNC(taskCQB);
            } forEach _groups;
            if (_deleteAfterStartup) then {
                deleteVehicle _logic;
            };
        };
    };
};
true
