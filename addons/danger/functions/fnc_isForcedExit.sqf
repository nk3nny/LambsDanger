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
    private _unitSide = side group _unit;
    (_queue findIf {
        _x params ["", "", "", ["_causedBy", objNull]];
        !([_unitSide, side group _causedBy] call BIS_fnc_sideIsFriendly)
    }) isEqualTo -1
}
