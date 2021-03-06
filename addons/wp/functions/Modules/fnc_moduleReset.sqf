#include "script_component.hpp"
/*
 * Author: jokoho482, nkenny
 * Resets all unit orders
 *
 * Arguments:
 * 0: Unit being reset <OBJECT> or <GROUP>
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
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if !(_isActivated && local _logic) exitWith {};

        if (_isCuratorPlaced) then {

            // grabs unit under cursor
            private _group = GET_CURATOR_UNIT_UNDER_CURSOR;

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = LELSTRING(main,NoUnitSelected);
            };

            // resets unit
            if (_error isEqualTo "") then {
                if (_group isEqualType objNull) then { _group = group _group; };
                [objNull, format ["%1 reset", groupId _group]] call BIS_fnc_showCuratorFeedbackMessage;
                [QGVAR(taskReset), [_group], leader _group] call CBA_fnc_targetEvent;
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
            };

            // clean up
            deleteVehicle _logic;
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;
            {
                [QGVAR(taskReset), [_x], leader _x] call CBA_fnc_targetEvent;
            } forEach _groups;
        };
    };
};
