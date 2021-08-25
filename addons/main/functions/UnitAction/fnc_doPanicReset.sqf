#include "script_component.hpp"
/*
 * Author: nkenny
 * Reset panic state on unit
 *
 * Arguments:
 * 0: unit panicking <OBJECT>
 * 1: time until reset <NUMBER>
 * 2: Unstick animation <BOOL>
 *
 * Return Value:
 * nil
 *
 * Example:
 * [bob] call lambs_main_fnc_doPanicReset;
 *
 * Public: No
*/
params ["_unit", "_timeout", ["_animation", false]];
[
    {
        params ["_unit", "_animation"];
        _unit setUnitPos "AUTO";
        _unit setVariable [QEGVAR(danger,forceMove), nil];
        if (_animation) then {[_unit, "gestureYes"] call FUNC(doGesture);};
    }, [_unit, _animation], _timeout
] call CBA_fnc_waitAndExecute;
