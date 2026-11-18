#include "script_component.hpp"
/*
 * Author: nkenny
 * Reset stance. Check if the timer has been updated. If so, delay stance reset.
 *
 * Arguments:
 * 0: unit resetting stance <OBJECT>
 * 1: set new timer <BOOL>, default false
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_main_fnc_doStanceReset;
 *
 * Public: No
*/

params [["_unit", objNull, [objNull]], ["_set", false, [false]]];

if (!alive _unit) exitWith {false};
private _stayDown = _unit getVariable [QGVAR(stayDown), 0];

// set timer
if (_set) exitWith {

    private _delay = 12 + random 15;

    // variable already set
    if (_stayDown > time) exitWith {
        _delay = (time + _delay) max (_stayDown + 2);
        _unit setVariable [QGVAR(stayDown), floor _delay];
        false
    };

    // call new event in delay
    _unit setVariable [QGVAR(stayDown), floor (time + _delay)];
    [{call FUNC(doStanceReset)}, [_unit, false], _delay] call CBA_fnc_waitAndExecute;
    true
};

// check if timer has updated
if (_stayDown > ceil time) exitWith {
    [{call FUNC(doStanceReset)}, [_unit, false], _stayDown - time] call CBA_fnc_waitAndExecute;
    false
};

// reset stance. Set to AUTO then a lower priority
private _unitPos = unitPos _unit;
_unit setUnitPos "AUTO";
_unit setUnitPosWeak _unitPos;
_unit setVariable [QGVAR(stayDown), nil];

// end
true
