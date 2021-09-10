#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if FSM should be exited early
 *
 * Arguments:
 * 0: unit being tested <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * bob call lambs_danger_fnc_isForcedExit;
 *
 * Public: No
*/
params ["_unit", ["_queue", []]];
fleeing _unit
|| {_unit getVariable [QGVAR(disableAI), false]}
|| {(behaviour _unit) isEqualTo "CARELESS"}
|| {!(_unit checkAIFeature "MOVE")}
|| {
    private _ret = true;
    {
        _x params ["", "", "", ["_causedBy", objNull]];
        if !([side group _unit, side group _causedBy] call BIS_fnc_sideIsFriendly) then {
            _ret = false;
            break;
        };
    } forEach _queue;
    _ret
}
