#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises group level hiding
 *
 * Arguments:
 * 0: units list <ARRAY>
 * 1: danger position <ARRAY> or <OBJECT>
 * 2: list of buildings <ARRAY>
 * 3: reason for hiding (used in debugging) <STRING>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob, angryJoe] call lambs_main_fnc_doGroupHide;
 *
 * Public: No
*/
params ["_units", "_pos", ["_buildings", []], ["_action", "group"]];

// check units
_units = _units select { _x call FUNC(isAlive) && { isNull objectParent _x } && { !isPlayer _x } };
if (_units isEqualTo []) exitWith {false};

{
    // force movement!
    _x setVariable [QEGVAR(danger,forceMove), true];
    [{_this setVariable [QEGVAR(danger,forceMove), nil]}, _x, 20 + random 40] call CBA_fnc_waitAndExecute;

    // hide units
    [
        {
            params ["_arguments", "_action"];
            _arguments call FUNC(doHide);
            if (_action isNotEqualTo "") then {
                (_arguments select 0) setVariable [QEGVAR(main,currentTask), format ["Hide (%1)", _action], EGVAR(main,debug_functions)];
            };
        },
        [[_x, _pos, nil, _buildings], _action],
        1 + random 2
    ] call CBA_fnc_waitAndExecute;
} foreach _units;

// end
true
