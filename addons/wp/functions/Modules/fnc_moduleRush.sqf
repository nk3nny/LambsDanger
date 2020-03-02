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
            if (is3DEN) exitWith {};
            _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
            if !(_isActivated) exitWith {};
            if (_isCuratorPlaced) then {

            } else {
                private _groups = synchronizedObjects _logic apply {group _x};
                _groups = _groups arrayIntersect _groups;

                private _area = _logic getVariable ["objectarea",[]];
                private _range = _area select ((_area select 0) < (_area select 1));
                private _cycle = _logic getVariable ["CycleTime", 4];

                {
                    [_x, _range, _cycle, _area] spawn FUNC(taskRush);
                } forEach _groups;
            };
        };
    };
};
true
