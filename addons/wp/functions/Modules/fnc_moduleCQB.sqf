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
            private _group = grpNull;
            private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
            if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _group = group (_mouseOver select 1); };
            if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _group = _mouseOver select 1; };

            if (isNull _group) then {
                private _groups = allGroups;
                ["Task CQB",
                    [
                        ["Groups", "DROPDOWN", "TODO", _groups apply {str _x}, 0],
                        ["Radius", "NUMBER", "TODO", 200],
                        ["Cycle Time", "NUMBER", "TODO", 4]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_groups", "_logic"];
                        _data params ["_groupIndex", "_radius", "_cycle"];
                        [_groups select _groupIndex, getPos _logic, _radius, _cycle, nil, false] spawn FUNC(taskCQB);
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
                private _targets = allMissionObjects QGVAR(Target);
                ["Task CQB",
                    [
                        ["Targets", "DROPDOWN", "TODO", _targets apply { vehicleVarName _x}, 0],
                        ["Radius", "NUMBER", "TODO", 200],
                        ["Cycle Time", "NUMBER", "TODO", 4]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_targets", "_logic", "_group"];
                        _data params ["_targetIndex", "_radius", "_cycle"];
                        [_group, getPos (_targets select _targetIndex), _radius, _cycle, nil, false] spawn FUNC(taskCQB);
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

            {
                [_x, getPos _logic, _radius, _cycle, _area, false] spawn FUNC(taskCQB);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
