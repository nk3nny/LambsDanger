#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit acts in panic ~ may be improved in the future using position of danger and re-implementing more actions -nkenny
 *
 * Arguments:
 * 0: unit panicking <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_doPanic;
 *
 * Public: No
*/
params [["_unit", ObjNull, [ObjNull]]];

// exit if unit is dead or otherwis captured
if (
    !(_unit call FUNC(isAlive))
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// settings
//_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Panic", GVAR(debug_functions)];

// eventhandler
[QGVAR(OnPanic), [_unit, group _unit]] call FUNC(eventCallback);

// callout
[_unit, "Stealth", "panic", 55] call FUNC(doCallout);

// debug
if (GVAR(debug_functions)) then {format ["%1 panic! (%2)", side _unit, name _unit] call FUNC(debugLog);};

// end
true
