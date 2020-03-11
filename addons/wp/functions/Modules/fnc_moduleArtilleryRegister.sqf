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

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = "No Unit Seleted";
            };
            if (_error == "") then {
                private _success = [_group] call FUNC(taskArtilleryRegister);
                if (_success) then {
                    [objNull, "Units have been added to Artillery Pool"] call BIS_fnc_showCuratorFeedbackMessage;
                } else {
                    [objNull, "No Units have been added to Artillery Pool"] call BIS_fnc_showCuratorFeedbackMessage;
                };

                deleteVehicle _logic;
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};

            if (_groups isEqualTo []) then {
                private _area = _logic getVariable ["objectarea", []];
                _area params ["_a", "_b", "_angle", "_isRectangle"];

                _groups = allGroups select { (leader _x) inArea [(getPos _logic), _a, _b, _angle, _isRectangle] };
            };
            _groups = _groups arrayIntersect _groups;
            {
                [_x] call FUNC(taskArtilleryRegister);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
