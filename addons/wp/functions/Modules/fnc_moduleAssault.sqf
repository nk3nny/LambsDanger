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
            _groups = _groups arrayIntersect _groups;

            private _retreat = _logic getVariable ["IsRetreat", false];
            private _threshold = _logic getVariable ["DistanceThreshold", 15];
            private _cycle = _logic getVariable ["CycleTime", 3];
            {
                [_x, getPos _logic, _retreat, _threshold, _cycle, false] spawn FUNC(taskAssault);
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
