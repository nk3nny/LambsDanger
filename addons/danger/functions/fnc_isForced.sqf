#include "script_component.hpp"
/*
 * Author: nkenny
 * Checks if FSM level movement is forced
 *
 * Arguments:
 * 0: unit being tested <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * bob call lambs_danger_fnc_isForced;
 *
 * Public: No
*/
_this getVariable [QGVAR(forceMove), false]
|| {currentCommand _this in ["ATTACK", "GET IN", "ACTION", "HEAL", "REARM", "JOIN"]}
|| {!(_this call EFUNC(main,isAlive))}
|| {(_this getVariable ["ace_medical_ai_healQueue", []]) isNotEqualTo []}
|| {GVAR(disableAIPlayerGroup) && {isPlayer leader _this}}
