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
                ["Task CQB",
                    [
                        ["Groups", "DROPDOWN", "TODO", _groups apply {str _x}, 0],
                        ["Radius", "NUMBER", "TODO", 200],
                        ["Cycle Time", "NUMBER", "TODO", 4],
                        ["Delete After Start", "BOOLEAN", "TODO", false]
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
                GVAR(ModuleTargets) = GVAR(ModuleTargets) - [objNull];
                private _targets = GVAR(ModuleTargets);
                ["Task CQB",
                    [
                        ["Targets", "DROPDOWN", "TODO", _targets apply { vehicleVarName _x}, 0],
                        ["Radius", "NUMBER", "TODO", 200],
                        ["Cycle Time", "NUMBER", "TODO", 4]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_radius", "_cycle"];
                        [_group, (_targets select _targetIndex), _radius, _cycle, nil, false] spawn FUNC(taskCQB);
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
            private _radius = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable ["CycleTime", 4];
            private _deleteAfterStartup = _logic getVariable ["DeleteOnStartUp", false];

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
