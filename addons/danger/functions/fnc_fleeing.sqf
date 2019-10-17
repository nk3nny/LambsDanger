#include "script_component.hpp"
/*
 * Author: nkenny
 * Adds debug and unique behaviour on unit fleeing
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_fleeing;
 *
 * Public: No
*/
params ["_unit"];

// check disabled
if (_this getVariable [QGVAR(disableAI), false]) exitWith {false};

// variable
_unit setVariable [QGVAR(currentTask), "Fleeing"];
// this could have an event attached to it too - nkenny

// play gesture
if (random 1 > 0.8) then {[_unit, ["GestureCeaseFire","FastF","FastF","FastRF","FastLF"]] call FUNC(gesture);}
// ideally find better gestures or animations to represent things. But. It is what it is. - nkenny

// update path
[_unit, _unit findNearestEnemy _unit, 60] call FUNC(hideInside);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 Fleeing! (%2m)", side _unit,round (_unit distance (expectedDestination _unit select 0))];};

// end
true