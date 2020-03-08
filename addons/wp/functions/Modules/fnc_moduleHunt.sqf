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

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = "No Unit Seleted";
            };

            if (_error == "") then {
                ["Task Hunt",
                    [
                        ["Radius", "NUMBER", "TODO", 200],
                        ["CycleTime", "NUMBER", "TODO", 4]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic"];
                        _data params ["_range", "_cycle"];
                        [_group, _range, _cycle] spawn FUNC(taskHunt);
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_group, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea",[]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable ["CycleTime", 4];

            {
                [_x, _range, _cycle, _area] spawn FUNC(taskHunt);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
