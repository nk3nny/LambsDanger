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
        if !(_isActivated) exitWith {};
        if (_isCuratorPlaced) then {

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
