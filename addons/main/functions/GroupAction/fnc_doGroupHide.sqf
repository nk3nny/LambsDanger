#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises group level hiding
 *
 * Arguments:
 * 0: units list <ARRAY>
 * 1: danger position <ARRAY> or <OBJECT>
 * 2: reason for hiding (used in debugging) <STRING>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob, angryJoe] call lambs_main_fnc_doGroupHide;
 *
 * Public: No
*/
params ["_units", "_pos", ["_action", "group"]];

// check units
_units = _units select { _x call FUNC(isAlive) && { isNull objectParent _x } && { !isPlayer _x } };
if (_units isEqualTo []) exitWith {false};

{
    [_x, _pos] call FUNC(doHide);
    if (_action isNotEqualTo "") then {
        _x setVariable [QEGVAR(main,currentTask), format ["Hide (%1)", _action], EGVAR(main,debug_functions)];
    };
} forEach _units;

// end
true
