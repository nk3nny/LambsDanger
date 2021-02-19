#include "script_component.hpp"
/*
 * Author: jokoho482
 * Registers artillery to dynamic artillery system
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
                _error = LELSTRING(main,NoUnitSelected);
            };
            if (_error == "") then {
                private _success = [_group] call FUNC(taskArtilleryRegister);
                [objNull, ([LLSTRING(Module_TaskArtilleryRegister_ZeusNotification_NoUnitAdded), LLSTRING(Module_TaskArtilleryRegister_ZeusNotification_UnitAdded)] select _success)] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            };
        } else {
            private _groups = (synchronizedObjects _logic) apply {group _x};

            if (_groups isEqualTo []) then {
                private _area = _logic getVariable ["objectarea", [10, 10, 0, false, -1]];
                _area params ["_a", "_b", "_angle", "_isRectangle", ["_c", -1]];

                _groups = allGroups select { (leader _x) inArea [(getPos _logic), _a, _b, _angle, _isRectangle, _c] };
            };
            _groups = _groups arrayIntersect _groups;
            {
                [_x] call FUNC(taskArtilleryRegister);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
    case "connectionChanged3DEN": {
        _input params [["_logic", objNull, [objNull]]];
        private _found = (get3DENConnections _logic) findIf { !((_x select 1) isKindOf "EmptyDetector") } != -1;
        if (_found) then {
            _logic set3DENAttribute ["size2", [0, 0]];
        } else {
            _logic set3DENAttribute ["size2", [100, 100]];
            _logic clear3DENAttribute "size2";
        };
    };
};
true
