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

private _mode = param [0,"",[""]];
private _input = param [1,[],[[]]];

switch (_mode) do {
    // Default object init
    case "init": {
        private _logic = _input param [0,objNull,[objNull]]; // Module logic
        private _isActivated = _input param [1,true,[true]]; // True when the module was activated, false when it's deactivated
        private _isCuratorPlaced = _input param [2,false,[true]]; // True if the module was placed by Zeus
        if !(_isActivated) exitWith {};
        if (_isCuratorPlaced) then {

        } else {
            private _units = synchronizedObjects _logic;

            private _retreat = _logic getVariable ["IsRetreat", false];
            private _threshold = _logic getVariable ["DistanceThreshold", 15];
            private _cycle = _logic getVariable ["CycleTime", 3];
            {
                [_x, getPos _logic, _retreat, _threshold, _cycle] call FUNC(taskAssault);
            } forEach _units;
        };
    };
    // When some attributes were changed (including position and rotation)
    case "attributesChanged3DEN": {
        private _logic = _input param [0,objNull,[objNull]];
    };
    // When added to the world (e.g., after undoing and redoing creation)
    case "registeredToWorld3DEN": {
        private _logic = _input param [0,objNull,[objNull]];

    };
    // When removed from the world (i.e., by deletion or undoing creation)
    case "unregisteredFromWorld3DEN": {
        private _logic = _input param [0,objNull,[objNull]];

    };
    // When connection to object changes (i.e., new one is added or existing one removed)
    case "connectionChanged3DEN": {
        private _logic = _input param [0,objNull,[objNull]];

    };
    // When object is being dragged
    case "dragged3DEN": {
        private _logic = _input param [0,objNull,[objNull]];

    };
};
true
