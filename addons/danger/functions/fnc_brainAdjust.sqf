#include "script_component.hpp"
/*
 * Author: nkenny
 * adjusts priorities
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: priorities <ARRAY>
 *
 * Return Value:
 * array
 *
 * Example:
 * [bob] call lambs_danger_fnc_brainAdjust;
 *
 * Public: No
*/

params ["_unit", ["_priorties", GVAR(fsmPriorities)]];

private _modifiedPriorties = _unit getVariable QGVAR(Priorities);
if (!isNil "_modifiedPriorties" && { _modifiedPriorties isEqualType [] } && { count GVAR(fsmPriorities) == count _modifiedPriorties}) then {
    _priorties = _modifiedPriorties;
};
// end
_priorties
