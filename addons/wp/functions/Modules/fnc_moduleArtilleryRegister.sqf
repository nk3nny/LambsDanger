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

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _unit) then {
                _error = "No Unit Seleted";
            };
            if (_error == "") then {
                [_unit] call FUNC(taskArtilleryRegister);
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};

            if (_groups isEqualTo []) then {
                private _area = _logic getVariable ["objectarea", []];
                _area params ["_a", "_b", "_angle", "_isRectangle", "_c"];

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
