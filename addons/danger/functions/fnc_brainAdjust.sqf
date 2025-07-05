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
params ["_unit", ["_priorities", GVAR(fsmPriorities)]];

// this function may have use in the future - nkenny
// Add validation for priorities array
if !(_priorities isEqualType []) then {
    _priorities = GVAR(fsmPriorities);
};

// end
_priorities
