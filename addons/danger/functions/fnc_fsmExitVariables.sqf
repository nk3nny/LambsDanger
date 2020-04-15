#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if FSM should be exited
 *
 * Arguments:
 * 0: Unit being checked <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * bob call lambs_danger_fnc_fsmExitVariables;
 *
 * Public: No
*/
fleeing _this
|| {_this getVariable [QGVAR(disableAI), false]}
|| {!(_this call FUNC(isAlive))}
|| {isPlayer leader _this && {GVAR(disableAIPlayerGroup)}
|| {!(_this getVariable ["ace_medical_ai_healQueue", []] isEqualTo [])}
