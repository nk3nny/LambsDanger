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
fleeing _this
|| {_this getVariable [QGVAR(disableAI), false]}
|| {(behaviour _this) isEqualTo "CARELESS"}
|| {!(_this checkAIFeature "MOVE")}
