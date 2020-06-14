#include "script_component.hpp"
/*
 * Author: jokoho482
 * Logs Debug Informations
 *
 * Arguments:
 * String
 *
 * Return Value:
 * none
 *
 * Example:
 * [] call lambs_main_fnc_debugLog;
 *
 * Public: No
*/

params ["_str"];
systemChat _str;
diag_log ("[LAMBS Danger FSM] : " + _str);
