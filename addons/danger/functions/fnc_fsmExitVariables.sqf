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
|| {(_this getVariable ["ACE_isUnconscious", false])}
|| {_this getVariable [QGVAR(disableAI), false]}
|| {isplayer leader _this && {_this getVariable [QGVAR(disableAIPlayerGroup), false]}}
