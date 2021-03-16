#include "script_component.hpp"
/*
 * Author: jokoho482
 * Logs Debug Informations
 *
 * Arguments:
 * String, format Array
 *
 * Return Value:
 * none
 *
 * Example:
 * [] call lambs_main_fnc_debugLog;
 *
 * Public: No
*/
private _str = _this;
if (_this isEqualType []) then {
    _str = format _this;
};
systemChat _str;
diag_log text ("[LAMBS Danger FSM] : " + _str);
